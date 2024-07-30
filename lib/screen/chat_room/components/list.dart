import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../src/api.dart';
import '../../../widgets/received_message.dart';
import '../../../widgets/sent_message.dart';

// ignore: must_be_immutable
class ChatRoomList extends StatelessWidget {
  String senderId, image;
  List data;
  ChatRoomList({
    super.key,
    required this.data,
    required this.senderId,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dmy = DateFormat("HH:mm");
    final widgetKey = GlobalKey();


    if (data.isNotEmpty) {
      return ListView.separated(
        padding:
            const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          var row = data[index];

          var local = dmy.format(DateTime.parse(row['created_at']).toLocal());
          var datetime = local.toString();

          return Column(
            children: [
              SentMessage(
                onLongPress: () {
                  showMenu(
                    items: <PopupMenuEntry>[
                      const PopupMenuItem(
                        //value: this._index,
                        child: Row(
                          children: [Text("Context item 1")],
                        ),
                      )
                    ],
                    context: context,
                    position: _getRelativeRect(widgetKey),
                  );
                },
                time: datetime,
                // ignore: unnecessary_null_comparison
                image: image != null
                    ? '${ApiService.folder}/${image}'
                    : ApiService.imgDefault,
                child: Text(
                  row['message'] ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.64,
                    letterSpacing: 0.5,
                    color: Color(0xffffffff),
                  ),
                ),
              ),
              ReceivedMessage(
                time: datetime,
                child: Column(
                  children: [
                    Text(
                      row['answer'] ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.64,
                        letterSpacing: 0.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        itemCount: data.isEmpty ? 0 : data.length,
      );
    } else {
      return Center(
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: const Text("No data found"),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      );
    }
  }

  RelativeRect _getRelativeRect(GlobalKey key) {
    return RelativeRect.fromSize(
        _getWidgetGlobalRect(key), const Size(200, 200));
  }

  Rect _getWidgetGlobalRect(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    debugPrint('Widget position: ${offset.dx} ${offset.dy}');
    return Rect.fromLTWH(offset.dx / 3.1, offset.dy * 1.05,
        renderBox.size.width, renderBox.size.height);
  }
}
