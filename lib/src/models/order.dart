import 'dart:convert';

import 'package:lavador/src/models/addresss.dart';
import 'package:lavador/src/models/product.dart';
import 'package:lavador/src/models/user.dart';


Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {

  String id;
  String idClient;
  String id_delivery;
  String id_address;
  String status;
  double lat;
  double lng;
  int timestamp;
  List<Product> products = [];
  List<Order> toList = [];
  User client;
  User delivery;
  Addresss address;

  Order({
    this.id,
    this.idClient,
    this.id_delivery,
    this.id_address,
    this.status,
    this.lat,
    this.lng,
    this.timestamp,
    this.products,
    this.client,
    this.delivery,
    this.address
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      id: json["id"] is int ? json["id"].toString() : json['id'],
      idClient: json["id_client"],
      id_delivery: json["id_delivery"],
      id_address: json["id_address"],
      status: json["status"],
      lat: json["lat"] is String ? double.parse(json["lat"]) : json["lat"],
      lng: json["lng"] is String ? double.parse(json["lng"]) : json["lng"],
      timestamp: json["timestamp"] is String ? int.parse(json["timestamp"]) : json["timestamp"],
      products: json["products"] != null ? List<Product>.from(json["products"].map((model) => model is Product ? model : Product.fromJson(model))) ?? [] : [],
      client: json['client'] is String ? userFromJson(json['client']) : json['client'] is User ? json['client'] : User.fromJson(json['client'] ?? {}),
      delivery: json['delivery'] is String ? userFromJson(json['delivery']) : json['delivery'] is User ? json['delivery'] : User.fromJson(json['delivery'] ?? {}),
      address: json['address'] is String ? addressFromJson(json['address']) : json['address'] is Addresss ? json['address'] : Addresss.fromJson(json['address'] ?? {})
  );

  Order.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Order order = Order.fromJson(item);
      toList.add(order);
    });
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_client": idClient,
    "id_delivery": id_delivery,
    "id_address": id_address,
    "status": status,
    "lat": lat,
    "lng": lng,
    "timestamp": timestamp,
    "products": products,
    "client": client,
    "delivery": delivery,
    "address": address,
  };
}
