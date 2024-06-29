import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wahyu/latihan29juni/screen_page/page_detail.dart';
import 'package:wahyu/latihan29juni/screen_page/page_insert.dart';
import 'dart:convert';
import '../model/model_wisata.dart';



class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController searchController = TextEditingController();
  List<Datum>? wisataList;
  List<Datum>? filteredWisataList;

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  Future<void> getNotes() async {
    try {
      var response = await http.get(Uri.parse('http://10.127.222.22/wisataDB/getWisata.php'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['isSuccess'] == true) {
          List<Datum> wisata = (jsonData['data'] as List).map((item) => Datum.fromJson(item)).toList();
          setState(() {
            wisataList = wisata;
            filteredWisataList = wisataList;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load notes: ${jsonData['message']}')));
        }
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      print('Error getNotes: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      var response = await http.post(
        Uri.parse('http://10.127.222.22/wisataDB/delWisata.php'),
        body: {'id': id},
      );
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['is_success'] == true) {
        setState(() {
          wisataList!.removeWhere((note) => note.id == id);
          filteredWisataList = List.from(wisataList!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wisata deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete note: ${jsonData['message']}')));
      }
    } catch (e) {
      print('Error deleteWisata: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Wisata')),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  filteredWisataList = wisataList
                      ?.where((note) =>
                  note.namaWisata.toLowerCase().contains(value.toLowerCase()) ||
                      note.lokasiWisata.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredWisataList != null
                ? ListView.builder(
              itemCount: filteredWisataList!.length,
              itemBuilder: (context, index) {
                Datum wisata = filteredWisataList![index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PageDetailWisata(namaWst: filteredWisataList![index]),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Image.network('http://10.127.222.22/wisataDB/gambar/${wisata.gambar}', width: 100, height: 80,),
                        title: Text(
                          '${wisata.namaWisata}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "${wisata.lokasiWisata}",
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     IconButton(
                        //       icon: Icon(Icons.edit, color: Colors.blue),
                        //       onPressed: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (context) => PageEditNotes(
                        //               id: note.id,
                        //               judulNote: note.judulNote,
                        //               isiNote: note.isiNote,
                        //               ket: note.ket,
                        //             ),
                        //           ),
                        //         ).then((updatedNote) {
                        //           if (updatedNote != null) {
                        //             setState(() {
                        //               int index = noteList!.indexWhere((n) => n.id == updatedNote.id);
                        //               if (index != -1) {
                        //                 noteList![index] = updatedNote;
                        //                 filteredNoteList = List.from(noteList!);
                        //               }
                        //             });
                        //           }
                        //         });
                        //       },
                        //     ),
                        //     IconButton(
                        //       icon: Icon(Icons.delete, color: Colors.red),
                        //       onPressed: () {
                        //         showDialog(
                        //           context: context,
                        //           builder: (context) => AlertDialog(
                        //             title: Text('Delete Note'),
                        //             content: Text('Are you sure you want to delete this note?'),
                        //             actions: [
                        //               TextButton(
                        //                 onPressed: () {
                        //                   Navigator.of(context).pop();
                        //                 },
                        //                 child: Text('Cancel'),
                        //               ),
                        //               TextButton(
                        //                 onPressed: () {
                        //                   deleteNote(note.id);
                        //                   Navigator.of(context).pop();
                        //                 },
                        //                 child: Text('Yes'),
                        //               ),
                        //             ],
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ],
                        // ),
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageInsertWisata()),
          );

          if (newNote != null) {
            setState(() {
              wisataList!.add(newNote);
              if (searchController.text.isNotEmpty) {
                filteredWisataList = wisataList
                    ?.where((wisata) =>
                wisata.namaWisata
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                    wisata.lokasiWisata
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList();
              } else {
                filteredWisataList = List.from(wisataList!);
              }
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
    );
  }
}
