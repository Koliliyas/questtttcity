import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/home_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/language_screen/language_screen.dart';
import 'package:los_angeles_quest/features/presentation/splash_screen/cubit/splash_screen_cubit.dart';
import 'package:los_angeles_quest/locator_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashScreenCubit(
          secureStorage: sl(), reloadToken: sl(), getMe: sl(), sharedPreferences: sl())
        ..checkData(),
      child: BlocBuilder<SplashScreenCubit, SplashScreenState>(
        builder: (context, state) {
          if (state is SplashScreenLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!state.isHasAppAuth) {
                Navigator.push(
                  context,
                  FadeInRoute(const LanguageScreen(), Routes.languageScreen),
                );
              } else {
                Navigator.push(
                  context,
                  FadeInRoute(
                    const HomeScreen(),
                    Routes.homeScreen,
                    arguments: {'role': state.role, 'username': state.username},
                  ),
                );
              }
            });
          }
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Paths.backgroundGradient1Path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high),
              ),
              child: Center(
                child: Padding(
                  padding: getMarginOrPadding(left: 100, right: 100),
                  child: SvgPicture.asset(Paths.logo, width: double.infinity),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
