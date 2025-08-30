import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class StatisticsCardBodyItem extends StatelessWidget {
  const StatisticsCardBodyItem(
      {super.key,
      this.isRevenueField = false,
      required this.title,
      required this.value});

  final String title;
  final String value;
  final bool isRevenueField;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: UiConstants.textStyle20
                  .copyWith(color: UiConstants.whiteColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 15.w),
        Text(
          value,
          style: (isRevenueField
                  ? UiConstants.textStyle18
                  : UiConstants.textStyle20)
              .copyWith(
                  color: isRevenueField
                      ? UiConstants.orangeColor
                      : UiConstants.whiteColor,
                  fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
