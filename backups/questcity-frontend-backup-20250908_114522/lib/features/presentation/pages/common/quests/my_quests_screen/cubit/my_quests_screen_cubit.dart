import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_all_quests.dart';

part 'my_quests_screen_state.dart';

class MyQuestsScreenCubit extends Cubit<MyQuestsScreenState> {
  final GetAllQuests getAllQuests;
  MyQuestsScreenCubit(this.getAllQuests) : super(MyQuestsScreenInitial());

  int selectedChip = 0;

  onTapChip(int value) {
    selectedChip = value;
    emit(MyQuestsScreenUpdating());
    emit(MyQuestsScreenInitial());
  }

  Future<void> loadData() async {
    emit(MyQuestsScreenLoading());
    final result = await getAllQuests(NoParams());
    result.fold(
      (failure) => emit(MyQuestsScreenError()),
      (questsList) {
        // Создаем правильную структуру для QuestListModel
        final questListData = {'items': questsList};
        final questListModel = QuestListModel.fromJson(questListData);
        emit(MyQuestsScreenLoaded(questsList: questListModel));
      },
    );
  }
}
