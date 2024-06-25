import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'model_notes.dart';

class DetailNotes extends StatelessWidget {

  final Datum? data;
  const DetailNotes(this.data, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Notes"),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              data?.judul ?? "",
              style: const TextStyle(fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, bottom: 16,
                left: 16),
            child: Text(
              data?.isi ?? "",
              style: const TextStyle(fontSize: 14, fontWeight:
              FontWeight.w400),
              textAlign: TextAlign.justify,
            ),
          )
        ],
      ),
    );
  }
}