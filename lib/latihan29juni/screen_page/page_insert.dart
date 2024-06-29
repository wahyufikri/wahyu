import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:wahyu/latihannotes15juni/screen_page/page_utama.dart';
import '../model/model_insert.dart';

class PageInsertWisata extends StatefulWidget {
  const PageInsertWisata({super.key});

  @override
  State<PageInsertWisata> createState() => _PageInsertWisataState();
}

class _PageInsertWisataState extends State<PageInsertWisata> {
  TextEditingController txtNamaWisata = TextEditingController();
  TextEditingController txtLokasiWisata = TextEditingController();
  TextEditingController txtDeskripsi = TextEditingController();
  TextEditingController txtlat = TextEditingController();
  TextEditingController txtlong = TextEditingController();
  TextEditingController txtprofil = TextEditingController();
  TextEditingController txtgambar = TextEditingController();

  //validasi form
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  //Proses untuk hit API
  bool isLoading = false;

  Future<ModelInsert?> addWisata() async {
    //handle error
    try {
      setState(() {
        isLoading = true;
      });

      http.Response response = await http.post(
        Uri.parse('http://10.127.222.22/wisataDB/addWisata.php'),
        body: {
          "nama_wisata": txtNamaWisata.text,
          "lokasi_wisata": txtLokasiWisata.text,
          "deskripsi": txtDeskripsi.text,
          "lat": txtlat.text,
          "long": txtlong.text,
          "profil": txtprofil.text,
          "gambar": txtgambar.text,

        },
      );

      if (response.statusCode == 200) {
        ModelInsert data = modelInsertFromJson(response.body);
        if (data.value == 1) {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.message}')),
            );

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PageUtama()),
            );
          });
        } else if (data.value == 2) {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.message}')),
            );
          });
        } else {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.message}')),
            );
          });
        }
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode}')),
          );
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('Wisata Baru'),
      ),
      body: Form(
        key: keyForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildTextField('Nama', txtNamaWisata),
                buildTextField('Lokasi', txtLokasiWisata),
                buildTextField('Deskripsi', txtDeskripsi),
                buildTextField('Lat', txtlat),
                buildTextField('Lng', txtlong),
                buildTextField('Profil', txtprofil),
                buildTextField('Gambar', txtgambar),
                SizedBox(height: 20),
                //Proses cek loading
                Center(
                  child: isLoading
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : MaterialButton(
                    minWidth: 150,
                    height: 45,
                    onPressed: () {
                      //Cek validasi form ada kosong atau tidak
                      if (keyForm.currentState?.validate() == true) {
                        setState(() {
                          addWisata();
                        });
                      }
                    },
                    child: Text('Insert'),
                    color: Colors.green,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        width: 1,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
Widget buildTextField(String hint, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      validator: (val) => val!.isEmpty ? "Tidak boleh kosong" : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
