import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestEditPointItem extends StatelessWidget {
  const QuestEditPointItem(
      {super.key,
      required this.title,
      required this.onTap,
      this.isRequired = true,
      this.isFilledData = false,
      required this.controller,
      required this.onDeletePoint});

  final String title;
  final Function() onTap;
  final bool isRequired;
  final bool isFilledData;
  final TextEditingController controller;
  final Function() onDeletePoint;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      borderRadius: 24.r,
      onTap: onTap,
      contentPadding: getMarginOrPadding(all: 20),
      body: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: UiConstants.textStyle11
                    .copyWith(color: UiConstants.whiteColor),
              ),
              Padding(
                padding: getMarginOrPadding(left: 16),
                child: isFilledData
                    ? SvgPicture.asset(Paths.checkInCircleIconPath,
                        height: 24.w, width: 24.w)
                    : SizedBox(height: 24.w, width: 24.w),
              ),
              const Spacer(),
              Visibility(
                visible: !isRequired,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                      color: UiConstants.whiteColor.withValues(alpha: .46),
                      shape: BoxShape.circle),
                  child: GestureDetector(
                    onTap: onDeletePoint,
                    child: Icon(Icons.close_rounded,
                        size: 17.w, color: UiConstants.whiteColor),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: LocaleKeys.kTextLocationName.tr(),
                  controller: controller,
                  fillColor: UiConstants.whiteColor,
                  textStyle: UiConstants.textStyle12
                      .copyWith(color: UiConstants.blackColor),
                  textColor: UiConstants.blackColor,
                  isExpanded: true,
                  validator: (value) => Utils.validate(value),
                ),
              ),
              SizedBox(width: 10.w),
              GradientCard(
                height: 58.w,
                color: UiConstants.orangeColor,
                beginGradient: Alignment.centerLeft,
                endGradient: Alignment.centerRight,
                shape: BoxShape.circle,
                body: Icon(Icons.keyboard_arrow_right_rounded,
                    size: 30.w, color: UiConstants.whiteColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}

