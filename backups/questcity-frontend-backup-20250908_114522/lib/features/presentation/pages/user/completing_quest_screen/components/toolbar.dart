import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/chat_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/artifacts_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/toolbar_circle.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/toolbar_circle_ring.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/toolbar_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/tools_screen/tools_screen.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class Toolbar extends StatelessWidget {
  final List<QuestPointModel> route;
  final String questName;
  final String mileage;
  final int questId;
  final CompletingQuestScreenCubit cubit;
  const Toolbar(
      {super.key,
      required this.onTapHints,
      required this.route,
      required this.questName,
      required this.mileage,
      required this.questId,
      required this.cubit});

  final Function() onTapHints;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ToolbarCircleRing(height: 289.h, opacity: .6),
        ToolbarCircleRing(height: 222.h, opacity: .5),
        ToolbarCircleRing(height: 158.h, opacity: .3),
        const ToolbarCircle(),
        Positioned(
          top: -25.h,
          right: 65.w,
          child: ToolbarItem(
              size: 130.w,
              textPadding: 20.h,
              iconPath: Paths.toolbarArtifacts,
              onTap: () => Navigator.push(
                    context,
                    FadeInRoute(const ArtifactsScreen(), Routes.artifactsScreen),
                  ),
              title: LocaleKeys.kTextArtifacts.tr()),
        ),
        Positioned(
          top: -15.h,
          left: 70.w,
          child: ToolbarItem(
              size: 130.w,
              textPadding: 25.h,
              iconPath: Paths.toolbarTools,
              onTap: () => Navigator.push(
                    context,
                    FadeInRoute(
                        ToolsScreen(
                          questId: questId,
                          questName: questName,
                          mileage: mileage,
                          route: route,
                          cubit: cubit,
                        ),
                        Routes.toolsScreen),
                  ),
              title: LocaleKeys.kTextTools.tr()),
        ),
        Positioned(
          bottom: -30.h,
          child: ToolbarItem(
            size: 120.w,
            textPadding: 30.h,
            iconPath: Paths.toolbarChats,
            title: LocaleKeys.kTextChats.tr(),
            countMessage: 2,
            onTap: () => Navigator.push(
              context,
              FadeInRoute(const ChatScreen(isQuestChat: true), Routes.chatScreen),
            ),
          ),
        ),
        Positioned(
          top: 90.h,
          left: 30.w,
          child: ToolbarItem(
            size: 120.w,
            textPadding: 25.h,
            iconPath: Paths.toolbarHints,
            title: LocaleKeys.kTextHints.tr(),
            onTap: onTapHints,
          ),
        ),
        Positioned(
          top: 90.h,
          right: 10.w,
          child: ToolbarItem(
            size: 160.w,
            textPadding: 40.h,
            iconPath: Paths.toolbarFriends,
            title: LocaleKeys.kTextFriends.tr(),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

