import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class AddressBody extends StatelessWidget {
  const AddressBody({super.key, required this.onButtonTap});

  final Function() onButtonTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 197,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomTextField(
            isTextFieldInBottomSheet: true,
            hintText: 'Adress...',
            controller: TextEditingController(),
            fillColor: UiConstants.whiteColor,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            textColor: UiConstants.blackColor,
            isExpanded: true,
            validator: (value) => Utils.validate(value),
          ),
          SizedBox(height: 22.h),
          CustomButton(title: LocaleKeys.kTextNext.tr(), onTap: onButtonTap),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

