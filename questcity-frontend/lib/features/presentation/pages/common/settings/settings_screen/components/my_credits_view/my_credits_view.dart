import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/present_credits_screen/present_credits_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/settings_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/settings_screen_controller.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class MyCreditsView extends StatelessWidget {
  const MyCreditsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      contentPadding: getMarginOrPadding(all: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                TextSpan(
                  text: '/1000',
                  style: UiConstants.textStyle3
                      .copyWith(color: UiConstants.whiteColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                width: 84.w,
                child: SettingsButton(
                  title: LocaleKeys.kTextBuy.tr(),
                  icon: Paths.cardIconPath,
                  onTap: () => SettingsScreenController.showInputCreditsSheet(
                      context, CreditsActions.BUY),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: SettingsButton(
                  title: LocaleKeys.kTextPresent.tr(),
                  icon: Paths.giftIconPath,
                  onTap: () => Navigator.push(
                    context,
                    FadeInRoute(const PresentCreditsScreen(),
                        Routes.presentCreditsScreen),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: SettingsButton(
                  title: LocaleKeys.kTextExchange.tr(),
                  icon: Paths.changeCircleIconPath,
                  onTap: () =>
                      SettingsScreenController.showExchangeSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

