import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../launcher/launcher.dart';
import 'constant.dart';
import 'preference.dart';

logoutDialog(BuildContext context) {
  SharedPref sharedPref = SharedPref();

  Future<void> _deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      print('File deleted: $filePath');
    } else {
      print('File not found: $filePath');
    }
  }

  Future<String> _getDownloadDirectoryPath() async {
    Directory? directory;
    try {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      print("Error getting download directory: $err");
      throw Exception("Unable to get the downloads directory");
    }
    return directory!.path;
  }

  Future<String> _getSharedFilePath() async {
    final directory = await _getDownloadDirectoryPath();
    return '$directory/.shared_token';
  }

  Future<String> _getSharedFilePathId() async {
    final directory = await _getDownloadDirectoryPath();
    return '$directory/.shared_id';
  }

  Widget cancelButton = DialogButton(
    color: clrPrimary,
    child: const Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Text(
        "Tidak",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop(false);
    },
  );

  Widget continueButton = DialogButton(
    padding: const EdgeInsets.only(right: 10, left: 10),
    color: clrBackground,
    child: const Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        "Ya",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    onPressed: () async {
      sharedPref.dropPref("id");
      sharedPref.dropPref("access_token");
      try {
        String sharedTokenFilePath = await _getSharedFilePath();
        String sharedIdFilePath = await _getSharedFilePathId();
        await _deleteFile(sharedTokenFilePath);
        await _deleteFile(sharedIdFilePath);

        print('Shared token and ID files deleted');
      } catch (e) {
        print('Error deleting shared files: $e');
      }

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LauncherPage(
              token: '',
            ),
          ),
          (Route<dynamic> route) => false);
    },
  );

  AlertDialog alert = AlertDialog(
    surfaceTintColor: Colors.white,
    backgroundColor: Colors.white,
    title: const Text(
      "Konfirmasi",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: clrPrimary,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    content: const Text("Apakah anda yakin akan keluar ?"),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancelButton,
          continueButton,
        ],
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
