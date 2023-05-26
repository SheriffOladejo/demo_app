import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:demo_app/utils/hex_color.dart';

Future<bool> checkConnection() async{
  var result = await (Connectivity().checkConnectivity());
  if(result == ConnectivityResult.none){
    return false;
  }
  else{
    return true;
  }
}

bool isValidEmail(String email){
  if(email.isEmpty) {
    return false;
  }
  bool email_valid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  return email_valid;
}

Widget loadingPage(){
  return const Center(
    child: CircularProgressIndicator(),
  );
}

Route slideLeft(Widget next) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => next,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Future showToast(String message){
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0
  );
}

OutlineInputBorder focusedBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: HexColor("#1541D7"),
    ),
    borderRadius: BorderRadius.circular(16),
  );
}

OutlineInputBorder disabledBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(
      color: Colors.grey,
    ),
    borderRadius: BorderRadius.circular(16),
  );
}

OutlineInputBorder errorBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(
      color: Colors.red,
    ),
    borderRadius: BorderRadius.circular(16),
  );
}

OutlineInputBorder enabledBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(
        color: Colors.black
    ),
    borderRadius: BorderRadius.circular(16),
  );
}
