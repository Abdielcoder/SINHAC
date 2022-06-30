import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoDataWidget extends StatelessWidget {

  String text;

  NoDataWidget({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage("assets/img/encamino.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect( // make sure we apply clip it properly
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),

          child: Lottie.asset(
              'assets/json/wait2.json',
              fit: BoxFit.fill
          ),
        ),
      ),
    );
  }
}

