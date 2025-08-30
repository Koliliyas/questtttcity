import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/statistics_card_body_item.dart';
// ignore: unused_import
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/statistics_screen.dart';

class StatisticsCardBody extends StatelessWidget {
  const StatisticsCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: getMarginOrPadding(top: 18),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => [
              StatisticsCardBodyItem(
                  title: LocaleKeys.kTextQuestPurchases.tr(), value: '1254'),
              StatisticsCardBodyItem(
                  title: LocaleKeys.kTextPaymentByCredits.tr(),
                  value: '\$1254'),
              StatisticsCardBodyItem(
                  title: LocaleKeys.kTextQuestRevenue.tr(),
                  value: '\$1254',
                  isRevenueField: true)
            ][index],
        separatorBuilder: (context, index) => Padding(
              padding: getMarginOrPadding(top: 2, bottom: 2),
              child: Divider(
                color: UiConstants.lightVioletColor.withValues(alpha: .58),
              ),
            ),
        itemCount: 3);
  }
}

