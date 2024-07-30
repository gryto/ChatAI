import 'package:flutter/material.dart';

import 'constant.dart';

loaderDialog(BuildContext context) {
  return Center(
    child: Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
        ),
        const CircularProgressIndicator(
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(clrPrimary),
        ),
      ],
    ),
  );
}