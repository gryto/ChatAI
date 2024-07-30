import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../gen/assets.gen.dart';
import '../../src/api.dart';
import '../../src/constant.dart';
import '../../src/device_utils.dart';
import '../../src/loader.dart';
import '../../src/preference.dart';
import '../../src/utils.dart';
import '../../widgets/spacer/spacer_custom.dart';
import 'components/list.dart';

class ChatRoomPage extends StatefulWidget {
  final String senderId, image;
  final data;

  const ChatRoomPage({
    Key? key,
    // required this.receiverId,
    required this.data,
    required this.senderId,
    required this.image,
    // required this.receiverImage,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final DateFormat dmy = DateFormat("HH:mm");
  final DateFormat dm = DateFormat("HH:mm");
  final _formKey = GlobalKey<FormState>();
  final _keyword = TextEditingController();
  FocusNode inputNode = FocusNode();
  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }



  String userpath = "";
  String photo = "";
  var imageData;
  var filename;
  FilePickerResult? result;
  String replyText = '';
  String messageReply = '';
  late final ValueChanged onSwipedMessage;
  List listDataHistoryDay = [];

  String nomer = "", akun = "";

  SharedPref sharedPref = SharedPref();
  String accessToken = "";
  String userId = "";
  String chatId = "";
  String message = "";
  bool isProcess = true;
  List listData = [];
  late ScrollController _listScrollController;
  bool _isVisible = true;

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  getDataAi(str) async {
    try {
      final params = {'message': str.toString()};

      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.chatAi;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.post(Uri.parse(uri),
          headers: {
            "Authorization": bearerToken.toString(),
          },
          body: params);

      if (response.statusCode == 200) {
        _keyword.text = '';
        listDataHistoryDay.clear;
        getDataHistoryDay();
      } else {
        // toastShort(context, message);
      }
    } catch (e) {
      // toastShort(context, e.toString());
      // print(e.toString());
    }

    setState(() {
      // scrollListToEnd();
      isProcess = true;
    });
  }

  getDataHistoryDay() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.historyAiDay;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);

      if (response.statusCode == 200) {
        listDataHistoryDay = content['data'];
      } else {
        // toastShort(context, message);
      }
    } catch (e) {
      // toastShort(context, e.toString());
    }

    setState(() {
      scrollListToEnd();
      isProcess = false;
    });
  }

  checkSession() async {
    var aToken = await sharedPref.getPref("access_token");
    getDataHistoryDay();
    _listScrollController = ScrollController();

    // Tambahkan listener pada ScrollController
    _listScrollController.addListener(() {
      setState(() {
        // Periksa apakah posisi scroll sudah mencapai bagian paling bawah
        _isVisible = !(_listScrollController.position.pixels >=
            _listScrollController.position.maxScrollExtent);
      });
    });

    setState(() {
      accessToken = aToken;
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

  @override
  void initState() {
    checkSession();

    print("senderid");
    print(widget.senderId);
    super.initState();
  }

  @override
  void dispose() {
    // Hapus listener pada saat widget di-dispose
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: DeviceUtils.getScaledHeight(context, 1),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: clrBackgroundLight,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: MediaQuery.of(context).size.height * 0.80,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  controller: _listScrollController,
                  child: !isProcess
                      ? ChatRoomList(
                          senderId: widget.senderId,
                          data: listDataHistoryDay,
                          image: widget.image)
                      : loaderDialog(context),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding * 0.68),
                        decoration: BoxDecoration(
                          color: clrBackgroundLight,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    focusNode: inputNode,
                                    style: const TextStyle(color: Colors.black),
                                    cursorColor: Colors.white54,
                                    controller: _keyword,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    // onFieldSubmitted: (value) {
                                    //   getDataAi(value);
                                    // },
                                    decoration: InputDecoration(
                                      suffixIconColor: Colors.white54,
                                      filled: true,
                                      fillColor: clrBackgroundLight,
                                      hintText: 'Isi pesan ...',
                                      hintStyle: const TextStyle(
                                          color: Colors.black26),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 35),
                    Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            getDataAi(_keyword.text);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: clrPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        // Tentukan visibilitas floating button berdasarkan nilai _isVisible
        visible: _isVisible,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: GestureDetector(
            onTap: () {
              scrollListToEnd();
            },
            child: SizedBox(
              width: 30,
              height: 30,
              child: FittedBox(
                child: FloatingActionButton(
                  foregroundColor: clrBackground,
                  backgroundColor: clrBackgroundLight,
                  shape: const CircleBorder(),
                  onPressed: scrollListToEnd,
                  child: const Icon(
                    Icons.keyboard_double_arrow_down,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DummyWaveWithPlayIcon extends StatelessWidget {
  const DummyWaveWithPlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          // rectanglesHz (0:577)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoSY (0:592)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglejqz (0:578)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle5ex (0:581)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRD2 (0:585)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        //     ],
        //   ),
        // ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglexye (0:590)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),

        Container(
          // rectangleSP2 (0:587)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleyNx (0:582)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleJg8 (0:579)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleEpg (0:593)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglez3A (0:586)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle8QG (0:589)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHHA (0:584)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle2Ve (0:598)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglenUp (0:591)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleGPz (0:588)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoep (0:583)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle9Tn (0:580)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHZz (0:594)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRw6 (0:595)
          width: 3,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglea3J (0:596)
          width: 3,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleifJ (0:597)
          width: 3,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const CustomWidthSpacer(
          size: 0.05,
        ),

        Text(
          '01:3',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2575,
            letterSpacing: 1,
            color: const Color(0xffffffff),
          ),
        ),

        const CustomWidthSpacer(
          size: 0.05,
        ),

        Image.asset(
          Assets.images.playIcon.path,
          width: 28,
          height: 28,
        )
      ],
    );
  }
}

class DateDevider extends StatelessWidget {
  const DateDevider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: 100, // OK
        height: 41, // OK
        decoration: const BoxDecoration(
          color: Color(0xffF2F3F6),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Center(
            child: Text(
          'Today',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.193359375,
            letterSpacing: 1,
            color: const Color(0xff77838f),
          ),
        )),
      ),
    );
  }
}

class ChatRoomHeader extends StatelessWidget {
  final String no, user;
  const ChatRoomHeader({Key? key, required this.no, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15, top: 25, bottom: 5),
      // const EdgeInsets.fromLTRB(16, 48, 16, 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Image.asset(
              Assets.icons.leftIcon.path,
              width: 16,
              height: 16,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage('${ApiService.folder}/image-user/$no'),
                  fit: BoxFit.fill),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            user,
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'SF Pro Text',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2575,
              letterSpacing: 1,
              color: const Color(0xff3b566e),
            ),
          ),
        ],
      ),
    );
  }
}
