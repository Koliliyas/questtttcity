import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'statistics_screen_filter_body_state.dart';

class StatisticsScreenFilterBodyCubit
    extends Cubit<StatisticsScreenFilterBodyState> {
  final List<int> selectedIndexes;
  final Function(int categoryIndex, int value) onTap;
  final Function() onReset;
  StatisticsScreenFilterBodyCubit(
      this.selectedIndexes, this.onTap, this.onReset)
      : super(StatisticsScreenFilterBodyInitial()) {
    _init();
  }

  List<int> _selectedIndexes = [];

  Future _init() async {
    _selectedIndexes = selectedIndexes;
    emit(StatisticsScreenFilterBodyUpdating());
    emit(StatisticsScreenFilterBodyInitial());
  }

  List<int> getSelectedIndexes() {
    return _selectedIndexes;
  }

  onTapSubcategory(int preferencesIndex, int preferencesItemIndex,
      {int? preferencesSubItemIndex, bool preferencesItemHasSubitems = false}) {
    if (preferencesIndex >= 0 && preferencesIndex < _selectedIndexes.length) {
      _selectedIndexes[preferencesIndex] = preferencesItemIndex;
      onTap(preferencesIndex, preferencesItemIndex);
      emit(StatisticsScreenFilterBodyUpdating());
      emit(StatisticsScreenFilterBodyInitial());
    }
  }

  onResetFilter() {
    _selectedIndexes = [0, 0, 0, 0, 0, 0, 0];
    onReset();
    emit(StatisticsScreenFilterBodyUpdating());
    emit(StatisticsScreenFilterBodyInitial());
  }
}
