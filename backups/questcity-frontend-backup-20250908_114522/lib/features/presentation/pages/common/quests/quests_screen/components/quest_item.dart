import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/quest_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_edit_screen/quest_edit_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/quests_screen_controller.dart';

class QuestItemWidget extends StatelessWidget {
  const QuestItemWidget(
      {super.key,
      required this.questItem,
      this.height,
      this.questItemStatus,
      this.isFavorite = false,
      this.canEdit = false});

  final QuestItem questItem;
  final double? height;
  final QuestItemStatus? questItemStatus;
  final bool isFavorite;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = QuestsScreenController.getQuestCardChips(
        questItemStatus, questItem.id, isFavorite);
    return Stack(
      children: [
        GradientCard(
          onTap: () => Navigator.push(
            context,
            FadeInRoute(
                QuestScreen(
                  questId: questItem.id,
                ),
                Routes.questScreen),
          ),
          height: height ?? 203.h,
          contentPadding: EdgeInsets.zero,
          body: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              child: Image.network(
                questItem.image,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: canEdit
              ? GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    FadeInRoute(QuestEditScreen(questId: questItem.id),
                        Routes.questEditScreen),
                  ),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                        color: UiConstants.whiteColor, shape: BoxShape.circle),
                    padding: getMarginOrPadding(all: 10),
                    child: SvgPicture.asset(Paths.pencilIconPath),
                  ),
                )
              : Row(children: chips),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            questItem.name,
            style:
                UiConstants.textStyle4.copyWith(color: UiConstants.whiteColor),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 14,
          child: Container(
            padding: getMarginOrPadding(left: 5, right: 5, top: 2, bottom: 2),
            decoration: BoxDecoration(
              color: UiConstants.whiteColor.withValues(alpha: .32),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Icon(Icons.star_rate_rounded,
                    color: UiConstants.yellowColor, size: 25.w),
                SizedBox(width: 2.w),
                Padding(
                  padding: getMarginOrPadding(top: 4),
                  child: Text(
                    questItem.rating.toString(),
                    style: UiConstants.textStyle4
                        .copyWith(color: UiConstants.whiteColor),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
