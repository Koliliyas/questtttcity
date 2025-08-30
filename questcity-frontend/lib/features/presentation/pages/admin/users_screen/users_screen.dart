import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/unlock_requests.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/components/users_all_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/components/users_page_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/cubit/users_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/account_request_credits_screen/requests_for_credits_screen.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/account_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/components/notification_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/blur_rectangle_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/button_chips/button_chips_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: 0, viewportFraction: 1.05);
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high),
            ),
            child: BlocBuilder<UsersScreenCubit, UsersScreenState>(builder: (context, state) {
              UsersScreenCubit cubit = context.read<UsersScreenCubit>();

              if (state is UsersScreenLoading) {
                return const CustomLoadingIndicator();
              } else if (state is UsersScreenError) {
                return Text(
                  state.message,
                  style: const TextStyle(color: Colors.black, fontSize: 25),
                );
              }
              UsersScreenLoaded loadedState = state as UsersScreenLoaded;
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => cubit.getAllUsers(),
                    child: Padding(
                      padding: getMarginOrPadding(
                          top: MediaQuery.of(context).padding.top + 24, left: 16, right: 16),
                      child: Column(
                        children: [
                          CustomSearchView(
                            controller: cubit.searchController,
                            options: cubit.users
                                .map((user) => '${user.firstName} ${user.lastName}')
                                .toList(),
                            suffixWidget: NotificationView(
                              onTap: () => Navigator.push(
                                context,
                                FadeInRoute(const RequestsForCreditsScreen(),
                                    Routes.requestsForCreditsScreen),
                              ),
                            ),
                          ),
                          SizedBox(height: 19.h),
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              padding: getMarginOrPadding(
                                  bottom: 156 + (loadedState.activePageView == 0 ? 72 : 0)),
                              children: [
                                ButtonChipsView(
                                  onTapChip: (index) {
                                    cubit.changeChip(index);
                                    controller.animateToPage(index,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.fastOutSlowIn);
                                  },
                                  activeChipIndex: loadedState.activePageView!,
                                  chipNames: [
                                    LocaleKeys.kTextAllUsers.tr(),
                                    LocaleKeys.kTextLockedUsers.tr()
                                  ],
                                ),
                                SizedBox(height: 26.h),
                                UsersPageView(
                                  controller: controller,
                                  onPageChanged: cubit.changeChip,
                                  children: [
                                    UsersAllView(users: cubit.users),
                                    UsersAllView(
                                      users: cubit.users.where((user) {
                                        return loadedState.unlockRequests
                                                .firstWhereOrNull<UnlockRequest>(
                                              (element) => element.email == user.email,
                                            ) !=
                                            null;
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const BlurRectangleView(),
                  Visibility(
                    visible: loadedState.activePageView == 0,
                    child: Positioned(
                      left: 16.w,
                      right: 16.w,
                      bottom: 156.h,
                      child: CustomButton(
                          title: LocaleKeys.kTextAddUser.tr(),
                          onTap: () => Navigator.push(
                                context,
                                FadeInRoute(
                                    const AccountScreen(
                                      isAdminEditView: true,
                                      isCreateUser: true,
                                    ),
                                    Routes.accountScreen),
                              ),
                          iconLeft:
                              Icon(Icons.add_rounded, size: 25.w, color: UiConstants.whiteColor),
                          buttonColor: UiConstants.greenColor),
                    ),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

extension FirstWhereOrNull on Iterable {
  T? firstWhereOrNull<T>(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

