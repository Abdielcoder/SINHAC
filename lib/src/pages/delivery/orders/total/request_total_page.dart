import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lavador/src/pages/delivery/orders/total/request_total_controller.dart';
import 'package:lottie/lottie.dart';


import '../../../../models/order.dart';
import '../../../../models/product.dart';
import '../../../../models/response_api.dart';
import '../../../../models/user.dart';
import '../../../../provider/orders_provider.dart';

import '../../../../utils/my_colors.dart';
import '../../../../utils/my_snackbar.dart';
import '../../../../utils/shared_pref.dart';
import '../list/delivery_orders_list_page.dart';



const blue = Color(0xFF4781ff);
const kTitleStyle = TextStyle(
    fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold);
const kSubtitleStyle = TextStyle(fontSize: 18, color:  Colors.white);


class RequestTotalPage extends StatefulWidget {
  const RequestTotalPage({Key key}) : super(key: key);
  @override
  _RequestTotalPageState createState() => _RequestTotalPageState();
}

class _RequestTotalPageState extends State<RequestTotalPage> {
  List<Product> selectedProducts = [];
  SharedPref _sharedPref = new SharedPref();
  PageController pageController = new PageController(initialPage: 0);
  RequestTotalOntroller _con = new RequestTotalOntroller();
  OrdersProvider _ordersProvider = new OrdersProvider();
  User user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ExactAssetImage("assets/img/buscando.jpg"),
                fit: BoxFit.cover,
              ),
            ),
             child: ClipRRect( // make sure we apply clip it properly
             child: BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 30, sigmaY: 10),

            child: PageView(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Slide(
                      hero: Lottie.asset(
                          'assets/json/money.json',
                          fit: BoxFit.fill
                      ),
                      title: "Ganancias hasta el momento",
                      subtitle:
                      "Servicios: 7 Total  840.00",
                      onNext: nextPage,
                      cancel: cancelServices),

                ])),
      ),
    )
      ),
    );
  }

  void nextPage() {

  }

  void goToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

  }
  void refresh() {
    setState(() {}); // CTRL + S
  }

  void cancelServices() async {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const DeliveryOrdersListPage()),
      ModalRoute.withName('delivery/orders/list',),
    );
  }


}



class Slide extends StatelessWidget {
  final Widget hero;
  final String title;
  final String subtitle;
  final VoidCallback onNext;
  final VoidCallback cancel;

  const Slide({Key key, this.hero, this.title, this.subtitle, this.onNext, this.cancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: hero),
          Padding(
            padding: const EdgeInsets.all(1),
            child: Column(
              children: [
                Text(
                  title,
                  style: kTitleStyle,

                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  subtitle,
                  style: kSubtitleStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                ProgressButton(cancel: cancel),
              ],
            ),
          ),
          GestureDetector(
            onTap: ()=>cancel(),
            child: Text(
              "Regresar",
              style: kSubtitleStyle,
            ),
          ),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}

class ProgressButton extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback cancel;
  const ProgressButton({Key key, this.onNext,this.cancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(children: [
        Container(
          height: 500,
          width: 500,
          child: Lottie.asset(
            'assets/json/pulse.json',
            width: 500,
            height: 500,
          ),
        ),

        Center(
          child: GestureDetector(

            child: Container(
              height: 60,
              width: 60,

              child: Center(

                child: Image.asset(
                  "./assets/images/backarrow.png",
                  width: 600,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Colors.deepPurpleAccent,
                boxShadow: [
                  BoxShadow(color: Colors.white, spreadRadius: 3),
                ],
              ),

            ),
            onTap: ()=>cancel(),
          ),

        ),

      ]),
    );
  }




}