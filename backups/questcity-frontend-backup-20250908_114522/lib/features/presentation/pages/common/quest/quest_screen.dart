import 'package:carousel_slider/carousel_slider.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/bloc/purchase_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/components/more_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/buy_quest_panel.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/quest_categories_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/quest_description_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/quest_rating_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/quest_see_map_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/cubit/quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/locator_service.dart';


class QuestScreen extends StatelessWidget {
  final int questId;
  const QuestScreen({super.key, required this.questId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseCubit, PurchaseState>(
      builder: (context, state) {
        return BlocBuilder<HomeScreenCubit, HomeScreenState>(
          builder: (context, state) {
            HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
            return BlocProvider(
              create: (context) => QuestScreenCubit(sl(), sl())..loadData(questId),
              child: BlocBuilder<QuestScreenCubit, QuestScreenState>(
                builder: (context, state) {
                  QuestScreenCubit cubit = context.read<QuestScreenCubit>();
                  if (state is QuestScreenLoading) {
                    return const CustomLoadingIndicator();
                  }
                  if (state is QuestScreenLoaded) {
                    return Scaffold(
                      body: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(Paths.backgroundGradient1Path),
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.high),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 390.h,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(state.quest.image),
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high),
                              ),
                            ),
                            Padding(
                              padding: getMarginOrPadding(
                                  top: MediaQuery.of(context).padding.top + 20, bottom: 12),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: getMarginOrPadding(left: 16, right: 16),
                                    child: CustomAppBar(
                                      onTapBack: () => Navigator.pop(context),
                                      title: state.quest.name,
                                      action: homeCubit.role == Role.USER
                                          ? MoreButton(
                                              onTap: cubit.changeMoreButton,
                                              isActive: cubit.isMoreButtonTap)
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: 275.h),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: getMarginOrPadding(left: 16, right: 16),
                                        child: QuestCategoriesView(
                                          preferences: state.quest.mainPreferences,
                                          reward: state.quest.credits.reward,
                                          vehicle: state.vehicle,
                                        ),
                                      ),
                                      SizedBox(height: 11.h),
                                      SizedBox(
                                        child: CarouselSlider.builder(
                                          options: CarouselOptions(
                                            height: 185.h,
                                            viewportFraction: 0.8,
                                            initialPage: 0,
                                            enableInfiniteScroll: false,
                                            enlargeCenterPage: true,
                                            enlargeFactor: 0.3,
                                            scrollDirection: Axis.horizontal,
                                          ),
                                          itemCount: state.quest.points.length,
                                          itemBuilder: (context, index, realIndex) =>
                                              QuestDescriptionItem(
                                            point: state.quest.points[index],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 23.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          QuestRatingView(
                                            reviews: state.quest.reviews,
                                            questName: state.quest.name,
                                          ),
                                          SizedBox(width: 10.w),
                                          QuestSeeMapView(
                                            questImage: state.quest.image,
                                            mileage: state.quest.mainPreferences.milege,
                                            points: state.quest.points,
                                            questName: state.quest.name,
                                            merchItem: state.quest.merch,
                                            questId: questId,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 16.w,
                              right: 16.w,
                              bottom: 60.h,
                              child: homeCubit.role == Role.USER
                                  ? BuyQuestPanel(
                                      questImage: state.quest.image,
                                      questName: state.quest.name,
                                      mileage: state.quest.mainPreferences.milege,
                                      questId: questId,
                                      price: state.quest.mainPreferences.price.amount,
                                      isQuestPurchased: (state.quest.mainPreferences.price.amount ==
                                                  null ||
                                              state.quest.mainPreferences.price.amount == 0) &&
                                          state.quest.mainPreferences.price.isSubscription == false,
                                      onBuyQuest: context.read<PurchaseCubit>().purchaseQuest,
                                      merchItem: state.quest.merch,
                                    )
                                  : CustomButton(
                                      title: LocaleKeys.kTextEditQuest.tr(),
                                      onTap: () => Navigator.push(
                                            context,
                                            FadeInRoute(
                                                const EditQuestScreen(), Routes.editQuestScreen),
                                          ),
                                      hasGradient: false),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        );
      },
    );
  }
}

