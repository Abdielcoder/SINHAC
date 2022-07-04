import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
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

  //List<String> status = ['DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  List<String> status = ['DESPACHADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  IO.Socket socket;
  bool isUpdated;

  bool isClose = false;
  bool llegada = false;
  double _distanceBetween;
  Position _position;
  StreamSubscription _positionStream;

  String idCliente;
  String addressName;
  LatLng addressLatLng;
  double latSockectString;
  double lngSockectString;
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
      idCliente = data['idClient'];
      latSockectString = data['lat'];
      lngSockectString = data['lng'];
      print('-------- KUGX12 $latSockectString----------');
      print('-------- KUGX14 $lngSockectString----------');
      isCloseToDeliveryPosition();
    });

    _ordersProvider.init(context, user);
    checkGPS();

    refresh();
  }

  Future<List<Order>> getOrders(String status) async {

    return await _ordersProvider.getByClientAndStatus(idCliente, status);
    refresh();
  }

  // Future<List<Order>> getOrders(String status) async {
  //
  //   return await _ordersProvider.getByDeliveryAndStatus("2", status);
  //   refresh();
  // }

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
    //Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
    Navigator.pushNamed(context, 'roles');
    refresh();
  }
  void goInicio() {
    //Navigator.pushNamedAndRemoveUntil(context, 'delivery/orders/list', (route) => false);
    Navigator.pushNamed(context, 'delivery/orders/list');
    refresh();
  }
  void goEntregado() {
    //Navigator.pushNamedAndRemoveUntil(context, 'delivery/orders/entregado', (route) => false);
    Navigator.pushNamed(context, 'delivery/orders/entregado');
    refresh();
  }
  void goCancelado() {
    //Navigator.pushNamedAndRemoveUntil(context, 'delivery/orders/cancelado', (route) => false);
    Navigator.pushNamed(context, 'delivery/orders/cancelado');
    refresh();
  }
  void goGanancias() {
    //Navigator.pushNamedAndRemoveUntil(context, 'delivery/orders/total', (route) => false);
    Navigator.pushNamed(context, 'delivery/orders/total');
    refresh();
  }
  void dispose() {
    socket?.disconnect();
  }

  void isCloseToDeliveryPosition() {
    print('-------- KUGX 6  ---------- $_position');
    _distanceBetween = Geolocator.distanceBetween(
        _position.latitude,
        _position.longitude,
        latSockectString,
        lngSockectString
    );
    print('-------- KUGX8 ${ _position.latitude} ----------');
    print('-------- KUGX9 ${ _position.longitude} ----------');
    print('-------- KUGX10 $latSockectString ----------');
    print('-------- KUGX11 $lngSockectString----------');

    print('-------- KUGX7 $_distanceBetween ----------');

    if (_distanceBetween <= 5000 && !isClose) {
      print('-------- KUGX 15 ${_distanceBetween} ----------');
     // print('-------- TOKEN ${order.client.notificationToken} ----------');
      getOrders('DESPACHADO');
      isClose = true;
    }


  }

  void updateLocation() async {
    try {
      print('-------- KUGX 4  ----------');
      await _determinePosition(); // OBTENER LA POSICION ACTUAL Y TAMBIEN SOLICITAR LOS PERMISOS
      _position = await Geolocator.getLastKnownPosition(); // LAT Y LNG
      print('-------- KUGX 5  ---------- $_position');
     // saveLocation();

   // _position.latitude, _position.longitude);




    } catch(e) {
      print('Error: $e');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    print('-------- KUGX 1  ----------');
    if (isLocationEnabled) {
      updateLocation();
      print('-------- KUGX 2  ----------');
    }
    else {
      print('-------- KUGX 3  ----------');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }


}