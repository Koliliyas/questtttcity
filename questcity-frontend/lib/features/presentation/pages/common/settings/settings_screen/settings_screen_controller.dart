import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/custom_bottom_sheet_template.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/present_credits_screen/components/choose_card_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/present_credits_screen/components/present_credits_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/my_credits_view/exchange_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/my_credits_view/exchange_choice_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/language_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/subscription_payment_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/try_our_new_subscription_body.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class SettingsScreenController {
  static showTryOurNewSubscriptionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 380,
        isBack: false,
        titleText: LocaleKeys.kTextTryNewSubscription.tr(),
        isBackgroundImage: true,
        onTapButton: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            showSubscriptionPaymentSheet(context);
          }
        },
        buttonText: LocaleKeys.kTextPaySubscription.tr(),
        body: const TryOurNewSubscriptionBody(),
      ),
    );
  }

  static showChangeLanguageSheet(
      BuildContext context, Function(Locale locale) onChangeLocale) {
    Locale locale = context.locale;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 366,
        isBack: true,
        onTapBack: () => Navigator.pop(context),
        titleText: LocaleKeys.kTextLanguage.tr(),
        isBackgroundImage: true,
        onTapButton: () {
          Navigator.pop(context);
          onChangeLocale(locale);
        },
        buttonText: LocaleKeys.kTextConfirmChanges.tr(),
        body: LanguageBody(
            onChangeLocale: (Locale newLocale) => locale = newLocale),
      ),
    );
  }

  static showSubscriptionPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 572,
        isBack: true,
        onTapBack: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            showTryOurNewSubscriptionSheet(context);
          }
        },
        titleText: LocaleKeys.kTextSubscriptionPayment.tr(),
        isBackgroundImage: true,
        onTapButton: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            showSubscriptionIsActiveSheet(context);
          }
        },
        buttonText: '${LocaleKeys.kTextPurchase.tr()} \$14.99',
        body: const SubscriptionPaymentBody(),
      ),
    );
  }

  static showSubscriptionIsActiveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 286,
        isBack: false,
        titleText: LocaleKeys.kTextSubscriptionActive.tr(),
        isBackgroundImage: true,
        onTapButton: () => Navigator.pop(context),
        buttonText: LocaleKeys.kTextOkay.tr(),
        body: Text(
          LocaleKeys.kTextSubscriptionDaysLeft.tr(),
          style:
              UiConstants.textStyle7.copyWith(color: UiConstants.orangeColor),
        ),
      ),
    );
  }

  static showInputCreditsSheet(
      BuildContext context, CreditsActions creditsAction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: creditsAction == CreditsActions.BUY ? 294 : 334,
        isBackgroundImage: true,
        isBack: false,
        titleText: creditsAction == CreditsActions.BUY
            ? LocaleKeys.kTextNumberOfCredits.tr()
            : LocaleKeys.kTextPresentCreditsTo.tr(),
        body: PresentCreditsBody(
            creditsAction: creditsAction,
            onButtonTap: (int creditsCount) async {
              Navigator.pop(context);
              await Future.delayed(
                const Duration(milliseconds: 200),
              );
              if (context.mounted) {
                chooseCardSheet(context, creditsCount, creditsAction);
              }
            }),
      ),
    );
  }

  static chooseCardSheet(
      BuildContext context, int creditsCount, CreditsActions creditsAction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: creditsAction == CreditsActions.BUY ? 376 : 466,
        isBackgroundImage: true,
        isBack: true,
        onTapBack: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            creditsAction == CreditsActions.EXCHANGE
                ? showExchangeChoiceSheet(context)
                : showInputCreditsSheet(context, creditsAction);
          }
        },
        titleText: LocaleKeys.kTextChooseTheCard.tr(),
        body: ChooseCardBody(
            creditsAction: creditsAction,
            creditsCount: creditsCount,
            onButtonTap: () => Navigator.pop(context)),
      ),
    );
  }

  static showExchangeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 564,
        isBack: false,
        titleText: LocaleKeys.kTextExchange.tr(),
        isBackgroundImage: true,
        onTapButton: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            showExchangeChoiceSheet(context);
          }
        },
        buttonText: LocaleKeys.kTextNext.tr(),
        body: const ExchangeBody(),
      ),
    );
  }

  static showExchangeChoiceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 338,
        isBack: true,
        onTapBack: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            showExchangeSheet(context);
          }
        },
        titleText: 'Hollywood Hills',
        isBackgroundImage: true,
        onTapButton: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            chooseCardSheet(context, 5, CreditsActions.EXCHANGE);
          }
        },
        buttonText: LocaleKeys.kTextExchangeCredits.tr(),
        body: const ExchangeChoiceBody(),
      ),
    );
  }
}

enum CreditsActions { EXCHANGE, BUY, PRESENT }

