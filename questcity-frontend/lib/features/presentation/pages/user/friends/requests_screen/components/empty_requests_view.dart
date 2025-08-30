import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class EmptyRequestsView extends StatelessWidget {
  const EmptyRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getMarginOrPadding(bottom: 156),
      child: Center(
        child: Text(
          LocaleKeys.kTextNoRequestsYet.tr(),
          style: UiConstants.textStyle7.copyWith(color: UiConstants.whiteColor),
        ),
      ),
    );
  }
}

