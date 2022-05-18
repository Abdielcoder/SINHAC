import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';

import 'package:http/http.dart';
import 'package:lavador/src/models/mercado_pago_card_token.dart';
import 'package:lavador/src/models/mercado_pago_document_type.dart';
import 'package:lavador/src/models/user.dart';
import 'package:lavador/src/provider/mercado_pago_provider.dart';
import 'package:lavador/src/utils/my_snackbar.dart';
import 'package:lavador/src/utils/shared_pref.dart';

import '../../../../models/cards_client.dart';

class ClientPaymentsCreateController {

  BuildContext context;
  Function refresh;
  GlobalKey<FormState> keyForm = new GlobalKey();

  TextEditingController documentNumberController = new TextEditingController();

  String cardNumber = '';
  String expireDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  double totalPayment = 0;
  List<MercadoPagoDocumentType> documentTypeList = [];
  MercadoPagoProvider _mercadoPagoProvider = new MercadoPagoProvider();
  User user;
  SharedPref _sharedPref = new SharedPref();

  // String typeDocument = 'CC';
  CardClient card_client = new CardClient();

  List<CardClient> cardsStore = [];

  bool duplicado= true;
  String expirationYear;
  int expirationMonth;
  String month;
  MercadoPagoCardToken cardToken;
  double totalPs =0;
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    cardsStore = CardClient.fromJsonList(await _sharedPref.read('card')).toList;
    //await _sharedPref.remove('card');
    _mercadoPagoProvider.init(context, user);
    // getIdentificationTypes();
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    totalPs = arguments['totalPs'];
  }

  void addCard() {
    int index = cardsStore.indexWhere((c) => c.cardNumber == card_client.cardNumber);

    if(index == -1) { //NO EXISTE
      cardsStore.add(card_client);
      duplicado = false;
    }else{

    }
    

    // cardsStore.add(card_client);
    _sharedPref.save('card', cardsStore);
    MySnackbar.show(context, "Tarjeta se agrego Correctamente");
  }

  void addItemCard( String card, String expiryDate,String name, String ccv, bool valor) {

    card_client.cardNumber = card;
    card_client.expiryDate= expiryDate;
    card_client.cardHolderName = name;
    card_client.ccv = ccv;
    card_client.estado = valor;
  }


  void createCardToken() async {
    String documentNumber = documentNumberController.text;

    if (cardNumber.isEmpty) {
      MySnackbar.show(context, 'Ingresa el numero de la tarjeta');
      return;
    }

    if (expireDate.isEmpty) {
      MySnackbar.show(context, 'Ingresa la fecha de expiracion de la tarjeta');
      return;
    }

    if (cvvCode.isEmpty) {
      MySnackbar.show(context, 'Ingresa el codigo de seguridad de la tarjeta');
      return;
    }

    if (cardHolderName.isEmpty) {
      MySnackbar.show(context, 'Ingresa el titular de la tarjeta');
      return;
    }



    if (expireDate != null) {
      List<String> list = expireDate.split('/');
      if (list.length == 2) {
        expirationMonth = int.parse(list[0]);
        expirationYear = '20${list[1]}';
      }
      else {
        MySnackbar.show(
            context, 'Inserta el mes y el año de expiracion de la tarjeta');
      }
    }

    if (cardNumber != null) {
      cardNumber = cardNumber.replaceAll(RegExp(' '), '');
    }

    print('CVV: $cvvCode');
    print('Card Number: $cardNumber');
    print('cardHolderName: $cardHolderName');
    // print('documentId: $typeDocument');
    // print('documentNumber: $documentNumber');
    print('expirationYear: $expirationYear');
    print('expirationMonth: $expirationMonth');

    month =  expirationMonth.toString();
    String expiryDate = month+'/'+expirationYear;

    addItemCard(cardNumber,expiryDate,cardHolderName,cvvCode,false);
    addCard();


    if(duplicado == true){
      MySnackbar.show(context, "Ya has agregado esta tarjeta antes");
      Navigator.pop(context, true);
    }else{
      Navigator.pushNamedAndRemoveUntil(
          context,
          'client/payments/stripe/existingcards',
              (route) => false,
          arguments: {
            'totalPs': totalPs,

          }
      );
    }




    // cardsStore.forEach((c) {
    //   print('Tarjetas listadas ${c.toJson()}');
    // });

  }

    void onCreditCardModelChanged(CreditCardModel creditCardModel) {
      cardNumber = creditCardModel.cardNumber;
      expireDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      refresh();
    }
  }

