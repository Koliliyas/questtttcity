import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      contentPadding:
          getMarginOrPadding(left: 34, right: 34, bottom: 34, top: 16),
      body: Column(
        children: [
          Image.asset(Paths.bigCheckInCircle),
          SizedBox(height: 10.h),
          Text(LocaleKeys.kTextInvitationsSent.tr(),
              style: UiConstants.textStyle4
                  .copyWith(color: UiConstants.whiteColor),
              textAlign: TextAlign.center)
        ],
      ),
    );
  }
}

