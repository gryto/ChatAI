import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'constant.dart';

onBasicAlertPressed(context, text, desc) {
  var alertStyle = AlertStyle(
    backgroundColor: Colors.white,
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleTextAlign: TextAlign.left,
    descStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    descTextAlign: TextAlign.left,
    animationDuration: const Duration(milliseconds: 300),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: const BorderSide(
        color: Colors.grey,
      ),
    ),
  );

  Alert(
    context: context,
    style: alertStyle,
    title: text,
    desc: desc,
    buttons: [
      DialogButton(
        onPressed: () => Navigator.pop(context),
        color: clrPrimary,
        radius: BorderRadius.circular(10.0),
        child: const Text(
          "TUTUP",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    ],
  ).show();
}
