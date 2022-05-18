import 'dart:convert';

Addresss addressFromJson(String str) => Addresss.fromJson(json.decode(str));

String addressToJson(Addresss data) => json.encode(data.toJson());

class Addresss {
  Addresss({
    this.id,
    this.idUser,
    this.address,
    this.neighborhood,
    this.lat,
    this.lng,
  });

  String id;
  String idUser;
  String address;
  String neighborhood;
  double lat;
  double lng;
  List<Addresss> toList = [];

  factory Addresss.fromJson(Map<String, dynamic> json) => Addresss(
    id: json["id"] is int ? json['id'].toString() : json['id'],
    idUser: json["id_user"],
    address: json["address"],
    neighborhood: json["neighborhood"],
    lat: json["lat"] is String ? double.parse(json["lat"]) : json["lat"],
    lng: json["lng"] is String ? double.parse(json["lng"]) : json["lng"],
  );

  Addresss.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Addresss address = Addresss.fromJson(item);
      toList.add(address);
    });
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_user": idUser,
    "address": address,
    "neighborhood": neighborhood,
    "lat": lat,
    "lng": lng,
  };
}
