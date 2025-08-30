import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class MoreButton extends StatelessWidget {
  const MoreButton({super.key, required this.onTap, required this.isActive});

  final Function() onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 53.w,
        height: 53.w,
        decoration: BoxDecoration(
            color: UiConstants.whiteColor.withValues(alpha: isActive ? 1 : .5),
            shape: BoxShape.circle),
        padding: getMarginOrPadding(all: 0),
        child: Icon(Icons.more_horiz,
            color: isActive
                ? UiConstants.lightOrangeColor
                : UiConstants.dark2VioletColor,
            size: 35.w),
      ),
    );
  }
}
