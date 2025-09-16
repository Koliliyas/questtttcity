import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/friend_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class FriendItem<T extends IFriendModel> extends StatelessWidget {
  const FriendItem({
    super.key,
    required this.isRequest,
    this.onTap,
    required this.index,
    required this.friend,
    required this.cubit,
  });

  final int index;
  final bool isRequest;
  final Function(int index)? onTap;
  final T friend;
  final FriendsScreenCubit cubit;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: () => onTap != null ? onTap!(0) : null,
      borderRadius: 24.r,
      body: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25.w,
                child: ClipOval(
                  child: Image.asset(
                    Paths.avatarPath,
                    fit: BoxFit.cover,
                    width: 50.w,
                    height: 50.w,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '${friend.firstName} ${friend.lastName}',
                style: UiConstants.textStyle4.copyWith(color: UiConstants.whiteColor),
              ),
            ],
          ),
          if (isRequest)
            Padding(
              padding: getMarginOrPadding(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                        onTap: () => cubit.updateRequest(friend.id as int, 'rejected'),
                        height: 41.h,
                        borderRadius: 40.r,
                        textStyle: UiConstants.textStyle2,
                        title: LocaleKeys.kTextDecline.tr(),
                        textColor: UiConstants.whiteColor,
                        buttonColor: Colors.transparent,
                        hasGradient: true),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CustomButton(
                        onTap: () => cubit.updateRequest(friend.id as int, 'accepted'),
                        height: 41.h,
                        borderRadius: 40.r,
                        textStyle: UiConstants.textStyle2,
                        title: LocaleKeys.kTextAddToFriends.tr(),
                        hasGradient: false),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

