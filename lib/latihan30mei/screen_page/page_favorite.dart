import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/model_audio.dart';

class PageFavorite extends StatelessWidget {
  final Set<String> favoriteIds;

  PageFavorite({required this.favoriteIds});

  Future<ModelAudio> fetchAudio() async {
    final response = await http.get(Uri.parse('http://192.168.0.116/audioDB/audio.php'));

    if (response.statusCode == 200) {
      return modelAudioFromJson(response.body);
    } else {
      throw Exception('Failed to load audio');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(color: Colors.green)), // Set text color to green
        backgroundColor: Colors.black, // Set app bar color to black
        iconTheme: IconThemeData(color: Colors.green), // Set icon color to green
      ),
      body: SafeArea(
        child: FutureBuilder<ModelAudio>(
          future: fetchAudio(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Datum> favoriteData = snapshot.data!.data
                  .where((audio) => favoriteIds.contains(audio.id))
                  .toList();

              if (favoriteData.isEmpty) {
                return Center(child: Text('No favorites yet.', style: TextStyle(color: Colors.green))); // Set text color to green
              }

              return ListView.builder(
                itemCount: favoriteData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0), // Add padding here
                    child: ListTile(
                      leading: Image.network('http://192.168.0.116/audioDB/gambar/${favoriteData[index].gambar}'),
                      title: Text(favoriteData[index].judul, style: TextStyle(color: Colors.green)), // Set text color to green
                      trailing: Icon(Icons.favorite, color: Colors.green), // Set icon color to green
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}', style: TextStyle(color: Colors.green))); // Set text color to green
            }

            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator(color: Colors.green)); // Set spinner color to green
          },
        ),
      ),
    );
  }
}
