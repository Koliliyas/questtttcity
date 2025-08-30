import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/cubit/chat_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/bottom_navigation_bar_tile.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_list_screen/cubit/quests_list_screen_cubit.dart';
import 'package:los_angeles_quest/locator_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeScreenCubit? cubit;

  @override
  Widget build(BuildContext context) {
    // Получаем аргументы из текущего маршрута
    Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Защита от null аргументов
    Role role = Role.USER;
    if (args != null) {
      final roleValue = args!['role'];
      role = (roleValue as Role?) ?? Role.USER;
    } else {
      print('🔍 DEBUG: args is null, using default role USER');
    }

    context.read<HomeScreenCubit>().init(role);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<FriendsScreenCubit>()..getFriends(args?['username'] ?? ''),
          lazy: false,
        ),
        BlocProvider<ChatScreenCubit>(
            create: (BuildContext context) => ChatScreenCubit(
                getAllChats: sl(),
                sharedPreferences: sl(),
                webSocketConnect: sl(),
                webSocketDisconnect: sl(),
                webSocketSendMessage: sl(),
                webSocketReceiveMessages: sl())
              ..getChats()),
        BlocProvider<QuestsListScreenCubit>(
            create: (BuildContext context) => QuestsListScreenCubit(
                  getQuestsUC: sl(),
                  deleteQuestUC: sl(),
                )..loadQuests()),
      ],
      child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
        builder: (context, state) {
          cubit = context.read<HomeScreenCubit>();
          int selectedIndex = cubit!.selectedPageIndex;

          // Детальное логирование для диагностики
          print('🔍 DEBUG: selectedIndex = $selectedIndex');
          print(
              '🔍 DEBUG: navigatorStack.length = ${cubit!.navigatorStack.length}');
          print('🔍 DEBUG: iconsPaths.length = ${cubit!.iconsPaths.length}');
          print('🔍 DEBUG: iconsNames.length = ${cubit!.iconsNames.length}');

          // Защита от некорректного индекса
          if (selectedIndex < 0 ||
              selectedIndex >= cubit!.navigatorStack.length) {
            print(
                '🔍 DEBUG: Fixing invalid selectedIndex from $selectedIndex to 0');
            selectedIndex = 0;
            cubit!.selectedPageIndex = 0;
          }
          if (state is HomeScreenInitial) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (selectedIndex >= 0 &&
                    selectedIndex < cubit!.navigatorStack.length &&
                    cubit!.navigatorStack[selectedIndex].length > 1) {
                  cubit!.onRemoveLastRoute();
                } else {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                }
              },
              child: Scaffold(
                //resizeToAvoidBottomInset: false,
                body: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    IndexedStack(
                      index: selectedIndex >= 0 &&
                              selectedIndex < cubit!.navigatorStack.length
                          ? selectedIndex
                          : 0,
                      children: cubit!.navigatorStack.isNotEmpty
                          ? cubit!.navigatorStack
                              .map((tabScreensList) => tabScreensList.isNotEmpty
                                  ? tabScreensList.last
                                  : const SizedBox.shrink())
                              .toList()
                          : [const SizedBox.shrink()],
                    ),
                    Positioned(
                      bottom: 62.h,
                      child: BlurryContainer(
                        blur: 15,
                        borderRadius: BorderRadius.circular(64.r),
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.only(right: 8.w, left: 8.w),
                          width: MediaQuery.of(context).size.width -
                              (cubit!.navigatorStack.isNotEmpty &&
                                      cubit!.navigatorStack.length == 2
                                  ? 130.w
                                  : 32.w),
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: UiConstants.whiteColor.withValues(alpha: .2),
                            border: GradientBoxBorder(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: .3)
                                  ],
                                ),
                                width: 1),
                            borderRadius: BorderRadius.circular(64.r),
                            boxShadow: [
                              BoxShadow(
                                  color: UiConstants.shadowColor
                                      .withValues(alpha: .15),
                                  offset: Offset(0, 4.h),
                                  blurRadius: 18.4.r),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: cubit!.navigatorStack.isNotEmpty &&
                                    cubit!.iconsPaths.isNotEmpty &&
                                    cubit!.iconsNames.isNotEmpty
                                ? List.generate(
                                    cubit!.navigatorStack.length > 0
                                        ? cubit!.navigatorStack.length
                                        : 1, (index) {
                                    print(
                                        '🔍 DEBUG: List.generate index: $index');
                                    if (index >= 0 &&
                                        index < cubit!.iconsPaths.length &&
                                        index < cubit!.iconsNames.length) {
                                      return BottomNavigationBarTile(
                                          icon: index < cubit!.iconsPaths.length
                                              ? cubit!.iconsPaths[index]
                                              : cubit!.iconsPaths.isNotEmpty
                                                  ? cubit!.iconsPaths.first
                                                  : 'assets/icons/home.svg',
                                          title: index <
                                                  cubit!.iconsNames.length
                                              ? cubit!.iconsNames[index]
                                              : cubit!.iconsNames.isNotEmpty
                                                  ? cubit!.iconsNames.first ??
                                                      'Home'
                                                  : 'Home',
                                          countChatMessage: cubit!.role ==
                                                      Role.ADMIN &&
                                                  index == 1
                                              ? (context
                                                      .read<ChatScreenCubit>()
                                                      .chats
                                                      .isNotEmpty
                                                  ? context
                                                      .read<ChatScreenCubit>()
                                                      .chats
                                                      .map((chat) => chat
                                                          .message.newMessage)
                                                      .toList()
                                                      .length
                                                  : 0)
                                              : null,
                                          onTap: () {
                                            print(
                                                '🔍 DEBUG: BottomNavigationBarTile onTap called with index: $index');
                                            if (index >= 0) {
                                              cubit!.onChangePage(index);
                                            } else {
                                              print(
                                                  '🔍 DEBUG: Invalid index $index, ignoring tap');
                                            }
                                          },
                                          isActive: selectedIndex == index);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  })
                                : [const SizedBox.shrink()],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
