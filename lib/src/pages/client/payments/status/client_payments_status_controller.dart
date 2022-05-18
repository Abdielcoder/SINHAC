import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:lavador/src/models/mercado_pago_payment.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/provider/users_provider.dart';
import 'package:lavador/src/utils/shared_pref.dart';

import '../../../../provider/push_notifications_provider.dart';

class ClientPaymentsStatusController {
  SharedPref _sharedPref = new SharedPref();
  BuildContext context;
  Function refresh;
  String brandCard ='';
  String last4= '';
  User user;
  PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();

  UsersProvider _usersProvider = new UsersProvider();
  List<String> tokens = [];

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    user = User.fromJson(await _sharedPref.read('user'));

    _usersProvider.init(context,sessionUser: user);

    tokens = await _usersProvider.getAdminsNotificationTokens();

    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    brandCard = arguments['brand'];
    last4 = arguments['last4'];
    refresh();
  }



  void sendNotification() {
    List<String> registration_ids = [];

    tokens.forEach((token) {
      if(token != null){
        registration_ids.add(token);
      }
    });

    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    };
    print('TOKENS DE ADMIN ################## ${registration_ids.toString()}');
    pushNotificationsProvider.sendMessageMultiple(
        registration_ids,
        data,
        'COMPRA EXITOSA',
        'Un cliente solcito un servicio'
    );
  }

  void finishShopping() {
    Navigator.pushNamedAndRemoveUntil(context, 'client/products/list', (route) => false);
    sendNotification();
  }

}