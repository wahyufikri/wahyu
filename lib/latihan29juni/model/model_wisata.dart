// To parse this JSON data, do
//
//     final modelWisata = modelWisataFromJson(jsonString);

import 'dart:convert';

ModelWisata modelWisataFromJson(String str) => ModelWisata.fromJson(json.decode(str));

String modelWisataToJson(ModelWisata data) => json.encode(data.toJson());

class ModelWisata {
  bool isSuccess;
  String message;
  List<Datum> data;

  ModelWisata({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ModelWisata.fromJson(Map<String, dynamic> json) => ModelWisata(
    isSuccess: json["isSuccess"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "isSuccess": isSuccess,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String id;
  String namaWisata;
  String lokasiWisata;
  String deskripsi;
  String lat;
  String lng;
  String profil;
  String gambar;

  Datum({
    required this.id,
    required this.namaWisata,
    required this.lokasiWisata,
    required this.deskripsi,
    required this.lat,
    required this.lng,
    required this.profil,
    required this.gambar,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    namaWisata: json["nama_wisata"],
    lokasiWisata: json["lokasi_wisata"],
    deskripsi: json["deskripsi"],
    lat: json["lat"],
    lng: json["lng"],
    profil: json["profil"],
    gambar: json["gambar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama_wisata": namaWisata,
    "lokasi_wisata": lokasiWisata,
    "deskripsi": deskripsi,
    "lat": lat,
    "lng": lng,
    "profil": profil,
    "gambar": gambar,
  };
}