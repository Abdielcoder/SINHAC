import 'package:flutter/material.dart';
import 'package:lavador/src/models/order.dart';
import 'package:lavador/src/models/product.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/provider/orders_provider.dart';
import 'package:lavador/src/provider/users_provider.dart';
import 'package:lavador/src/utils/shared_pref.dart';

import 'package:url_launcher/url_launcher.dart';

class ClientOrdersDetailController {

  BuildContext context;
  Function refresh;

  Product product;

  int counter = 1;
  double productPrice;

  SharedPref _sharedPref = new SharedPref();

  double total = 0;
  Order order;

  User user;
  List<User> users = [];
  UsersProvider _usersProvider = new UsersProvider();
  OrdersProvider _ordersProvider = new OrdersProvider();
  String idDelivery;

  Future init(BuildContext context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;
    user = User.fromJson(await _sharedPref.read('user'));
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user);
    getTotal();
    getUsers();
    refresh();
  }

  void updateOrder() async {
    Navigator.pushNamed(context, 'client/orders/map', arguments: order.toJson());
  }

  void getUsers() async {
    users = await _usersProvider.getDeliveryMen();
    refresh();
  }

  void getTotal() {
    total = 0;
    order.products.forEach((product) {
      total = total + (product.price * product.quantity);
    });
    refresh();
  }

}