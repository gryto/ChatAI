import 'dart:convert';
import 'package:flutter/material.dart';
import '../src/preference.dart';
import 'screen/chat_room/chat_room.dart';
import 'screen/profile/page.dart';
import 'src/api.dart';
import 'src/constant.dart';
import 'src/toast.dart';
import 'src/utils.dart';
import 'package:http/http.dart' as http;

class MainTabBar extends StatefulWidget {
  final id;
  // final page;
  const MainTabBar({Key? key, required this.id, 
  // required this.page
  })
      : super(key: key);

  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  SharedPref sharedPref = SharedPref();
  bool isProcess = false;
  int pageIndex = 0;
  String fullName = "";
  String division = "";
  String typeUser = "";
  String path = "";
  String accessToken = "";
  String dateString = "";
  late final Function(int) callback;
  String message = "";
  List<Map<String, dynamic>> listData = [];
  List listDataHistoryMonth = [];
  List listDataHistoryWeek = [];
  List listDataHistoryDay = [];
  String messagess = "";
  List<Widget> pages = <Widget>[]; // Declare pages here

  String fullname = "";
  late int userId = 0;

  var offset = 0;
  var limit = 10;

  @override
  void initState() {
    getDataHistoryDay();
    getData(widget.id);
    getDataHistory();
    getDataHistoryWeek();
    // getDataAi();
    // print("historyhfjfhjf");
    // pageIndex = widget.page;
    super.initState();
  }

  getData(id) async {
    pages = [
      ChatRoomPage(senderId: userId.toString(), data: listDataHistoryDay, image: path),
    ];
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.detailUser;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});

      if (response.statusCode == 200) {
        setState(() {
          var content = json.decode(response.body);

          fullname = content['data']['fullname'];
          division = content['data']['getrole']['name'];
          listData.add(content['data']);
          userId = content['data']['id'];
          path = content['data']['image'];
          pages = [
            ChatRoomPage(senderId: userId.toString(), data: listDataHistoryDay, image: path),
          ];
        });
      } else {
        toastShort(context, message);
      }
    } catch (e) {
      toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }

  getDataHistory() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      // var url = ApiService.historyAi;
      var url = ApiService.historyAiMonth;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri), headers: {
        "Authorization": bearerToken.toString(),
      });
      var content = json.decode(response.body);

      if (content['status'] == 200) {
        print("history month");
        listDataHistoryMonth = content['data'];
        print(listDataHistoryMonth);
      } else {
        // toastShort(context, message);
      }
    } catch (e) {
      // toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }

  getDataHistoryWeek() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      // var url = ApiService.historyAi;
      var url = ApiService.historyAiWeek;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);

      if (content['status'] == 200) {
        print("history week");
        listDataHistoryWeek = content['data'];
        print(listDataHistoryWeek);
      } else {
        // toastShort(context, message);
      }
    } catch (e) {
      // toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }

  getDataHistoryDay() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      // var url = ApiService.historyAi;
      var url = ApiService.historyAiDay;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);

      print("historyhoooo");

      if (response.statusCode == 200) {
        print("DAYYYYYYhistoryhsetelah");
        listDataHistoryDay = content['data'];
        print(listDataHistoryDay);
      } else {
        toastShort(context, message);
      }
    } catch (e) {
      toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chat AI',
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: Colors.black87,
                ),
                selectionColor: pageIndex == 2
                    ? Theme.of(context).primaryColor
                    : clrBackground,
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child:
            ChatRoomPage(senderId: userId.toString(), data: listDataHistoryDay, image: path,),
      ),
      drawer: Drawer(
        backgroundColor: clrBackgroundLight,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: clrPrimary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingLogic(id: widget.id),
                        ),
                      );
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                              '${ApiService.folder}/$path',
                              scale: 10,
                            ),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullname,
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.2575,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        division,
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.2575,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: Text(
                'Hari ini',
                style: SafeGoogleFont('SF Pro Text',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Colors.black87),
              ),
              onTap: () {
                pageIndex = 0;
                Navigator.pop(context);
              },
            ),
            lastDay(data: listDataHistoryDay),
            ListTile(
              leading: const Icon(Icons.timer),
              title: Text(
                'Seminggu Terakhir',
                style: SafeGoogleFont('SF Pro Text',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Colors.black87),
              ),
              onTap: () {
                pageIndex = 0;
                Navigator.pop(context);
              },
            ),
            lastWeek(data: listDataHistoryWeek),
            ListTile(
              leading: const Icon(Icons.timer),
              title: Text(
                'Sebulan Terakhir',
                style: SafeGoogleFont('SF Pro Text',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Colors.black87),
              ),
              onTap: () {
                pageIndex = 0;
                Navigator.pop(context);
              },
            ),
            lastMonth(data: listDataHistoryMonth),
          ],
        ),
      ),
    );
  }

  lastMonth({required final data}) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        if (index < 5) {
          var row = data[index];

          return GestureDetector(
            child: ListTile(
              title: Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                row['message'] ?? "-",
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: pageIndex == 1 ? clrPrimary : clrBackground,
                ),
              ),
              onTap: () {

              },
            ),
          );
        }
        return null;
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: data.isEmpty ? 0 : data.length,
    );
  }

  lastWeek({required final data}) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        if (index < 5) {
          var row = data[index];

          return GestureDetector(
            child: ListTile(
              title: Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                row['message'] ?? "-",
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: pageIndex == 1 ? clrPrimary : clrBackground,
                ),
              ),
              onTap: () {},
            ),
          );
        }
        return null;
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: data.isEmpty ? 0 : data.length,
    );
  }

  lastDay({required final data}) {
    int startIndex = data.length > 5 ? data.length - 5 : 0;
    int itemCount = data.length > 5 ? 5 : data.length;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        var row = data[startIndex + index];

        return GestureDetector(
          child: ListTile(
            title: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              row['message'] ?? "-",
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2575,
                letterSpacing: 1,
                color: pageIndex == 1 ? clrPrimary : clrBackground,
              ),
            ),
            onTap: () {},
          ),
        );
        // }
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: itemCount,
    );
  }
}
