import 'package:flutter/material.dart';
import 'package:lavador/src/models/response_api.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/provider/users_provider.dart';
import 'package:lavador/src/utils/my_snackbar.dart';
import 'package:lavador/src/utils/shared_pref.dart';

import '../../provider/push_notifications_provider.dart';

class LoginController {

  BuildContext context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  UsersProvider usersProvider = new UsersProvider();
  PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();
  SharedPref _sharedPref = new SharedPref();

  Future init(BuildContext context) async {
    this.context = context;
    await usersProvider.init(context);
    User user = User.fromJson(await _sharedPref.read('user') ?? {});

    print('Usuario: ${user.toJson()}');

    if (user?.sessionToken != null) {
      pushNotificationsProvider.saveToken(user,context);
      // Navigator.pushNamedAndRemoveUntil(
          // context, 'client/products/list', (route) => false);
      if (user.roles.length > 1) {
        Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
      }
      else {
        Navigator.pushNamedAndRemoveUntil(context, 'delivery/orders/list', (route) => false);
      }
    }


  }

  void goToRegisterPage() {
    Navigator.pushNamed(context, 'register');
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    ResponseApi responseApi = await usersProvider.login(email, password);
    MySnackbar.show(context, responseApi.message);
    //
    // print('Respuesta object: ${responseApi}');
    // print('Respuesta: ${responseApi.toJson()}');

    if (responseApi.success) {
      User user = User.fromJson(responseApi.data);
      _sharedPref.save('user', user.toJson());
      Navigator.pushNamedAndRemoveUntil(
          context, 'client/products/list', (route) => false);
      pushNotificationsProvider.saveToken(user,context);

      print('USUARIO LOGEADO: ${user.toJson()}');
        if (user.roles.length > 1) {
          Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
        }
        else {
          Navigator.pushNamedAndRemoveUntil(context, user.roles[0].route, (route) => false);
        }

      }
      else {
        MySnackbar.show(context, responseApi.message);
      }

    }
  }
