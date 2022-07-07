import 'dart:convert';

import 'package:lavador/src/models/addresss.dart';
import 'package:lavador/src/models/product.dart';
import 'package:lavador/src/models/user.dart';


Total totalFromJson(String str) => Total.fromJson(json.decode(str));

String totalToJson(Total data) => json.encode(data.toJson());

class Total {


  String ventas;
  String name;
  List<Total> toList = [];


  Total({

    this.ventas,
    this.name

  });

  factory Total.fromJson(Map<String, dynamic> json) => Total(

      ventas: json["ventas"],
      name: json["name"],

  );

  Total.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Total total = Total.fromJson(item);
      toList.add(total);
    });
  }

  Map<String, dynamic> toJson() => {
    "ventas": ventas,
    "name":name,
  };
}
