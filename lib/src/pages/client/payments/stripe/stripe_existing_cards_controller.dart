

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lavador/src/models/cards_client.dart';

import '../../../../models/addresss.dart';
import '../../../../models/order.dart';
import '../../../../models/product.dart';
import '../../../../models/response_api.dart';
import '../../../../models/user.dart';
import '../../../../provider/address_provider.dart';
import '../../../../provider/orders_provider.dart';
import '../../../../utils/shared_pref.dart';

class StripeExistingCardsController {

  BuildContext context;
  Function refresh;

  CardClient cardClient;


  SharedPref _sharedPref = new SharedPref();


  List<CardClient> cardsStore = [];

  List<Product> selectedProducts = [];
  double totalPs;
  User user;
  List<Addresss> address = [];
  OrdersProvider _ordersProvider = new OrdersProvider();
  AddressProvider _addressProvider = new AddressProvider();
  double totalPayment;
  Future init(BuildContext context, Function refresh,CardClient cardClient) async {
    this.context = context;
    this.refresh = refresh;
    //await _sharedPref.remove('card');
    user = User.fromJson(await _sharedPref.read('user'));
    selectedProducts = Product.fromJsonList(await _sharedPref.read('order')).toList;
    _addressProvider.init(context, user);
    _ordersProvider.init(context, user);
    cardsStore = CardClient.fromJsonList(await _sharedPref.read('card')).toList;

    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    totalPs = arguments['totalPs'];

    print('@222222ww222222 $totalPs');
    getCards();
   // getTotalPayment();
    refresh();
  }

  // void getTotalPayment() {
  //   selectedProducts.forEach((product) {
  //     totalPayment = totalPayment + (product.quantity * product.price);
  //
  //     print('Total a pagarsss: ${(totalPayment*100).floor()}');
  //   });
  //   refresh();
  // }

  void getCards() async {
    cardsStore.forEach((c) {
      print('Tarjetas listadas ${c.toJson()}');


    });
  }

  void deleteItem(CardClient cardClient) {
    cardsStore.removeWhere((p) => p.cardNumber == cardClient.cardNumber);
    _sharedPref.save('card', cardsStore);
    refresh();
   // getTotal();
  }

  void createOrder() async {



    Addresss a = Addresss.fromJson(await _sharedPref.read('address') ?? {});
    List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order')).toList;
    Order order = new Order(
        idClient: user.id,
        idAddress: a.id,
        products: selectedProducts
    );
    ResponseApi responseApi = await _ordersProvider.create(order);


    if(responseApi.success){

      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('order');
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(context, 'client/products/list', (route) => false);
      });

    }
    // Navigator.pushNamedAndRemoveUntil(context, 'client/payments/status', (route) => false);
    print('Producto seleccionado: ${responseApi.message}');


    // }else{
    //   progressDialog.close();
    // }


  }

  void cancelOrder() {
    Navigator.pushNamedAndRemoveUntil(
        context, 'client/products/list', (route) => false);
  }

}