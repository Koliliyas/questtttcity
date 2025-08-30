import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/close_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/current_quest_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/invite_friend_screen.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ActionPanel extends StatelessWidget {
  final String questImage;
  final String questName;
  const ActionPanel({super.key, required this.questImage, required this.questName});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
        contentPadding: getMarginOrPadding(all: 16),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomButton(
                  onTap: () => Navigator.push(
                        context,
                        FadeInRoute(const InviteFriendScreen(), Routes.inviteFriendScreen),
                      ),
                  title: LocaleKeys.kTextInvite.tr(),
                  height: 49.h),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CurrentQuestView(
                questImage: questImage,
                questName: questName,
              ),
            ),
            SizedBox(width: 16.w),
            const CloseButton(),
          ],
        ));
  }
}

