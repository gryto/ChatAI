import 'package:flutter/material.dart';
import '../gen/assets.gen.dart';
import '../src/constant.dart';
import '../src/utils.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: Stack(
        children: <Widget>[
          child,
          Positioned(
            top: 120,
            right: size.height / 5.5,
            child: Column(
              children: [
                Positioned(
                  top: 100,
                  right: size.height / 5.5,
                  child: Image.asset(
                    Assets.icons.icLauncher.path,
                    width: 100,
                    height: 100,
                  ),
                ),
                Center(
                  child: Text(
                    "Chat AI",
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.2575,
                      letterSpacing: 1,
                      color: clrPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
