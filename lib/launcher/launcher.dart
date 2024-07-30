import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import '../src/api.dart';
import '../src/constant.dart';
import '../src/preference.dart';
import '../login/login.dart';
import '../src/utils.dart';

class LauncherPage extends StatefulWidget {
  final String token;
  const LauncherPage({Key? key, required this.token}) : super(key: key);

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  SharedPref sharedPref = SharedPref();
  String url = ApiService.detailUser;
  String message = "";
  bool isLogged = false;
  bool bacaToken = false;
  String readToken = "";
  String? token = '';
  String? id = '';

  @override
  void initState() {
    requestPermissions();

    super.initState();
  }

  startLaunching() async {
    var duration = const Duration(seconds: 2);
    // requestPermissions();
    return Timer(duration, checkSession);
  }

  void checkSession() async {
    try {
      var userId = await sharedPref.getPref("id_usr");
      print("userid: $userId");
      await getDetailUser(userId);

      if (isLogged == true) {
        goToApp(userId);
      } else {
        if (token != null && id != null) {
          goToApp(userId);
        } else {
          goToLogin();
        }
      }
    } catch (e) {
      goToLogin();
    }
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      if (await Permission.storage.request().isGranted) {
        print('Storage permission granted');
      } else {
        print('Storage permission denied');
      }
    }

    var manageStatus = await Permission.manageExternalStorage.status;
    if (!manageStatus.isGranted) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        print('Manage External Storage permission granted');
      } else {
        _showSettingsDialog();
        print('Manage External Storage permission denied');
      }
    }
    readFile();
  }

  void _showSettingsDialog() async {
    var manageStatus = await Permission.manageExternalStorage.status;

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Diperlukan'),
        content: const Text(
            'Aplikasi ini memerlukan izin penyimpanan agar berfungsi dengan baik. Harap berikan izin di pengaturan sistem.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (!manageStatus.isGranted) {
                if (await Permission.manageExternalStorage
                    .request()
                    .isGranted) {
                  print('Manage External Storage permission granted');
                } else {
                  _showSettingsDialog();
                  print('Manage External Storage permission denied');
                }
              }
              readFile();
              // openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  void readFile() async {
    try {
      final directory = await _getDownloadDirectoryPath();
      final file = File('$directory/.shared_token');
      final fileId = File('$directory/.shared_id');
      if (await file.exists() && await fileId.exists()) {
        String contents = await file.readAsString();
        String contentsId = await fileId.readAsString();
        // var readToken = contents;
        // print(object)
        setState(() {
          readToken = contents.toString();
          print("tokerndrifile $readToken");
        });
        await sharedPref.setPref('access_token', contents);
        print("sgaredpref");
        print(sharedPref.setPref('id_usr', contentsId));
        _loadToken();
        // _saveToken(contents);
        // print("bacatoken $contents");
      } else {
        print('File does not exist');
        goToLogin();
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  Future<void> _loadToken() async {
    token = await sharedPref.getPref('access_token');
    id = await sharedPref.getPref('id_usr');
    print("readtoken $token");
    print("readid $id");
    // if (token != null) {
    // bacaToken == true;
    // print("boolbacatoken");
    // print(bacaToken);
    //   readToken = token ?? "No token found";
    // }

    setState(() {
      if (token != null) {
        bacaToken == true;
        readToken = token ?? "No token found";
      }
      startLaunching();
      // readToken = token ?? "No token found";
      // bacaToken == true;
    });
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

// Call this function before trying to access the file
// await requestPermissions();

  getDetailUser(userId) async {
    try {
      var response = await http.post(Uri.parse(url),
          headers: {'Accept': 'application/json'}, body: {"user_id": userId});
      var content = json.decode(response.body);

      if (content['status'] == 200) {
        setState(() {
          isLogged = true;
        });
      } else {
        setState(() {
          isLogged = false;
        });
      }
    } catch (e) {
      isLogged = false;
    }
  }

  void goToApp(userId) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainTabBar(id: userId)),
        (Route<dynamic> route) => false);
  }

  void goToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
      return LoginPage(
        tkn: widget.token,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clrPrimary,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.80,
          child: Center(
            child: Text(
              "Chat AI",
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 80,
                fontWeight: FontWeight.w700,
                height: 1.2575,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  permissionServiceCall() async {
    await permissionServices().then(
      (value) {
        if (value[Permission.storage]!.isGranted) {}
      },
    );
  }

  /*Permission services*/
  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      //add more permission to request here.
    ].request();

    if (statuses[Permission.storage]!.isPermanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.storage.status.isPermanentlyDenied == true &&
                await Permission.storage.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall(); /* opens app settings until permission is granted */
            }
          }
        },
      );
    } else {
      if (statuses[Permission.storage]!.isDenied) {
        permissionServiceCall();
      }
    }

    /*{Permission.camera: PermissionStatus.granted, Permission.storage: PermissionStatus.granted}*/
    return statuses;
  }
}
