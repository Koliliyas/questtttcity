import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/cubit/custom_bottom_sheet_template_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/cubit/custom_text_field_state.dart';

class CustomTextFieldCubit extends Cubit<CustomTextFieldState> {
  CustomTextFieldCubit()
      : super(const CustomTextFieldState(isValid: true, isNotEmpty: false));

  void onEditingComplete(String value, bool isTextFieldInBottomSheet,
      BuildContext context, Key? key,
      {RegExp? regExp, String? customErrorText}) {
    bool isValid = true;
    bool isNotEmpty = false;
    String? errorText;

    if (value.isEmpty) {
      isValid = false;
      errorText = LocaleKeys.kTextFieldCannotBeEmpty.tr();
      if (isTextFieldInBottomSheet) {
        context
            .read<CustomBottomSheetTemplateCubit>()
            .addHeightToBottomSheet(true, key!);
      }
    } else {
      isNotEmpty = true;
      if (regExp != null) {
        isValid = regExp.hasMatch(value);
        if (!isValid) {
          errorText = customErrorText ?? '';
        }
      }
      if (isTextFieldInBottomSheet) {
        context
            .read<CustomBottomSheetTemplateCubit>()
            .addHeightToBottomSheet(false, key!);
      }
    }

    emit(CustomTextFieldState(
        isValid: isValid, isNotEmpty: isNotEmpty, errorText: errorText));
  }
}

