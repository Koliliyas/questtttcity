import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class BlurRectangleView extends StatelessWidget {
  const BlurRectangleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 251.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            UiConstants.black2Color.withValues(alpha: 0),
            UiConstants.black2Color.withValues(alpha: .85),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
      ),
    );
  }
}
