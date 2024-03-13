import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_message/dialog/dialogwindow.dart';

import 'package:flash_message/screens/chat_screen.dart';
import 'package:flash_message/screens/firbase_api.dart';
import 'package:flash_message/screens/login_screen.dart';
import 'package:flash_message/screens/registration_screen.dart';
import 'package:flash_message/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //await FirebaseApi.initializeFlutterLocalNotificationsPlugin();
  await GetStorage.init();
  runApp(FlashChat());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  log('Handling a background message ${message.messageId}');
  showBackGroundOverlayWindow();
}

void showBackGroundOverlayWindow() {
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
  SystemAlertWindow.showSystemWindow(
      height: 200, width: 200, prefMode: prefMode);
  log('BG overlay');
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DialogNotify(),
    ),
  );
}

class FlashChat extends StatefulWidget {
  FlashChat({super.key});

  @override
  State<FlashChat> createState() => _FlashChatState();
}

class _FlashChatState extends State<FlashChat> {
  //final prefs = SharedPreferences.getInstance();
  final box = GetStorage();
  bool isShowingWindow = false;
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
  void showOverlayWindow() async {
    if (!isShowingWindow) {
      isShowingWindow = true;
      await SystemAlertWindow.sendMessageToOverlay('show system window');
      SystemAlertWindow.showSystemWindow(
        height: 200,
        width: MediaQuery.of(context).size.width.floor() - 15,
        gravity: SystemWindowGravity.CENTER,
        prefMode: prefMode,
      );
      log('system window shown');
    }
    // else {
    //   isShowingWindow = false;
    //   SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
    //   log('system window disabled');
    // }
  }

  getinitial() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        log('onMessage entered');
        showOverlayWindow();
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('onMessageOpenedApp entered');
      // Handle notification message when app is in background but opened by user
      showOverlayWindow();
    });

  //   // Fetch the initial message when the app is opened from a terminated state
  //   RemoteMessage? initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();
  //   if (initialMessage != null && initialMessage.notification != null) {
  //     log('App opened from terminated state with notification message');
  //     showOverlayWindow();
  //   }
   }

  @override
  void initState() {
    getinitial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final bool userLoggedIn = prefs.getString('currentUser') != null;
    final bool userLoggedIn = box.read('currentUser') != null;
    return GetMaterialApp(
      home: userLoggedIn ? ChatScreen() : WelcomeScreen(),
      getPages: [
        GetPage(name: WelcomeScreen.id, page: () => WelcomeScreen()),
        GetPage(name: RegistrationScreen.id, page: () => RegistrationScreen()),
        GetPage(name: LoginScreen.id, page: () => LoginScreen()),
        GetPage(name: ChatScreen.id, page: () => ChatScreen()),
        //GetPage(name: AlertWindowScreen.id, page: () => AlertWindowScreen()),
      ],
    );
  }
}
