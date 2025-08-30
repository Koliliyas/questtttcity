import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class CurrentQuestView extends StatelessWidget {
  final String questImage;
  final String questName;
  const CurrentQuestView({super.key, required this.questImage, required this.questName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49.h,
      padding: getMarginOrPadding(top: 4, bottom: 4, right: 6, left: 6),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor,
        borderRadius: BorderRadius.circular(19.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Image.network(questImage, height: 41.w, width: 41.w, fit: BoxFit.cover),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(questName,
                style: UiConstants.textStyle24.copyWith(color: UiConstants.blackColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          )
        ],
      ),
    );
  }
}
