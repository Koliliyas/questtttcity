import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/new_password_screen/cubit/new_password_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/components/back_icon_button.dart';
import 'package:los_angeles_quest/locator_service.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NewPasswordScreenCubit(email: email, verifyResetPassword: sl()),
      child: BlocBuilder<NewPasswordScreenCubit, NewPasswordScreenState>(
        builder: (context, state) {
          NewPasswordScreenCubit cubit = context.read<NewPasswordScreenCubit>();
          NewPasswordScreenInitial loadedState = state as NewPasswordScreenInitial;
          return Scaffold(
            body: Form(
              key: cubit.formKey,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(Paths.backgroundLandscape),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: getMarginOrPadding(
                            left: 16, right: 16, bottom: 44, top: 44),
                        child: BlurryContainer(
                          blur: 30,
                          borderRadius: BorderRadius.circular(40.r),
                          padding: EdgeInsets.zero,
                          child: Container(
                            padding: getMarginOrPadding(
                                left: 16, right: 16, top: 24, bottom: 24),
                            decoration: BoxDecoration(
                              color: UiConstants.grayColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    BackIconButton(
                                      onTap: () => Navigator.pop(context),
                                    ),
                                    SizedBox(width: 15.w),
                                    Text(
                                      LocaleKeys.kTextNewPassword.tr(),
                                      style: UiConstants.signUpp.copyWith(
                                          color: UiConstants.whiteColor,
                                          height: 1),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                Padding(
                                  padding:
                                      getMarginOrPadding(right: 16, left: 16),
                                  child: Text(
                                    LocaleKeys
                                        .kTextEnterTheCodeWeSentYouToYourEmail
                                        .tr(),
                                    style: UiConstants.textStyle16.copyWith(
                                        color: UiConstants.whiteColor),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                CustomTextField(
                                  hintText: LocaleKeys.kTextCode.tr(),
                                  controller: cubit.codeController,
                                  fillColor: UiConstants.whiteColor,
                                  textStyle: UiConstants.textStyle12
                                      .copyWith(color: UiConstants.blackColor),
                                  textColor: UiConstants.blackColor,
                                  isExpanded: true,
                                  validator: (value) => Utils.validate(value),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(6),
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChangedField: (_) => cubit.onTextChanged(),
                                ),
                                SizedBox(height: 20.h),
                                CustomTextField(
                                  height: 57.h,
                                  hintText: LocaleKeys.kTextNewPassword.tr(),
                                  controller: cubit.passwordController,
                                  fillColor: UiConstants.whiteColor,
                                  textStyle: UiConstants.textStyle12
                                      .copyWith(color: UiConstants.blackColor),
                                  textColor: UiConstants.blackColor,
                                  isObscuredText: true,
                                  contentPadding: getMarginOrPadding(
                                      left: 20, right: 20, top: 30),
                                  isNeedShowHiddenTextIcon: true,
                                  validator: (value) => Utils.validate(value),
                                  onChangedField: (_) => cubit.onTextChanged(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),
                                  ],
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 16.h),
                                CustomTextField(
                                  height: 57.h,
                                  hintText:
                                      LocaleKeys.kTextRepeatNewPassword.tr(),
                                  controller: cubit.repeatPasswordController,
                                  fillColor: UiConstants.whiteColor,
                                  textStyle: UiConstants.textStyle12
                                      .copyWith(color: UiConstants.blackColor),
                                  textColor: UiConstants.blackColor,
                                  isObscuredText: true,
                                  contentPadding: getMarginOrPadding(
                                      left: 20, right: 20, top: 30, bottom: 0),
                                  isNeedShowHiddenTextIcon: true,
                                  validator: (value) => Utils.validate(value),
                                  onChangedField: (_) => cubit.onTextChanged(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),
                                  ],
                                  textInputAction: TextInputAction.done,
                                ),
                                SizedBox(height: 16.h),
                                CustomButton(
                                    height: 57.h,
                                    title: LocaleKeys.kTextSaveChanges.tr(),
                                    onTap: loadedState.allFieldsValidate
                                        ? () => cubit.verifyPassword(context)
                                        : null,
                                    textColor: loadedState.allFieldsValidate
                                        ? null
                                        : UiConstants.whiteColor,
                                    buttonColor: loadedState.allFieldsValidate
                                        ? null
                                        : UiConstants.lightGrayColor,
                                    hasGradient: false),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

