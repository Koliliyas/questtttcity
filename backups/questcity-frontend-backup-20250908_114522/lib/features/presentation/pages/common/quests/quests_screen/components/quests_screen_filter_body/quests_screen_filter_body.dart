import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/quests_screen_filter_body/cubit/quests_screen_filter_body_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestsScreenFilterBody extends StatefulWidget {
  const QuestsScreenFilterBody(
      {super.key, required this.selectedIndexes, required this.onTap, required this.onResetFilter});

  final Map<FilterCategory, int> selectedIndexes;
  final Function(FilterCategory categoryIndex, int value) onTap;
  final Function() onResetFilter;

  @override
  State<QuestsScreenFilterBody> createState() => _QuestsScreenFilterBodyState();
}

class _QuestsScreenFilterBodyState extends State<QuestsScreenFilterBody> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocProvider(
        create: (context) =>
            QuestsScreenFilterBodyCubit(widget.selectedIndexes, widget.onTap, widget.onResetFilter),
        child: BlocBuilder<QuestsScreenFilterBodyCubit, QuestsScreenFilterBodyState>(
          builder: (context, state) {
            QuestsScreenFilterBodyCubit cubit = context.read<QuestsScreenFilterBodyCubit>();
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Expanded(
                      child: Text(
                        LocaleKeys.kTextFilter.tr(),
                        style: UiConstants.textStyle6.copyWith(color: UiConstants.whiteColor),
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
                          style: UiConstants.textStyle7.copyWith(color: UiConstants.whiteColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
                // Expanded(
                //   child: ListView(
                //     padding: getMarginOrPadding(bottom: 120),
                //     children: [
                //       ListView.separated(
                //         padding: EdgeInsets.zero,
                //         shrinkWrap: true,
                //         physics: const NeverScrollableScrollPhysics(),
                //         itemBuilder: (context, position) => QuestPreferenceView(
                //           preferenceIndex: position,
                //           title: QuestScreenData().data[position].title,
                //           preferencesItems: QuestScreenData().data[position].items,
                //           checkedItemIndex: cubit.getSelectedIndexes()[position],
                //           onTap: cubit.onTapSubcategory,
                //         ),
                //         separatorBuilder: (context, index) => SizedBox(height: 24.h),
                //         itemCount: QuestScreenData().data.length,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}

