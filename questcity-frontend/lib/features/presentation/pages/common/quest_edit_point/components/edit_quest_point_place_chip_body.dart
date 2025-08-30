import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class EditQuestPointPlaceChipBody extends StatelessWidget {
  const EditQuestPointPlaceChipBody({
    super.key,
    required this.coordinate1Controller,
    required this.coordinate2Controller,
    required this.onTapCoordinateField,
    required this.onChangeRadiusOfRandomOccurrenceValue,
    required this.radiusOfRandomOccurrenceIndex,
  });

  final TextEditingController coordinate1Controller;
  final TextEditingController coordinate2Controller;
  final Function(bool isFirstCoordinate) onTapCoordinateField;
  final int radiusOfRandomOccurrenceIndex;
  final Function(int index) onChangeRadiusOfRandomOccurrenceValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(LocaleKeys.kTextCoordinates.tr()),
        SizedBox(height: 12.h),
        _buildCoordinateField(coordinate1Controller,
            '${LocaleKeys.kTextCoordinate.tr()} (1)', true),
        SizedBox(height: 12.h),
        _buildCoordinateField(coordinate2Controller,
            '${LocaleKeys.kTextCoordinate.tr()} (2)', false),
        SizedBox(height: 28.h),
        _buildSectionTitle(LocaleKeys.kTextDetectionRadius.tr()),
        SizedBox(height: 12.h),
        _buildReadOnlyTextField('5-10 m'),
        SizedBox(height: 28.h),
        _buildSectionTitle(LocaleKeys.kTextHeight.tr()),
        SizedBox(height: 12.h),
        _buildReadOnlyTextField('5-10 m'),
        SizedBox(height: 28.h),
        _buildSectionTitle(LocaleKeys.kTextRandomRadius.tr()),
        SizedBox(height: 12.h),
        _buildRadiusOptions(),
        SizedBox(height: 12.h),
        _buildReadOnlyTextField('5-10 m'),
        SizedBox(height: 28.h),
        _buildSectionTitle(LocaleKeys.kTextInteractionInaccuracy.tr()),
        SizedBox(height: 12.h),
        _buildReadOnlyTextField('5-10 m'),
        SizedBox(height: 28.h),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: UiConstants.textStyle8.copyWith(color: UiConstants.whiteColor),
    );
  }

  Widget _buildCoordinateField(TextEditingController controller,
      String hintText, bool isFirstCoordinate) {
    return GestureDetector(
      onTap: () => onTapCoordinateField(isFirstCoordinate),
      child: CustomTextField(
        hintText: hintText,
        controller: controller,
        fillColor: UiConstants.whiteColor,
        textStyle:
            UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
        textColor: UiConstants.blackColor,
        isExpanded: true,
        isEnabled: false,
      ),
    );
  }

  Widget _buildReadOnlyTextField(String hintText) {
    return CustomTextField(
      hintText: hintText,
      controller: TextEditingController(),
      fillColor: UiConstants.whiteColor,
      textStyle:
          UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
      textColor: UiConstants.blackColor,
      isExpanded: true,
      isEnabled: false,
    );
  }

  Widget _buildRadiusOptions() {
    return Row(
      children: [
        Expanded(
          child: QuestPreferenceViewItem(
            preferencesItem: QuestPreferenceItem(LocaleKeys.kTextYes.tr()),
            isChecked: radiusOfRandomOccurrenceIndex == 0,
            onTap: (preferencesIndex, preferencesItemIndex,
                    {bool preferencesItemHasSubitems = false,
                    int? preferencesSubItemIndex}) =>
                onChangeRadiusOfRandomOccurrenceValue(preferencesItemIndex),
            index: 0,
            preferenceIndex: 0,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: QuestPreferenceViewItem(
            preferencesItem: QuestPreferenceItem(LocaleKeys.kTextNo.tr()),
            isChecked: radiusOfRandomOccurrenceIndex == 1,
            onTap: (preferencesIndex, preferencesItemIndex,
                    {bool preferencesItemHasSubitems = false,
                    int? preferencesSubItemIndex}) =>
                onChangeRadiusOfRandomOccurrenceValue(preferencesItemIndex),
            index: 1,
            preferenceIndex: 0,
          ),
        ),
      ],
    );
  }
}

