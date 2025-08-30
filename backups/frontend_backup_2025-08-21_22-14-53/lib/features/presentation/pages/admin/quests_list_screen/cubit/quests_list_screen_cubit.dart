import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_create_screen/quest_create_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_edit_screen/quest_edit_screen.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_all_quests_admin.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/delete_quest.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';

// Абстрактный класс для состояний
abstract class QuestsListScreenState extends Equatable {
  const QuestsListScreenState();

  @override
  List<Object?> get props => [];
}

// Состояние загрузки
class QuestsListScreenLoading extends QuestsListScreenState {
  const QuestsListScreenLoading();
}

// Состояние загружено
class QuestsListScreenLoaded extends QuestsListScreenState {
  final List<Map<String, dynamic>> quests;

  const QuestsListScreenLoaded({required this.quests});

  @override
  List<Object?> get props => [quests];
}

// Состояние ошибки
class QuestsListScreenError extends QuestsListScreenState {
  final String message;

  const QuestsListScreenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit для управления состоянием
class QuestsListScreenCubit extends Cubit<QuestsListScreenState> {
  final GetAllQuestsAdmin getQuestsUC; // Use case для получения квестов
  final DeleteQuest deleteQuestUC; // Use case для удаления квеста

  QuestsListScreenCubit({
    required this.getQuestsUC,
    required this.deleteQuestUC,
  }) : super(const QuestsListScreenLoading()) {
    searchController.addListener(_onSearchTextChanged);
  }

  final TextEditingController searchController = TextEditingController();

  void _onSearchTextChanged() {
    // Здесь будет логика поиска
    print('🔍 DEBUG: Search text changed: ${searchController.text}');
  }

  // Загрузка списка квестов
  Future<void> loadQuests() async {
    try {
      emit(const QuestsListScreenLoading());

      // Вызываем use case для получения квестов с сервера
      final result = await getQuestsUC(NoParams());

      result.fold(
        (failure) {
          print(
              '🔍 DEBUG: QuestsListScreenCubit.loadQuests() - Failure: $failure');
          emit(QuestsListScreenError(message: failure.toString()));
        },
        (quests) {
          print(
              '🔍 DEBUG: QuestsListScreenCubit.loadQuests() - Success: ${quests.length} quests');
          emit(QuestsListScreenLoaded(quests: quests));
        },
      );
    } catch (e) {
      print('🔍 DEBUG: QuestsListScreenCubit.loadQuests() - Exception: $e');
      emit(QuestsListScreenError(message: e.toString()));
    }
  }

  // Метод для загрузки тестовых данных (временное решение)
  Future<void> loadTestQuests() async {
    try {
      emit(const QuestsListScreenLoading());

      // Имитируем задержку сети
      await Future.delayed(const Duration(seconds: 1));

      // Тестовые данные для отладки UI
      final testQuests = [
        {
          'id': 1,
          'title': 'Тестовый квест 1',
          'description': 'Описание тестового квеста 1',
          'category_id': 1,
          'difficulty': 'Easy',
          'duration': '1-2 hours',
          'cost': 100,
          'reward': 200,
        },
        {
          'id': 2,
          'title': 'Тестовый квест 2',
          'description': 'Описание тестового квеста 2',
          'category_id': 2,
          'difficulty': 'Medium',
          'duration': '2-3 hours',
          'cost': 150,
          'reward': 300,
        },
      ];

      print(
          '🔍 DEBUG: QuestsListScreenCubit.loadTestQuests() - Loading test data');
      emit(QuestsListScreenLoaded(quests: testQuests));
    } catch (e) {
      print('🔍 DEBUG: QuestsListScreenCubit.loadTestQuests() - Exception: $e');
      emit(QuestsListScreenError(
          message: 'Ошибка загрузки тестовых данных: $e'));
    }
  }

  // Удаление квеста
  Future<void> deleteQuest(int questId) async {
    try {
      final result = await deleteQuestUC(DeleteQuestParams(questId: questId));
      result.fold(
        (failure) {
          emit(QuestsListScreenError(message: failure.toString()));
        },
        (_) {
          // Перезагружаем список после успешного удаления
          loadQuests();
          // Можно добавить уведомление об успешном удалении
          print('✅ Quest $questId deleted successfully');
        },
      );
    } catch (e) {
      emit(QuestsListScreenError(message: 'Delete failed: $e'));
    }
  }

  // Навигация к созданию квеста
  void navigateToCreateQuest(BuildContext context) {
    Navigator.push(
      context,
      FadeInRoute(
        const QuestCreateScreen(),
        Routes.questCreateScreen,
      ),
    );
  }

  // Навигация к редактированию квеста
  void navigateToEditQuest(BuildContext context, int questId) {
    Navigator.push(
      context,
      FadeInRoute(
        QuestEditScreen(questId: questId),
        Routes.questEditScreen,
        arguments: {'questId': questId},
      ),
    );
  }

  // Убираю метод dispose, так как он не нужен для Cubit
}
