import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';

class MentorPreferencesBodyWithSwitch extends StatelessWidget {
  final bool hasMentor;
  final Function(bool) onChanged;

  const MentorPreferencesBodyWithSwitch({
    super.key,
    required this.hasMentor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Отладочная информация
    print('🔍 DEBUG: MentorPreferencesBodyWithSwitch.build()');
    print('  - hasMentor: $hasMentor');
    print('  - hasMentor type: ${hasMentor.runtimeType}');

    return Column(
      children: [
        // Boolean переключатель
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: UiConstants.greyColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasMentor ? 'Yes' : 'No',
                style: UiConstants.textStyle14.copyWith(
                  color: UiConstants.blackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: hasMentor,
                onChanged: onChanged,
                activeColor: UiConstants.orangeColor,
                activeTrackColor: UiConstants.orangeColor.withOpacity(0.3),
                inactiveThumbColor: UiConstants.greyColor,
                inactiveTrackColor: UiConstants.greyColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Описание
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: UiConstants.greyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: UiConstants.greyColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasMentor
                      ? 'Mentor is required for this quest'
                      : 'No mentor required for this quest',
                  style: UiConstants.textStyle12.copyWith(
                    color: UiConstants.greyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
