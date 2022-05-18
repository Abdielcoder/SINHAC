import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lavador/src/models/addresss.dart';
import 'package:lavador/src/models/cards_client.dart';
import 'package:lavador/src/utils/my_colors.dart';
import 'package:lavador/src/widgets/no_data_widget.dart';
import 'package:auto_reload/auto_reload.dart';
import 'client_address_list_controller.dart';

class ClientAddressListPage extends StatefulWidget {
  CardClient cardClient;

  @override
  _ClientAddressListPageState createState() => _ClientAddressListPageState();
}

class _ClientAddressListPageState extends State<ClientAddressListPage> {
  double totalPayment = 0;
  ClientAddressListController _con = new ClientAddressListController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
    _listAddress();
    print(totalPayment);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        title: Text('Direcciones'),
        actions: [
          _iconAdd()
        ],
      ),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              child: _textSelectAddress()
          ),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: _listAddress()
          ),


        ],
      ),


    );

  }

  Widget _noAddress() {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 30),
            child: NoDataWidget(text: 'No tienes ninguna direccion agrega una nueva')
        ),
        _buttonNewAddress()
      ],
    );
  }


  Widget _buttonNewAddress() {
    return Container(
      height: 40,
      child: ElevatedButton(
        onPressed: _con.goToNewAddress,
        child: Text(
            'Nueva direccion'
        ),
        style: ElevatedButton.styleFrom(
            primary: Colors.blue
        ),
      ),
    );
  }

  Widget _buttonAccept() {

      return Container(
        height: 50,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 50),
        child: ElevatedButton(
          onPressed:  _con.createOrder,
          child: Text(
              'Pagar con tarjeta'

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

  Widget _buttonAcceptCash() {

    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric( horizontal: 50),
      child: ElevatedButton(
        onPressed:  _con.createOrderCash,
        child: Text(
            'Pagar con efectivo'

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



  Widget _buttonAcceptCreateCard() {

      return Container(
        height: 50,
        width: double.infinity,
        margin: EdgeInsets.symmetric( horizontal: 50),
        child: ElevatedButton(
          onPressed: (){
            _con.cardsStore.length > 2?AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              animType: AnimType.BOTTOMSLIDE,
              title: 'Solo puedes ingresar hasta 3 tarjetas elimina Una.',
              desc: '',
              btnOkOnPress: () {

              },
            ).show():Navigator.pushNamed(
                context,
                'client/payments/create');
            ;
          },
          child: Text(
              'Agregar Tarjeta'
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


  Widget _listAddress() {
    return FutureBuilder(
        future: _con.getAddress(),
        builder: (context, AsyncSnapshot<List<Addresss>> snapshot) {


          if (snapshot.hasData) {

            if (snapshot.data.length > 0) {

              return Stack(
                  children: [ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (_, index) {
                        return _radioSelectorAddress(snapshot.data[index], index);
                      }
                  ),
                    Container(
                     margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.450),

                      child: _buttonAcceptCreateCard(),
                    ),
                    Container(
                     margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.550),

                      child: _buttonAccept(),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.650),

                      child: _buttonAcceptCash(),
                    ),
                  ]
              );


            }
            else {
              return _noAddress();
            }

          }
          else {
            return _noAddress();
          }

        }

    );

  }

  Widget _radioSelectorAddress(Addresss address, int index) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(

            children: [

              Radio(
                value: index,
                groupValue: _con.radioValue,
                onChanged:_con.handleRadioValueChange,

              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address?.address ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    address?.neighborhood ?? '',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )
                ],
              ),

            ],
          ),
          Divider(
            color: Colors.grey[400],
          )
        ],
      ),
    );
  }

  Widget _textSelectAddress() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Text(
        'Elige donde recibir tus compras',
        style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }


  Widget _iconAdd() {
    return IconButton(
        onPressed: _con.goToNewAddress,
        icon: Icon(Icons.add, color: Colors.white)
    );
  }

  void refresh() {
    setState(() {

    });

  }
}
