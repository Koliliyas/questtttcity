import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class CustomSnappingBottomHeader extends StatelessWidget {
  final String questName;
  final String mileage;
  final int spots;
  const CustomSnappingBottomHeader(
      {super.key, required this.questName, required this.mileage, required this.spots});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(questName,
            style: UiConstants.textStyle6.copyWith(color: UiConstants.whiteColor),
            textAlign: TextAlign.center),
        SizedBox(height: 3.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mileage,
              style: UiConstants.textStyle7.copyWith(color: UiConstants.orangeColor),
            ),
            SizedBox(width: 14.w),
            Text(
              '$spots ${LocaleKeys.kTextSpots.tr().toLowerCase()}',
              style: UiConstants.textStyle7.copyWith(color: UiConstants.orangeColor),
            ),
          ],
        ),
      ],
    );
  }
}

