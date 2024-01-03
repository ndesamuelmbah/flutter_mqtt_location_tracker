import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showErrorToast(String message) {
  Fluttertoast.showToast(
      backgroundColor: Colors.pink,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      msg: message);
}

void showSuccessToast(String message) {
  Fluttertoast.showToast(
      backgroundColor: Colors.black,
      toastLength: Toast.LENGTH_LONG,
      msg: message);
}
