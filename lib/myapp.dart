import 'package:flutter/material.dart';
import 'launcher/launcher.dart';

class MyApp extends StatelessWidget {
  final String tkn;
  const MyApp({Key? key, 
  required this.tkn
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHAT HELPER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      routes: {
        '/': (context) => LauncherPage( token: tkn),
      },
    );
  }
}
