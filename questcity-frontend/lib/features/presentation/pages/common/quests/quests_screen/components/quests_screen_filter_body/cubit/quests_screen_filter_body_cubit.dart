import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart';

part 'quests_screen_filter_body_state.dart';

class QuestsScreenFilterBodyCubit extends Cubit<QuestsScreenFilterBodyState> {
  final Map<FilterCategory, int> selectedIndexes;
  final Function(FilterCategory categoryIndex, int value) onTap;
  final Function() onReset;
  QuestsScreenFilterBodyCubit(this.selectedIndexes, this.onTap, this.onReset)
      : super(QuestsScreenFilterBodyInitial()) {
    _init();
  }

  Map<FilterCategory, int> _selectedIndexes = {};

  Future _init() async {
    _selectedIndexes = selectedIndexes;
    emit(QuestsScreenFilterBodyUpdating());
    emit(QuestsScreenFilterBodyInitial());
  }

  Map<FilterCategory, int> getSelectedIndexes() {
    return _selectedIndexes;
  }

  onTapSubcategory(FilterCategory category, int value) {
    _selectedIndexes[category] = value;
    onTap(category, value);
    emit(QuestsScreenFilterBodyUpdating());
    emit(QuestsScreenFilterBodyInitial());
  }

  onResetFilter() {
    _selectedIndexes = {};
    onReset();
    emit(QuestsScreenFilterBodyUpdating());
    emit(QuestsScreenFilterBodyInitial());
  }
}
