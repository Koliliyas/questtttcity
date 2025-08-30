import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class RightArrowInOrangeCircle extends StatelessWidget {
  const RightArrowInOrangeCircle({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 23.w,
        width: 23.w,
        decoration: const BoxDecoration(
            color: UiConstants.orangeColor, shape: BoxShape.circle),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Center(
            child: Icon(Icons.arrow_forward_ios_rounded,
                color: UiConstants.whiteColor, size: 12.w),
          ),
        ),
      ),
    );
  }
}
