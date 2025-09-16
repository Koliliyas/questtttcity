import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/quest_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_edit_screen/quest_edit_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

import '../../../../../../data/models/quests/quest_list_model.dart';

class QuestsSmallView extends StatelessWidget {
  const QuestsSmallView(
      {super.key, this.canEdit = false, required this.questItems});

  final bool canEdit;
  final QuestListModel questItems;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: getMarginOrPadding(left: 16, right: 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18.w,
        mainAxisSpacing: 18.w,
        childAspectRatio: 170.h / 235.h, // Adjust this ratio as needed
      ),
      itemCount: 6,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          FadeInRoute(
              QuestScreen(
                questId: questItems.items[index].id,
              ),
              Routes.questScreen),
        ),
        child: Container(
          padding: getMarginOrPadding(bottom: 12, left: 9, right: 9),
          height: 235.h, // Fixed height for each item
          decoration: BoxDecoration(
            color: UiConstants.whiteColor.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: [
              Expanded(
                child: GradientCard(
                  contentPadding: EdgeInsets.zero,
                  contentMargin: getMarginOrPadding(top: 10),
                  body: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Image.asset(
                          questItems.items[index].image,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8.w,
                        right: 12.w,
                        left: 12.w,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: getMarginOrPadding(
                                    left: 5, right: 9, top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  color: UiConstants.whiteColor
                                      .withValues(alpha: .32),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star_rate_rounded,
                                        color: UiConstants.yellowColor,
                                        size: 25.w),
                                    SizedBox(width: 2.w),
                                    Padding(
                                      padding: getMarginOrPadding(top: 4),
                                      child: Text(
                                        questItems.items[index].rating
                                            .toString(),
                                        style: UiConstants.textStyle4.copyWith(
                                            color: UiConstants.whiteColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: canEdit
                                    ? () => Navigator.push(
                                          context,
                                          FadeInRoute(
                                              QuestEditScreen(
                                                questId:
                                                    questItems.items[index].id,
                                              ),
                                              Routes.questEditScreen),
                                        )
                                    : null,
                                child: Container(
                                  padding: canEdit
                                      ? getMarginOrPadding(all: 10)
                                      : null,
                                  height: 36.w,
                                  width: 36.w,
                                  decoration: BoxDecoration(
                                      color: UiConstants.whiteColor
                                          .withValues(alpha: canEdit ? 1 : .5),
                                      shape: BoxShape.circle),
                                  child: canEdit
                                      ? SvgPicture.asset(Paths.pencilIconPath)
                                      : const Icon(
                                          Icons.favorite_outline,
                                          color: UiConstants.redColor,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  borderRadius: 24.r,
                ),
              ),
              SizedBox(height: 13.h),
              Text(questItems.items[index].name,
                  style: UiConstants.textStyle4
                      .copyWith(color: UiConstants.whiteColor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
