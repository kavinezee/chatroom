import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_message/dialog/dialogwindow.dart';
import 'package:flash_message/screens/chat_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:system_alert_window/system_alert_window.dart';

//final FirebaseMessaging _messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
//SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;

class FirebaseApi {
  static const serverToken =
      'AAAAXlLFMmM:APA91bE04CyC0VtBjGP-QCVP65Viqe8CGnJYv33IDKHfikkRlfRdCX0U7lSRKbft21-c_uUC_pmTssidbTxn8YcTsetLo-kFfcnX0QZJTFvDP-Im7L_a5No8YgueelhzhHVtSzmiul9A';
  static const kphoneToken =
      'druRwo4XRnSGwMzkmfYYNs:APA91bGZBhXLyfhto4o2iTyEXPKTmjdoo1WoNdCFk7WKUjWUoJmCPRvR-WlWNfvj_RXqGTSrCbZeyI3Z7VDBBeCHStLgVb7veZRpDOYfagsdxwxmpVxDzdqZOJGjZkl9y0HiAfwXRlMT';

  static const gphoneToken =
      'cRB8s9O9Rw-KrIzIy5RR8c:APA91bHxqcVm60C8s2ID5K2hwuXbxzwGMWJ2lBOoczxKK_FcMxUc5MIussx8XDS765Fj5tcuANTTLfod5rjLq505Fh_kZ5HXvkntpHvXRA8jPCSBUFAZwGTX4Rz9d4aUgn-2KTlhfG2Y';

  static Future initializeFlutterLocalNotificationsPlugin() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // for sending push notification
  static Future<void> sendPushNotification({
    required String title,
    required String msg,
  }) async {
    try {
      final body = {
        "to": kphoneToken,
        "notification": {
          'title': title, //our name should be send
          'body': msg,
          //'topic': 'allUser',
          //"android_channel_id": "messages"
        },
        'ttl': '86000s',
      };
      var res =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader: 'key=$serverToken'
              },
              body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
      // if (res.statusCode == 200) {
      // AndroidNotificationDetails androidPlatformChannelSpecifics =
      //     const AndroidNotificationDetails(
      //   'messages',
      //   'Messages',
      //   importance: Importance.max,
      //   priority: Priority.max,
      //   showWhen: true,
      // );
      // NotificationDetails platformChannelSpecifics =
      //     NotificationDetails(android: androidPlatformChannelSpecifics);
      // await flutterLocalNotificationsPlugin.show(
      //   0,
      //   title,
      //   msg,
      //   platformChannelSpecifics,
      //   payload: 'item x',
      // );
      // log('local noti showed');

      // Display system alert window popup
      // showMessagePopup(title, msg);
      // }
    } catch (e) {
      log('error  in show notify $e');
    }

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {}
    //   // Listen for incoming messages
  }
}

// void showMessagePopup(String title, String msg) {
//   if (const ChatScreen().createState().mounted) {
//     const ChatScreen().createState().showOverlayWindow();
//   } else {
//     log('not mounted');
//   }
// }
