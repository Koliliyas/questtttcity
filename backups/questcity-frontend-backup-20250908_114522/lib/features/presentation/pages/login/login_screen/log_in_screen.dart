import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/forget_password_screen/forget_password_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/cubit/login_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/components/remember_user.dart';
import 'package:los_angeles_quest/locator_service.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/back_icon_button.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool isUnlock = false;
  bool isUnlockComplete = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginScreenCubit(
          authLogin: sl(),
          getMe: sl(),
          sharedPreferences: sl(),
          firebaseMessaging: sl(),
          getVerificationCode: sl(),
          repository: sl(),
          authNewCubit: sl()),
      child: BlocBuilder<LoginScreenCubit, LoginScreenState>(
        builder: (context, state) {
          LoginScreenCubit cubit = context.read<LoginScreenCubit>();

          // РћР±СЂР°Р±РѕС‚РєР° СЃРѕСЃС‚РѕСЏРЅРёСЏ Р·Р°РіСЂСѓР·РєРё
          if (state is LoginScreenLoading) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Paths.backgroundLandscape),
                      fit: BoxFit.cover),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            UiConstants.whiteColor),
                      ),
                      if (state.message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          state.message!,
                          style: UiConstants.textStyle16
                              .copyWith(color: UiConstants.whiteColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }

          // Р”Р»СЏ СЃРѕСЃС‚РѕСЏРЅРёР№ Initial Рё Loaded
          final isInitialState = state is LoginScreenInitial;
          final loadedState = isInitialState
              ? state as LoginScreenInitial
              : LoginScreenInitial(
                  rememberUser: sl<SharedPreferences>()
                          .getBool(SharedPreferencesKeys.isRememberUser) ??
                      false);

          print(
              'рџ”Ќ DEBUG: State updated - allFieldsValidate: ${loadedState.allFieldsValidate}');
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
                  if (!isUnlock && !isUnlockComplete)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: getMarginOrPadding(
                              left: 16, right: 16, bottom: 44, top: 44),
                          child: BlurryContainer(
                            blur: 150,
                            borderRadius: BorderRadius.circular(40.r),
                            padding: EdgeInsets.zero,
                            child: Container(
                              padding: getMarginOrPadding(
                                  left: 16, right: 16, top: 24, bottom: 24),
                              decoration: BoxDecoration(
                                color: UiConstants.whiteColor
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LocaleKeys.kTextLogIn.tr(),
                                        style: UiConstants.signUpp.copyWith(
                                            color: UiConstants.whiteColor),
                                      ),
                                      Container(
                                        width: 24.w,
                                        height: 24.w,
                                        decoration: const BoxDecoration(
                                            color: UiConstants.purpleColor,
                                            shape: BoxShape.circle),
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Icon(Icons.close,
                                              size: 17.w,
                                              color: UiConstants.whiteColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    LocaleKeys
                                        .kTextGoOnQuestsTogetherWithYourFriendsToHaveAGoodTime
                                        .tr(),
                                    style: UiConstants.textStyle16.copyWith(
                                        color: UiConstants.whiteColor),
                                  ),
                                  SizedBox(height: 20.h),
                                  CustomTextField(
                                    height: 57.h,
                                    hintText: LocaleKeys.kTextEmail.tr(),
                                    controller: cubit.emailController,
                                    fillColor: UiConstants.whiteColor,
                                    textStyle: UiConstants.textStyle12.copyWith(
                                        color: UiConstants.blackColor),
                                    textColor: UiConstants.blackColor,
                                    isExpanded: true,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) =>
                                        Utils.validateEmail(value),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(30),
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'\s'),
                                      ),
                                    ],
                                    textInputAction: TextInputAction.next,
                                    onChangedField: (_) =>
                                        cubit.onTextChanged(),
                                  ),
                                  SizedBox(height: 14.h),
                                  CustomTextField(
                                    height: 57.h,
                                    hintText: LocaleKeys.kTextPassword.tr(),
                                    controller: cubit.passwordController,
                                    fillColor: UiConstants.whiteColor,
                                    textStyle: UiConstants.textStyle12.copyWith(
                                        color: UiConstants.blackColor),
                                    textColor: UiConstants.blackColor,
                                    isObscuredText: true,
                                    contentPadding: getMarginOrPadding(
                                        left: 20,
                                        right: 20,
                                        top: 30,
                                        bottom: 0),
                                    isNeedShowHiddenTextIcon: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Пароль не может быть пустым';
                                      }
                                      if (value.length < 6) {
                                        return 'Пароль должен содержать минимум 6 символов';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'\s'),
                                      ),
                                    ],
                                    textInputAction: TextInputAction.done,
                                    onChangedField: (_) =>
                                        cubit.onTextChanged(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushReplacement(
                                          context,
                                          FadeInRoute(
                                              const ForgetPasswordScreen(),
                                              Routes.forgetScreen),
                                        ),
                                        child: Text(
                                          LocaleKeys.kTextForgetThePassword
                                              .tr(),
                                          style: UiConstants.rememberTheUser
                                              .copyWith(
                                                  color: UiConstants.whiteColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      UiConstants.whiteColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomButton(
                                      height: 57.h,
                                      title: LocaleKeys.kTextLogIn.tr(),
                                      onTap: () {
                                        print(
                                            'рџ”Ќ DEBUG: Button tapped, allFieldsValidate: ${loadedState.allFieldsValidate}');
                                        cubit.login(context);
                                      },
                                      textColor: loadedState.allFieldsValidate
                                          ? null
                                          : UiConstants.whiteColor,
                                      buttonColor: loadedState.allFieldsValidate
                                          ? null
                                          : UiConstants.lightGrayColor,
                                      hasGradient: false),
                                  SizedBox(height: 16.h),
                                  RememberUser(
                                      isRemembered: loadedState.rememberUser,
                                      onChangeRememberedCheckbox:
                                          cubit.onChangeRememberUser),
                                  SizedBox(height: 20.h),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isUnlock = true;
                                      });
                                    },
                                    child: Text(
                                      LocaleKeys.kTextUnblock.tr(),
                                      style: UiConstants.textStyle16.copyWith(
                                          color: UiConstants.whiteColor,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              UiConstants.whiteColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (isUnlock)
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
                                color: UiConstants.whiteColor
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      BackIconButton(
                                        onTap: () {
                                          setState(() {
                                            isUnlock = false;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        LocaleKeys.kTextUnblock.tr(),
                                        style: UiConstants.signUpp.copyWith(
                                            color: UiConstants.whiteColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    "Р Р°Р·Р±Р»РѕРєРёСЂРѕРІРєР° Р°РєРєР°СѓРЅС‚Р°",
                                    style: UiConstants.textStyle16.copyWith(
                                        color: UiConstants.whiteColor),
                                  ),
                                  SizedBox(height: 20.h),
                                  CustomButton(
                                      height: 57.h,
                                      title: LocaleKeys.kTextUnblock.tr(),
                                      onTap: () {
                                        setState(() {
                                          isUnlockComplete = true;
                                        });
                                      },
                                      hasGradient: false),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (isUnlockComplete)
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
                                color: UiConstants.whiteColor
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      BackIconButton(
                                        onTap: () {
                                          setState(() {
                                            isUnlockComplete = false;
                                            isUnlock = false;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        LocaleKeys.kTextUnblock.tr(),
                                        style: UiConstants.signUpp.copyWith(
                                            color: UiConstants.whiteColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    "РђРєРєР°СѓРЅС‚ СѓСЃРїРµС€РЅРѕ СЂР°Р·Р±Р»РѕРєРёСЂРѕРІР°РЅ!",
                                    style: UiConstants.textStyle16.copyWith(
                                        color: UiConstants.whiteColor),
                                  ),
                                  SizedBox(height: 20.h),
                                  CustomButton(
                                      height: 57.h,
                                      title: "РџСЂРѕРґРѕР»Р¶РёС‚СЊ",
                                      onTap: () {
                                        setState(() {
                                          isUnlockComplete = false;
                                          isUnlock = false;
                                        });
                                      },
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
