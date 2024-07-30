import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../src/api.dart';
import '../../../src/constant.dart';
import '../../../src/dialog_info.dart';
import '../../../src/loader.dart';
import '../../../src/preference.dart';
import '../../../src/utils.dart';
import '../page.dart';
import 'package:path/path.dart' as path;

class InfoUser extends StatefulWidget {
  final Map? todo;
  const InfoUser({Key? key, required this.todo}) : super(key: key);

  @override
  State<InfoUser> createState() => _InfoUserState();
}

class _InfoUserState extends State<InfoUser> {
  SharedPref sharedPref = SharedPref();
  String accessToken = "";
  String message = "";
  bool isProcess = false;
  final cntrlId = TextEditingController();
  final cntrlUserfullname = TextEditingController();
  final cntrlUsername = TextEditingController();
  final cntrlUseremail = TextEditingController();
  final cntrlUsernip = TextEditingController();
  final cntrlUserphone = TextEditingController();
  final cntrlUserrole = TextEditingController();
  final cntrlUserphoto = TextEditingController();
  final cntrlUsermethod = TextEditingController();
  List listData = [];

  String id = "";
  String name = "";
  String email = "";
  String nip = "";
  String phone = "";
  String role = "";
  String userpath = "";
  String photo = "";
  String roleId = "";

  // XFile? _image;
  File? _image;
  var gambar;
  final picker = ImagePicker();
  var imageData;
  var filename;
  var splitted;
  File? pathgambar;

  @override
  void initState() {
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }

    final todo = widget.todo;
    if (todo != null) {
      final id = todo['id'].toString();
      final name = todo['fullname'];
      final email = todo['email'];
      final nip = todo['nip'].toString();
      final phone = todo['no_hp'];
      final role = todo['role_id'].toString();
      final roleId = todo['role_id'].toString();
      final _image = todo['image'];
      final username =
          todo['username'].toString() == "null" ? "-" : todo['username'];
      const method = "put";

      print(name);
      print(email);
      print(nip);
      print(phone);
      print(username);
      print(method);
      print(pathgambar);
      print(role);
      print(roleId);

      photo = _image;
      cntrlId.text = id;
      cntrlUserfullname.text = name;
      cntrlUseremail.text = email;
      cntrlUsernip.text = nip;
      cntrlUserphone.text = phone;
      cntrlUserrole.text = role;
      cntrlUsername.text = username;
      cntrlUsermethod.text = method;
      print("phototodo");
      print(photo);
    }
    super.initState();
  }

  Future updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("You can not call updated data");
      print(todo);
      return;
    }

    // Future<File> downloadImage(String url) async {
    //   final response = await http.get(Uri.parse(url));
    //   final documentDirectory = await getDownloadsDirectory();
    //   final file = File('${documentDirectory!.path}/downloaded_image.jpg');
    //   await file.writeAsBytes(response.bodyBytes);
    //   return file;
    // }

    // final id = todo['id'].toString();
    // final gambar = todo['image'].toString();

    // // File photo2 = File('${ApiService.folder}/$gambar');

    // File photo2;

    // if (gambar.startsWith('http')) {
    //   photo2 = await downloadImage('${ApiService.folder}/$gambar');
    // } else {
    //   photo2 = File(gambar);
    // }

    final id = todo['id'].toString();
    final gambar = todo['image'].toString();
    final photo2 = '${ApiService.folder}/$gambar';

    final name = cntrlUserfullname.text;
    final nip = cntrlUsernip.text;
    final email = cntrlUseremail.text;
    final phone = cntrlUserphone.text;
    final username = cntrlUsername.text;
    final role = cntrlUserrole.text;
    final method = cntrlUsermethod.text;
    // final photo;

    final photo = _image ?? photo2;

    print(name);
    print(nip);
    print(email);
    print(phone);
    print(username);
    print(role);
    print(method);
    print(_image);
    print("sblmsend");

    print(photo);

    var url = ApiService.editUser;
    var uri = "$url/$id";
    var response = http.MultipartRequest(
      'POST',
      Uri.parse(uri),
    );
    var accessToken = await sharedPref.getPref("access_token");
    var bearerToken = 'Bearer $accessToken';
    Map<String, String> headers = {
      "Authorization": bearerToken.toString(),
      // "Content-type": "multipart/form-data" // Not required since it's automatically added by http.MultipartRequest
    };

    response.headers.addAll(headers);
    response.fields.addAll({
      "id": id,
      "fullname": name,
      "nip": nip,
      "no_hp": phone,
      "email": email,
      "username": username,
      "_method": method,
      "role": role
    });

    if (photo is File) {
      final httpImage = http.MultipartFile.fromBytes(
        'image',
        // _image ?? photo as File
        File(photo.path).readAsBytesSync(),
        filename: path.basename(photo.path),
      );
      response.files.add(httpImage);
      // Use the URL directly
    } else {
      // final image = response.fields['image'] =photo2;
      // response.fields(photo2);
      //  response.files.clear();
       response.fields['image'] = photo2;
    }

    var request = await response.send();
    var responsed = await http.Response.fromStream(request);
    var content = json.decode(responsed.body);

    print(request);
    print(responsed);
    print(content);

    if (content['status_code'] == 200) {
      cntrlUserfullname.text = name;
      cntrlUseremail.text = email;
      cntrlUserphone.text = phone;
      cntrlUsername.text = username;
      // _image = photo;
      print("stlh send");
      print(photo);

      print("jfjjfjf");

      print("sddd");

      // print(photo);

      sharedPref.setPref("name", name);
      print("object");

      // ignore: use_build_context_synchronously
      _onAlertButtonPressed(context, true, "Data Berhasil Diperbaharui");
      // moveToSecondPage();
    } else {
      // ignore: use_build_context_synchronously
      onBasicAlertPressed(context, 'Error', e.toString());
    }

    setState(() {
      isProcess = false;

    });
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

  void moveToSecondPage() async {
    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SettingLogic(),
        ),
        (Route<dynamic> route) => false);
  }

  late FocusNode focusNode = FocusNode()
    ..addListener(() {
      setState(() {});
    });

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

// Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageData = await pickedFile
          .readAsBytes(); //ini bytes imagenya yg dikirim ke server

      setState(() {
        // _image != null ? _image = File(pickedFile.path) :  _image = photo as File;
        _image = File(pickedFile.path);
        filename = pickedFile.name;
        print("imagepicked");
        print(_image);
      });

      // gambar = _image.toString();

      // splitted = gambar.split("/"); //ini path imagenya
      // print("object");

      // print(splitted[6]);
      // print(splitted[6] + "/" + splitted[7]);

      filename = pickedFile.name; //ini nama imagenya
    } else {
      _image = photo as File;
    }
  }

// Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageData = await pickedFile.readAsBytes();

      setState(() {
        // _image != null ? _image = File(pickedFile.path) :  _image = photo as File;
        _image = File(pickedFile.path);
        filename = pickedFile.name;
        print("imagepicked");
        print(_image);
      });

      filename = pickedFile.name;
      print(filename);
      print(_image);
    } else {
      _image = photo as File;
    }
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height - 20;
    double w = MediaQuery.of(context).size.width - 0;
    var mediaQueryHeight = MediaQuery.of(context).size.height;
    // var photo = _image!.path;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        actions: [],
        backgroundColor: Colors.white,
        title: Text(
          "Detail Profile",
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.2575,
            letterSpacing: 1,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 100,
                          child: Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.expand,
                            children: [
                              CircleAvatar(
                                backgroundColor: clrPrimary,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                          as ImageProvider<Object>?
                                      : NetworkImage(
                                          '${ApiService.folder}/$photo',
                                          scale: 10,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: mediaQueryHeight / 7,
                                child: RawMaterialButton(
                                  onPressed: () {
                                    showOptions();
                                  },
                                  elevation: 2.0,
                                  fillColor: clrBackground,
                                  padding: const EdgeInsets.all(5.0),
                                  shape: const CircleBorder(),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    TextFormField(
                      enabled: false,
                      focusNode: _focusNodes[3],
                      controller: cntrlUsernip,
                      decoration: InputDecoration(
                        hoverColor: clrPrimary,
                        labelText: "NIP",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.badge,
                          color: _focusNodes[3].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                        ),
                      ),
                    ),
                    TextFormField(
                      focusNode: _focusNodes[1],
                      controller: cntrlUserfullname,
                      decoration: InputDecoration(
                        hoverColor: clrPrimary,
                        labelText: "Nama Lengkap",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusColor: clrPrimary,
                        focusedBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.account_circle,
                          color: _focusNodes[1].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                        ),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: _focusNodes[1].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    TextFormField(
                      focusNode: _focusNodes[6],
                      controller: cntrlUsername,
                      decoration: InputDecoration(
                        hoverColor: clrPrimary,
                        labelText: "Username",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusColor: clrPrimary,
                        focusedBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.account_circle,
                          color: _focusNodes[6].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                        ),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: _focusNodes[6].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    TextFormField(
                      focusNode: _focusNodes[2],
                      controller: cntrlUseremail,
                      decoration: InputDecoration(
                        hoverColor: clrPrimary,
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.mail,
                          color: _focusNodes[2].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                        ),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: _focusNodes[2].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    TextFormField(
                      focusNode: _focusNodes[4],
                      controller: cntrlUserphone,
                      decoration: InputDecoration(
                        hoverColor: clrPrimary,
                        labelText: "No. Telp",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.phone,
                          color: _focusNodes[4].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                        ),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: _focusNodes[4].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    TextFormField(
                      enabled: false,
                      focusNode: _focusNodes[5],
                      controller: cntrlUserrole,
                      decoration: InputDecoration(
                        hoverColor: clrPrimary,
                        labelText: "Role",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.verified_user,
                          color: _focusNodes[5].hasFocus
                              ? clrPrimary
                              : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    !isProcess
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              width: w,
                              height: h / 14.7,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: clrPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  updateData();
                                },
                                child: const Text(
                                  "Ubah",
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : loaderDialog(context),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
