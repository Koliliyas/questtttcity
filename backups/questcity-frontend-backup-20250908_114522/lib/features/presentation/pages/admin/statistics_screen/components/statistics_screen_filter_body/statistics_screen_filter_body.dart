import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/statistics_screen_filter_body/cubit/statistics_screen_filter_body_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/statistics_screen_data.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view.dart';

class StatisticsScreenFilterBody extends StatefulWidget {
  const StatisticsScreenFilterBody(
      {super.key,
      required this.selectedIndexes,
      required this.onTap,
      required this.onResetFilter,
      required this.dateController,
      required this.isExpandedQuestsInFilter,
      required this.onExpandedOrCollapsedQuestsFilter});

  final List<int> selectedIndexes;
  final Function(int categoryIndex, int value) onTap;
  final Function() onResetFilter;
  final TextEditingController dateController;
  final bool isExpandedQuestsInFilter;
  final Function() onExpandedOrCollapsedQuestsFilter;

  @override
  State<StatisticsScreenFilterBody> createState() =>
      _StatisticsScreenFilterBodyState();
}

class _StatisticsScreenFilterBodyState
    extends State<StatisticsScreenFilterBody> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocProvider(
        create: (context) => StatisticsScreenFilterBodyCubit(
            widget.selectedIndexes, widget.onTap, widget.onResetFilter),
        child: BlocBuilder<StatisticsScreenFilterBodyCubit,
            StatisticsScreenFilterBodyState>(
          builder: (context, state) {
            StatisticsScreenFilterBodyCubit cubit =
                context.read<StatisticsScreenFilterBodyCubit>();
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Expanded(
                      child: Text(
                        LocaleKeys.kTextFilter.tr(),
                        style: UiConstants.textStyle6
                            .copyWith(color: UiConstants.whiteColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            cubit.onResetFilter();
                          });
                        },
                        child: Text(
                          LocaleKeys.kTextClearFilter.tr(),
                          style: UiConstants.textStyle7
                              .copyWith(color: UiConstants.whiteColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: getMarginOrPadding(bottom: 120),
                    children: [
                      ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, position) => QuestPreferenceView(
                            preferenceIndex: position,
                            title: StatisticsScreenData().data[position].title,
                            preferencesItems:
                                StatisticsScreenData().data[position].items,
                            checkedItemIndex:
                                cubit.getSelectedIndexes()[position],
                            onTap: cubit.onTapSubcategory,
                            isExpanded: position == 1
                                ? widget.isExpandedQuestsInFilter
                                : null,
                            onTapExpanded:
                                widget.onExpandedOrCollapsedQuestsFilter),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 24.h),
                        itemCount: StatisticsScreenData().data.length,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        LocaleKeys.kTextPeriod.tr(),
                        style: UiConstants.textStyle8
                            .copyWith(color: UiConstants.whiteColor),
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () async {
                          DateTime? date = await Utils.showDatePicker(context);
                          if (date != null) {
                            widget.dateController.text =
                                DateFormat('MMMM yyyy').format(date);
                          }
                        },
                        child: CustomTextField(
                          controller: widget.dateController,
                          textInputAction: TextInputAction.next,
                          isExpanded: true,
                          textStyle: UiConstants.textStyle12
                              .copyWith(color: UiConstants.blackColor),
                          fillColor: UiConstants.whiteColor,
                          isEnabled: false,
                          suffixWidget: SvgPicture.asset(Paths.calendar),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CustomMonthPicker extends DatePickerModel {
  CustomMonthPicker(
      {super.currentTime, super.minTime, super.maxTime, super.locale});

  @override
  List<int> layoutProportions() {
    return [1, 1, 0];
  }
}

