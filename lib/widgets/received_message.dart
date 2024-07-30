import 'package:flutter/material.dart';
import '../gen/assets.gen.dart';
import '../src/constant.dart';
import '../src/device_utils.dart';
import '../src/utils.dart';
import 'chat_bubble.dart';

class ReceivedMessage extends StatelessWidget {
  final Widget child;
  final String time;
  const ReceivedMessage({
    Key? key,
    required this.child,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  Assets.icons.icChatGPT.path
                  // scale: 10,
                ),
                fit: BoxFit.cover),
            shape: BoxShape.circle,
          ),
        ),
        Align(
          alignment: Alignment
              .topLeft, //Change this to Alignment.topRight or Alignment.topLeft
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPaint(
                painter: ChatBubble(
                    color: clrBackgroundLight, alignment: Alignment.topLeft),
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: 100,
                      maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 10, top: 10, bottom: 10),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          time,
          textAlign: TextAlign.right,
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.2575,
            letterSpacing: 1,
            color: const Color(0xff77838f),
          ),
        ),
      ],
    ));

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          messageTextGroup,
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
