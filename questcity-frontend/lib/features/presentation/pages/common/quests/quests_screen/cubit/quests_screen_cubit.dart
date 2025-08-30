import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/category/get_all_categories.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_all_quests.dart';

import '../../../../../../data/models/quests/quest_list_model.dart';
part 'quests_screen_state.dart';

class QuestsScreenCubit extends Cubit<QuestsScreenState> {
  final GetAllCategories getAllCategoriesUC;
  final GetAllQuests
      getAllQuestsUC; // ✅ Используем правильный use case для обычных пользователей
  QuestsScreenCubit(
      {required this.getAllCategoriesUC, required this.getAllQuestsUC})
      : super(QuestsScreenLoading()) {
    searchController.addListener(_onSearchTextChanged);
  }
  TextEditingController searchController = TextEditingController();

  Future loadData() async {
    try {
      print('🔍 DEBUG: loadData() - Starting...');
      emit(QuestsScreenLoading());
      print('🔍 DEBUG: Loading categories...');
      List<CategoryEntity> categoriesList = await _loadCategories();
      print('🔍 DEBUG: Loading quests...');
      QuestListModel questList = await _loadQuests();

      print('🔍 DEBUG: Data loaded successfully');
      print('🔍 DEBUG: Categories count: ${categoriesList.length}');
      print('🔍 DEBUG: Quests count: ${questList.items.length}');

      final newState = QuestsScreenLoaded(
          categoriesList: categoriesList,
          questsList: questList,
          fullList: questList,
          selectedIndexes: <FilterCategory,
              int>{}, // Инициализируем пустую Map с типом
          countFilters: 0);

      print('🔍 DEBUG: Emitting new state: ${newState.runtimeType}');
      emit(newState);
      print('🔍 DEBUG: State emitted successfully');
    } catch (e) {
      print('🔍 DEBUG: Error loading data: $e');
      // Вместо эмита ошибки, эмитим загруженное состояние с пустыми данными
      emit(QuestsScreenLoaded(
          categoriesList: <CategoryEntity>[],
          questsList: QuestListModel(items: <QuestItem>[]),
          fullList: QuestListModel(items: <QuestItem>[]),
          selectedIndexes: <FilterCategory, int>{},
          countFilters: 0));
    }
  }

  Future<List<CategoryEntity>> _loadCategories() async {
    try {
      print('🔍 DEBUG: Starting categories load...');
      final failureOrLoads = await getAllCategoriesUC(NoParams());

      return failureOrLoads.fold(
        (error) {
          print('🔍 DEBUG: Categories error: $error');
          // Возвращаем пустой список вместо ошибки
          return <CategoryEntity>[];
        },
        (loadedCategories) {
          print('🔍 DEBUG: Categories loaded: ${loadedCategories.length}');
          // Проверяем, что список не null и содержит валидные элементы
          if (loadedCategories == null) return <CategoryEntity>[];

          // Фильтруем только валидные категории
          return loadedCategories
              .where((category) =>
                  category != null && category.id != null && category.id > 0)
              .toList();
        },
      );
    } catch (e) {
      print('🔍 DEBUG: Categories exception: $e');
      // Возвращаем пустой список вместо ошибки
      return <CategoryEntity>[];
    }
  }

  Future<QuestListModel> _loadQuests() async {
    try {
      print('🔍 DEBUG: Starting quests load...');
      final result = await getAllQuestsUC(NoParams());

      return result.fold(
        (failure) {
          print('🔍 DEBUG: Quests error: $failure');
          return QuestListModel(items: <QuestItem>[]);
        },
        (questsData) {
          print('🔍 DEBUG: Quests loaded - Type: ${questsData.runtimeType}');
          print('🔍 DEBUG: Quests loaded - Data: $questsData');

          if (questsData == null) {
            print('🔍 DEBUG: questsData is null!');
            return QuestListModel(items: <QuestItem>[]);
          }

          if (questsData is! List) {
            print(
                '🔍 DEBUG: questsData is not a List: ${questsData.runtimeType}');
            return QuestListModel(items: <QuestItem>[]);
          }

          print('🔍 DEBUG: Quests loaded: ${questsData.length}');

          // Преобразуем данные из API в QuestItem
          final questItems = questsData.map((quest) {
            print('🔍 DEBUG: Processing quest: $quest');
            return QuestItem(
              id: quest['id'] ?? 0,
              name: quest['name'] ?? 'Unknown Quest',
              image: quest['image'] ?? 'assets/images/quest_1.png',
              rating: 4.5, // Default rating
              mainPreferences: MainPreferences(
                categoryId: quest['category_id'] ?? 1,
                group: 1, // single
                vehicleId: 1,
                price: Price(amount: 0, isSubscription: false),
                timeframe: 120, // 2 hours in minutes
                level: 'beginner',
                milege: 'local',
                placeId: 1,
              ),
            );
          }).toList();

          print('🔍 DEBUG: Created ${questItems.length} QuestItems');
          return QuestListModel(items: questItems);
        },
      );
    } catch (e) {
      print('🔍 DEBUG: Quests exception: $e');
      // Возвращаем пустой список вместо ошибки
      return QuestListModel(items: <QuestItem>[]);
    }
  }

  void onTapCategory(int categoryIndex) {
    if (state is QuestsScreenLoaded) {
      QuestsScreenLoaded currentState = state as QuestsScreenLoaded;

      print(
          '🔍 DEBUG: onTapCategory called with index: $categoryIndex, categories count: ${currentState.categoriesList.length}');

      // Защита от некорректных индексов
      if (categoryIndex < 0 ||
          currentState.categoriesList.isEmpty ||
          categoryIndex >= currentState.categoriesList.length) {
        print(
            '🔍 DEBUG: Invalid category index: $categoryIndex, categories count: ${currentState.categoriesList.length}');
        return;
      }

      // Дополнительная проверка на существование категории
      if (currentState.categoriesList[categoryIndex] == null) {
        print('🔍 DEBUG: Category at index $categoryIndex is null');
        return;
      }

      // Проверяем, что category.id валиден
      final category = currentState.categoriesList[categoryIndex];
      if (category.id == null || category.id < 0) {
        print('🔍 DEBUG: Invalid category ID: ${category.id}');
        return;
      }

      final nexIndexes =
          currentState.selectedCategories.contains(categoryIndex);

      Set<int> newSelectedCategories =
          Set.from(currentState.selectedCategories);
      if (!nexIndexes) {
        newSelectedCategories.add(categoryIndex);
      } else {
        newSelectedCategories.remove(categoryIndex);
      }

      List<QuestItem> items = [];
      if (newSelectedCategories.isEmpty) {
        items = currentState.fullList.items;
      } else {
        for (final quest in currentState.fullList.items) {
          // Защита от null значений
          if (quest.mainPreferences?.categoryId != null &&
              quest.mainPreferences!.categoryId > 0 &&
              newSelectedCategories
                  .contains(quest.mainPreferences!.categoryId)) {
            items.add(quest);
          }
        }
      }

      print('🔍 DEBUG: Filtered quests count: ${items.length}');

      emit(currentState.copyWith(
        questsList: QuestListModel(items: items),
        selectedCategories: newSelectedCategories,
      ));
    }
  }

  void searchFilter() {
    if (state is QuestsScreenLoaded) {
      QuestsScreenLoaded currentState = state as QuestsScreenLoaded;

      try {
        final searchText = searchController.text.toLowerCase().trim();
        List<QuestItem> filteredItems = [];

        if (searchText.isEmpty) {
          // Если поиск пустой, показываем все квесты
          filteredItems = currentState.fullList.items;
        } else {
          // Фильтруем по тексту поиска
          filteredItems = currentState.fullList.items.where((quest) {
            // Защита от null значений
            final name = quest.name.toLowerCase();
            return name.contains(searchText);
          }).toList();
        }

        emit(currentState.copyWith(
          questsList: QuestListModel(items: filteredItems),
          searchText: searchText,
        ));
      } catch (e) {
        print('🔍 DEBUG: Error in searchFilter: $e');
        // В случае ошибки показываем все квесты
        emit(currentState.copyWith(
          questsList: currentState.fullList,
          searchText: searchController.text,
        ));
      }
    }
  }

  void onTapSubcategory(FilterCategory categoryIndex, int value) {
    if (state is QuestsScreenLoaded) {
      QuestsScreenLoaded currentState = state as QuestsScreenLoaded;

      final selectedIndexes =
          Map<FilterCategory, int>.from(currentState.selectedIndexes);

      // Защита от некорректных значений, включая -1
      if (value >= 0) {
        selectedIndexes[categoryIndex] = value;
      } else {
        // Если передается -1 или другое некорректное значение, удаляем фильтр
        selectedIndexes.remove(categoryIndex);
      }

      // Защита от некорректных индексов при подсчете фильтров
      int countFilters = 0;
      try {
        // Фильтруем только валидные индексы (>= 0) и считаем их
        countFilters =
            selectedIndexes.values.where((e) => e != null && e >= 0).length;
      } catch (e) {
        print('🔍 DEBUG: Error counting filters: $e');
        countFilters = 0;
      }

      print(
          '🔍 DEBUG: onTapSubcategory - category: $categoryIndex, value: $value, countFilters: $countFilters');

      emit(currentState.copyWith(
        selectedIndexes: selectedIndexes,
        countFilters: countFilters,
      ));
    }
  }

  void onResetFilter() {
    if (state is QuestsScreenLoaded) {
      QuestsScreenLoaded currentState = state as QuestsScreenLoaded;

      print('🔍 DEBUG: Resetting filters');

      emit(currentState.copyWith(
        selectedIndexes: <FilterCategory, int>{},
        countFilters: 0,
        // Сбрасываем также выбранные категории
        selectedCategories: <int>{},
        // Возвращаем полный список квестов
        questsList: currentState.fullList,
      ));
    }
  }

  void onChangeSearchFieldEditingStatus(bool isSearchFieldEditing) {
    if (state is QuestsScreenLoaded) {
      QuestsScreenLoaded currentState = state as QuestsScreenLoaded;

      emit(currentState.copyWith(isSearchFieldEditing: isSearchFieldEditing));
    }
  }

  void _onSearchTextChanged() {
    if (state is QuestsScreenLoaded) {
      QuestsScreenLoaded currentState = state as QuestsScreenLoaded;
      //companies = currentState.companiesList!
      //    .where((e) => (e.name.toLowerCase())
      //        .startsWith(searchController.text.toLowerCase()))
      //    .toList();
      emit(currentState.copyWith(searchText: searchController.text));
    }
  }

  @override
  Future<void> close() {
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    return super.close();
  }
}
