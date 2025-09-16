part of 'quest_edit_screen_cubit.dart';

abstract class QuestEditScreenState extends Equatable {
  const QuestEditScreenState();

  @override
  List<Object?> get props => [];
}

class QuestEditScreenLoading extends QuestEditScreenState {
  const QuestEditScreenLoading();
}

class QuestEditScreenError extends QuestEditScreenState {
  final String message;

  const QuestEditScreenError(this.message);

  @override
  List<Object?> get props => [message];
}

class QuestEditScreenLoaded extends QuestEditScreenState {
  final List<List<int>> selectedIndexes;
  final List<QuestEditLocationItem> pointsData;
  final List<XFile> merchImages;
  final int creditsRadioIndex;
  final File? image;
  final String? imageUrl; // Добавляем URL изображения
  final String difficultyLevel;
  final String groupType;
  final int categoryId;
  final int vehicleId;
  final bool hasMentor;

  const QuestEditScreenLoaded({
    required this.selectedIndexes,
    required this.pointsData,
    required this.merchImages,
    required this.creditsRadioIndex,
    this.image,
    this.imageUrl,
    required this.difficultyLevel,
    required this.groupType,
    required this.categoryId,
    required this.vehicleId,
    required this.hasMentor,
  });

  QuestEditScreenLoaded copyWith({
    List<List<int>>? selectedIndexes,
    List<QuestEditLocationItem>? pointsData,
    List<XFile>? merchImages,
    int? creditsRadioIndex,
    File? image,
    String? imageUrl,
    String? difficultyLevel,
    String? groupType,
    int? categoryId,
    int? vehicleId,
    bool? hasMentor,
  }) {
    return QuestEditScreenLoaded(
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      pointsData: pointsData ?? this.pointsData,
      merchImages: merchImages ?? this.merchImages,
      creditsRadioIndex: creditsRadioIndex ?? this.creditsRadioIndex,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      groupType: groupType ?? this.groupType,
      categoryId: categoryId ?? this.categoryId,
      vehicleId: vehicleId ?? this.vehicleId,
      hasMentor: hasMentor ?? this.hasMentor,
    );
  }

  @override
  List<Object?> get props => [
        selectedIndexes,
        pointsData,
        merchImages,
        creditsRadioIndex,
        image,
        imageUrl,
        difficultyLevel,
        groupType,
        categoryId,
        vehicleId,
        hasMentor,
      ];
}
