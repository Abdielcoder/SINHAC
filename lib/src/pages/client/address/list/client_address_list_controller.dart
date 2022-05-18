import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:lavador/src/models/addresss.dart';
import 'package:lavador/src/models/cards_client.dart';
import 'package:lavador/src/models/order.dart';
import 'package:lavador/src/models/product.dart';
import 'package:lavador/src/models/response_api.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/provider/StripeProvider.dart';
import 'package:lavador/src/provider/address_provider.dart';
import 'package:lavador/src/provider/orders_provider.dart';
import 'package:lavador/src/utils/my_snackbar.dart';
// import 'package:lavador/src/provider/orders_provider.dart';
import 'package:lavador/src/utils/shared_pref.dart';

class ClientAddressListController {

  BuildContext context;
  Function refresh;


  AddressProvider _addressProvider = new AddressProvider();



  int radioValue = 0;
  bool elestado = false;
  bool isCreated;
  double totalPayment = 0;
  double totalPaymentD = 0;
  String pago = '';
  Map<String, dynamic> dataIsCreated;
  List<CardClient> cardsStore = [];
  List<Product> selectedProducts = [];
  SharedPref _sharedPref = new SharedPref();
  User user;
  List<Addresss> address = [];
  OrdersProvider _ordersProvider = new OrdersProvider();
  StripeProvider _stripeProvider = new StripeProvider();
  String cardname;
  ProgressDialog progressDialog;
  String nameCard;
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    progressDialog = new ProgressDialog(context: context);
    cardsStore = CardClient.fromJsonList(await _sharedPref.read('card')).toList;
    user = User.fromJson(await _sharedPref.read('user'));
    selectedProducts = Product.fromJsonList(await _sharedPref.read('order')).toList;
    _addressProvider.init(context, user);
    _ordersProvider.init(context, user);
    _stripeProvider.init(context);
    getTotalPayment();

    Addresss a = Addresss.fromJson(await _sharedPref.read('address') ?? {});
    if (a.id !=null) {

    }
    refresh();
  }


  void getCards() async {
    cardsStore.forEach((c) {
      print('Tarjetas listadas ${c.toJson()}');


    });
  }
  void createOrder() async {
      //
      // Addresss a = Addresss.fromJson(await _sharedPref.read('address') ?? {});
      // List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order')).toList;
      // Order order = new Order(
      //     idClient: user.id,
      //     idAddress: a.id,
      //     products: selectedProducts
      // );
      // ResponseApi responseApi = await _ordersProvider.create(order);
      //
      //
      // if(responseApi.success){
      //   print('@222222 $totalPayment');
      //   SharedPreferences preferences = await SharedPreferences.getInstance();
      //   await preferences.remove('order');
        Future.delayed(Duration.zero, () {
          //Navigator.pushNamed(context, '  3
          // \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ aQ433client/payments/stripe/existingcards');
          Navigator.pushNamedAndRemoveUntil(
               context,
              'client/payments/stripe/existingcards',
                  (route) => false,
              arguments: {
              'totalPs': totalPayment,

            }
          );
        });

     //  }
     // // Navigator.pushNamedAndRemoveUntil(context, 'client/payments/status', (route) => false);
     //  print('Producto seleccionado: ${responseApi.message}');
     //  progressDialog.close();

    // }else{
    //   progressDialog.close();
    // }

  }

  void createOrderCash() async {

    Addresss a = Addresss.fromJson(await _sharedPref.read('address') ?? {});
    List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order')).toList;
    Order order = new Order(
        idClient: user.id,
        idAddress: a.id,
        products: selectedProducts
    );
    ResponseApi responseApi = await _ordersProvider.createOrderCash(order);


    if(responseApi.success){
      print('@222222 $totalPayment');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('order');
      Future.delayed(Duration.zero, () {
        //Navigator.pushNamed(context, '  3
        // \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ aQ433client/payments/stripe/existingcards');
        Navigator.pushNamedAndRemoveUntil(
            context,
            'client/products/list',
                (route) => false,

        );
      });

    }
    // Navigator.pushNamedAndRemoveUntil(context, 'client/payments/status', (route) => false);
    print('Producto seleccionado: ${responseApi.message}');
    progressDialog.close();

    // }else{
    //   progressDialog.close();
    // }

  }



  void getTotalPayment() {
    progressDialog.show(max: 100, msg: 'Realizando transaccion');
    selectedProducts.forEach((product) {
      totalPayment = totalPayment + (product.quantity * product.price);
      print('Total a pagar: ${(totalPayment*100).floor()}');
    });
    refresh();
    progressDialog.close();
  }

  void handleRadioValueChange(int value) async {
    radioValue = value;
    _sharedPref.save('address', address[value]);

    refresh();
    print('Valor seleccioonado: $radioValue');
  }



  Future<List<Addresss>> getAddress() async {
    address = await _addressProvider.getByUser(user.id);

    Addresss a = Addresss.fromJson(await _sharedPref.read('address') ?? {});
    int index = address.indexWhere((ad) => ad.id == a.id);

    if (index != -1) {
      radioValue = index;
      elestado = true;
    }

    print('SE GUARDO LA DIRECCION: ${a.toJson()}');
    print('LO QUE TREA ADRESSESS  ${address.toString()}');
    return address;
  }

  void goToNewAddress() async {
    var result = await Navigator.pushNamed(context, 'client/address/create');

    if (result != null) {
      if (result) {
        refresh();
      }
    }
  }

}