import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ToolsCarouselItem extends StatelessWidget {
  const ToolsCarouselItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 216.w,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(Paths.artifactQuestMapIcon, fit: BoxFit.cover),
          ),
          SizedBox(height: 15.h),
          Text(
            LocaleKeys.kTextQuestMap.tr(),
            style:
                UiConstants.textStyle3.copyWith(color: UiConstants.whiteColor),
          ),
          SizedBox(height: 15.h),
          Text(LocaleKeys.kTextCheckItinerary.tr(),
              style: UiConstants.rememberTheUser
                  .copyWith(color: UiConstants.grayColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

