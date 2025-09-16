import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/components/quest_detail_info_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/components/quest_detail_header.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/components/quest_detail_points_section.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/components/quest_detail_merchandise_section.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/components/quest_detail_reviews_section.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/locator_service.dart';

class QuestDetailScreen extends StatelessWidget {
  final int questId;
  final QuestItem? questItem; // Опциональный параметр для передачи данных

  const QuestDetailScreen({
    super.key,
    required this.questId,
    this.questItem,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          QuestDetailScreenCubit(sl())..loadQuestDetails(questId, questItem),
      child: BlocBuilder<QuestDetailScreenCubit, QuestDetailScreenState>(
        builder: (context, state) {
          if (state is QuestDetailScreenLoading) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Paths.backgroundGradient1Path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                child: const CustomLoadingIndicator(),
              ),
            );
          }

          if (state is QuestDetailScreenError) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Paths.backgroundGradient1Path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.w,
                        color: UiConstants.redColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: UiConstants.textStyle2.copyWith(
                          color: UiConstants.whiteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        title: LocaleKeys.kTextCancel.tr(),
                        onTap: () => Navigator.pop(context),
                        hasGradient: false,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is QuestDetailScreenLoaded) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Paths.backgroundGradient1Path),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    child: Column(
                      children: [
                        // App Bar
                        Padding(
                          padding: getMarginOrPadding(
                            top: MediaQuery.of(context).padding.top + 20,
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: CustomAppBar(
                            onTapBack: () => Navigator.pop(context),
                            title: LocaleKeys.kTextQuestDetails.tr(),
                          ),
                        ),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: getMarginOrPadding(
                              left: 16,
                              right: 16,
                              bottom: 100, // Space for Get Started button
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Quest Header with Image and Basic Info
                                QuestDetailHeader(
                                  questItem: state.questItem,
                                  questDetails: state.questDetails,
                                ),

                                SizedBox(height: 24.h),

                                // Quest Information Cards
                                QuestDetailInfoCard(
                                  questItem: state.questItem,
                                  questDetails: state.questDetails,
                                ),

                                SizedBox(height: 24.h),

                                // Description Section
                                if (state.questDetails?.description != null)
                                  _buildDescriptionSection(
                                      context, state.questDetails!.description),

                                SizedBox(height: 24.h),

                                // Points Section
                                if (state.questDetails?.points != null &&
                                    state.questDetails!.points.isNotEmpty)
                                  QuestDetailPointsSection(
                                    points: state.questDetails!.points,
                                  ),

                                SizedBox(height: 24.h),

                                // Merchandise Section
                                if (state.questDetails?.merch != null &&
                                    state.questDetails!.merch.isNotEmpty)
                                  QuestDetailMerchandiseSection(
                                    merchandise: state.questDetails!.merch,
                                  ),

                                SizedBox(height: 24.h),

                                // Reviews Section
                                if (state.questDetails?.reviews != null &&
                                    state.questDetails!.reviews.isNotEmpty)
                                  QuestDetailReviewsSection(
                                    reviews: state.questDetails!.reviews,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Get Started Button - Positioned at bottom
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    child: CustomButton(
                      title: LocaleKeys.kTextGetStarted.tr(),
                      onTap: () {
                        // TODO: Implement quest start logic
                        Navigator.push(
                          context,
                          FadeInRoute(
                            // Placeholder for quest start screen
                            const SizedBox(), // Replace with actual quest start screen
                            Routes.questScreen, // Replace with actual route
                          ),
                        );
                      },
                      iconLeft: Icon(
                        Icons.play_arrow_rounded,
                        size: 25.w,
                        color: UiConstants.whiteColor,
                      ),
                      buttonColor: UiConstants.orangeColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, String description) {
    return Container(
      width: double.infinity,
      padding: getMarginOrPadding(all: 16),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: UiConstants.whiteColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                size: 20.w,
                color: UiConstants.whiteColor,
              ),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.kTextDescription.tr(),
                style: UiConstants.textStyle2.copyWith(
                  color: UiConstants.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: UiConstants.textStyle5.copyWith(
              color: UiConstants.whiteColor.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
