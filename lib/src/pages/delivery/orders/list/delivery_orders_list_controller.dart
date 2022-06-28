import 'package:flutter/material.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:lavador/src/models/order.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/pages/delivery/orders/detail/delivery_orders_detail_page.dart';
import 'package:lavador/src/provider/orders_provider.dart';
import 'package:lavador/src/utils/shared_pref.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../api/environment.dart';

class DeliveryOrdersListController {

  BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Function refresh;
  User user;

  List<String> status = ['DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  IO.Socket socket;
  bool isUpdated;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    openDrawer();


    socket = IO.io('http://${Environment.API_DELIVERY}/orders/status', <String, dynamic> {
      'transports': ['websocket'],
      'autoConnect': false
    });

    socket.connect();
    int idStatusOrder =1;

    socket.on('status/${idStatusOrder}', (data) {
      print('VLIX: ${data}');

    });

    _ordersProvider.init(context, user);
    refresh();
  }

  Future<List<Order>> getOrders(String status) async {

    return await _ordersProvider.getByDeliveryAndStatus(user.id, status);
    refresh();
  }

  void openBottomSheet(Order order) async {

    isUpdated = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => DeliveryOrdersDetailPage(order: order)
    );

    if (isUpdated) {
      refresh();
    }
  }

  void logout() {
    _sharedPref.logout(context, user.id);
  }

  void goToCategoryCreate() {
    Navigator.pushNamed(context, 'restaurant/categories/create');
    refresh();
  }

  void goToProductCreate() {
    Navigator.pushNamed(context, 'restaurant/products/create');
    refresh();
  }

  void openDrawer() {
    key.currentState.openDrawer();
    refresh();
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
    refresh();
  }
  void dispose() {
    socket?.disconnect();
  }
}