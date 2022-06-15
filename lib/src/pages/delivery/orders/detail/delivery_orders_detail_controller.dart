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

class DeliveryOrdersDetailController {

  BuildContext context;
  Function refresh;

  Product product;

  int counter = 1;
  double productPrice;

  SharedPref _sharedPref = new SharedPref();

  double total = 0;
  Order order;
  PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();

  User user;
  List<User> users = [];
  UsersProvider _usersProvider = new UsersProvider();
  OrdersProvider _ordersProvider = new OrdersProvider();
  String idDelivery;
  String idClient;

  IO.Socket socket;


  Future init(BuildContext context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;
    user = User.fromJson(await _sharedPref.read('user'));
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user);

    socket = IO.io('http://${Environment.API_DELIVERY}/orders/status', <String, dynamic> {
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.connect();

    // socket.on('status/${order.id}', (data) {
    //   print('DATA EMITIDA: ${data}');
    //
    //   // addMarker(
    //   //     'delivery',
    //   //     data['lat'],
    //   //     data['lng'],
    //   //     'Tu Lavador',
    //   //     '',
    //   //     deliveryMarker
    //   // );
    //
    // });


    getTotal();
    getUsers();
    refresh();
  }

  // void sendNotification(String tokenDelivery) {
  //
  //   Map<String, dynamic> data = {
  //     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //     "screen": "client/orders/list",
  //   };
  //
  //   pushNotificationsProvider.sendMessage(
  //       tokenDelivery,
  //       data,
  //       'SERVICIO DESPACHADO',
  //       'Tu servicio esta en proceso...'
  //   );
  // }



  void updateOrder() async {

    // order.idClient = idClient;
  print('#@#@#@#@#@#'+order.status.toString());
    if (order.status == 'DESPACHADO') {
      ResponseApi responseApi = await _ordersProvider.updateToOnTheWay(order);
      emitStatus('ONWAY');
      MySnackbar.show(context, responseApi.message);
      if (responseApi.success) {
        // User idClient = await _usersProvider.getById(order.idClient);
        // print("TU ID CLIENTE ES ${idClient}");

        Navigator.pushNamed(context, 'delivery/orders/map', arguments: order.toJson());
      }
    }
    else {
      Navigator.pushNamed(context, 'delivery/orders/map', arguments: order.toJson());
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

  //SEND OBJECT DATA TO SOKECT LISTENER
  void emitStatus(String status) {
    socket.emit('status', {
      'id_order': '1',
       'statusOrder': status,
      // 'lng': _position.longitude,
    });
  }

}