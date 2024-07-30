import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

toastShort(BuildContext context, txt) {
  Fluttertoast.showToast(
      msg: txt, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
}
