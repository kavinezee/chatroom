import 'package:flash_message/components/rounded_buttons.dart';
import 'package:flash_message/constants.dart';
import 'package:flash_message/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flash_message/keep_user.dart';

class LoginScreen extends StatefulWidget {
  static const String id = '/login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GetStorage storage = GetStorage();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  // late String email;
  // late String password;
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    authController.email = value;
                  },
                  decoration: kTextFeildDecaration.copyWith(labelText: 'Email'),
                ),
                SizedBox(
                  height: 12.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    authController.password = value;
                  },
                  decoration:
                      kTextFeildDecaration.copyWith(labelText: 'Password'),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                    colour: Colors.lightBlueAccent,
                    title: 'Log In',
                    onPressed: () async {
                      authController.signIn(
                          authController.email, authController.password);

                      // final UserCredential user =
                      //     await _auth.signInWithEmailAndPassword(
                      //   email: email,
                      //   password: password,
                      // );
                      // // Save authentication state locally
                      // box.write('user', true);
                      // if (user != false) {
                      //   Get.toNamed(ChatScreen.id);
                      // }
                    }),
                SizedBox(
                  height: 24.0,
                ),
                TextButton(
                    onPressed: () {
                      const Text('To Register');
                      Get.toNamed(RegistrationScreen.id);
                    },
                    child: const Icon(
                      Icons.logout,
                      color: Colors.black,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
