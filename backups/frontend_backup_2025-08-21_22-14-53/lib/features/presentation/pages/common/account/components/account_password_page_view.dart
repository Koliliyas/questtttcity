import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';

class AccountPasswordPageView extends StatelessWidget {
  const AccountPasswordPageView(
      {super.key,
      required this.canEdit,
      required this.currentPasswordController,
      required this.newPasswordController,
      required this.newRepeatePasswordController});

  final bool canEdit;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController newRepeatePasswordController;

  @override
  Widget build(BuildContext context) {
    TextEditingController();
    return Column(
      children: [
        CustomTextField(
            hintText: LocaleKeys.kTextCurrentPassword.tr(),
            controller: currentPasswordController,
            textInputAction: TextInputAction.next,
            isExpanded: true,
            isObscuredText: true,
            isNeedShowHiddenTextIcon: true,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            fillColor: UiConstants.whiteColor,
            contentPadding:
                getMarginOrPadding(left: 20, right: 20, top: 20, bottom: 12),
            isEnabled: canEdit),
        SizedBox(height: 12.h),
        CustomTextField(
            hintText: LocaleKeys.kTextNewPassword.tr(),
            controller: newPasswordController,
            textInputAction: TextInputAction.next,
            isExpanded: true,
            isObscuredText: true,
            isNeedShowHiddenTextIcon: true,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            fillColor: UiConstants.whiteColor,
            contentPadding:
                getMarginOrPadding(left: 20, right: 20, top: 20, bottom: 12),
            isEnabled: canEdit),
        SizedBox(height: 12.h),
        CustomTextField(
            hintText: LocaleKeys.kTextRepeatNewPassword.tr(),
            controller: newRepeatePasswordController,
            textInputAction: TextInputAction.done,
            isExpanded: true,
            isObscuredText: true,
            isNeedShowHiddenTextIcon: true,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            fillColor: UiConstants.whiteColor,
            contentPadding:
                getMarginOrPadding(left: 20, right: 20, top: 20, bottom: 12),
            isEnabled: canEdit),
      ],
    );
  }
}

