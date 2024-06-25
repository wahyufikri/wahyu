import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

import 'model_audio.dart';


enum PlayerState { stopped, playing, paused }

class PageLatAudio extends StatefulWidget {
  const PageLatAudio({super.key});

  @override
  State<PageLatAudio> createState() => _PageLatAudioState();
}

class _PageLatAudioState extends State<PageLatAudio> {
  List<Datum> _audioList = [];
  List<Datum> _filteredAudioList = [];
  bool _isLoading = true;
  final List<AudioPlayer> _audioPlayers = [];
  final List<PlayerState> _playerStates = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAudioData();
    _searchController.addListener(_updateSearchQuery);
  }

  Future<void> _fetchAudioData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.116/latAudio/getAudio.php'));

      if (response.statusCode == 200) {
        final modelAudio = modelAudioFromJson(response.body);
        if (modelAudio.isSuccess && modelAudio.data.isNotEmpty) {
          setState(() {
            _audioList = modelAudio.data;
            _filteredAudioList = _audioList;
            for (int i = 0; i < _audioList.length; i++) {
              _audioPlayers.add(AudioPlayer());
              _playerStates.add(PlayerState.stopped);
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load audio data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching audio data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredAudioList = _audioList.where((audio) {
        return audio.judul.toLowerCase().contains(_searchQuery) ||
            audio.penyanyi.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  void _play(int index) async {
    final audioUrl = 'http://192.168.0.116/latAudio/audio/${_filteredAudioList[index].audio}';

    // Stop all other audio players
    for (int i = 0; i < _audioPlayers.length; i++) {
      if (i != index && _playerStates[i] == PlayerState.playing) {
        await _audioPlayers[i].stop();
        setState(() => _playerStates[i] = PlayerState.stopped);
      }
    }

    // Play the selected audio
    try {
      final result = await _audioPlayers[index].play(audioUrl);
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.playing);
      } else {
        print('Error while playing audio: $result');
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _pause(int index) async {
    try {
      final result = await _audioPlayers[index].pause();
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.paused);
      } else {
        print('Error while pausing audio: $result');
      }
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  void _stop(int index) async {
    try {
      final result = await _audioPlayers[index].stop();
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.stopped);
      } else {
        print('Error while stopping audio: $result');
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Music'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredAudioList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: Image.network(
                      'http://192.168.0.116/latAudio/gambar/${_filteredAudioList[index].gambar}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50);
                      },
                    ),
                    title: Text(
                      _filteredAudioList[index].judul,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_filteredAudioList[index].penyanyi),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: _playerStates[index] == PlayerState.playing
                              ? null
                              : () => _play(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause),
                          onPressed: _playerStates[index] == PlayerState.playing
                              ? () => _pause(index)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: _playerStates[index] == PlayerState.playing ||
                              _playerStates[index] == PlayerState.paused
                              ? () => _stop(index)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}