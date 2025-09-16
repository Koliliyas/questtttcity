import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/empty_statistics_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/filter_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/statistics_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/cubit/statistics_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/statistics_screen_controller.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        //HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return BlocProvider(
          create: (context) => StatisticsScreenCubit(),
          child: BlocBuilder<StatisticsScreenCubit, StatisticsScreenState>(
            builder: (context, state) {
              StatisticsScreenCubit cubit =
                  context.read<StatisticsScreenCubit>();
              return Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(Paths.backgroundGradient1Path),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high),
                  ),
                  child: Padding(
                    padding: getMarginOrPadding(
                        top: MediaQuery.of(context).padding.top + 20,
                        right: 16,
                        left: 16),
                    child: Column(
                      children: [
                        CustomAppBar(
                          onTapBack: () => Navigator.pop(context),
                          title: LocaleKeys.kTextStatistics.tr(),
                          action: FilterButtonWithCounter(
                            countFilters: cubit.countFilters,
                            onTap: () =>
                                StatisticsScreenController.showFilterSheet(
                                    context, cubit),
                          ),
                        ),
                        cubit.countFilters != 0
                            ? Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(height: 24.h),
                                    StatisticsCard(
                                      isDropdown: false,
                                      isCategoryCard: !(cubit
                                              .isExpandedQuestsInFilter &&
                                          cubit.selectedIndexes.isNotEmpty &&
                                          cubit.selectedIndexes.last != -1),
                                    ),
                                    if (!(cubit.selectedIndexes.isNotEmpty &&
                                        cubit.selectedIndexes.last != -1 &&
                                        cubit.isExpandedQuestsInFilter))
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(height: 24.h),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                LocaleKeys.kTextCategoryQuests
                                                    .tr(),
                                                style: UiConstants.textStyle18
                                                    .copyWith(
                                                        color: UiConstants
                                                            .whiteColor,
                                                        fontWeight:
                                                            FontWeight.w500),
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            Expanded(
                                              child: ListView.separated(
                                                  padding: getMarginOrPadding(
                                                      bottom: 24),
                                                  itemBuilder:
                                                      (context, index) =>
                                                          const StatisticsCard(
                                                              isDropdown: true),
                                                  separatorBuilder: (context,
                                                          index) =>
                                                      SizedBox(height: 10.h),
                                                  itemCount: 5),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : const EmptyStatisticsView(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

