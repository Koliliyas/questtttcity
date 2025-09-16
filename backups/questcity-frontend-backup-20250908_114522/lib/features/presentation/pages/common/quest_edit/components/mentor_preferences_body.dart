import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';

class MentorPreferencesBody extends StatelessWidget {
  final TextEditingController mentorPreferenceController;

  const MentorPreferencesBody({
    super.key,
    required this.mentorPreferenceController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
            hintText: 'Name of the file.xlsx',
            controller: mentorPreferenceController,
            fillColor: UiConstants.whiteColor,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            textColor: UiConstants.blackColor,
            isExpanded: true,
            isEnabled: true,
            validator: (value) => Utils.validate(value),
            textInputAction: TextInputAction.next),
      ],
    );
  }
}
