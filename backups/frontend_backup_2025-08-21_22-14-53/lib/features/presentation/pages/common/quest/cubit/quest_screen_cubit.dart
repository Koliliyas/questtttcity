import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_vehicles.dart';

import '../../../../../data/models/quests/quest_model.dart';
import '../../../../../domain/usecases/quest/get_quest.dart';

part 'quest_screen_state.dart';

class QuestScreenCubit extends Cubit<QuestScreenState> {
  final GetQuest getQuest;
  final GetVehicles getVehicles;
  QuestScreenCubit(this.getQuest, this.getVehicles)
      : super(QuestScreenInitial());

  bool isMoreButtonTap = false;

  void changeMoreButton() {
    isMoreButtonTap = !isMoreButtonTap;
    emit(QuestScreenLoading());
    emit(QuestScreenInitial());
  }

  Future<void> loadData(int questId) async {
    final quest = await getQuest(questId);
    final vehiclesResult = await getVehicles.call(NoParams());

    vehiclesResult.fold(
      (failure) {
        emit(QuestScreenError('Failed to load vehicles'));
        return;
      },
      (vehicles) {
        final vehicle = vehicles
            .firstWhere(
              (element) => quest.mainPreferences.vehicleId == element.id,
            )
            .title;

        emit(QuestScreenLoaded(quest: quest, vehicle: vehicle));
      },
    );
  }
}
