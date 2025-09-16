import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/core/language_cubit/language_cubit_cubit.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/bloc/purchase_cubit.dart';
import 'package:los_angeles_quest/features/presentation/bloc/audioplayer_bloc.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/cubit/users_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/cubit/account_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/splash_screen/splash_screen.dart';
import 'package:los_angeles_quest/features/repositories/purchase_repository_impl.dart';
import 'package:los_angeles_quest/features/domain/usecases/purchase_use_case.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/category_create_screen/category_create_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/statistics_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/users_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_list_screen/quests_list_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_create_screen/quest_create_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_edit_screen/quest_edit_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/account_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/chat_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/quest_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/quest_detail_screen.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/reviews_screen/reviews_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/see_a_map_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/my_quests_screen/my_quests_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/cubit/custom_bottom_sheet_template_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/home_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/enter_the_code_screen/enter_the_code_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/forget_password_screen/forget_password_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/log_in_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/new_password_screen/new_password_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/sign_in_screen/sign_in_scrreen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/start_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/edit_quest_point_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/artifacts_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/completing_quest_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/invite_friend_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/tools_screen/tools_screen.dart';
import 'package:los_angeles_quest/l10n/l10n.dart';

import 'package:los_angeles_quest/locator_service.dart';
import 'features/presentation/pages/login/language_screen/language_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/internal_chat_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/present_credits_screen/present_credits_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/location_screen/location_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/password_screen/password_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/payment_screen.dart';
// Тестовые импорты удалены после завершения миграции
import 'package:los_angeles_quest/locator_service.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light),
  );

  runApp(EasyLocalization(
      supportedLocales: L10n.all,
      path: 'assets/l10n',
      fallbackLocale: L10n.all[0],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Size designSize = Size(390, 844 + MediaQuery.of(context).padding.top);
    return ScreenUtilInit(
      designSize: designSize,
      fontSizeResolver: (fontSize, instance) {
        final display = View.of(context).display;
        final screenSize = display.size / display.devicePixelRatio;
        final scaleWidth = screenSize.width / designSize.width;

        return fontSize * scaleWidth;
      },
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => di.sl<LanguageCubit>()),
            BlocProvider(
                create: (context) => di.sl<CustomBottomSheetTemplateCubit>()),
            BlocProvider(create: (context) => di.sl<HomeScreenCubit>()),
            BlocProvider(
              create: (context) => PurchaseCubit(
                PurchaseUseCase(PurchaseRepositoryImpl()),
              ),
            ),
            BlocProvider(create: (context) => di.sl<AudioPlayerBloc>()),
            BlocProvider<UsersScreenCubit>(
              create: (BuildContext context) =>
                  di.sl<UsersScreenCubit>()..getAllUsers(),
            ),
            BlocProvider<AccountScreenCubit>(
              create: (BuildContext context) {
                final cubit = di.sl<AccountScreenCubit>();
                // Set role after creation
                cubit.role = context.read<HomeScreenCubit>().role;
                return cubit;
              },
            ),
            BlocProvider<QuestsScreenCubit>(
              create: (BuildContext context) =>
                  di.sl<QuestsScreenCubit>()..loadData(),
            ),
          ],
          child: BlocBuilder<LanguageCubit, Locale>(
            builder: (context, state) {
              return MaterialApp(
                  title: 'Quests',
                  routes: {
                    Routes.splashScreen: (context) => const SplashScreen(),
                    // ignore: prefer_const_constructors
                    Routes.languageScreen: (context) => LanguageScreen(),
                    Routes.startScreen: (context) => const StartScreen(),
                    Routes.signInScreen: (context) => const SignInScreen(),
                    Routes.newPasswordScreen: (context) =>
                        const NewPasswordScreen(
                          email: '',
                        ),
                    Routes.enterTheCodeScreen: (context) =>
                        const EnterTheCodeScreen(),
                    Routes.logInScreen: (context) => const LogInScreen(),
                    Routes.forgetScreen: (context) =>
                        const ForgetPasswordScreen(),
                    Routes.homeScreen: (context) => const HomeScreen(),
                    Routes.myQuestScreen: (context) => const MyQuestsScreen(),
                    Routes.questScreen: (context) =>
                        const QuestScreen(questId: 1),
                    Routes.accountScreen: (context) => const AccountScreen(
                          isAdminEditView: false,
                        ),
                    Routes.passwordScreen: (context) => PasswordScreen(),
                    Routes.paymentScreen: (context) => const PaymentScreen(),
                    Routes.presentCreditsScreen: (context) =>
                        const PresentCreditsScreen(),
                    Routes.locationScreen: (context) => const LocationScreen(),
                    Routes.internalChatScreen: (context) =>
                        const InternalChatScreen(),
                    Routes.seeMapScreen: (context) => const SeeAMapScreen(
                          questImage: '',
                          route: [],
                          questName: '',
                          merchItem: [],
                          questId: 1,
                          mileage: '',
                        ),
                    Routes.reviewsScreen: (context) => const ReviewsScreen(
                          reviews: [],
                          questName: '',
                        ),
                    Routes.editQuestScreen: (context) =>
                        const EditQuestScreen(),
                    Routes.editQuestPointScreen: (context) {
                      final args = ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>?;
                      final pointIndex = args?['pointIndex'] ?? 0;
                      return EditQuestPointScreen(pointIndex: pointIndex);
                    },
                    // Routes.requestsForCreditsScreen: (context) =>
                    //     const RequestsForCreditsScreen(),
                    Routes.categoryCreateScreen: (context) =>
                        const CategoryCreateScreen(),
                    Routes.statisticsCreateScreen: (context) =>
                        const StatisticsScreen(),
                    Routes.usersScreen: (context) => const UsersScreen(),
                    Routes.questsListScreen: (context) =>
                        const QuestsListScreen(),
                    Routes.questCreateScreen: (context) =>
                        const QuestCreateScreen(),
                    Routes.questEditScreen: (context) => QuestEditScreen(
                          questId: (ModalRoute.of(context)?.settings.arguments
                                  as Map<String, dynamic>?)?['questId'] ??
                              0,
                        ),
                    Routes.completingQuestScreen: (context) =>
                        const CompletingQuestScreen(
                          questImage: '',
                          questId: 1,
                          questName: '',
                          mileage: '',
                        ),
                    Routes.inviteFriendScreen: (context) =>
                        const InviteFriendScreen(),
                    Routes.chatScreen: (context) => const ChatScreen(),
                    Routes.artifactsScreen: (context) =>
                        const ArtifactsScreen(),
                    Routes.toolsScreen: (context) => ToolsScreen(
                          route: const [],
                          questId: 1,
                          questName: '',
                          mileage: '',
                          cubit: CompletingQuestScreenCubit(sl()),
                        ),
                    Routes.questDetailScreen: (context) {
                      final args = ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>?;
                      final questId = args?['questId'] ?? 1;
                      final questItem = args?['questItem'] as QuestItem?;
                      return QuestDetailScreen(
                        questId: questId,
                        questItem: questItem,
                      );
                    },
                    // Тестовые маршруты удалены после завершения миграции
                  },
                  initialRoute: Routes.splashScreen,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: state);
            },
          ),
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
