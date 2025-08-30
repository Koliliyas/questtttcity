import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/reviews_screen/review_item.dart';
import 'package:los_angeles_quest/features/presentation/widgets/blur_rectangle_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ReviewsScreen extends StatelessWidget {
  final List<Review> reviews;
  final String questName;
  const ReviewsScreen({super.key, required this.reviews, required this.questName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Paths.backgroundGradient1Path),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high),
                ),
                child: Padding(
                  padding: getMarginOrPadding(
                      top: MediaQuery.of(context).padding.top + 20, right: 16, left: 16),
                  child: Column(
                    children: [
                      CustomAppBar(
                        onTapBack: () => Navigator.pop(context),
                        title: LocaleKeys.kTextReviews.tr(),
                      ),
                      Text(
                        questName,
                        style: UiConstants.textStyle21.copyWith(color: UiConstants.whiteColor),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: ListView.separated(
                          padding:
                              getMarginOrPadding(bottom: homeCubit.role == Role.USER ? 156 : 20),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ReviewItem(review: reviews[index]),
                          separatorBuilder: (context, index) => SizedBox(height: 16.h),
                          itemCount: reviews.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const BlurRectangleView(),
              Visibility(
                visible: homeCubit.role == Role.USER,
                child: Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 60.h,
                  child: CustomButton(
                    title: 'Leave feedback',
                    onTap: () {},
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

