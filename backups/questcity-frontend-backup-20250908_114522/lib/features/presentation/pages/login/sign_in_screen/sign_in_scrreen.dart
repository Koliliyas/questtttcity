import 'package:los_angeles_quest/utils/logger.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/home_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/log_in_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/sign_in_screen/cubit/sign_in_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/locator_service.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInScreenCubit(authRegister: sl()),
      child: BlocBuilder<SignInScreenCubit, SignInScreenState>(
        builder: (context, state) {
          SignInScreenCubit cubit = context.read<SignInScreenCubit>();
          SignInScreenInitial loadedState = state as SignInScreenInitial;
          return Scaffold(
            body: Form(
              key: cubit.formKey,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(Paths.backgroundLandscape), fit: BoxFit.cover),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: getMarginOrPadding(left: 16, right: 16, bottom: 44, top: 49),
                      child: BlurryContainer(
                        blur: 30,
                        borderRadius: BorderRadius.circular(40.r),
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: getMarginOrPadding(left: 24, right: 24, top: 24),
                          decoration: BoxDecoration(
                            color: UiConstants.grayColor.withValues(alpha: .3),
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.kTextSignUp.tr(),
                                    style:
                                        UiConstants.signUpp.copyWith(color: UiConstants.whiteColor),
                                  ),
                                  Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: const BoxDecoration(
                                        color: UiConstants.purpleColor, shape: BoxShape.circle),
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(Icons.close,
                                          size: 17.w, color: UiConstants.whiteColor),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Expanded(
                                child: ListView(
                                  padding: getMarginOrPadding(bottom: 24),
                                  children: [
                                    CustomTextField(
                                      hintText: LocaleKeys.kTextNickname.tr(),
                                      controller: cubit.nicknameController,
                                      fillColor: UiConstants.whiteColor,
                                      textStyle: UiConstants.textStyle12
                                          .copyWith(color: UiConstants.blackColor),
                                      textColor: UiConstants.blackColor,
                                      isExpanded: true,
                                      validator: (value) => Utils.validate(value),
                                      inputFormatters: [LengthLimitingTextInputFormatter(15)],
                                      textInputAction: TextInputAction.next,
                                      onChangedField: (_) => cubit.onTextChanged(),
                                    ),
                                    SizedBox(height: 14.h),
                                    CustomTextField(
                                      hintText: LocaleKeys.kTextFirstName.tr(),
                                      controller: cubit.fNameController,
                                      fillColor: UiConstants.whiteColor,
                                      textStyle: UiConstants.textStyle12
                                          .copyWith(color: UiConstants.blackColor),
                                      textColor: UiConstants.blackColor,
                                      isExpanded: true,
                                      validator: (value) => Utils.validate(value),
                                      textInputAction: TextInputAction.next,
                                      onChangedField: (_) => cubit.onTextChanged(),
                                    ),
                                    SizedBox(height: 14.h),
                                    CustomTextField(
                                      hintText: LocaleKeys.kTextLastName.tr(),
                                      controller: cubit.sNameController,
                                      fillColor: UiConstants.whiteColor,
                                      textStyle: UiConstants.textStyle12
                                          .copyWith(color: UiConstants.blackColor),
                                      textColor: UiConstants.blackColor,
                                      isExpanded: true,
                                      validator: (value) => Utils.validate(value),
                                      textInputAction: TextInputAction.next,
                                      onChangedField: (_) => cubit.onTextChanged(),
                                    ),
                                    SizedBox(height: 14.h),
                                    CustomTextField(
                                      hintText: LocaleKeys.kTextEmail.tr(),
                                      controller: cubit.emailController,
                                      fillColor: UiConstants.whiteColor,
                                      textStyle: UiConstants.textStyle12
                                          .copyWith(color: UiConstants.blackColor),
                                      textColor: UiConstants.blackColor,
                                      isExpanded: true,
                                      isShowError: true,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) => Utils.validateEmail(value),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(30),
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'),
                                        ),
                                      ],
                                      textInputAction: TextInputAction.next,
                                      onChangedField: (_) => cubit.onTextChanged(),
                                    ),
                                    SizedBox(height: 14.h),
                                    CustomTextField(
                                      height: 57.h,
                                      hintText: LocaleKeys.kTextPassword.tr(),
                                      controller: cubit.passwordController,
                                      fillColor: UiConstants.whiteColor,
                                      textStyle: UiConstants.textStyle12
                                          .copyWith(color: UiConstants.blackColor),
                                      textColor: UiConstants.blackColor,
                                      isObscuredText: true,
                                      contentPadding: getMarginOrPadding(
                                          left: 20, right: 20, top: 30, bottom: 0),
                                      isNeedShowHiddenTextIcon: true,
                                      validator: (value) => Utils.validatePassword(value),
                                      textInputAction: TextInputAction.next,
                                      onChangedField: (_) => cubit.onTextChanged(),
                                    ),
                                    SizedBox(height: 14.h),
                                    CustomTextField(
                                        height: 57.h,
                                        hintText: LocaleKeys.kTextRepeatThePassword.tr(),
                                        controller: cubit.repeatPasswordController,
                                        fillColor: UiConstants.whiteColor,
                                        textStyle: UiConstants.textStyle12
                                            .copyWith(color: UiConstants.blackColor),
                                        textColor: UiConstants.blackColor,
                                        isObscuredText: true,
                                        contentPadding: getMarginOrPadding(
                                            left: 20, right: 20, top: 30, bottom: 0),
                                        isNeedShowHiddenTextIcon: true,
                                        validator: (value) => Utils.validatePassword(value),
                                        textInputAction: TextInputAction.done,
                                        onChangedField: (value) {
                                          cubit.onTextChanged();
                                          Utils.validatePassword(value);
                                        }),
                                    SizedBox(height: 16.h),
                                    CustomButton(
                                      height: 57.h,
                                      title: LocaleKeys.kTextSignUp.tr(),
                                      hasGradient: false,
                                      onTap: loadedState.allFieldsValidate
                                          ? () => cubit.register(context)
                                          : null,
                                      textColor:
                                          loadedState.allFieldsValidate ? null : UiConstants.whiteColor,
                                      buttonColor: loadedState.allFieldsValidate
                                          ? null
                                          : UiConstants.lightGrayColor,
                                    ),
                                    SizedBox(height: 20.h),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "${LocaleKeys.kTextPleaseReadThe.tr()} ",
                                            style: UiConstants.textStyle17
                                                .copyWith(color: UiConstants.whiteColor),
                                          ),
                                          TextSpan(
                                            text: LocaleKeys.kTextUserAgreement.tr(),
                                            style: UiConstants.textStyle17.copyWith(
                                                color: UiConstants.whiteColor,
                                                decoration: TextDecoration.underline),
                                          ),
                                          TextSpan(
                                            text: " ${LocaleKeys.kTextAnd.tr()} ",
                                            style: UiConstants.textStyle17
                                                .copyWith(color: UiConstants.whiteColor),
                                          ),
                                          TextSpan(
                                            text: " ${LocaleKeys.kTextPrivacePolice.tr()} ",
                                            style: UiConstants.textStyle17.copyWith(
                                                color: UiConstants.whiteColor,
                                                decoration: TextDecoration.underline),
                                            //   recognizer: TapGestureRecognizer()
                                            //..onTap = () =>
                                            //    privacyPolicyModel.onClickText != null
                                            //        ? privacyPolicyModel.onClickText!()
                                            //        : null,
                                          ),
                                          TextSpan(
                                            text: LocaleKeys.kTextBeforeLoggingIntoTheApp.tr(),
                                            style: UiConstants.textStyle17
                                                .copyWith(color: UiConstants.whiteColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: getMarginOrPadding(top: 20.h, bottom: 20.h),
                                      child: const Divider(color: UiConstants.whiteColor),
                                    ),
                                    Text(
                                      LocaleKeys.kTextOrUse.tr(),
                                      style: UiConstants.textStyle17
                                          .copyWith(color: UiConstants.whiteColor),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 13.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final googleSignIn = GoogleSignIn(
                                              signInOption: SignInOption.standard,
                                            );
                                            final account = await googleSignIn.signIn();

                                            if (account != null) {
                                              final googleKey = await account.authentication;
                                              appLogger.d(googleKey.idToken);
                                            }
                                          },
                                          child: Image.asset(Paths.google),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pushAndRemoveUntil(
                                              context,
                                              FadeInRoute(const HomeScreen(), Routes.homeScreen,
                                                  arguments: {
                                                    'role': Role.MANAGER,
                                                  }),
                                              (route) => false),
                                          child: Image.asset(Paths.facebook),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pushAndRemoveUntil(
                                              context,
                                              FadeInRoute(const HomeScreen(), Routes.homeScreen,
                                                  arguments: {'role': Role.ADMIN}),
                                              (route) => false),
                                          child: Image.asset(Paths.apple),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacement(
                                        context,
                                        FadeInRoute(const LogInScreen(), Routes.logInScreen),
                                      ),
                                      child: Text(LocaleKeys.kTextAlreadyHaveAnAccount.tr(),
                                          style: UiConstants.textStyle16.copyWith(
                                            color: UiConstants.whiteColor,
                                            decoration: TextDecoration.underline,
                                            decorationColor: UiConstants.whiteColor,
                                          ),
                                          textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

