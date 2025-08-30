import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/data/models/friend_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/components/friends_view.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class RequestsScreen extends StatelessWidget {
  final List<FriendRequestModel> friendRequestModel;
  final FriendsScreenCubit cubit;
  const RequestsScreen({super.key, required this.friendRequestModel, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return Scaffold(
          body: Container(
            padding: getMarginOrPadding(
                top: MediaQuery.of(context).padding.top + 20, right: 16, left: 16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high),
            ),
            child: Column(
              children: [
                CustomAppBar(
                    title: LocaleKeys.kTextRequests.tr(), onTapBack: homeCubit.onRemoveLastRoute),
                SizedBox(height: 14.h),
                Expanded(
                  child: FriendsView(
                    friends: friendRequestModel,
                    cubit: cubit,
                    isRequest: true,
                    padding: getMarginOrPadding(top: 20, bottom: 156),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

