import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:lavador/src/provider/users_provider.dart';

import '../models/user.dart';

class PushNotificationsProvider {



  AndroidNotificationChannel pushnotificationapp;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;



  void initPushNotifications() async {


    pushnotificationapp = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(pushnotificationapp);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void onMessageListener() async {

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      print('NUEVA NOTIFICACION EN PRIMER PLANO');

      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                pushnotificationapp.id,
                pushnotificationapp.name,
                pushnotificationapp.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');

    });

  }

  void saveToken(User user, BuildContext context) async {
    String token = await FirebaseMessaging.instance.getToken();
    print('tok3ns save : ${token}');
    UsersProvider usersProvider = new UsersProvider();
    usersProvider.init(context,sessionUser: user);
    usersProvider.updateNotificationToken(user.id, token);
  }

  Future<void> sendMessage(String to, Map<String, dynamic> data, String title, String body) async {
    print('Entre al envio de la notifiacion.');
    Uri url = Uri.http('fcm.googleapis.com', '/fcm/send');

    await http.post(
        url,
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAbPaV4hs:APA91bH8q0XP07xJ2esPmubb2SqUhd4RQGCiI0emPSMCSbFXF0G3hJ9BJWumYY22BOGJTFknLQA0O5Y_D0wUhbOVtqnMewqVWIyfEKArBbAyVTTM4oufF2QLGD5MBFTQvIVUocn9zebQ'
        },
        body: jsonEncode(
            <String, dynamic> {
              'notification': <String, dynamic> {
                'body': body,
                'title': title,
              },
              'priority': 'high',
              'ttl': '4500s',
              'data': data,
              'to': to
            }
        )
    );
  }

  Future<void> sendMessageMultiple(List<String> toList, Map<String, dynamic> data, String title, String body) async {

    Uri url = Uri.http('fcm.googleapis.com', '/fcm/send');

    await http.post(
        url,
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAbPaV4hs:APA91bH8q0XP07xJ2esPmubb2SqUhd4RQGCiI0emPSMCSbFXF0G3hJ9BJWumYY22BOGJTFknLQA0O5Y_D0wUhbOVtqnMewqVWIyfEKArBbAyVTTM4oufF2QLGD5MBFTQvIVUocn9zebQ'
        },
        body: jsonEncode(
            <String, dynamic> {
              'notification': <String, dynamic> {
                'body': body,
                'title': title,
              },
              'priority': 'high',
              'ttl': '4500s',
              'data': data,
              'registration_ids': toList
            }
        )
    );
  }


}