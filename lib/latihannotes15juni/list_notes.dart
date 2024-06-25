import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'model_notes.dart';
// Sesuaikan dengan file model Notes yang Anda gunakan

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<ModelNotes> futureNotes;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureNotes = fetchNotes();
  }

  Future<ModelNotes> fetchNotes() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.116/latNotes/getNotes.php'),
    );

    if (response.statusCode == 200) {
      return modelNotesFromJson(response.body);
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.116/latNotes/deleteNotes.php?id=$id'),
      );
      if (response.statusCode == 200) {
        // Update futureNotes to trigger UI refresh
        setState(() {
          futureNotes = fetchNotes();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note deleted successfully.')),
        );
      } else {
        throw Exception('Failed to delete note: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: $e')),
      );
    }
  }

  Future<void> _editNote(Datum note) async {
    _titleController.text = note.judul;
    _contentController.text = note.isi;

    bool editConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Judul'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Isi'),
              maxLines: null, // Allows multiline input
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Close dialog with edit confirmed
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // Close dialog without saving
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    if (editConfirmed != null && editConfirmed) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.0.116/latNotes/updateNotes.php'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'id': note.id.toString(),
            'judul': _titleController.text,
            'isi': _contentController.text,
          },
        );

        if (response.statusCode == 200) {
          // Update futureNotes to trigger UI refresh
          setState(() {
            futureNotes = fetchNotes();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note updated successfully.')),
          );
        } else {
          throw Exception('Failed to update note: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update note: $e')),
        );
      }
    }
  }

  Future<void> _addNote() async {
    // Setelah dialog ditutup, reset nilai controller
    _titleController.text = '';
    _contentController.text = '';

    bool addConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambahkan Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Judul'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Isi'),
              maxLines: null, // Allows multiline input
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Close dialog with add confirmed
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // Close dialog without saving
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    if (addConfirmed != null && addConfirmed) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.0.116/latNotes/addNotes.php'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'judul': _titleController.text,
            'isi': _contentController.text,
          },
        );
        if (response.statusCode == 200) {
          // Update futureNotes to trigger UI refresh
          setState(() {
            futureNotes = fetchNotes();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note added successfully.')),
          );
        } else {
          throw Exception('Failed to add note: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add note: $e')),
        );
      }
    }
  }


  void _showNoteDetail(Datum note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.judul),
        content: Text(note.isi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _trimText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + '...';
    }
    return text;
  }

  Future<void> _deleteNoteConfirmation(Datum note) async {
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Close dialog with true value
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // Close dialog with false value
            },
            child: Text('No'),
          ),
        ],
      ),
    );

    if (deleteConfirmed) {
      await _deleteNote(note.id); // Delete note if user confirms
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: FutureBuilder<ModelNotes>(
        future: futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load notes'));
          } else if (!snapshot.hasData || !snapshot.data!.isSuccess) {
            return Center(child: Text('No notes available'));
          } else {
            final notes = snapshot.data!.data;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  elevation: 3, // Mengubah ketinggian shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Mengubah sudut radius
                    side: BorderSide(color: Colors.grey, width: 0.5), // Mengubah garis tepi
                  ),
                  child: // Pada bagian ListTile di dalam ListView.builder:
                  ListTile(
                    title: Text(
                      note.judul,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue, // Ubah warna teks judul
                      ),
                    ),
                    subtitle: Text(
                      _trimText(note.isi, 50),
                      style: TextStyle(
                        color: Colors.grey, // Ubah warna teks isi
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () => _showNoteDetail(note),
                          color: Colors.green, // Ubah warna ikon 'lihat detail'
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editNote(note),
                          color: Colors.orange, // Ubah warna ikon 'edit'
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteNoteConfirmation(note),
                          color: Colors.red, // Ubah warna ikon 'hapus'
                        ),
                      ],
                    ),
                  ),

                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
      ),
    );
  }
}