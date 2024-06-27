import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/model_video.dart';
import 'detail_video.dart';


class PageLatVideo extends StatefulWidget {
  const PageLatVideo({Key? key}) : super(key: key);

  @override
  _PageLatVideoState createState() => _PageLatVideoState();
}

class _PageLatVideoState extends State<PageLatVideo> {
  List<Datum> _videoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideoData();
  }

  Future<void> _fetchVideoData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.158.167/videoDB/getVideo.php'));

      if (response.statusCode == 200) {
        final modelVideo = modelVideoFromJson(response.body);
        if (modelVideo.isSuccess && modelVideo.data.isNotEmpty) {
          setState(() {
            _videoList = modelVideo.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load video data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching video data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
        backgroundColor: Colors.red, // Sesuaikan dengan warna YouTube
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _videoList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(
                    videoUrl:
                    'http://192.168.158.167/videoDB/video_file/${_videoList[index].videoFile}',
                    title: _videoList[index].judulVideo,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          'http://192.168.158.167/videoDB/gambar/${_videoList[index].gambar}',
                          fit: BoxFit.cover,
                          height: 200,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _videoList[index].judulVideo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _videoList[index].videoFile,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}