import 'package:flutter/material.dart';
import 'package:lavador/src/models/order.dart';
import 'package:lavador/src/models/product.dart';
import 'package:lavador/src/models/response_api.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/provider/orders_provider.dart';
import 'package:lavador/src/provider/users_provider.dart';
import 'package:lavador/src/utils/my_snackbar.dart';
import 'package:lavador/src/utils/shared_pref.dart';

import '../../../../api/environment.dart';
import '../../../../provider/push_notifications_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RestaurantOrdersDetailController {

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
  PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();
  String idDelivery;

  IO.Socket socket;

  Future init(BuildContext context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;
    user = User.fromJson(await _sharedPref.read('user'));
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user);

    socket = IO.io('https://${Environment.API_DELIVERY}/orders/asigned', <String, dynamic> {
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.connect();

    getTotal();
    getUsers();
    refresh();
  }

  void sendNotification(String tokenDelivery) {

    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      "screen": "delivery/orders/list",
    };

    pushNotificationsProvider.sendMessage(
        tokenDelivery,
        data,
        'PEDIDO ASIGNADO A LAVADOR',
        'te han asignado un pedido'
    );
  }



  void updateOrder() async {
    if (idDelivery != null) {

      order.id_delivery = idDelivery;
      ResponseApi responseApi = await _ordersProvider.updateToDispatched(order);

      User deliveryUser = await _usersProvider.getById(order.id_delivery);
      sendNotification(deliveryUser.notificationToken);
      emitLavador(deliveryUser.id);

      MySnackbar.show(context, responseApi.message);
      Navigator.pop(context, true);
    }
    else {
      MySnackbar.show(context, 'Seleccione el Lavador');
    }
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
  void dispose() {
    socket?.disconnect();
  }

  void emitLavador(String idLavador) {
    socket.emit('idOrder', {
      'id_order': order.id,
      'idLavador':idLavador,

    });
  }
}