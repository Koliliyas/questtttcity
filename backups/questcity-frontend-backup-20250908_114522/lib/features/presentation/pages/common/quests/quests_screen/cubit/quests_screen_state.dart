part of 'quests_screen_cubit.dart';

abstract class QuestsScreenState extends Equatable {
  const QuestsScreenState();

  @override
  List<Object?> get props => [];
}

enum FilterCategory { vehicle, price, time, level, mileage, places }

class QuestsScreenLoaded extends QuestsScreenState {
  final List<CategoryEntity> categoriesList;
  final QuestListModel questsList;
  final QuestListModel fullList;
  final String searchText;
  final Map<FilterCategory, int> selectedIndexes;
  final Set<int> selectedCategories;
  final int countFilters;
  final bool isSearchFieldEditing;

  const QuestsScreenLoaded({
    this.selectedCategories = const {},
    required this.fullList,
    this.categoriesList = const [],
    this.questsList = const QuestListModel(items: []),
    this.searchText = '',
    this.selectedIndexes = const {},
    this.countFilters = 0,
    this.isSearchFieldEditing = false,
  });

  // Геттер для безопасного доступа к категориям
  List<CategoryEntity> get safeCategoriesList => categoriesList ?? [];

  // Геттер для безопасного доступа к квестам
  QuestListModel get safeQuestsList => questsList ?? QuestListModel(items: []);

  // Геттер для безопасного доступа к полному списку
  QuestListModel get safeFullList => fullList ?? QuestListModel(items: []);

  QuestsScreenLoaded copyWith({
    List<CategoryEntity>? categoriesList,
    QuestListModel? questsList,
    QuestListModel? fullList,
    String? searchText,
    Map<FilterCategory, int>? selectedIndexes,
    Set<int>? selectedCategories,
    int? countFilters,
    bool? isSearchFieldEditing,
  }) {
    return QuestsScreenLoaded(
      categoriesList: categoriesList ?? this.categoriesList,
      fullList: fullList ?? this.fullList,
      questsList: questsList ?? this.questsList,
      searchText: searchText ?? this.searchText,
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      countFilters: countFilters ?? this.countFilters,
      isSearchFieldEditing: isSearchFieldEditing ?? this.isSearchFieldEditing,
    );
  }

  @override
  List<Object?> get props =>
      [categoriesList, searchText, selectedIndexes, countFilters];
}

class QuestsScreenLoading extends QuestsScreenState {}

class QuestsScreenError extends QuestsScreenState {
  final String message;

  const QuestsScreenError({required this.message});

  @override
  List<Object> get props => [message];
}
