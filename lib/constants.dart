import 'package:flutter/material.dart';

class Constants {
  static const int MATCH_PARENT = -1;
  static const int WRAP_CONTENT = -2;

  static const String CHANNEL = "in.jvapps.system_alert_window";
  static const String BACKGROUND_CHANNEL =
      "in.jvapps.system_alert_window/background";
  static const String MESSAGE_CHANNEL =
      "in.jvapps.system_alert_window/message";
}


const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  labelText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFeildDecaration = InputDecoration(
  labelText: 'Enter a Value',
  contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kTextpasswordrule = TextStyle(
    fontSize: 10.0,
    color: Colors.grey); //Password must be at least 6 characters long