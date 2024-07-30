import 'package:flutter/material.dart';
import '../../widgets/spacer/spacer_custom.dart';
import '../src/constant.dart';
import '../src/utils.dart';

class CallCardWidget extends StatelessWidget {
  const CallCardWidget({
    super.key,
    required this.name,
    required this.condition,
    required this.image,
    required this.isOnline,
    required this.secondTitle,
    required this.secondColor,
    required this.time,
  });
  final String name;
  final String condition;
  final String image;
  final bool isOnline;

  final String secondTitle;
  final Color secondColor;

  final String time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(image), fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: clrBackground,
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
                  name,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: const Color(0xff1e2022),
                  ),
                ),
                const CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  secondTitle,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: secondColor,
                  ),
                ),
                const CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  time,
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
            ),
          ),
          const CustomWidthSpacer(),
          condition == 'Finish'
              ? Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: clrDone,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.done,
                    size: 14,
                    color: clrBackgroundLight,
                  ),
                )
              : condition == 'Request'
                  ? Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: clrPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning,
                        size: 14,
                        color: clrBackgroundLight,
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
                        Icons.accessibility,
                        size: 26,
                        color: clrSecondary,
                      ),
                    )
        ],
      ),
    );
  }
}
