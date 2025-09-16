import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/my_credits_view/exchange_item.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ExchangeChoiceBody extends StatelessWidget {
  const ExchangeChoiceBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${LocaleKeys.kTextMyCredits.tr()}: ',
                style: UiConstants.textStyle3
                    .copyWith(color: UiConstants.whiteColor),
              ),
              TextSpan(
                text: '500',
                style: UiConstants.textStyle3
                    .copyWith(color: UiConstants.orangeColor),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        const ExchangeItem(creditsCount: 50)
      ],
    );
  }
}

