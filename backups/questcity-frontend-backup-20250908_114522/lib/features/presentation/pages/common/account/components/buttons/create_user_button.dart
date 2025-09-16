import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

class CreateUserButton extends StatelessWidget {
  const CreateUserButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
        title: LocaleKeys.kTextCreateUser.tr(),
        buttonColor: UiConstants.orangeColor,
        onTap: onTap);
  }
}

