import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class RequestsButton extends StatelessWidget {
  const RequestsButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      buttonColor: UiConstants.whiteColor,
      textColor: UiConstants.black2Color,
      title: '2 ${LocaleKeys.kTextRequests.tr().toLowerCase()}',
      onTap: onTap,
      height: 62.h,
      textPadding: EdgeInsets.zero,
      borderRadius: 24.r,
      iconRight: Image.asset(Paths.arrowForwardInCircleIconPath),
    );
  }
}

