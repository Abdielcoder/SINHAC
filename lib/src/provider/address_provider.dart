import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:lavador/src/api/environment.dart';
import 'package:lavador/src/models/addresss.dart';
import 'package:lavador/src/models/response_api.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/utils/my_snackbar.dart';
import 'package:lavador/src/utils/shared_pref.dart';

class AddressProvider {

  String _url = Environment.API_DELIVERY;
  String _api = '/api/address';
  BuildContext context;
  User sessionUser;

  Future init(BuildContext context, User sessionUser) {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Addresss>> getByUser(String idUser) async {
    try {
      Uri url = Uri.http(_url, '$_api/findByUser/${idUser}');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {

        MySnackbar.show(context, 'Sesion expirada');
        new SharedPref().logout(context, sessionUser.id);
      }
      final data = json.decode(res.body); // CATEGORIAS
      Addresss address = Addresss.fromJsonList(data);
      return address.toList;
    }
    catch(e) {
      print('Error: $e');
      return [];
    }
  }

  Future<ResponseApi> create(Addresss address) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(address);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken
      };
      final res = await http.post(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        MySnackbar.show(context, 'Sesion expirada');
        new SharedPref().logout(context, sessionUser.id);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

}