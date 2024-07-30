import 'package:flutter/material.dart';
import '../src/utils.dart';


class BottomIconWidget extends StatelessWidget {
  const BottomIconWidget({
    Key? key,
    required this.title,
    required this.iconName,
    this.iconColor,
    this.tap,
  }) : super(key: key);
  final String title;
  final IconData iconName;
  final Color? iconColor;
  final Function()? tap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: tap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(iconName, size: 18, color: iconColor,)
            ),
            Text(
              title,
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2575,
                letterSpacing: 1,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
