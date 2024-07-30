import 'package:flutter/material.dart';
import '../src/constant.dart';
import '../src/utils.dart';
import 'spacer/spacer_custom.dart';

class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    super.key,
    required this.image,
    required this.isOnline,
    required this.message,
    required this.count,
    required this.unReadCount,
    required this.isUnReadCountShow,
    required this.time,
  });

  final String image;
  final bool isOnline;
  final String message;
  final String count;
  final String unReadCount;
  final bool isUnReadCountShow;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x21000000),
              offset: Offset(0, 2),
              blurRadius: 24,
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                unReadCount == 'Request'
                    ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(image), fit: BoxFit.fill),
                          shape: BoxShape.circle,
                        ),
                      )
                    : unReadCount == 'Handle'
                        ? Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.list_alt),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.done, color: Colors.green,),
                          ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: clrPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const CustomWidthSpacer(
              size: 0.03,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2575,
                      letterSpacing: 0.6000000238,
                      color: Colors.black87,
                    ),
                  ),
                  const CustomWidthSpacer(
                    size: 0.03,
                  ),
                  const CustomHeightSpacer(
                    size: 0.003,
                  ),
                  Text(
                    time,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.2575,
                      letterSpacing: 0.6000000238,
                      color: const Color(0xff77838f),
                    ),
                  ),
                ],
              ),
            ),
            const CustomWidthSpacer(
              size: 0.03,
            ),
            unReadCount == 'Request'
                ? const SizedBox(
                    width: 22,
                    height: 22,
                  )
                : unReadCount == 'Handle'
                    ? Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: clrPrimary,
                          // borderRadius: BorderRadius.circular(11),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            count,
                            textAlign: TextAlign.center,
                            style: SafeGoogleFont(
                              'SF Pro Text',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.2575,
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: clrBackgroundLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.done,
                          size: 14,
                          color: clrPrimary,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
