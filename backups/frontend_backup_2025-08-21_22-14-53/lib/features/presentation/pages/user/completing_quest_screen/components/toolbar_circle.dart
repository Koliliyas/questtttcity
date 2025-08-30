import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class ToolbarCircle extends StatelessWidget {
  const ToolbarCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84.h,
      decoration: BoxDecoration(
        color: UiConstants.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: UiConstants.whiteColor.withValues(alpha: .25),
              offset: const Offset(0, 0),
              blurRadius: 11.8),
          BoxShadow(
              color: UiConstants.whiteColor.withValues(alpha: .25),
              offset: const Offset(0, 0),
              blurRadius: 11.8),
        ],
      ),
    );
  }
}
