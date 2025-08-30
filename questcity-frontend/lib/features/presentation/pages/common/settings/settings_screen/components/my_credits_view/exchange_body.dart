import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/my_credits_view/exchange_item.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ExchangeBody extends StatefulWidget {
  const ExchangeBody({super.key});

  @override
  State<ExchangeBody> createState() => _SubscriptionPaymentBodyState();
}

class _SubscriptionPaymentBodyState extends State<ExchangeBody> {
  int checkedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 564 - 100,
      child: Column(
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
          SizedBox(height: 12.h),
          Text(
            LocaleKeys.kTextQuestSelectionInstructions.tr(),
            style:
                UiConstants.textStyle2.copyWith(color: UiConstants.whiteColor),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.separated(
                padding: getMarginOrPadding(bottom: 100),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) => ExchangeItem(
                      isChecked: checkedIndex == index,
                      onTap: () => setState(
                        () => checkedIndex = index,
                      ),
                      creditsCount: 100,
                    ),
                separatorBuilder: (BuildContext context, int index) =>
                    SizedBox(height: 8.h),
                itemCount: 10),
          )
        ],
      ),
    );
  }
}

