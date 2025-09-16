import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/components/invite_friend_item.dart';

class InviteFriendList extends StatelessWidget {
  const InviteFriendList(
      {super.key, required this.onTap, required this.checkedFriendStatuses});

  final Function(int index) onTap;
  final List<bool> checkedFriendStatuses;

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return GradientCard(
      borderRadius: 24.r,
      contentPadding: getMarginOrPadding(all: 16),
      body: Column(
        children: [
          CustomSearchView(
            controller: searchController,
            fillColor: UiConstants.whiteColor,
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) => InviteFriendItem(
                      onTap: onTap,
                      index: index,
                      isChecked: checkedFriendStatuses[index],
                    ),
                separatorBuilder: (context, index) => Padding(
                      padding: getMarginOrPadding(top: 16, bottom: 16),
                      child: Divider(
                        color: UiConstants.whiteColor.withValues(alpha: .3),
                      ),
                    ),
                itemCount: checkedFriendStatuses.length),
          )
        ],
      ),
    );
  }
}
