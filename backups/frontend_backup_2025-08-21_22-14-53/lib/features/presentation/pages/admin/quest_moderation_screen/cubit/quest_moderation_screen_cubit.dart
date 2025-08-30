import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Состояния экрана модерации
abstract class QuestModerationScreenState extends Equatable {
  const QuestModerationScreenState();

  @override
  List<Object?> get props => [];
}

class QuestModerationScreenLoading extends QuestModerationScreenState {
  const QuestModerationScreenLoading();
}

class QuestModerationScreenLoaded extends QuestModerationScreenState {
  final Map<String, dynamic> moderationData;

  const QuestModerationScreenLoaded({required this.moderationData});

  @override
  List<Object?> get props => [moderationData];
}

class QuestModerationScreenError extends QuestModerationScreenState {
  final String message;

  const QuestModerationScreenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit для управления состоянием экрана модерации
class QuestModerationScreenCubit extends Cubit<QuestModerationScreenState> {
  QuestModerationScreenCubit() : super(const QuestModerationScreenLoading());

  // Загрузка данных модерации (пока заглушка)
  Future<void> loadModerationData() async {
    try {
      emit(const QuestModerationScreenLoading());

      // Пока используем заглушку, позже будет API
      await Future.delayed(const Duration(seconds: 1));

      final mockModerationData = {
        'pending_quests': [
          {
            'id': 1,
            'title': 'Новый квест 1',
            'author': 'Автор 1',
            'image': 'https://example.com/image1.jpg',
            'created_at': '2024-01-15',
            'status': 'На проверке',
          },
          {
            'id': 2,
            'title': 'Новый квест 2',
            'author': 'Автор 2',
            'image': 'https://example.com/image2.jpg',
            'created_at': '2024-01-16',
            'status': 'На проверке',
          },
        ],
        'complaints': [
          {
            'id': 1,
            'target': 'Квест "Проблемный"',
            'reporter': 'Пользователь 1',
            'reason': 'Неприемлемый контент',
            'date': '2024-01-15',
            'status': 'Новая',
          },
          {
            'id': 2,
            'target': 'Комментарий пользователя',
            'reporter': 'Пользователь 2',
            'reason': 'Спам',
            'date': '2024-01-16',
            'status': 'В расследовании',
          },
        ],
        'reviews': [
          {
            'id': 1,
            'quest_title': 'Квест "Отличный"',
            'author': 'Пользователь 3',
            'rating': 5,
            'text': 'Очень понравился квест!',
            'date': '2024-01-15',
          },
          {
            'id': 2,
            'quest_title': 'Квест "Хороший"',
            'author': 'Пользователь 4',
            'rating': 4,
            'text': 'Хороший квест, но можно улучшить.',
            'date': '2024-01-16',
          },
        ],
        'comments': [
          {
            'id': 1,
            'quest_title': 'Квест "Обсуждение"',
            'author': 'Пользователь 5',
            'text': 'Интересная идея!',
            'date': '2024-01-15',
          },
          {
            'id': 2,
            'quest_title': 'Квест "Обсуждение"',
            'author': 'Пользователь 6',
            'text': 'Согласен с предыдущим комментарием.',
            'date': '2024-01-16',
          },
        ],
      };

      emit(QuestModerationScreenLoaded(moderationData: mockModerationData));
    } catch (e) {
      emit(QuestModerationScreenError(message: e.toString()));
    }
  }

  // Обновление данных модерации
  Future<void> refreshModerationData() async {
    await loadModerationData();
  }
}
