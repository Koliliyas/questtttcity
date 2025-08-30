import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class AccountPersonalInformationPageView extends StatelessWidget {
  const AccountPersonalInformationPageView(
      {super.key,
      required this.canEdit,
      required this.nicknameController,
      required this.emailController});

  final bool canEdit;
  final TextEditingController nicknameController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hintText: LocaleKeys.kTextNickname.tr(),
          controller: nicknameController,
          textInputAction: TextInputAction.next,
          isExpanded: true,
          textStyle:
              UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
          fillColor: UiConstants.whiteColor,
          validator: (value) => Utils.validate(value),
          isEnabled: canEdit,
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          hintText: LocaleKeys.kTextEmail.tr(),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          isExpanded: true,
          textStyle:
              UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
          fillColor: UiConstants.whiteColor,
          validator: (value) => Utils.validate(value),
          inputFormatters: [
            FilteringTextInputFormatter.deny(
              RegExp(r'\s'),
            ),
          ],
          isEnabled: canEdit,
        ),
      ],
    );
  }
}

