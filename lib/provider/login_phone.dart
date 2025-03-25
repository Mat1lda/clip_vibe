import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../views/pages/auth/register_phone_screen.dart';
import '../views/pages/home/home_screen.dart';

class LoginPhoneProvider extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController textEditingController = TextEditingController();
  bool isTextFieldEmpty = true;
  bool isErrorText = false;
  bool isErrorSms = false;
  String country = '+84';
  String codeVerify = '';
  String smsCode = '';
  bool resend = false;

  void onTextFieldChanged() {
    isTextFieldEmpty = textEditingController.text.isEmpty;
    notifyListeners();
  }

  void onTextFieldError() {
    isErrorText = !isErrorText;
    notifyListeners();
  }

  void selectedCountry(String newValue) {
    country = newValue;
    notifyListeners();
  }

  void inputCode(String newValue) {
    smsCode = newValue;
    notifyListeners();
  }

  void Resend(bool value) {
    resend = value;
    notifyListeners();
  }
  void smsError(bool value){
    isErrorSms = value;
    notifyListeners();
  }

  Future<void> onSubmitPhone(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$country ${textEditingController.text}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          print('${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          codeVerify = verificationId;
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => VerifyOTP()));
        },
        codeAutoRetrievalTimeout: (String verificationId) {});

  }

  Future<void> verify(BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: codeVerify,
        smsCode: smsCode,
      );
      UserCredential userCredential = await auth.signInWithCredential(credential);
      String? uid = userCredential.user?.uid;
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (snapshot.exists) {
          textEditingController.text = '';
          final storage = FlutterSecureStorage();
          await storage.write(key: 'uID', value: uid);
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }else{
          textEditingController.text = '';
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPhoneScreen(uid: uid)));
        }
      } catch (error) {
        print('Kiểm tra người dùng không thành công: $error');
      }
    } catch (e) {
      smsError(true);
      print('Lỗi xác minh số điện thoại: $e');
    }
  }
}