import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/features/presentation/widgets/button_chips/button_chips_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';

class AccountQuestsPageView extends StatefulWidget {
  const AccountQuestsPageView(
      {super.key,
      required this.onTapQuestsPreference,
      required this.managerCanEditQuests,
      required this.managerCanSendCredits,
      required this.owner});

  final Function(bool questPreference) onTapQuestsPreference;
  final bool managerCanEditQuests;
  final bool managerCanSendCredits;
  final Role owner;

  @override
  State<AccountQuestsPageView> createState() => _AccountQuestsPageViewState();
}

class _AccountQuestsPageViewState extends State<AccountQuestsPageView> {
  int activePage = 0;

  @override
  Widget build(BuildContext context) {
    PageController controller =
        PageController(initialPage: 0, viewportFraction: 1.05);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.owner == Role.MANAGER) _buildChipButtons(controller),
        if (widget.owner == Role.MANAGER)
          SizedBox(
            height: 56.h,
            child: PageView(
              controller: controller,
              onPageChanged: (value) => setState(() {
                activePage = value;
              }),
              children: [
                QuestPreferenceViewItem(
                  preferencesItem: QuestPreferenceItem('Can send credits'),
                  isChecked: widget.managerCanEditQuests,
                  onTap: (preferencesIndex, preferencesItemIndex,
                          {bool? preferencesItemHasSubitems,
                          preferencesSubItemIndex}) =>
                      widget.onTapQuestsPreference(true),
                  index: 0,
                  preferenceIndex: 0,
                  padding: getMarginOrPadding(left: 24, right: 24),
                ),
                QuestPreferenceViewItem(
                  preferencesItem: QuestPreferenceItem('Can edit quests'),
                  isChecked: widget.managerCanSendCredits,
                  onTap: (preferencesIndex, preferencesItemIndex,
                          {bool? preferencesItemHasSubitems,
                          preferencesSubItemIndex}) =>
                      widget.onTapQuestsPreference(false),
                  index: 1,
                  preferenceIndex: 0,
                  padding: getMarginOrPadding(left: 24, right: 24),
                ),
              ],
            ),
          ),
        GridView.builder(
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
          itemBuilder: (context, index) => Container(
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
                            index % 2 == 0
                                ? Paths.quest1Path
                                : Paths.quest2Path,
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 36.w,
                                  width: 36.w,
                                  decoration: BoxDecoration(
                                      color: UiConstants.whiteColor
                                          .withValues(alpha: .5),
                                      shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.favorite_outlined,
                                    color: UiConstants.redColor,
                                  ),
                                ),
                                SizedBox(width: 8.58.w),
                                Container(
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: const BoxDecoration(
                                      color: UiConstants.greenColor,
                                      shape: BoxShape.circle),
                                  //    padding: getMarginOrPadding(all: 10),
                                  child: const Icon(Icons.check,
                                      color: UiConstants.whiteColor),
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
                Text(LocaleKeys.kTextHollywoodHills.tr(),
                    style: UiConstants.textStyle4
                        .copyWith(color: UiConstants.whiteColor),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipButtons(PageController controller) {
    return Padding(
      padding: getMarginOrPadding(left: 16, right: 16, bottom: 20),
      child: ButtonChipsView(
        onTapChip: (index) {
          setState(() {
            activePage = index;
          });
          controller.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn);
        },
        activeChipIndex: activePage,
        chipNames: ['Edit', LocaleKeys.kTextCredits.tr()],
      ),
    );
  }
}

