import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class TryOurNewSubscriptionBody extends StatelessWidget {
  const TryOurNewSubscriptionBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '\$14.99 / ${LocaleKeys.kTextMonth.tr()}',
          style:
              UiConstants.textStyle3.copyWith(color: UiConstants.orangeColor),
        ),
        SizedBox(height: 24.h),
        const TryOutNewSubscriptionBodyItem(),
        SizedBox(height: 12.h),
        const TryOutNewSubscriptionBodyItem(),
        SizedBox(height: 12.h),
        const TryOutNewSubscriptionBodyItem(),
      ],
    );
  }
}

class TryOutNewSubscriptionBodyItem extends StatelessWidget {
  const TryOutNewSubscriptionBodyItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.kTextAdvantageSubscription.tr(),
          style: UiConstants.textStyle7.copyWith(color: UiConstants.whiteColor),
        ),
        SvgPicture.asset(Paths.ckeckInCircleIconPath,
            width: 24.w, height: 24.w),
      ],
    );
  }
}

