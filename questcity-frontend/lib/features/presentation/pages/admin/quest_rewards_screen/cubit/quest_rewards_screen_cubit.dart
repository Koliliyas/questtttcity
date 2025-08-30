import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Состояния экрана наград
abstract class QuestRewardsScreenState extends Equatable {
  const QuestRewardsScreenState();

  @override
  List<Object?> get props => [];
}

class QuestRewardsScreenLoading extends QuestRewardsScreenState {
  const QuestRewardsScreenLoading();
}

class QuestRewardsScreenLoaded extends QuestRewardsScreenState {
  final List<Map<String, dynamic>> rewards;

  const QuestRewardsScreenLoaded({required this.rewards});

  @override
  List<Object?> get props => [rewards];
}

class QuestRewardsScreenError extends QuestRewardsScreenState {
  final String message;

  const QuestRewardsScreenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit для управления состоянием экрана наград
class QuestRewardsScreenCubit extends Cubit<QuestRewardsScreenState> {
  QuestRewardsScreenCubit() : super(const QuestRewardsScreenLoading());

  // Загрузка наград (пока заглушка)
  Future<void> loadRewards() async {
    try {
      emit(const QuestRewardsScreenLoading());

      // Пока используем заглушку, позже будет API
      await Future.delayed(const Duration(seconds: 1));

      final mockRewards = [
        {
          'id': 1,
          'name': 'Базовые кредиты',
          'type': 'credits',
          'cost': 100,
          'reward': 150,
        },
        {
          'id': 2,
          'name': 'Первое достижение',
          'type': 'achievement',
          'level': 1,
          'badge': 'Новичок',
        },
        {
          'id': 3,
          'name': 'Бонус за скорость',
          'type': 'bonus',
          'bonus_type': 'speed',
          'condition': 'Завершить квест за 30 минут',
        },
      ];

      emit(QuestRewardsScreenLoaded(rewards: mockRewards));
    } catch (e) {
      emit(QuestRewardsScreenError(message: e.toString()));
    }
  }

  // Обновление наград
  Future<void> refreshRewards() async {
    await loadRewards();
  }
}
