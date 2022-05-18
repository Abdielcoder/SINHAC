import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:lavador/src/models/category.dart';
import 'package:lavador/src/models/product.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:lavador/src/provider/categories_provider.dart';
import 'package:lavador/src/provider/products_provider.dart';
import 'package:lavador/src/provider/users_provider.dart';
import 'package:lavador/src/utils/shared_pref.dart';

import '../../../../provider/push_notifications_provider.dart';


class ClientProductsListController {
  GoogleSignInAccount _currentUser;
  BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Function refresh;
  User user;
  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  ProductsProvider _productsProvider = new ProductsProvider();
  List<Category> categories = [];
  StreamController<String> streamController = StreamController();
  TextEditingController _searchController = new TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email'
      ]
  );

  Timer searchOnStoppedTyping;

  String productName = '';

  PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();

  UsersProvider _usersProvider = new UsersProvider();
  List<String> tokens = [];

  ProgressDialog _progressDialog;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    user = User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, user);
    _productsProvider.init(context, user);
    _progressDialog = ProgressDialog(context: context);
    _usersProvider.init(context,sessionUser: user);
    tokens = await _usersProvider.getAdminsNotificationTokens();
    //sendNotification();



    getCategories();
    refresh();
  }

  void sendNotification() {
    List<String> registration_ids = [];

    tokens.forEach((token) {
      if(token != null){
        registration_ids.add(token);
      }
    });

    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      "screen": "delivery/orders/list",
    };

    pushNotificationsProvider.sendMessageMultiple(
        registration_ids,
        data,
        'COMPRA EXITOSA',
        'Un cliente solcito un servicio'
    );
  }

  void onChangeText(String text) {
    const duration = Duration(milliseconds:800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping.cancel();
      refresh();
    }

    searchOnStoppedTyping = new Timer(duration, () {
      productName = text;
      refresh();
       // getProducts(idCategory, text);
      print('TEXTO COMPLETO $text');
    });
  }

  Future<List<Product>> getProducts(String idCategory, String productName) async {
    if (productName.isEmpty) {
      return await _productsProvider.getByCategory(idCategory);
    }
    else {
      return await _productsProvider.getByCategoryAndProductName(idCategory, productName);
    }
  }

  void getCategories() async {
    _progressDialog.show(max: 400, msg: 'Espere un momento...');
    categories = await _categoriesProvider.getAll();
    refresh();
    _progressDialog.close();
  }

  void openBottomSheet(Product product) {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => ClientProductsDetailPage(product: product)
    );
  }

  void logout() {

    _googleSignIn.disconnect();
    print('logout 3');
    _sharedPref.logout(context, user.id);
    print('logout id value 1: ${user.id}');
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }

  void goToUpdatePage() {
    Navigator.pushNamed(context, 'client/update');
  }

  void goToOrdersList() {
    Navigator.pushNamed(context, 'client/orders/list');
  }

  void goToCards() {
    Future.delayed(Duration.zero, () {
      //Navigator.pushNamed(context, '  3
      // \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ aQ433client/payments/stripe/existingcards');
      Navigator.pushNamedAndRemoveUntil(
          context,
          'client/payments/stripe/existingcards/menu',
              (route) => false,
          arguments: {
            'totalPs': 0.0,

          }
      );
    });
  }

  void goToOrderCreatePage() {
    Navigator.pushNamed(context, 'client/orders/create');
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }

}