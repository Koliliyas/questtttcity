import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/formatters/card_number_formatter.dart';
import 'package:los_angeles_quest/core/formatters/cvv_input_formatter.dart';
import 'package:los_angeles_quest/core/formatters/date_input_formatter.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class AddNewCardBody extends StatelessWidget {
  const AddNewCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController cardNumberController = TextEditingController();
    TextEditingController fullNameController = TextEditingController();
    TextEditingController cvvController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    return SizedBox(
      height: 446 - 100,
      child: Column(
        children: [
          CustomTextField(
            hintText: '0000 0000 0000 0000',
            controller: cardNumberController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            isExpanded: true,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            fillColor: UiConstants.whiteColor,
            isTextFieldInBottomSheet: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberFormatter()
            ],
          ),
          SizedBox(height: 12.h),
          CustomTextField(
              hintText: LocaleKeys.kTextFullName.tr(),
              controller: fullNameController,
              textInputAction: TextInputAction.next,
              isExpanded: true,
              textStyle: UiConstants.textStyle12
                  .copyWith(color: UiConstants.blackColor),
              fillColor: UiConstants.whiteColor,
              isTextFieldInBottomSheet: true),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: '***',
                  controller: cvvController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  isExpanded: true,
                  textStyle: UiConstants.textStyle12
                      .copyWith(color: UiConstants.blackColor),
                  fillColor: UiConstants.whiteColor,
                  isTextFieldInBottomSheet: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CvvInputFormatter()
                  ],
                ),
              ),
              SizedBox(width: 22.w),
              Expanded(
                child: CustomTextField(
                  hintText: '00/00',
                  controller: dateController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.done,
                  isExpanded: true,
                  textStyle: UiConstants.textStyle12
                      .copyWith(color: UiConstants.blackColor),
                  fillColor: UiConstants.whiteColor,
                  isTextFieldInBottomSheet: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    DateInputFormatter()
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          CustomButton(
            title: LocaleKeys.kTextAddNewCard.tr(),
            onTap: () => Navigator.pop(context),
          ),
          SizedBox(height: 23.h),
        ],
      ),
    );
  }
}

