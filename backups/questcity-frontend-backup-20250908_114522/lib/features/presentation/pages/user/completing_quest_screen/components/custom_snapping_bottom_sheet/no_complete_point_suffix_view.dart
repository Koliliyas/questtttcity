import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/points_list.dart';

class NoCompletePointSuffixView extends StatelessWidget {
  const NoCompletePointSuffixView(
      {super.key, required this.pointStatus, required this.index});

  final PointStatus pointStatus;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 30.w,
          width: 30.w,
          decoration: BoxDecoration(
            color: pointStatus == PointStatus.current
                ? UiConstants.orangeColor
                : UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: UiConstants.textStyle4.copyWith(
                  color: pointStatus == PointStatus.current
                      ? UiConstants.whiteColor
                      : UiConstants.black2Color),
            ),
          ),
        ),
      ],
    );
  }
}
