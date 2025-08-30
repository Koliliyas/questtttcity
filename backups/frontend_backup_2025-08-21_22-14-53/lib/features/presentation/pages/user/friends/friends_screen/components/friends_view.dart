import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/features/data/models/friend_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/components/friend_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';

class FriendsView<T extends IFriendModel> extends StatelessWidget {
  const FriendsView(
      {super.key,
      this.isRequest = false,
      this.padding,
      this.onTap,
      required this.friends,
      required this.cubit,
      this.isScrollable = true});

  final bool isRequest;
  final bool isScrollable;
  final EdgeInsets? padding;
  final List<T> friends;
  final Function(int index)? onTap;
  final FriendsScreenCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: !isScrollable ? const NeverScrollableScrollPhysics() : null,
      padding: padding ?? EdgeInsets.zero,
      shrinkWrap: true,
      itemBuilder: (context, index) => FriendItem(
        index: index,
        isRequest: isRequest,
        onTap: onTap,
        friend: friends[index],
        cubit: cubit,
      ),
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemCount: friends.length,
    );
  }
}
