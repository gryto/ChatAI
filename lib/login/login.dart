import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../home.dart';
import '../src/api.dart';
import '../src/constant.dart';
import '../src/preference.dart';
import '../src/utils.dart';
import 'background.dart';

class LoginPage extends StatefulWidget {
  final String tkn;
  const LoginPage({Key? key, required this.tkn}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _token = '';
  String? token;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final cntrlNip = TextEditingController();
  final cntrlPassword = TextEditingController();
  final cntrlToken = TextEditingController();
  String img = "";
  String userId = "";
  String userFullname = "";
  String userNip = "";
  String userHp = "";
  String userEmail = "";
  String userUsername = "";
  String userRole = "";
  String accessToken = "";
  int sign = 0;

  SharedPref sharedPref = SharedPref();
  String url = ApiService.setLogin;
  String message = "";
  bool isProcess = false;

  Future<String> _getSharedFilePath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path + '/.shared_token';
  }

  Future<String> _getSharedFilePathId() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path + '/.shared_id';
  }

  Future<void> _saveTokenToFile(String token, id) async {
    String filePath = await _getSharedFilePath();
    String filePathId = await _getSharedFilePathId();
    File file = File(filePath);
    File fileId = File(filePathId);
    await file.writeAsString(token);
    await fileId.writeAsString(id);
    print('Token saved to file: $filePath');
    print('Id saved to file: $filePathId');
  }

  Future<String> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      _onAlertButtonPressed(context, false, "Folder download tidak ditemukan");
    }

    return directory!.path;
  }

  _onAlertButtonPressed(context, status, message) {
    Alert(
      context: context,
      type: !status ? AlertType.error : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: clrPrimary,
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  Future<void> _downloadTokenFile() async {
    // if (await Permission.storage.request().isGranted) {
    String sharedFilePath = await _getSharedFilePath();
    File sharedFile = File(sharedFilePath);

    String sharedFilePathId = await _getSharedFilePathId();
    File sharedFileId = File(sharedFilePathId);

    if (await sharedFile.exists() && await sharedFileId.exists()) {
      String directoryPath = await _getDownloadDirectoryPath();
      String savePath = '$directoryPath/.shared_token';
      String savePathId = '$directoryPath/.shared_id';
      await sharedFile.copy(savePath);
      await sharedFileId.copy(savePathId);
      print('Token file downloaded to: $savePath');
      print('Id file downloaded to: $savePathId');
      _onAlertButtonPressed(
          context, true, "Token file downloaded successfully.");
    } else {
      print('Shared token file not found');
      _onAlertButtonPressed(context, false, "Token file not found.");
    }
    // } else {
    //   print('Storage permission denied');
    //   _onAlertButtonPressed(context, false, "Storage permission denied.");
    // }
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

  /////////////////////////////

  loginCheck(username, password, tkn) async {
    setState(() {
      isProcess = true;
    });

    print('tokenlogin');

    print(widget.tkn);

    try {
      var accessToken = await sharedPref.getPref("access_token");
      var response = await http.post(Uri.parse(url),
          headers: {'Accept': 'application/json'},
          body: {"nip": username, "password": password, "tkn": widget.tkn});
      var content = json.decode(response.body);
      print(url);
      print(content.toString());

      if (content['status'] == 200) {
        userId = content['id_usr'].toString();
        userFullname = content['fullname'].toString();
        userNip = content['nip'].toString();
        userHp = content['no_hp'].toString();
        userEmail = content['email'].toString();
        userUsername = content['username'].toString();
        accessToken = content['access_token'].toString();

        sharedPref.setPref("access_token", _token);
        sharedPref.setPref("id_usr", userId);
        sharedPref.setPref("fullname", userFullname);
        sharedPref.setPref("nip", userNip);
        sharedPref.setPref("no_hp", userHp);
        sharedPref.setPref("email", userEmail);
        sharedPref.setPref("username", userUsername);
        sharedPref.setPref("access_token", accessToken);

        // Save token to file
        await _saveTokenToFile(accessToken, userId);
        // await _saveTokenToFile(userId);

        print("savedtoken");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful. Token saved.')),
        );

        await _downloadTokenFile();

        goToApp(userId, sign);
      } else {
        // ignore: use_build_context_synchronously
        _onAlertButtonPressed(context, content['status'], content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _onAlertButtonPressed(context, false, e.toString());
    }

    setState(() {
      isProcess = false;
    });
  }

  goToApp(userId, sign) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainTabBar(id: userId)),
        (Route<dynamic> route) => false);
  }

  getFcmToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }

    setState(() {
      _token = token.toString();
    });
    print("hmmm");
    print(_token);
  }

  @override
  void initState() {
    super.initState();

    cntrlNip.text = "0101200401";
    cntrlPassword.text = "12345678";
    cntrlToken.text = widget.tkn;
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height - 20;
    double w = MediaQuery.of(context).size.width - 0;

    return SafeArea(
      child: Scaffold(
        body: Background(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                      child: Column(children: [
                        const SizedBox(
                          height: 140,
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          height: h / 1.7,
                          width: w / 1.1,
                          decoration: BoxDecoration(
                            color: clrPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 180,
                          ),
                          Container(
                            // alignment: Alignment.bottomRight,
                            height: h / 1.6,
                            width: w / 1.1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, right: 5, left: 5),
                              child: Column(
                                children: [
                                  const SizedBox(height: 75),
                                  Text(
                                    "MASUK APLIKASI",
                                    style: SafeGoogleFont(
                                      'SF Pro Text',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2575,
                                      letterSpacing: 1,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Silahkan Masukkan NIP dan Kata Sandi Anda!",
                                    style: SafeGoogleFont(
                                      'SF Pro Text',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2575,
                                      letterSpacing: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: customTextEditingController(
                                            'NIP Anda',
                                            const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                            cntrlNip,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: passwordTextFormField(
                                            'Kata Sandi',
                                            cntrlPassword,
                                            const Icon(
                                              Icons.lock,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: tokenTextEditingController(
                                            'Token',
                                            const Icon(
                                              Icons.key,
                                              color: Colors.grey,
                                            ),
                                            cntrlToken,
                                          ),
                                        ),
                                        !isProcess
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: SizedBox(
                                                  width: w,
                                                  height: h / 14.7,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          clrPrimary,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        loginCheck(
                                                            cntrlNip.text,
                                                            cntrlPassword.text,
                                                            cntrlToken.text);
                                                      }
                                                    },
                                                    child: Text(
                                                      "Login",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 1.2575,
                                                        letterSpacing: 1,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: SizedBox(
                                                  width: w,
                                                  height: h / 14.7,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          clrPrimary,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        loginCheck(
                                                            cntrlNip.text,
                                                            cntrlPassword.text,
                                                            cntrlToken.text);
                                                      }
                                                    },
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.grey,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                clrPrimary),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customTextEditingController(
      String hintText, Icon prefixIcon, TextEditingController controllerName) {
    return TextFormField(
      controller: controllerName,
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Enter Username";
        }
        return null;
      },
      style: SafeGoogleFont(
        'SF Pro Text',
        // fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2575,
        letterSpacing: 1,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: prefixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
    );
  }

  Widget passwordTextFormField(String hintText,
      TextEditingController controllerPassword, Icon prefIcon) {
    return TextFormField(
      controller: controllerPassword,
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Enter Your Password";
        }
        return null;
      },
      obscureText: _obscurePassword,
      style: SafeGoogleFont(
        'SF Pro Text',
        // fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2575,
        letterSpacing: 1,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: prefIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(width: 1, color: Colors.grey),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          child: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: clrPrimary,
          ),
        ),
        suffixStyle: const TextStyle(color: clrPrimary),
      ),
    );
  }
}

Widget tokenTextEditingController(
    String hintText, Icon prefixIcon, TextEditingController controllerToken) {
  return TextFormField(
    autofocus: false,
    controller: controllerToken,
    validator: (value) {
      if (value!.isEmpty) {
        return "Please Enter Token";
      }
      return null;
    },
    style: SafeGoogleFont(
      'SF Pro Text',
      fontWeight: FontWeight.w700,
      height: 1.2575,
      letterSpacing: 1,
      color: Colors.transparent,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none, // remove the underline
    ),
    enabled: false,
  );
}
