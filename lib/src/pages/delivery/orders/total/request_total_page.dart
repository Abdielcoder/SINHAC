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
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.81,
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
                _listTileAddress("Prueba de tarjeta"),
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
                'Gustavo ordaz',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    fontSize: 12
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _listTileAddress(String title) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.0, left: MediaQuery.of(context).size.height * 0.0, top:  MediaQuery.of(context).size.height * 0.12),
          child: Text(
            'Lugar servicio ',
            style: TextStyle(
                fontFamily: 'Lexendeca-Black',
                color: Colors.blue[900],
                fontSize: 14
            ),
          ),

        ),
        Container(
          margin: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0, left: MediaQuery.of(context).size.height * 0.0, top:  MediaQuery.of(context).size.height * 0.01),
          child: Text(
            title ?? '',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Lexendeca-Regular',
                fontSize: 14
            ),
          ),


        ),
      ],
    );
  }

  void nextPage() {

  }

  void goToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

  }

  Widget _menuDrawer() {
    return GestureDetector(
      onTap: _con.openDrawer,
      child: Container(
        margin: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Image.asset('assets/img/menu.png', width: 20, height: 20),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                  color: MyColors.primaryColor
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.email ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.phone ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                    maxLines: 1,
                  ),
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 10),
                    child: FadeInImage(
                      image: _con.user?.image != null
                          ? NetworkImage(_con.user?.image)
                          : AssetImage('assets/img/no-image.png'),
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/img/no-image.png'),
                    ),
                  )

                ],
              )
          ),
          _con.user != null ?
          _con.user.roles.length > 1 ?
          ListTile(
            onTap: _con.goToRoles,
            title: Text('Seleccionar rol'),
            trailing: Icon(Icons.person_outline),
          ) : Container() : Container(),
          ListTile(
            onTap: _con.goInicio,
            title: Text('Inicio'),
            trailing: Icon(Icons.all_inbox),
          ),
          ListTile(
            onTap: _con.goEntregado,
            title: Text('Entregado'),
            trailing: Icon(Icons.check_circle),
          ),
          ListTile(
            onTap: _con.goCancelado,
            title: Text('Cancelado'),
            trailing: Icon(Icons.no_meeting_room_outlined),
          ),
          ListTile(
            onTap: _con.goGanancias,
            title: Text('Ganancias'),
            trailing: Icon(Icons.account_balance_wallet),

          ),
          ListTile(
            onTap: _con.logout,
            title: Text('Cerrar sesion'),
            trailing: Icon(Icons.power_settings_new),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }




// class ProgressButton extends StatelessWidget {
//   final VoidCallback onNext;
//   const ProgressButton({Key key, this.onNext}) : super(key: key);

// @override
// Widget build(BuildContext context) {
//   return SizedBox(
//     width: 140,
//     height: 140,
//     child: Stack(children: [
//       Container(
//         height: 500,
//         width: 500,
//         child: Lottie.asset(
//           'assets/json/pulse.json',
//           width: 500,
//           height: 500,
//         ),
//       ),
//
//       // Center(
//       //   child: GestureDetector(
//       //
//       //     child: Container(
//       //       height: 60,
//       //       width: 60,
//       //
//       //       child: Center(
//       //
//       //         child: Image.asset(
//       //           "./assets/images/cancelarlavador.png",
//       //           width: 600,
//       //         ),
//       //       ),
//       //       decoration: BoxDecoration(
//       //         borderRadius: BorderRadius.circular(99),
//       //         color: Colors.deepPurpleAccent,
//       //         boxShadow: [
//       //           BoxShadow(color: Colors.white, spreadRadius: 3),
//       //         ],
//       //       ),
//       //
//       //     ),
//       //     onTap: () {
//       //       Navigator.push(
//       //         context,
//       //         new MaterialPageRoute(
//       //           builder: (context) => new ClientMenuListPage(),
//       //         ),
//       //       );
//       //     },
//       //   ),
//       //
//       // ),
//
//     ]),
//   );
// }

//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: SafeArea(
//           child: Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: ExactAssetImage("assets/img/encamino.jpg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: ClipRRect( // make sure we apply clip it properly
//               child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 30, sigmaY: 10),
//
//                   child: PageView(
//                       controller: pageController,
//                       physics: NeverScrollableScrollPhysics(),
//                       children: [
//                         Container(
//                           child: Slide(
//                               hero: Lottie.asset(
//                                   'assets/json/limpiando.json',
//                                   fit: BoxFit.fill
//                               ),
//                               title: "Tú servicio esta en curso",
//                               subtitle:
//                               "En espera de terminar el servicio...",
//                               onNext: nextPage),
//                         ),
//                       ])),
//             ),
//           )
//       ),
//     );
//   }
//
//
//   void nextPage() {
//
//   }
//
//   void goToLogin() {
//     Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
//
//   }
//   void refresh() {
//     setState(() {}); // CTRL + S
//   }
// }
//
// class Slide extends StatelessWidget {
//   final Widget hero;
//   final String title;
//   final String subtitle;
//   final VoidCallback onNext;
//
//   const Slide({Key key, this.hero, this.title, this.subtitle, this.onNext})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//               Expanded(child: hero),
//           Padding(
//             padding: const EdgeInsets.all(1),
//             child: Column(
//               children: [
//                 Text(
//                   title,
//                   style: kTitleStyle,
//
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   subtitle,
//                   style: kSubtitleStyle,
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 ProgressButton(onNext: onNext),
//               ],
//             ),
//           ),
//           // GestureDetector(
//           //   onTap: () {
//           //     Navigator.push(
//           //       context,
//           //       new MaterialPageRoute(
//           //         builder: (context) => new ClientMenuListPage(),
//           //       ),
//           //     );
//           //   },
//           //   child: Text(
//           //     "Cancelar",
//           //     style: kSubtitleStyle,
//           //   ),
//           // ),
//           SizedBox(
//             height: 50,
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class ProgressButton extends StatelessWidget {
//   final VoidCallback onNext;
//   const ProgressButton({Key key, this.onNext}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 140,
//       height: 140,
//       child: Stack(children: [
//         Container(
//           height: 500,
//           width: 500,
//           child: Lottie.asset(
//             'assets/json/pulse.json',
//             width: 500,
//             height: 500,
//           ),
//         ),
//
//         // Center(
//         //   child: GestureDetector(
//         //
//         //     child: Container(
//         //       height: 60,
//         //       width: 60,
//         //
//         //       child: Center(
//         //
//         //         child: Image.asset(
//         //           "./assets/images/cancelarlavador.png",
//         //           width: 600,
//         //         ),
//         //       ),
//         //       decoration: BoxDecoration(
//         //         borderRadius: BorderRadius.circular(99),
//         //         color: Colors.deepPurpleAccent,
//         //         boxShadow: [
//         //           BoxShadow(color: Colors.white, spreadRadius: 3),
//         //         ],
//         //       ),
//         //
//         //     ),
//         //     onTap: () {
//         //       Navigator.push(
//         //         context,
//         //         new MaterialPageRoute(
//         //           builder: (context) => new ClientMenuListPage(),
//         //         ),
//         //       );
//         //     },
//         //   ),
//         //
//         // ),
//
//       ]),
//     );
//   }

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