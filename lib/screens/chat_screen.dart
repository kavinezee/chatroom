import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flash_message/constants.dart';
import 'package:flash_message/main.dart';
import 'package:flash_message/main.dart';
import 'package:flash_message/screens/firbase_api.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flash_message/keep_user.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:system_alert_window/system_alert_window.dart';

final _firestore = FirebaseFirestore.instance;
final FirebaseMessaging _messaging = FirebaseMessaging.instance;
String? fcmToken;
User? loggedInUser;
final box = GetStorage();

class ChatScreen extends StatefulWidget {
  static const String id = '/chat_Screen';
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  AuthController authController = AuthController();

  bool isShowingWindow = false;
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
  static const String _mainAppPort = 'MainApp';
  final _receivePort = ReceivePort();
  SendPort? homePort;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    getCurrentUser();
    getFirebaseMessagingToken();

    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _mainAppPort,
    );
    log("$res: OVERLAY");
    _receivePort.listen((message) {
      log("message from OVERLAY: $message");
    });
  }

  //  @override
  // void dispose() {
  //   SystemAlertWindow.removeOnClickListener();
  //   super.dispose();
  // }

// request to Display over other apps
  Future<void> requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }

  // void showOverlayWindow() async {
  //   if (!isShowingWindow) {
  //     await SystemAlertWindow.sendMessageToOverlay('show system window');
  //     SystemAlertWindow.showSystemWindow(
  //       height: 200,
  //       width: MediaQuery.of(context).size.width.floor(),
  //       gravity: SystemWindowGravity.CENTER,
  //       prefMode: prefMode,
  //     );
  //     setState(() {
  //       isShowingWindow = true;
  //     });
  //   } else {
  //     setState(() {
  //       isShowingWindow = false;
  //     });
  //     SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
  //   }
  // }

  Future<void> getFirebaseMessagingToken() async {
    try {
      fcmToken = await _messaging.getToken();
      log("FirebaseMessagingToken  $fcmToken");
    } catch (e) {
      log('fcm error $e');
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        //print(user);
      }
    } catch (e) {
      log('ERRORUh $e');
    }
  }

// diaplay user
  void showUsersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<QuerySnapshot>(
          future: _firestore.collection('User').get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            print("$_firestore.collection('User')");
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return SimpleDialog(
              title: Text(
                '${loggedInUser?.email}',
                textAlign: TextAlign.center,
              ),
              //children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // final documentData = document.data() as Map<dynamic, dynamic>?;
              // return SimpleDialogOption(
              //   child: Text(documentData?["$loggedInUser"] ?? 'not found'),
              //   onPressed: () {
              //     //showUsersDialog;
              //   },

              //   ///=> Navigator.pop(context, document.data()),
              // );
              //}
              // ).toList(),
            );
          },
        );
      },
    );
  }
  // void getmessage() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data);
  //   }
  // }

  // void messageStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshot()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data);
  //     }
  //   }
  // }

//   *send message and notification

  void sendMessage() async {
    //FirebaseMessaging _messaging = FirebaseMessaging.instance;
    final notificationSettings = await _messaging.requestPermission();
    log('User granted permission: ${notificationSettings.authorizationStatus}');
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      FirebaseMessaging.instance.subscribeToTopic('allUsers');
    }
    if (messageTextController.text.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': messageTextController.text,
        'sender': loggedInUser?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    messageTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
              //showOverlayWindow();
              },
              icon: const Icon(Icons.door_back_door)),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  showUsersDialog();
                },
                icon: const Icon(Icons.groups_3_outlined)),
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  authController.signOut();
                  // _auth.signOut();
                  // box.remove('user');
                  // Get.back();
                  //Implement logout functionality
                }),
          ],
          title: const Text('⚡️Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const MessageStream(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Container(
                  decoration: kMessageContainerDecoration,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: messageTextController,
                          onChanged: (value) {
                            messageTextController.text = value;
                          },
                          decoration: kMessageTextFieldDecoration,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          sendMessage();
                          FirebaseApi.sendPushNotification(
                            title: '${loggedInUser?.email}',
                            msg: messageTextController.text,
                          );
                          log('msg receive 1 from send msg');
                        },
                        child: const Text(
                          'Send',
                          style: kSendButtonTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Text('loading.. !!!');
          //return const Text(' error.. !!');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        //final messages = snapshot.data!.data().reversed.toList();

        // List<MessageBubble> messageBubbles = [];
        // for (var message in messages) {
        //   final messageText = message.data?['text'] ?? 'No data';
        //   final messageSender = message['sender'];
        //   final messageBubble = MessageBubble(
        //     sender: messageSender,
        //     text: messageText,
        //   );
        //   //  Text('$messageText from $messageSender');
        //   messageBubbles.add(messageBubble);
        // }
        // return Expanded(
        //   child: ListView(
        //     padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        //     //reverse: true,
        //     children: messageBubbles,
        //   ),
        // );

        final messages = snapshot.data!.docs.reversed.toList();
        return Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index].data() as Map<String, dynamic>;
              final currentUser = loggedInUser?.email;
              Timestamp timeStamp =
                  messages[index].data()['timestamp'] ?? Timestamp.now();
              return MessageBubble(
                sender: message['sender'],
                text: message['text'],
                isMe: currentUser == message['sender'],
                timeStamp: timeStamp,
              );
            },
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.sender,
    required this.isMe,
    required this.timeStamp,
  });
  final String text;
  final String sender;
  final bool isMe;
  final Timestamp timeStamp;

  @override
  Widget build(BuildContext context) {
    DateTime messageDateTime = timeStamp.toDate();
    // String temp = messageDateTime.toString();
    String formattedTime = DateFormat.Hm().format(messageDateTime);
    //final String formattedTime = DateTime.timestamp().hour.minutes.toString();
    //DateTime.now().millisecondsSinceEpoch.toString()
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          //sender
          Text(
            sender,
            style: const TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          //time
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 8.0, color: Colors.black54),
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.purpleAccent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              //message
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
