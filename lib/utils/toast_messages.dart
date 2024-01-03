import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showErrorToast(String message, {bool webShowClose = false}) {
  Fluttertoast.showToast(
      backgroundColor: Colors.pink,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      webShowClose: webShowClose,
      msg: message);
}

void showSuccessToast(String message, {bool webShowClose = false}) {
  Fluttertoast.showToast(
      backgroundColor: Colors.black,
      toastLength: Toast.LENGTH_LONG,
      webShowClose: webShowClose,
      msg: message);
}
