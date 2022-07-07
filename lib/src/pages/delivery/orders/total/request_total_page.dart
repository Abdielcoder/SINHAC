import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lavador/src/pages/delivery/orders/total/request_total_controller.dart';
import 'package:lottie/lottie.dart';

import 'dart:convert' as convert;
import '../../../../models/order.dart';
import '../../../../models/product.dart';
import '../../../../models/response_api.dart';
import '../../../../models/total.dart';
import '../../../../models/user.dart';
import '../../../../provider/orders_provider.dart';
import 'package:http/http.dart' as http;
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
  String ventas;
  String totalVentas;
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });

    _llamaTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.80,
              child: _ngk()

          ),
          SafeArea(
            child: Column(
              children: [
                //  _buttonBack(),
                //_buttonCenterPosition(),

                Spacer(),
                _cardOrderInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ngk() {
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
                            title: "Tu balance del día",
                            subtitle:
                            "",
                            onNext: nextPage),
                      ])),
            ),
          )
      ),
    );
  }


  Widget _cardOrderInfo() {
    return Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.20,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3)
                  )
                ]
            ),
            child: Stack(
              children: [
                _clientInfo(),
                _listTileAddress(),
                Divider(color: Colors.grey[400], endIndent: 0, indent: 30,),

              ],
            ),

          )]);
  }




  Widget _clientInfo() {
    return Container(
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.03, top:  MediaQuery.of(context).size.height * 0.03),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            child: FadeInImage(
              image:
              NetworkImage("https://yt3.ggpht.com/itg6InC3mG_vz82zABL--M82TUZWN8tM2Nj5wNnzIxb3nB54PW5yXPCHf5f4aSNT4XZEAtr2=s900-c-k-c0x00ffffff-no-rj"),

              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/add_image.png'),
            ),
          ),
          Container(
            height: 50,
            width: 80,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _con.user?.name ,
                style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    fontSize: 20
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _listTileAddress() {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.0, left: MediaQuery.of(context).size.height * 0.2, top:  MediaQuery.of(context).size.height * 0),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.0, left: MediaQuery.of(context).size.height * 0.0, top:  MediaQuery.of(context).size.height * 0.06),
                child: Text(
                  'Sercivicios',
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.blue[900],
                      fontSize: 25
                  ),
                ),

              ),
              Container(
                margin: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0, left: MediaQuery.of(context).size.height * 0.0, top:  MediaQuery.of(context).size.height * 0.01),
                child: Text(
                  ventas ?? 'Actualizando....',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexendeca-Black',
                      fontSize: 30
                  ),
                ),


              ),
            ],

          ),
          Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.0, left: MediaQuery.of(context).size.height * 0.06, top:  MediaQuery.of(context).size.height * 0.06),
                child: Text(
                  'Total Servicios',
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.blue[900],
                      fontSize: 25
                  ),
                ),

              ),
              Container(
                margin: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0, left: MediaQuery.of(context).size.height * 0.06, top:  MediaQuery.of(context).size.height * 0.01),
                child: Text(
                  totalVentas ?? 'Actualizando....',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexendeca-Black',
                      fontSize: 30
                  ),
                ),


              ),
            ],

          ),
        ],
      ),
    );
  }

  Future<Widget> _llamaTotal()async{
    user = User.fromJson(await _sharedPref.read('user'));
    print('RESX : 1 ');
    getTotalServices(user.id);

  }


  Future<List<Total>> getTotalServices(String user) async {
    print('RESX : 2 ');
    var url = 'http://vossgps.com:3333/api/orders/deliveryEntregadoCount/$user';
    print(url);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(url));
    String statuscc = response.statusCode.toString();
    print('RESX : 4 $statuscc');
    if (response.statusCode == 201) {
      print('RESX : 3 ');
     var jsonResponse = convert.jsonDecode(response.body);
     // Map<List, dynamic> user = convert.jsonDecode(response.body);

      print('RESX 4 : $jsonResponse');
      ventas = jsonResponse[0]['ventas'];
      totalVentas = jsonResponse[0]['name'];
      print('RESX : $ventas');
      print('RESX : $ventas');
      setState(() {});
      //
      // if (sts != 'OK') {
      //   sts = 'Dont Updated';
      // } else {
      //   sts = 'Already updated';
      // }
      // var console = jsonResponse['CONSOLE'];
      // var strlen = scanws.length;
      // var operlen = strlen - 7;
      //
      // var stws = scanws.substring(0, 7);
      // var nuws = scanws.substring(8, strlen);
      // print('HYUYY ### $scanws');
      // print('HYUYY ### $sts');
      // print('HYUYY ### $console');

    }
  }

  void nextPage() {

  }

  void goToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

  }


  void refresh() {
    setState(() {}); // CTRL + S
  }



}

class Slide extends StatelessWidget {
  final Widget hero;
  final String title;
  final String subtitle;
  final VoidCallback onNext;

  const Slide({Key key, this.hero, this.title, this.subtitle, this.onNext})
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
                // ProgressButton(onNext: onNext),
              ],
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       new MaterialPageRoute(
          //         builder: (context) => new ClientMenuListPage(),
          //       ),
          //     );
          //   },
          //   child: Text(
          //     "Cancelar",
          //     style: kSubtitleStyle,
          //   ),
          // ),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}