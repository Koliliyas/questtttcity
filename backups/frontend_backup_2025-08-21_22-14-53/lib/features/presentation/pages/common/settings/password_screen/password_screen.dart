import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/password_screen/cubit/password_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/locator_service.dart';

class PasswordScreen extends StatelessWidget {
  PasswordScreen({super.key});

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newRepeatePasswordController = TextEditingController();
  bool get valid =>
      _newRepeatePasswordController.text == _newPasswordController.text &&
      _newPasswordController.text.length >= 8 &&
      _currentPasswordController.text.isNotEmpty;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordScreenCubit(
        sl(),
      ),
      child: BlocBuilder<PasswordScreenCubit, PasswordScreenState>(
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Paths.backgroundGradient1Path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high),
              ),
              child: Padding(
                padding: getMarginOrPadding(
                    top: MediaQuery.of(context).padding.top + 20, left: 16, right: 16, bottom: 12),
                child: Column(
                  children: [
                    CustomAppBar(
                        onTapBack: () => Navigator.pop(context),
                        title: LocaleKeys.kTextPassword.tr()),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      height: 67.h,
                      hintText: LocaleKeys.kTextCurrentPassword.tr(),
                      controller: _currentPasswordController,
                      textInputAction: TextInputAction.next,
                      isExpanded: true,
                      isObscuredText: true,
                      isNeedShowHiddenTextIcon: true,
                      textStyle: UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
                      fillColor: UiConstants.whiteColor,
                      contentPadding: getMarginOrPadding(left: 20, right: 20, top: 20, bottom: 20),
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      height: 67.h,
                      hintText: LocaleKeys.kTextNewPassword.tr(),
                      controller: _newPasswordController,
                      textInputAction: TextInputAction.next,
                      isExpanded: true,
                      isObscuredText: true,
                      isNeedShowHiddenTextIcon: true,
                      textStyle: UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
                      fillColor: UiConstants.whiteColor,
                      contentPadding: getMarginOrPadding(left: 20, right: 20, top: 20, bottom: 20),
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      height: 67.h,
                      hintText: LocaleKeys.kTextRepeatNewPassword.tr(),
                      controller: _newRepeatePasswordController,
                      textInputAction: TextInputAction.done,
                      isExpanded: true,
                      isObscuredText: true,
                      isNeedShowHiddenTextIcon: true,
                      textStyle: UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
                      fillColor: UiConstants.whiteColor,
                      contentPadding: getMarginOrPadding(left: 20, right: 20, top: 20, bottom: 20),
                    ),
                    const Spacer(),
                    CustomButton(
                        textColor: valid ? null : UiConstants.whiteColor,
                        buttonColor: valid ? null : UiConstants.lightGrayColor,
                        // isActive: valid,
                        title: LocaleKeys.kTextSaveChanges.tr(),
                        onTap: valid
                            ? () async {
                                final currentContext = context;
                                await currentContext.read<PasswordScreenCubit>().updatePassword(
                                    _currentPasswordController.text,
                                    _newRepeatePasswordController.text,
                                    _newRepeatePasswordController.text);
                                Navigator.pop(currentContext);
                              }
                            : null),
                    SizedBox(height: 65.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

