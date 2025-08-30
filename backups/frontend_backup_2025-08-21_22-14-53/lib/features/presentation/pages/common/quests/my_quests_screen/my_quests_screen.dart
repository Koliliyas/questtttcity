import 'dart:math';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/my_quests_screen/components/my_quests_screen_category_chip.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/my_quests_screen/cubit/my_quests_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/quest_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/quests_screen_controller.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/locator_service.dart';

class MyQuestsScreen extends StatelessWidget {
  const MyQuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CarouselSliderController buttonCarouselController = CarouselSliderController();
    final PageController pageController = PageController(viewportFraction: 1.1);
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        //HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return BlocProvider(
          create: (context) => MyQuestsScreenCubit(sl())..loadData(),
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Paths.backgroundGradient1Path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high),
              ),
              child: BlocBuilder<MyQuestsScreenCubit, MyQuestsScreenState>(
                builder: (context, state) {
                  MyQuestsScreenCubit cubit = context.read<MyQuestsScreenCubit>();

                  if (state is MyQuestsScreenLoaded) {
                    List<QuestItemStatus> statuses = [
                      QuestItemStatus.ALL,
                      QuestItemStatus.ACTIVE,
                      QuestItemStatus.COMPLETED,
                      QuestItemStatus.FAVORRITE
                    ];

                    final body = List.generate(
                      state.questsList.items.length,
                      (index) => QuestItemWidget(
                        questItem: state.questsList.items[index],
                        questItemStatus: statuses[index % 4],
                      ),
                    );
                    return Padding(
                      padding: getMarginOrPadding(
                          top: MediaQuery.of(context).padding.top + 20, bottom: 156),
                      child: Column(
                        children: [
                          Padding(
                            padding: getMarginOrPadding(left: 16, right: 16),
                            child: CustomAppBar(
                              title: LocaleKeys.kTextMyQuests.tr(),
                              onTapBack: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(height: 21.h),
                          Padding(
                            padding: getMarginOrPadding(left: 16, right: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MyQuestsScreenCategoryChip(
                                      text: LocaleKeys.kTextAll.tr(),
                                      isSelected: cubit.selectedChip == 0,
                                      index: 0,
                                      onTap: (int value) {
                                        pageController.animateToPage(value,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut);
                                      }),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: MyQuestsScreenCategoryChip(
                                      icon: Transform.rotate(
                                        angle: 25 * pi / 180,
                                        child: Transform.flip(
                                          flipX: true,
                                          child: const Icon(Icons.replay_outlined,
                                              color: UiConstants.whiteColor),
                                        ),
                                      ),
                                      isSelected: cubit.selectedChip == 1,
                                      index: 1,
                                      onTap: (int value) {
                                        pageController.animateToPage(value,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut);
                                      }),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: MyQuestsScreenCategoryChip(
                                      icon: const Icon(Icons.check, color: UiConstants.whiteColor),
                                      isSelected: cubit.selectedChip == 2,
                                      index: 2,
                                      onTap: (int value) {
                                        pageController.animateToPage(value,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut);
                                      }),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: MyQuestsScreenCategoryChip(
                                      icon:
                                          const Icon(Icons.favorite, color: UiConstants.whiteColor),
                                      isSelected: cubit.selectedChip == 3,
                                      index: 3,
                                      onTap: (int value) {
                                        pageController.animateToPage(value,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut);
                                      }),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Expanded(
                            child: PageView(
                              onPageChanged: cubit.onTapChip,
                              controller: pageController,
                              children: List.generate(
                                4,
                                (index) {
                                  return FractionallySizedBox(
                                    widthFactor: 1 / pageController.viewportFraction,
                                    child: index % 2 == 0
                                        ? Padding(
                                            padding: getMarginOrPadding(left: 16, right: 16),
                                            child: CarouselSlider(
                                              items: body,
                                              carouselController: buttonCarouselController,
                                              options: CarouselOptions(
                                                  scrollDirection: Axis.vertical,
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.34,
                                                  initialPage: 2,
                                                  disableCenter: true),
                                            ),
                                          )
                                        : ListView.separated(
                                            padding: getMarginOrPadding(left: 16, right: 16),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) => body[index],
                                            separatorBuilder: (context, index) =>
                                                SizedBox(height: 14.h),
                                            itemCount: 2),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

