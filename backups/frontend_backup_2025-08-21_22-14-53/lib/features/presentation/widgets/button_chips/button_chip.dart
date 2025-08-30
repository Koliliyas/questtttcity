import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class ButtonChip extends StatelessWidget {
  const ButtonChip(
      {super.key,
      required this.onTap,
      required this.index,
      required this.isSelected,
      required this.title});

  final Function(int index) onTap;
  final int index;
  final bool isSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: getMarginOrPadding(left: 20, right: 20, bottom: 10, top: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? UiConstants.lightOrangeColor
              : UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(
          title,
          style: UiConstants.rememberTheUser
              .copyWith(color: UiConstants.whiteColor),
        ),
      ),
    );
  }
}
