import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view_item.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class CreditsPreferencesBody extends StatelessWidget {
  const CreditsPreferencesBody(
      {super.key,
      this.radioIndex,
      required this.creditsAccrueController,
      required this.creditsPaysController,
      required this.changeManualOrAutoRadio});

  final int? radioIndex;
  final Function(int radioIndex) changeManualOrAutoRadio;
  final TextEditingController creditsAccrueController;
  final TextEditingController creditsPaysController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (radioIndex != null) _buildRadiusOptions(),
        SizedBox(height: 12.h),
        CustomTextField(
            hintText: LocaleKeys.kTextCreditsToAccrue.tr(),
            controller: creditsAccrueController,
            keyboardType: TextInputType.number,
            fillColor: UiConstants.whiteColor,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            textColor: UiConstants.blackColor,
            isExpanded: true,
            validator: (value) => Utils.validate(value),
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ),
              FilteringTextInputFormatter.digitsOnly
            ],
            textInputAction: TextInputAction.next),
        SizedBox(height: 12.h),
        CustomTextField(
            hintText: LocaleKeys.kTextCreditsForQuest.tr(),
            controller: creditsPaysController,
            keyboardType: TextInputType.number,
            fillColor: UiConstants.whiteColor,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            textColor: UiConstants.blackColor,
            isExpanded: true,
            validator: (value) => Utils.validate(value),
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ),
              FilteringTextInputFormatter.digitsOnly
            ],
            textInputAction: TextInputAction.done),
      ],
    );
  }

  Widget _buildRadiusOptions() {
    return Row(
      children: [
        Expanded(
          child: QuestPreferenceViewItem(
            preferencesItem: QuestPreferenceItem(LocaleKeys.kTextManual.tr()),
            isChecked: radioIndex == 0,
            onTap: (preferencesIndex, preferencesItemIndex,
                    {bool preferencesItemHasSubitems = false,
                    int? preferencesSubItemIndex}) =>
                changeManualOrAutoRadio(0),
            index: 0,
            preferenceIndex: 0,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: QuestPreferenceViewItem(
            preferencesItem: QuestPreferenceItem(LocaleKeys.kTextAuto.tr()),
            isChecked: radioIndex == 1,
            onTap: (preferencesIndex, preferencesItemIndex,
                    {bool preferencesItemHasSubitems = false,
                    int? preferencesSubItemIndex}) =>
                changeManualOrAutoRadio(1),
            index: 1,
            preferenceIndex: 0,
          ),
        ),
      ],
    );
  }
}

