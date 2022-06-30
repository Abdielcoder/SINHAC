import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lavador/src/models/order.dart';
import 'package:lavador/src/models/product.dart';
import 'package:lavador/src/utils/my_colors.dart';
import 'package:lavador/src/utils/relative_time_util.dart';
import 'package:lavador/src/widgets/no_data_widget.dart';

import 'delivery_orders_detail_controller.dart';


class DeliveryOrdersDetailPage extends StatefulWidget {

  Order order;

  DeliveryOrdersDetailPage({Key key, @required this.order}) : super(key: key);

  @override
  _DeliveryOrdersDetailPageState createState() => _DeliveryOrdersDetailPageState();
}

class _DeliveryOrdersDetailPageState extends State<DeliveryOrdersDetailPage> {

  DeliveryOrdersDetailController _con = new DeliveryOrdersDetailController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicio #${_con.order?.id ?? ''}'),
        backgroundColor: MyColors.primaryColor,
        actions: [
          Container(
            margin: EdgeInsets.only(top: 18, right: 15),
            child: Text(
              '\$ Total: ${_con.total}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color: Colors.grey[400],
                endIndent: 30, // DERECHA
                indent: 30, //IZQUIERDA
              ),
              SizedBox(height: 10),
              _textData('Cliente:', '${_con.order.client?.name ?? ''} ${_con.order.client?.lastname ?? ''}'),
              _textData('Servicio en:', '${_con.order.address?.address ?? ''}'),
              _textData(
                  'Fecha de servicio:',
                  '${RelativeTimeUtil.getRelativeTime(_con.order.timestamp ?? 0)}'
              ),
              _con.order.status != 'ENTREGADO' ? _buttonNext() : Container()
            ],
          ),
        ),
      ),
      body: _con.order.products.length > 0
      ? ListView(
        children: _con.order.products.map((Product product) {
          return _cardProduct(product);
        }).toList(),
      )
      : NoDataWidget(text: 'Ningun producto agregado',),
    );
  }

  Widget _textData(String title, String content) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          content,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buttonNext() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 20),
      child: ElevatedButton(
        onPressed: _con.updateOrder,
        style: ElevatedButton.styleFrom(
            primary: _con.order?.status == 'DESPACHADO' ? MyColors.primaryColorDark : Colors.green,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            )
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  _con.order?.status == 'DESPACHADO' ? 'INICIAR ENTREGA' : 'IR AL MAPA',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50, top: 4),
                height: 30,
                child: Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _cardProduct(Product product) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            _imageProduct(product),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? '',
                  style: TextStyle(
                      fontSize: 40,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Cantidad: ${product.quantity}',
                  style: TextStyle(
                      fontSize: 30
                  ),
                ),
              ],
            ),

          ],
        ),
    );
  }
  

  Widget _imageProduct(Product product) {
    return Container(
      width: 250,
      height: 250,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          color: Colors.grey[200]
      ),
      child: FadeInImage(
        image: product.image1 != null
            ? NetworkImage('https://static.wixstatic.com/media/b367ba_dcf3d60a8f0b4c018f9ed227b6abd8a1~mv2.png/v1/fill/w_400,h_288,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/Elements%20_Car%20illustration%201.png')
            : AssetImage('assets/img/no-image.png'),
        fit: BoxFit.contain,
        fadeInDuration: Duration(milliseconds: 250),
        placeholder: AssetImage('assets/img/no-image.png'),
      ),
    );
  }

  
  void refresh() {
    setState(() {});
  }
}
