import 'package:flutter/material.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: CustomButton(
              title: LocaleKeys.kTextLogOut.tr(),
              buttonColor: UiConstants.redColor,
              onTap: onTap,
              hasGradient: false),
        ),
        const Spacer(),
      ],
    );
  }
}

