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
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/cubit/login_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/components/remember_user.dart';
import 'package:los_angeles_quest/locator_service.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/back_icon_button.dart';

class LogInScreenIntegrated extends StatefulWidget {
  const LogInScreenIntegrated({super.key});

  @override
  State<LogInScreenIntegrated> createState() => _LogInScreenIntegratedState();
}

class _LogInScreenIntegratedState extends State<LogInScreenIntegrated> {
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
                                        style: UiConstants.textStyle24.copyWith(
                                            color: UiConstants.whiteColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      BackIconButton(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 32.h),
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
                                        cubit.validateFields(),
                                  ),
                                  SizedBox(height: 16.h),
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
                                    validator: (value) => Utils.validate(value),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'\s'),
                                      ),
                                    ],
                                    textInputAction: TextInputAction.done,
                                    onChangedField: (_) =>
                                        cubit.validateFields(),
                                  ),
                                  SizedBox(height: 16.h),
                                  RememberUser(
                                    isRemembered: loadedState.rememberUser,
                                    onChangeRememberedCheckbox: () {
                                      cubit.toggleRememberUser();
                                    },
                                  ),
                                  SizedBox(height: 24.h),

                                  // РћРЎРќРћР’РќРђРЇ РљРќРћРџРљРђ Р’РҐРћР”Рђ
                                  CustomButton(
                                    title: LocaleKeys.kTextLogIn.tr(),
                                    onTap: () {
                                      if (cubit.formKey.currentState!
                                          .validate()) {
                                        cubit.login(context);
                                      }
                                    },
                                  ),

                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "РќРµС‚ Р°РєРєР°СѓРЅС‚Р°?",
                                        style: UiConstants.textStyle14.copyWith(
                                            color: UiConstants.whiteColor),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, Routes.signInScreen);
                                        },
                                        child: Text(
                                          "Р—Р°СЂРµРіРёСЃС‚СЂРёСЂРѕРІР°С‚СЊСЃСЏ",
                                          style: UiConstants.textStyle14
                                              .copyWith(
                                                  color:
                                                      UiConstants.purpleColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, Routes.forgetScreen);
                                    },
                                    child: Text(
                                      "Р—Р°Р±С‹Р»Рё РїР°СЂРѕР»СЊ?",
                                      style: UiConstants.textStyle14.copyWith(
                                          color: UiConstants.whiteColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isUnlock && !isUnlockComplete) _buildUnlockAnimation(),
                  if (isUnlockComplete) _buildUnlockComplete(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnlockAnimation() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(Paths.backgroundLandscape), fit: BoxFit.cover),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(UiConstants.whiteColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Р Р°Р·Р±Р»РѕРєРёСЂРѕРІРєР°...',
              style: UiConstants.textStyle16
                  .copyWith(color: UiConstants.whiteColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockComplete() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(Paths.backgroundLandscape), fit: BoxFit.cover),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: UiConstants.whiteColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Р Р°Р·Р±Р»РѕРєРёСЂРѕРІР°РЅРѕ!',
              style: UiConstants.textStyle16
                  .copyWith(color: UiConstants.whiteColor),
            ),
          ],
        ),
      ),
    );
  }
}

