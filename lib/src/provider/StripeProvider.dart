import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:lavador/src/models/stripe_transaction_response.dart';
import 'package:http/http.dart' as http;
import 'package:lavador/src/utils/my_snackbar.dart';

class StripeProvider{

  String secret = "sk_test_51KfEMnE9FN5SXSt4IY3N3VbkKepk1IQjrC7DqiA3dY63Mg4yIDsRt7q55yr4eO7ag6D7Jwv5bC4osqGUbGaqWkHs00sjnLVA01";
  Map<String, String> headers ={
    'Authorization': 'Bearer sk_test_51KfEMnE9FN5SXSt4IY3N3VbkKepk1IQjrC7DqiA3dY63Mg4yIDsRt7q55yr4eO7ag6D7Jwv5bC4osqGUbGaqWkHs00sjnLVA01',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  BuildContext context;

  void init(BuildContext context){
    this.context = context;
    StripePayment.setOptions(StripeOptions(
        publishableKey: 'pk_test_51KfEMnE9FN5SXSt41LC4TEaXmvTAcmSiKl234zVQAdTFZpc83RKuaJKMaIQMtGiUMtUY2NdspWVnmwrRAMaeWSZE00tGNkXrNd',
        merchantId: 'test',
        androidPayMode: 'test'
    ));
  }




  Future<StripeTransactionResponse> payWithCard(String amount, String currency) async{
    try{
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
      var paymentIntent = await createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id
      ));

      if (response.status == 'succeeded') {
        return new StripeTransactionResponse ('Transaccion exitosa',  true, paymentMethod);

      }else{
        return new StripeTransactionResponse('Transaccion Fallida', false, paymentMethod);
      }
    }catch(e){
      print('Error de pago'+e);
      MySnackbar.show(context, 'Error de pago');
      return null;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async{
    try{
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      Uri uri = Uri.https('api.stripe.com','v1/payment_intents');
      var response = await http.post(uri, body: body, headers: headers);
      return jsonDecode(response.body);
    }catch(e){
      print('Error al crear el pago' + e);
      return null;
    }
  }

}