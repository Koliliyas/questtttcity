import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/log_in_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/sign_in_screen/sign_in_scrreen.dart';
import 'package:los_angeles_quest/l10n/l10n.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundLandscape),
                  fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: getMarginOrPadding(bottom: 44, left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                        title: LocaleKeys.kTextSignUp.tr(),
                        buttonColor: UiConstants.whiteColor,
                        textColor: UiConstants.black2Color,
                        onTap: () => Navigator.push(
                              context,
                              FadeInRoute(
                                  const SignInScreen(), Routes.signInScreen),
                            ),
                        hasGradient: false),
                  ),
                  SizedBox(width: 7.w),
                  CustomButton(
                      width: context.locale == L10n.all[0]
                          ? 237.w
                          : (MediaQuery.of(context).size.width - 39.w) / 2,
                      title: LocaleKeys.kTextLogIn.tr(),
                      buttonColor: UiConstants.purpleColor,
                      textColor: UiConstants.whiteColor,
                      onTap: () => Navigator.push(
                            context,
                            FadeInRoute(
                                const LogInScreen(), Routes.logInScreen),
                          ),
                      hasGradient: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

