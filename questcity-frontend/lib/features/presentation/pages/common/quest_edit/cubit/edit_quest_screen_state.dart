part of 'edit_quest_screen_cubit.dart';

abstract class EditQuestScreenState extends Equatable {
  const EditQuestScreenState();

  @override
  List<Object?> get props => [];
}

class EditQuestScreenLoading extends EditQuestScreenState {
  EditQuestScreenLoading() {
    print('🔍 DEBUG: EditQuestScreenLoading - Состояние загрузки создано');
  }
}

class EditQuestScreenError extends EditQuestScreenState {
  final String message;

  const EditQuestScreenError(this.message);

  @override
  List<Object?> get props => [message];
}

class EditQuestScreenSuccess extends EditQuestScreenState {
  final String message;

  const EditQuestScreenSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EditQuestScreenLoaded extends EditQuestScreenState {
  final List<List<int>> selectedIndexes;
  final List<QuestEditLocationItem> pointsData;
  final List<XFile> merchImages;
  final int creditsRadioIndex;
  final bool isFormValid; // Новое поле для валидации
  final Map<String, String?>
      validationErrors; // Новое поле для ошибок валидации
  final bool hasMentor; // Boolean переключатель для Mentor Preferences

  EditQuestScreenLoaded({
    required this.selectedIndexes,
    required this.pointsData,
    required this.merchImages,
    required this.creditsRadioIndex,
    this.isFormValid = false, // По умолчанию форма невалидна
    this.validationErrors = const {}, // По умолчанию нет ошибок
    this.hasMentor = false, // По умолчанию ментор не требуется
  }) {
    print('🔍 DEBUG: EditQuestScreenLoaded - Состояние загружено создано');
    print('  - selectedIndexes: ${selectedIndexes.length}');
    print('  - pointsData: ${pointsData.length}');
    print('  - merchImages: ${merchImages.length}');
    print('  - creditsRadioIndex: $creditsRadioIndex');
    print('  - isFormValid: $isFormValid');
    print('  - validationErrors: ${validationErrors.length}');
    print('  - hasMentor: $hasMentor');
  }

  EditQuestScreenLoaded copyWith({
    List<List<int>>? selectedIndexes,
    List<QuestEditLocationItem>? pointsData,
    List<XFile>? merchImages,
    int? creditsRadioIndex,
    bool? isFormValid,
    Map<String, String?>? validationErrors,
    bool? hasMentor,
  }) {
    return EditQuestScreenLoaded(
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      pointsData: pointsData ?? this.pointsData,
      merchImages: merchImages ?? this.merchImages,
      creditsRadioIndex: creditsRadioIndex ?? this.creditsRadioIndex,
      isFormValid: isFormValid ?? this.isFormValid,
      validationErrors: validationErrors ?? this.validationErrors,
      hasMentor: hasMentor ?? this.hasMentor,
    );
  }

  @override
  List<Object?> get props => [
        selectedIndexes,
        pointsData,
        merchImages,
        creditsRadioIndex,
        isFormValid,
        validationErrors,
        hasMentor,
      ];
}
