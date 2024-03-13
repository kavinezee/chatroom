import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:system_alert_window/system_alert_window.dart';

class DialogNotify extends StatefulWidget {
  const DialogNotify({super.key});

  @override
  State<DialogNotify> createState() => _DialogNotifyState();
}

class _DialogNotifyState extends State<DialogNotify> {
  bool update = false;
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
  @override
  void initState() {
    super.initState();
    SystemAlertWindow.overlayListener.listen((event) {
      log("$event in overlay");
      if (event is bool) {
        setState(() {
          update = event;
        });
      }
    });
  }

  Widget overlay() {
    return Container(
      color: Colors.lightBlueAccent.shade100,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('New Message',
              style: TextStyle(fontSize: 18, color: Colors.black45)),
          Text(
            'msg from friend',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
            },
            child: Text(
              ' close ',
              style: TextStyle(backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: overlay(),
    );
  }
}
