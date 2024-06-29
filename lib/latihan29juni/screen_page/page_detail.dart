import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../model/model_wisata.dart' as wisataModel;

class PageDetailWisata extends StatefulWidget {
  final wisataModel.Datum namaWst;

  const PageDetailWisata({Key? key, required this.namaWst}) : super(key: key);

  @override
  State<PageDetailWisata> createState() => _PageDetailWisataState();
}

class _PageDetailWisataState extends State<PageDetailWisata> {
  bool isLoading = false;
  // List<kamarModel.Datum> listKamar = [];

  // @override
  // void initState() {
  //   super.initState();
  //   fetchKamarData(widget.rumahSakit.id);
  // }

  // Future<void> fetchKamarData(String rumahSakitId) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     final response = await http.get(Uri.parse('http://192.168.0.116/rumahsakitDB/getKamar.php?id_rs=$rumahSakitId'));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print('Data kamar diterima: $data'); // Debug print
  //
  //       setState(() {
  //         kamarModel.ModelKamar modelKamar = kamarModel.ModelKamar.fromJson(data);
  //         listKamar = modelKamar.data.where((kamar) => kamar.rumahsakitId == rumahSakitId).toList();
  //         isLoading = false;
  //       });
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.toString())),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.namaWst.namaWisata,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse(widget.namaWst.lat), double.parse(widget.namaWst.lng)),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.namaWst.id),
                    position: LatLng(double.parse(widget.namaWst.lat), double.parse(widget.namaWst.lng)),
                    infoWindow: InfoWindow(
                      title: widget.namaWst.namaWisata,
                      snippet: widget.namaWst.lokasiWisata,
                    ),
                  ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.namaWst.namaWisata,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Alamat: ${widget.namaWst.lokasiWisata ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Deskripsi: ${widget.namaWst.deskripsi ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'No Telp: ${widget.namaWst.profil ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}