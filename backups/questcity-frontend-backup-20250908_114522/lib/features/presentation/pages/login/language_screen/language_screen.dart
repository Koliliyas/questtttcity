import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/language_screen/components/language_selection.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/start_screen.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

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
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: getMarginOrPadding(
                    top: 16, left: 16, right: 16, bottom: 44),
                child: BlurryContainer(
                  blur: 30,
                  borderRadius: BorderRadius.circular(40.r),
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: getMarginOrPadding(
                        top: 24, bottom: 24, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: UiConstants.whiteColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.kTextChooseTheLanguage.tr(),
                              style: UiConstants.signUpp
                                  .copyWith(color: UiConstants.whiteColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        const LanguageSelection(),
                        SizedBox(height: 16.h),
                        CustomButton(
                          buttonColor: UiConstants.lightOrangeColor,
                          title: LocaleKeys.kTextConfirm.tr(),
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              FadeInRoute(
                                  const StartScreen(), Routes.startScreen),
                              (route) => false),
                          hasGradient: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

