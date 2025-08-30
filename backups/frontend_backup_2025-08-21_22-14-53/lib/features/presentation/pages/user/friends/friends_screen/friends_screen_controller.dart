import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/custom_bottom_sheet_template.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/components/friends_add_friend_body.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class FriendsScreenController {
  static showInviteFriendSheet(BuildContext context, FriendsScreenCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 370,
        isBack: false,
        titleText: LocaleKeys.kTextInviteFriend.tr(),
        body: FriendsAddFriendBody(
          cubit: cubit,
        ),
      ),
    );
  }
}

