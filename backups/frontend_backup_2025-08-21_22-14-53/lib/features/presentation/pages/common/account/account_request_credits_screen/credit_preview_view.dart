import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class CreditPageView extends StatelessWidget {
  const CreditPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCreditCard(LocaleKeys.kTextHollywoodHills.tr(),
            LocaleKeys.kText100credits.tr(), false, context),
        SizedBox(height: 8.h),
        _buildCreditCard(LocaleKeys.kTextHollywoodHills.tr(),
            LocaleKeys.kText50credits.tr(), false, context),
        SizedBox(height: 8.h),
        _buildCreditCard(LocaleKeys.kTextHollywoodHills.tr(),
            LocaleKeys.kText10credits.tr(), true, context),
      ],
    );
  }

  Widget _buildCreditCard(
      String title, String credits, bool accrued, BuildContext context) {
    return GradientCard(
      borderRadius: 24.r,
      contentPadding:
          getMarginOrPadding(top: 9, bottom: 9, left: 10, right: 10),
      body: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              Paths.quest2Path,
              fit: BoxFit.cover,
              width: 57.w,
              height: 57.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: UiConstants.textStyle4
                      .copyWith(color: UiConstants.whiteColor),
                ),
                Text(
                  credits,
                  style: UiConstants.textStyle11
                      .copyWith(color: UiConstants.orangeColor),
                ),
              ],
            ),
          ),
          if (accrued)
            Padding(
              padding: getMarginOrPadding(right: 18),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  color: UiConstants.greenColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: UiConstants.whiteColor),
              ),
            )
          else
            Container(
              padding:
                  getMarginOrPadding(top: 6, bottom: 6, right: 12, left: 12),
              decoration: BoxDecoration(
                color: UiConstants.orangeColor,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Text(
                LocaleKeys.kTextAccrue.tr(),
                style: UiConstants.rememberTheUser
                    .copyWith(color: UiConstants.whiteColor),
              ),
            ),
        ],
      ),
    );
  }
}
