import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class BuddyHintView extends StatelessWidget {
  const BuddyHintView({super.key, required this.onPay, required this.onClose});

  final Function() onPay;
  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: getMarginOrPadding(right: 56, left: 56),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientCard(
                contentPadding: getMarginOrPadding(all: 16),
                hasBlur: true,
                body: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Column(
                      children: [
                        Image.asset(Paths.buddy, height: 180.h),
                        SizedBox(height: 10.h),
                        Text(LocaleKeys.kTextHintMessage.tr(),
                            style: UiConstants.textStyle4
                                .copyWith(color: UiConstants.whiteColor),
                            textAlign: TextAlign.center),
                      ],
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        height: 30.w,
                        width: 30.w,
                        decoration: const BoxDecoration(
                            color: UiConstants.whiteColor,
                            shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded,
                            size: 20.w, color: UiConstants.blackColor),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16.w,
          left: 16.w,
          bottom: 60.h,
          child: CustomButton(
              title: '${LocaleKeys.kTextPay.tr()} \$1', onTap: onPay),
        ),
      ],
    );
  }
}

