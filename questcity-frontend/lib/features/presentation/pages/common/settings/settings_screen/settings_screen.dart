import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/language_cubit/language_cubit_cubit.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/statistics_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/account_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/change_role_widget.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/cubit/settings_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/location_screen/location_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/password_screen/password_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/payment_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/my_credits_view/my_credits_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/settings_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/settings_screen_controller.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/locator_service.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_list_screen/quests_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return BlocProvider(
          create: (context) => SettingsScreenCubit(getMe: sl())..getMeData(),
          child: BlocBuilder<SettingsScreenCubit, SettingsScreenState>(
            builder: (context, state) {
              if (state is SettingsScreenLoading) {
                return const CustomLoadingIndicator();
              }

              SettingsScreenInitial loadedState =
                  state as SettingsScreenInitial;

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
                        top: MediaQuery.of(context).padding.top + 24,
                        left: 16,
                        right: 16),
                    child: Column(
                      children: [
                        if (homeCubit.role == Role.USER)
                          Padding(
                            padding: getMarginOrPadding(bottom: 5),
                            child: CustomSearchView(
                              controller: searchController,
                              options: const [
                                'Los Angeles',
                                'San Francisco',
                                'New York',
                                'Chicago'
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView(
                            padding: getMarginOrPadding(bottom: 156),
                            children: [
                              if (homeCubit.role == Role.USER)
                                Padding(
                                  padding:
                                      getMarginOrPadding(top: 32, bottom: 0),
                                  // ignore: prefer_const_constructors
                                  child: MyCreditsView(),
                                ),
                              SizedBox(height: 16.h),
                              SettingsItem(
                                title: LocaleKeys.kTextAccount.tr(),
                                onTap: () => Navigator.push(
                                  context,
                                  FadeInRoute(
                                      const AccountScreen(
                                        isAdminEditView: false,
                                      ),
                                      Routes.accountScreen),
                                ),
                              ),
                              if (homeCubit.role == Role.ADMIN)
                                Padding(
                                  padding: getMarginOrPadding(top: 16),
                                  child: SettingsItem(
                                    title: LocaleKeys.kTextStatistics.tr(),
                                    onTap: () => Navigator.push(
                                      context,
                                      FadeInRoute(const StatisticsScreen(),
                                          Routes.statisticsCreateScreen),
                                    ),
                                  ),
                                ),
                              if (homeCubit.role == Role.ADMIN)
                                Padding(
                                  padding: getMarginOrPadding(top: 16),
                                  child: SettingsItem(
                                    title: 'Управление квестами',
                                    onTap: () => Navigator.push(
                                      context,
                                      FadeInRoute(const QuestsListScreen(),
                                          Routes.questsListScreen),
                                    ),
                                  ),
                                ),
                              if (homeCubit.role == Role.USER)
                                Column(
                                  children: [
                                    SizedBox(height: 16.h),
                                    SettingsItem(
                                      title: LocaleKeys.kTextPassword.tr(),
                                      onTap: () => Navigator.push(
                                        context,
                                        FadeInRoute(PasswordScreen(),
                                            Routes.passwordScreen),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    SettingsItem(
                                      title: LocaleKeys.kTextPayment.tr(),
                                      onTap: () => Navigator.push(
                                        context,
                                        FadeInRoute(const PaymentScreen(),
                                            Routes.paymentScreen),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    SettingsItem(
                                      title: LocaleKeys.kTextLocation.tr(),
                                      onTap: () => Navigator.push(
                                        context,
                                        FadeInRoute(const LocationScreen(),
                                            Routes.locationScreen),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    SettingsItem(
                                      title: LocaleKeys.kTextSubscription.tr(),
                                      onTap: () => SettingsScreenController
                                          .showTryOurNewSubscriptionSheet(
                                              context),
                                    ),
                                  ],
                                ),
                              if (loadedState.roles == 2)
                                Padding(
                                  padding: getMarginOrPadding(top: 16),
                                  child: const ChangeRoleWidget(roles: [
                                    0,
                                    1,
                                    2,
                                  ]),
                                ),
                              SizedBox(height: 16.h),
                              SettingsItem(
                                title: LocaleKeys.kTextLanguage.tr(),
                                onTap: () => SettingsScreenController
                                    .showChangeLanguageSheet(
                                  context,
                                  (Locale locale) async {
                                    context
                                        .read<LanguageCubit>()
                                        .changeLanguage(context, locale)
                                        .then((_) {
                                      Future.delayed(
                                          const Duration(milliseconds: 250),
                                          () =>
                                              homeCubit.updateIconsLanguage());
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
