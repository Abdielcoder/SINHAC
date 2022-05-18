import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:lavador/src/pages/client/payments/stripe/stripe_existing_cards_controller.dart';
import 'package:lavador/src/utils/my_snackbar.dart';


import 'package:awesome_dialog/awesome_dialog.dart';

import '../../../../../models/cards_client.dart';
import '../../../../../provider/stripe_store_card_provider.dart';
import '../../../../../utils/my_colors.dart';
import '../../../../../widgets/no_data_widget.dart';

class ExistingCardsMenuPage extends StatefulWidget {
  CardClient cardClient;


  @override
  ExistingCardsMenuPageState createState() => ExistingCardsMenuPageState();
}

class ExistingCardsMenuPageState extends State<ExistingCardsMenuPage> {

  StripeExistingCardsController _con = new StripeExistingCardsController();

  String totalPaymentString = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.cardClient);
    });
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Mis Tarjetas'),
        backgroundColor: MyColors.primaryColor,
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.350,
        child: Column(
          children: [
            Divider(
              color: Colors.grey[400],
              endIndent: 30, // DERECHA
              indent: 30, //IZQUIERDA
            ),
            //  _textTotalPrice(),
            (_con.totalPs*100).floor() ==0?_buttonNuevaTarjeta():Container(),
            (_con.totalPs*100).floor() == 0?_buttonReresar():Container(),

          ],
        ),
      ),
      body: _con.cardsStore.length > 0
          ? ListView(
        children: _con.cardsStore.map((CardClient cardClient) {
          return _cardProduct(cardClient);
        }).toList(),
      )
          : NoDataWidget(text: 'Ningun producto agregado',),
    );
  }

  Widget _cardProduct(CardClient cardClient) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  payViaExistingCard(context,cardClient);
                },
                child: CreditCardWidget(
                  cardNumber: cardClient.cardNumber,
                  expiryDate: cardClient.expiryDate,
                  cardHolderName: cardClient.cardHolderName,
                  cvvCode: cardClient.ccv,
                  height: MediaQuery.of(context).size.height*0.210,
                  width: MediaQuery.of(context).size.width*0.650,
                  showBackView: false,
                ),
              ),
              SizedBox(height: 0),

            ],
          ),

          Column(

            children: [
              _textPrice('ELIMINAR'),
              _iconDelete(cardClient)
            ],
          )
        ],
      ),
    );
  }


  Widget _iconDelete(CardClient cardClient) {
    return IconButton(
        onPressed: () {
          _con.deleteItem(cardClient);
        },
        icon: Icon(Icons.delete, color: MyColors.primaryColor,)
    );
  }

  Widget _textPrice(String nombre) {
    return Container(
      margin: EdgeInsets.only(top: 1),
      child: Text(
        nombre,
        style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }
  Widget _textPago() {
    return Container(
      margin: EdgeInsets.only(top:20,left: 64),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PRECIONE UNA TARJETA PARA PAGAR',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14
            ),
          )
        ],
      ),
    );
  }

  payViaExistingCard(BuildContext context,CardClient cardClient) async {
    //ProgressDialog dialog = new ProgressDialog(context);
    // dialog.style(
    //     message: 'Please wait...'
    // );
    ProgressDialog progressDialog = new ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Espere un momento');
    print ( 'El valor de esta verga es: ${_con.totalPs}');
    // await dialog.show();
    var expiryArr = cardClient.expiryDate.split('/');
    CreditCard stripeCard = CreditCard(
      number: cardClient.cardNumber,
      expMonth: int.parse(expiryArr[0]),
      expYear: int.parse(expiryArr[1]),
    );
    try{
      print('valor psss #### : **** ${(_con.totalPs*100).floor()}');
      var response = await StripeService.payViaExistingCard(
          amount: '${(_con.totalPs*100).floor()}',
          currency: 'MXN',
          card: stripeCard
      );
      print('El error: **** ${response.toString()}');
      MySnackbar.show(context, response.message);
      if(response.message == 'Transaction successful'){

        progressDialog.close();
        MySnackbar.show(context, 'Tu orden ha sido procesada.');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Tu orden ha sido procesada.',
          desc: '',
          btnOkOnPress: () {
            _con.createOrder();
          },
        )..show();

      }else{
        if((_con.totalPs*100).floor()==0){
          progressDialog.close();
          MySnackbar.show(context, response.message);
          MySnackbar.show(context, 'Aviso.');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            title: 'En esta Sección solo puede Eliminar o crear tarjetas. .',
            desc: '',
            btnOkOnPress: () {
              _con.cancelOrder();
            },
          )..show();

        }else{
          progressDialog.close();
          MySnackbar.show(context, response.message);
          MySnackbar.show(context, 'Revisa tu forma de pago, orden no procesada.');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Revisa tu forma de pago, orden no procesada .',
            desc: '',
            btnOkOnPress: () {
              _con.cancelOrder();
            },
          )..show();
        }
      }

    }catch(e){
      MySnackbar.show(context, 'El error: **** ${e.message}' );
      print('El error: **** ${e.message}');
    }







  }

  void refresh() {
    setState(() {});
  }
  // //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Escoje una tarjeta'),
  //     ),
  //     body: Container(
  //       padding: EdgeInsets.all(20),
  //       child: ListView.builder(
  //         itemCount: cards.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           var card = cards[index];
  //           return InkWell(
  //             onTap: () {
  //               payViaExistingCard(context, card);
  //             },
  //             child: CreditCardWidget(
  //               cardNumber: card['cardNumber'],
  //               expiryDate: card['expiryDate'],
  //               cardHolderName: card['cardHolderName'],
  //               cvvCode: card['cvvCode'],
  //               showBackView: false,
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
  // void refresh() {
  //   setState(() {});
  // }

  Widget _buttonReresar() {

    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 50),
      child: ElevatedButton(
        onPressed:  (){
          Navigator.pushNamedAndRemoveUntil(context, 'client/products/list', (route) => false);
        },
        child: Text(
            'Regresar'

        ),
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            primary: MyColors.primaryColor
        ),
      ),
    );

  }

  Widget _buttonNuevaTarjeta() {

    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
      child: ElevatedButton(
        onPressed: (){
          _con.cardsStore.length >2?
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Solo puedes tener 3 Tarjetas elimina una .',
            desc: '',
            btnOkOnPress: () {

            },
          ).show():
          Navigator.pushNamedAndRemoveUntil(
              context,
              'client/payments/create',
                  (route) => false,
              arguments: {
                'totalPs': _con.totalPs,

              }
          );
        },
        child: Text(
            'Crear'

        ),
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            primary: MyColors.primaryColor
        ),
      ),
    );

  }

}