import 'package:flash_message/screens/chat_screen.dart';
import 'package:flash_message/screens/login_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  bool showSpinner = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();

  late String password;
  late String email;

  // Future<bool> checkLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final bool userLoggedIn = prefs.getString('User') != null;
  //   return userLoggedIn;
  // }

  Future<bool> checkLogin() async {
    final bool isLoggedIn = box.read('currentUser') != null;
    return isLoggedIn;
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      final UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Save authentication state locally
      box.write('currentUser', true);
      if (user != null) {
        Get.toNamed(ChatScreen.id);
      }
    } catch (e) {
      print('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // Clear authentication state locally
    box.remove('currentUser');
    Get.toNamed(LoginScreen.id);
  }
}
