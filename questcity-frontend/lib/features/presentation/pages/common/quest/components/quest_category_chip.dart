import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class QuestCategoryChip extends StatelessWidget {
  const QuestCategoryChip({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(left: 13, right: 13, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: [
          BoxShadow(
              offset: Offset(0, 4.h),
              blurRadius: 15.5.r,
              color: UiConstants.shadow2Color),
        ],
      ),
      child: Text(
        title,
        style: UiConstants.textStyle19.copyWith(color: UiConstants.whiteColor),
      ),
    );
  }
}
