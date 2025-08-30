import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ExcludeFriendView extends StatelessWidget {
  const ExcludeFriendView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      contentPadding: getMarginOrPadding(all: 16),
      body: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 48.w / 2,
                child: ClipOval(
                  child: Image.asset(
                    Paths.avatarPath,
                    fit: BoxFit.cover,
                    width: 48.w,
                    height: 48.w,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Tomas Andersen',
                  style: UiConstants.textStyle5
                      .copyWith(color: UiConstants.whiteColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(LocaleKeys.kTextExcludeFriendConfirmation.tr(),
              style: UiConstants.textStyle5
                  .copyWith(color: UiConstants.whiteColor),
              textAlign: TextAlign.center),
          SizedBox(height: 22.h),
          Text(LocaleKeys.kTextExcludeFriendWarning.tr(),
              style: UiConstants.textStyle7
                  .copyWith(color: UiConstants.whiteColor),
              textAlign: TextAlign.center)
        ],
      ),
    );
  }
}

