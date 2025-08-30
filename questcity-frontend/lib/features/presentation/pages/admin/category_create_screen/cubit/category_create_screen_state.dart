part of 'category_create_screen_cubit.dart';

abstract class CategoryCreateScreenState extends Equatable {
  const CategoryCreateScreenState();

  @override
  List<Object?> get props => [];
}

class CategoryCreateScreenInitial extends CategoryCreateScreenState {
  final XFile? image;
  final List<int> selectedQuestIndexes;

  const CategoryCreateScreenInitial({
    this.image,
    this.selectedQuestIndexes = const [],
  });

  CategoryCreateScreenInitial copyWith(
      {XFile? image, List<int>? selectedQuestIndexes}) {
    return CategoryCreateScreenInitial(
      image: image ?? this.image,
      selectedQuestIndexes: selectedQuestIndexes ?? this.selectedQuestIndexes,
    );
  }

  @override
  List<Object?> get props => [image, selectedQuestIndexes];
}
