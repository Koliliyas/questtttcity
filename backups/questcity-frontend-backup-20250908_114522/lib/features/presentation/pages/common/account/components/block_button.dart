import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class BlockButton extends StatelessWidget {
  const BlockButton({super.key, required this.onTap, required this.isBlocked});

  final Function() onTap;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 53.w,
        height: 53.w,
        decoration: BoxDecoration(
            color: isBlocked ? UiConstants.whiteColor : UiConstants.redColor,
            shape: BoxShape.circle),
        padding: getMarginOrPadding(all: 12),
        child: Transform.flip(
          flipX: true,
          child: Icon(Icons.block,
              color:
                  isBlocked ? UiConstants.blackColor : UiConstants.whiteColor),
        ),
      ),
    );
  }
}
