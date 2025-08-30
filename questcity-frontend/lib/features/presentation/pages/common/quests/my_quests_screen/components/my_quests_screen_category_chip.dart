import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class MyQuestsScreenCategoryChip extends StatelessWidget {
  const MyQuestsScreenCategoryChip(
      {super.key,
      this.text,
      this.icon,
      required this.isSelected,
      required this.onTap,
      required this.index});

  final String? text;
  final Widget? icon;
  final bool isSelected;
  final int index;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: getMarginOrPadding(top: 10, bottom: 10, right: 20, left: 20),
        decoration: BoxDecoration(
          color: isSelected ? UiConstants.orangeColor : UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: text != null
            ? Padding(
                padding: getMarginOrPadding(top: 2),
                child: Text(
                  text ?? '',
                  style: UiConstants.textStyle2
                      .copyWith(color: UiConstants.whiteColor),
                  textAlign: TextAlign.center,
                ),
              )
            : icon,
      ),
    );
  }
}
