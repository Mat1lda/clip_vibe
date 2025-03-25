import 'package:clip_vibe/databases/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../views/pages/auth/auth_screen.dart';
import '../../views/pages/auth/login_screen.dart';
import '../../views/pages/home/home_screen.dart';
import '../../views/widgets/snack_bar.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

  static loginFetch({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final storage = FlutterSecureStorage();
      String? uID = userCredential.user?.uid;

      if (uID != null) {
        try {
          await storage.write(key: 'uID', value: uID);
        } catch (e) {
          print("Error saving uID: $e");
        }
      }

      FocusScope.of(context).unfocus();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
      );

      getSnackBar('Login', 'Login Success.', Colors.green).show(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        getSnackBar('Login', 'No user found for that email.', Colors.red).show(context);
      } else if (e.code == 'wrong-password') {
        getSnackBar('Login', 'Wrong password provided for that user.', Colors.red).show(context);
      } else {
        getSnackBar('Error', 'An unexpected error occurred: ${e.message}', Colors.red).show(context);
      }
    }
  }

  static Logout({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();
      final storage = FlutterSecureStorage();
      await storage.deleteAll();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
      );
      getSnackBar('Logout', 'Logout Success.', Colors.green).show(context);
    } catch (e) {
      getSnackBar('Error', 'An unexpected error occurred.', Colors.red).show(context);
    }
  }

  static registerFetch({
    required BuildContext context,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await UserService.addUser(
        UID: userCredential.user?.uid,
        fullName: fullName,
        email: email,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );

      getSnackBar('Register', 'Register Success.', Colors.green).show(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        getSnackBar('Register', 'The password provided is too weak.', Colors.red).show(context);
      } else if (e.code == 'email-already-in-use') {
        getSnackBar('Register', 'The account already exists for that email.', Colors.red).show(context);
      } else {
        getSnackBar('Error', 'An unexpected error occurred: ${e.message}', Colors.red).show(context);
      }
    } catch (e) {
      print(e);
    }
  }
}
