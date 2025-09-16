import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/blur_rectangle_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/components/friends_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/components/invite_friend_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/components/requests_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/friends_screen_controller.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/requests_screen/requests_screen.dart';

import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final searchTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Paths.backgroundGradient1Path),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high),
                ),
                child: BlocBuilder<FriendsScreenCubit, FriendsScreenState>(
                  builder: (context, state) {
                    FriendsScreenCubit cubit = context.read<FriendsScreenCubit>();

                    if (state is FriendsScreenLoaded) {
                      return Padding(
                        padding: getMarginOrPadding(
                            top: MediaQuery.of(context).padding.top + 24, left: 16, right: 16),
                        child: Column(
                          children: [
                            CustomSearchView(
                              controller: searchTextController,
                              options: const [
                                'Los Angeles',
                                'San Francisco',
                                'New York',
                                'Chicago'
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                Expanded(
                                  child: InviteFriendButton(
                                    onTap: () => FriendsScreenController.showInviteFriendSheet(
                                        context, cubit),
                                  ),
                                ),
                                SizedBox(width: 22.w),
                                Expanded(
                                  child: RequestsButton(
                                    onTap: () => homeCubit.onTab2ScreenOpen(
                                      RequestsScreen(
                                        friendRequestModel: state.receivedRequests,
                                        cubit: cubit,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Expanded(
                              child: FriendsView(
                                friends: state.friends,
                                padding: getMarginOrPadding(bottom: 156, top: 27.h),
                                cubit: cubit,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              const BlurRectangleView()
            ],
          ),
        );
      },
    );
  }
}
