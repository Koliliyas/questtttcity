import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/present_credits_screen/cubit/present_credits_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/present_credits_screen/cubit/present_credits_screen_state.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/components/friends_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/settings_screen_controller.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

import '../../../../../locator_service.dart';

class PresentCreditsScreen extends StatelessWidget {
  const PresentCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PresentCreditsScreenCubit(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(Paths.backgroundGradient1Path),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high),
          ),
          child: BlocBuilder<PresentCreditsScreenCubit, PresentCreditsScreenState>(
            builder: (context, state) {
              PresentCreditsScreenCubit cubit = context.read<PresentCreditsScreenCubit>();
              return Padding(
                padding: getMarginOrPadding(
                    top: MediaQuery.of(context).padding.top + 20, left: 16, right: 16),
                child: Column(
                  children: [
                    CustomAppBar(
                        onTapBack: () => Navigator.pop(context),
                        title: LocaleKeys.kTextPresentCredits.tr()),
                    SizedBox(height: 25.h),
                    CustomSearchView(
                      controller: cubit.searchController,
                      options: const ['Los Angeles', 'San Francisco', 'New York', 'Chicago'],
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: BlocProvider(
                        create: (context) => sl<FriendsScreenCubit>()..getFriends(''),
                        child: BlocBuilder<FriendsScreenCubit, FriendsScreenState>(
                          builder: (context, state) {
                            if (state is FriendsScreenLoaded) {
                              return FriendsView(
                                cubit: context.read<FriendsScreenCubit>(),
                                friends: state.friends,
                                padding: getMarginOrPadding(bottom: 25, top: 25),
                                onTap: (index) => SettingsScreenController.showInputCreditsSheet(
                                    context, CreditsActions.PRESENT),
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

