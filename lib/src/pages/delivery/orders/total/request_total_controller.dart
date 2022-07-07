import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../api/environment.dart';
import '../../../../models/order.dart';
import '../../../../models/total.dart';
import '../../../../models/user.dart';
import '../../../../provider/orders_provider.dart';
import '../../../../utils/shared_pref.dart';



class RequestTotalOntroller{
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Function refresh;
  Order order;
  IO.Socket socket;
  IO.Socket socket2;
  User user;
  SharedPref _sharedPref = new SharedPref();
  OrdersProvider _ordersProvider = new OrdersProvider();
  double latFromShared;
  double lngFromShared;
  String idClientSharedP;
  String idAddressSharedP;
  String idClientSokect;
  String idAddressSokect;
  String userid;
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    // order = Order.fromJson(ModalRoute.of(context).settings.arguments as Map<String, dynamic>);
    user = User.fromJson(await _sharedPref.read('user'));
    _ordersProvider.init(context, user);
    userid = user.id;
    print('RESX : 0.0 $userid ');
  }

  // Future<List<Total>> getTotal() async {
  //
  //   return await _ordersProvider.getTotalPerDay(user.id);
  //   refresh();
  // }




}