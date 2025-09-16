import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/domain/usecases/category/get_all_categories.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';

// Состояния экрана категорий
abstract class QuestCategoriesScreenState extends Equatable {
  const QuestCategoriesScreenState();

  @override
  List<Object?> get props => [];
}

class QuestCategoriesScreenLoading extends QuestCategoriesScreenState {
  const QuestCategoriesScreenLoading();
}

class QuestCategoriesScreenLoaded extends QuestCategoriesScreenState {
  final List<Map<String, dynamic>> categories;

  const QuestCategoriesScreenLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class QuestCategoriesScreenError extends QuestCategoriesScreenState {
  final String message;

  const QuestCategoriesScreenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit для управления состоянием экрана категорий
class QuestCategoriesScreenCubit extends Cubit<QuestCategoriesScreenState> {
  final GetAllCategories getAllCategoriesUC;

  QuestCategoriesScreenCubit({
    required this.getAllCategoriesUC,
  }) : super(const QuestCategoriesScreenLoading());

  // Загрузка категорий
  Future<void> loadCategories() async {
    try {
      emit(const QuestCategoriesScreenLoading());

      final result = await getAllCategoriesUC(NoParams());

      result.fold(
        (failure) {
          emit(QuestCategoriesScreenError(message: failure.toString()));
        },
        (categories) {
          // Преобразуем в нужный формат
          final categoriesList = categories
              .map((category) => {
                    'id': category.id,
                    'name': category.title,
                    'description':
                        'Описание отсутствует', // У CategoryEntity нет поля description
                    'image': category.photoPath,
                  })
              .toList();

          emit(QuestCategoriesScreenLoaded(categories: categoriesList));
        },
      );
    } catch (e) {
      emit(QuestCategoriesScreenError(message: e.toString()));
    }
  }

  // Обновление категорий
  Future<void> refreshCategories() async {
    await loadCategories();
  }
}
