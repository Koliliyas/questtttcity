import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

class SaveChangesButton extends StatelessWidget {
  const SaveChangesButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
        title: LocaleKeys.kTextSaveChanges.tr(),
        buttonColor: UiConstants.orangeColor,
        onTap: onTap);
  }
}

