import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../api/environment.dart';
import '../../../../models/order.dart';
import '../../../../models/user.dart';
import '../../../../provider/orders_provider.dart';
import '../../../../utils/shared_pref.dart';



class RequestTotalOntroller{
  BuildContext context;
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
    socket = IO.io('http://${Environment.API_DELIVERY}/orders/status', <String, dynamic> {
      'transports': ['websocket'],
      'autoConnect': false
    });

    socket.connect();
    int idStatusOrder =1;

    // socket.on('status/${idStatusOrder}', (data) {
    //   print('DATA EMITIDA: ${data}');
    //   addStatus(data['statusOrder'],);
    // });

    print("SI ESTOY ENTRANDO AQUI....");
    // user = User.fromJson(await _sharedPref.read('user'));
    // _ordersProvider.init(context, user);
    // print('ORDEN: ${order.toJson()}');
    // checkGPS();

    Map<String, dynamic> map = await _sharedPref.read('service');
   // idClientSharedP = map['idClient'];
    idAddressSharedP = map['id_address'];

    latFromShared = map['lat'];
    lngFromShared = map['lng'];
    userid = user.id;
    print("BENX $userid");
    print("BENX $idAddressSharedP");
    print("BENX $latFromShared");
    print("BENX $lngFromShared");
    emitOrder();
  }

  void emitOrder() {
    socket.emit('status', {
      'id_order': 1,
      'statusOrder': "PETITION",
      'idClient': userid,
      'idAdress': idAddressSharedP,
      'lat': latFromShared,
      'lng': lngFromShared,
    });
  }

  void dispose() {
    socket?.disconnect();
  }

  //SEND OBJECT DATA TO SOKECT LISTENER
  // void emitPosition() {
  //   socket.emit('position', {
  //     'id_order': order.id,
  //     // 'lat': _position.latitude,
  //     // 'lng': _position.longitude,
  //   });
  // }

  // void addStatus(String status) {
  //   print("ENTRE METODO ADD STATUS");
  //   if(status=="ONWAY"){
  //     print("Navego a siguiente pantalla");
  //     Navigator.push(
  //       context,
  //       new MaterialPageRoute(
  //         builder: (context) => new OnwayCleanerPage(),
  //       ),
  //     );
  //
  //     refresh();
  //   }else{
  //     print("Algo paso mal sigo en la pantalla");
  //   }
  //
  //
  // }



}