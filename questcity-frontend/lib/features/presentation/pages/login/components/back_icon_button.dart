import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class BackIconButton extends StatelessWidget {
  const BackIconButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24.w,
        width: 24.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: UiConstants.darkVioletColor,
        ),
        child:
            Icon(Icons.arrow_back, color: UiConstants.whiteColor, size: 15.w),
      ),
    );
  }
}
