import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:lavador/src/utils/my_colors.dart';
import '../../models/response_api.dart';
import '../../models/user.dart';
import '../../provider/push_notifications_provider.dart';
import '../../provider/users_provider.dart';
import '../../utils/my_snackbar.dart';
import '../../utils/shared_pref.dart';
import 'loggin_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email'
  ]
);

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount _currentUser;
  PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();
  UsersProvider usersProvider = new UsersProvider();
  ProgressDialog _progressDialog;
  LoginController _con = new LoginController();
  SharedPref _sharedPref = new SharedPref();
  //GENERETED ALEATORI ID SESSION.

  void initState() {
    int automaticId = DateTime.now().millisecondsSinceEpoch;
    String automaticIdString = automaticId.toString();
    print("session id : ${automaticIdString}");
    usersProvider.init(context);
    _progressDialog = ProgressDialog();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      try {
        setState(() {
          _currentUser = account;
          print("User Name ${_currentUser.displayName}");
          print("User Email ${_currentUser.email}");
          print("User ID ${_currentUser.id}");
          print("User PhotoUrl ${_currentUser.photoUrl}");
          //INITIAL DATA FROM SOCIAL LOGIN
          var userJson = {
            'id':_currentUser.id,
            'name': _currentUser.displayName,
            'lastname':_currentUser.displayName,
            'email': _currentUser.email,
            'phone': '',
            'password': 'null',
            'session_token': 'JWT ${automaticIdString}',
            // 'notificationToken':'',
            'image':_currentUser.photoUrl,

          };

          //SAVE TO SHARED PREFERENCES

          //INSERT INTO DB POSTGRESS
          //HERE RESPONSE 2 WAYS..
          //1. INSERT SOCIAL USER
          //2. DONT INSERT AND RETURN MESSAGE ERROR DUPLICATE ENTRY
          InsertaGoogleBD(_currentUser.email,_currentUser.displayName,_currentUser.displayName,'000','null',_currentUser.photoUrl);
          //SAVE TOKEN TO DB

        });
      } catch (e, s) {
        print(s);
      }

      //READ USER FROM DB
      readDataFromUserDb(_currentUser.email,'null');
      //VALIATED SOCIAL LOGIN

    });

    _googleSignIn.signInSilently();
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });

  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount userGoogle = _currentUser;
    return Scaffold(
        body: Container(
          width: double.infinity,
          child: Stack(
            children: [
              // Positioned(
              //     top: -80,
              //     left: -100,
              //     child: _circleLogin()
              // ),
              // Positioned(
              //   child: _textLogin(),
              //   top: 60,
              //   left: 25,
              // ),
              SingleChildScrollView(
                child: Column(
                  children: [
                     _imageBanner(),
                     _lottieAnimation(),
                    _textFieldEmail(),
                    _textFieldPassword(),
                    _buttonLogin(),
                    _textDontHaveAccount()
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _lottieAnimation() {
    return Container(
      margin: EdgeInsets.only(
          top: 1,
          bottom: MediaQuery.of(context).size.height * 0.03
      ),
      child: Lottie.asset(
          'assets/json/lavador2.json',
          width: 270,
          height: 200,
          fit: BoxFit.fill
      ),
    );
  }

  Widget _textLogin() {
    return Text(
      'LOGIN',
      style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          fontFamily: 'NimbusSans'
      ),
    );
  }



  Widget _textDontHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?',
          style: TextStyle(
              color: MyColors.primaryColor,
              fontSize: 17
          ),
        ),
        SizedBox(width: 7),
        GestureDetector(
          onTap: _con.goToRegisterPage,
          child: Text(
            'Registrate',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: MyColors.primaryColor,
                fontSize: 17
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonLogin() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: ElevatedButton(
        onPressed: _con.login,
        child: Text('INGRESA'),
        style: ElevatedButton.styleFrom(
            primary: MyColors.primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            padding: EdgeInsets.symmetric(vertical: 15)
        ),
      ),
    );
  }


  Widget _buttonLoginGoogle() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: loginGoogle,
        icon: Image.asset( // <-- Icon
          'assets/img/google_logo_64x.png',
        ),
        label: Text('INGRESA'), //
        style: ElevatedButton.styleFrom(
            primary: MyColors.colorGoogle,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            padding: EdgeInsets.symmetric(vertical: 7)
        ),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      decoration: BoxDecoration(
          color: MyColors.primaryOpacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        controller: _con.passwordController,
        obscureText: true,
        decoration: InputDecoration(
            hintText: 'Contraseña',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            prefixIcon: Icon(
              Icons.lock,
              color: MyColors.primaryColor,
            )
        ),
      ),
    );
  }

  Widget _textFieldEmail() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      decoration: BoxDecoration(
          color: MyColors.primaryOpacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        controller: _con.emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'Correo electronico',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            prefixIcon: Icon(
              Icons.email,
              color: MyColors.primaryColor,
            )
        ),
      ),
    );
  }

  Widget _circleLogin() {
    return Container(
      width: 240,
      height: 230,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: MyColors.primaryColor
      ),
    );
  }

  Widget _imageBanner() {
    return Container(
      margin: EdgeInsets.only(
          top: 150,
          bottom: MediaQuery.of(context).size.height * 0.02
      ),
      child: Image.asset(
        'assets/img/voitu_alfa.png',
        width: 300,
        height: 100,
      ),
    );
  }

  Future<void> loginGoogle()async{
    try{
      await _googleSignIn.signIn();

    }catch(e){
      print('Error en sesion con Google : $e');
    }
  }

  //INSERT USER WHEN USER IS SOCIAL LOGIN
   InsertaGoogleBD(email,name,lastname,phone,password,imageFile)async {
     print("InsertaGoogleBD :1");
     User user = new User(
         email: email,
         name: name,
         lastname: lastname,
         phone: phone,
         password: password,
     );

     await usersProvider.create(user);

   }

   //READ DE NEW USER AFTER INSERT USER FROM  SOCIAL
   readDataFromUserDb(email,pass)async{
     ResponseApi responseApi = await usersProvider.login(email, pass);
     MySnackbar.show(context, responseApi.message);
     //
     // print('Respuesta object: ${responseApi}');
     // print('Respuesta: ${responseApi.toJson()}');
     print("READ DATA :1");
     if (responseApi.success) {
       //OBJECT TO SAVE A READ USER
       User user = User.fromJson(responseApi.data);

       _sharedPref.save('user', user);
       print("READ DATA :2");
       pushNotificationsProvider.saveToken(user,context);
       print('USUARIO LOGEADO SOCIAL MEDIA ###: ${user.toJson()}');
       if (_currentUser != null) {
         // User user = User.fromJson(userJson);
         print("READ DATA :0.0");
         // var socialData = SocialData(
         //     _currentUser.displayName, "", _currentUser.email, LoginType.GOOGLE);
         // _startHomeScreen(socialData);
         Navigator.pushNamedAndRemoveUntil(
             context, 'client/products/list', (route) => false);

       } else {
         print("READ DATA :0.0.1");
         // _showError('Error, Please try again later');
       }
     }
     else {
       print("READ DATA :3");
       MySnackbar.show(context, responseApi.message);
     }
   }
}