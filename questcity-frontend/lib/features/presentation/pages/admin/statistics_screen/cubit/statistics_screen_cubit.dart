import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'statistics_screen_state.dart';

class StatisticsScreenCubit extends Cubit<StatisticsScreenState> {
  StatisticsScreenCubit() : super(StatisticsScreenInitial());

  List<int> selectedIndexes = [0, 0];
  int countFilters = 0;
  bool isExpandedQuestsInFilter = true;
  final TextEditingController dateController = TextEditingController(
      text: DateFormat('MMMM yyyy').format(DateTime.now()));

  void onTapSubcategory(int categoryIndex, int value) {
    if (categoryIndex >= 0 && categoryIndex < selectedIndexes.length) {
      selectedIndexes[categoryIndex] = value;
      countFilters = selectedIndexes.where((e) => e != -1 && e >= 0).length;
      emit(StatisticsScreenUpdating());
      emit(StatisticsScreenInitial());
    }
  }

  void onResetFilter() {
    selectedIndexes = [0, 0];
    countFilters = 0;
    emit(StatisticsScreenUpdating());
    emit(StatisticsScreenInitial());
  }

  void onExpandedOrCollapsedQuestsFilter() {
    isExpandedQuestsInFilter = !isExpandedQuestsInFilter;
    emit(StatisticsScreenUpdating());
    emit(StatisticsScreenInitial());
  }
}
