import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class EmptyStatisticsView extends StatelessWidget {
  const EmptyStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: getMarginOrPadding(bottom: 120, left: 60, right: 60),
        child: Center(
          child: Text(LocaleKeys.kTextDisplayStatsForQuest.tr(),
              style: UiConstants.textStyle7.copyWith(
                color: UiConstants.whiteColor.withValues(alpha: .67),
              ),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

