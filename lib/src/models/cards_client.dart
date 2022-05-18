import 'dart:convert';

CardClient cardClientFromJson(String str) => CardClient.fromJson(json.decode(str));

String cardClientToJson(CardClient data) => json.encode(data.toJson());

class CardClient {

  String cardNumber;
  String expiryDate;
  String cardHolderName;
  bool estado;
  String ccv;
  List<CardClient> toList = [];
  CardClient({


    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.ccv,
    this.estado,
  });

  factory CardClient.fromJson(Map<String, dynamic> json) => CardClient(


    cardNumber: json["cardNumber"],
    expiryDate: json["expiryDate"],
    cardHolderName: json["cardHolderName"],
    ccv: json["ccv"],
    estado: json["estado"],
  );

  CardClient.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      CardClient card = CardClient.fromJson(item);
      toList.add(card);
    });
  }

  Map<String, dynamic> toJson() => {

    "cardNumber": cardNumber,
    "expiryDate": expiryDate,
    "cardHolderName": cardHolderName,
    "ccv": ccv,
    "estado": estado,
  };

  static bool isInteger(num value) => value is int || value == value.roundToDouble();

}
