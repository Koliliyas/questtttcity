import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/create_quest_admin.dart';
import 'package:los_angeles_quest/features/domain/usecases/file/upload_file.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_model.dart';

// Абстрактный класс для состояний
abstract class QuestCreateScreenState extends Equatable {
  const QuestCreateScreenState();

  @override
  List<Object?> get props => [];
}

// Начальное состояние
class QuestCreateScreenInitial extends QuestCreateScreenState {
  final File? image;
  final String difficultyLevel;
  final String groupType;
  final int? categoryId;
  final int? vehicleId;
  final int creditsMode; // 0 = Manual, 1 = Auto
  final List<XFile> merchImages;
  final bool hasMentor;
  final List<QuestEditLocationItem> pointsData;
  final List<PointEditData>
      pointEditData; // ← НОВОЕ: данные редактирования точек

  const QuestCreateScreenInitial({
    this.image,
    this.difficultyLevel = 'Easy',
    this.groupType = 'Solo',
    this.categoryId = 1,
    this.vehicleId = 1,
    this.creditsMode = 0,
    this.merchImages = const [],
    this.hasMentor = false,
    this.pointsData = const [],
    this.pointEditData = const [], // ← НОВОЕ
  });

  @override
  List<Object?> get props => [
        image,
        difficultyLevel,
        groupType,
        categoryId,
        vehicleId,
        creditsMode,
        merchImages,
        hasMentor,
        pointsData,
        pointEditData, // ← НОВОЕ
      ];

  QuestCreateScreenInitial copyWith({
    File? image,
    String? difficultyLevel,
    String? groupType,
    int? categoryId,
    int? vehicleId,
    int? creditsMode,
    List<XFile>? merchImages,
    bool? hasMentor,
    List<QuestEditLocationItem>? pointsData,
    List<PointEditData>? pointEditData, // ← НОВОЕ
  }) {
    return QuestCreateScreenInitial(
      image: image ?? this.image,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      groupType: groupType ?? this.groupType,
      categoryId: categoryId ?? this.categoryId,
      vehicleId: vehicleId ?? this.vehicleId,
      creditsMode: creditsMode ?? this.creditsMode,
      merchImages: merchImages ?? this.merchImages,
      hasMentor: hasMentor ?? this.hasMentor,
      pointsData: pointsData ?? this.pointsData,
      pointEditData: pointEditData ?? this.pointEditData, // ← НОВОЕ
    );
  }
}

// Состояние загрузки
class QuestCreateScreenLoading extends QuestCreateScreenState {
  const QuestCreateScreenLoading();
}

// Состояние успеха
class QuestCreateScreenSuccess extends QuestCreateScreenState {
  final String message;

  const QuestCreateScreenSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// Состояние ошибки
class QuestCreateScreenError extends QuestCreateScreenState {
  final String message;

  const QuestCreateScreenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit для управления состоянием
class QuestCreateScreenCubit extends Cubit<QuestCreateScreenState> {
  final CreateQuestAdmin
      createQuestUC; // Use case для создания квеста (админский)
  final UploadFile uploadFileUC; // Use case для загрузки файлов

  // Callback для обновления списка квестов
  VoidCallback? _onQuestCreated;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController creditsAccrueController = TextEditingController();
  final TextEditingController creditsPaysController = TextEditingController();
  final TextEditingController merchDescriptionController =
      TextEditingController();
  final TextEditingController merchPriceController = TextEditingController();

  // Контроллеры для точек
  final List<TextEditingController> pointControllers = [
    TextEditingController(), // Стартовая точка
    TextEditingController(), // Конечная точка
  ];

  QuestCreateScreenCubit({
    required this.createQuestUC,
    required this.uploadFileUC,
    VoidCallback? onQuestCreated,
  }) : super(QuestCreateScreenInitial(
          pointsData: [
            QuestEditLocationItem(LocaleKeys.kTextStartPoint.tr(),
                type: 'start'),
            QuestEditLocationItem(LocaleKeys.kTextFinishPoint.tr(),
                type: 'finish'),
          ],
        )) {
    // Сохраняем callback для обновления списка квестов
    _onQuestCreated = onQuestCreated;
  }

  // Выбор изображения
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        if (state is QuestCreateScreenInitial) {
          final currentState = state as QuestCreateScreenInitial;
          emit(currentState.copyWith(image: imageFile));
        }
      }
    } catch (e) {
      emit(QuestCreateScreenError(message: 'Ошибка выбора изображения: $e'));
    }
  }

  // Обновление основных настроек
  void updateMainPreference(int preferencesIndex, int preferencesItemIndex,
      int? preferencesSubItemIndex) {
    if (state is QuestCreateScreenInitial) {
      final currentState = state as QuestCreateScreenInitial;

      switch (preferencesIndex) {
        case 0: // Difficulty level
          final difficultyLevels = ['Easy', 'Medium', 'Hard'];
          emit(currentState.copyWith(
              difficultyLevel: difficultyLevels[preferencesItemIndex]));
          break;
        case 1: // Group type
          final groupTypes = ['Solo', 'Duo', 'Team', 'Family'];
          emit(currentState.copyWith(
              groupType: groupTypes[preferencesItemIndex]));
          break;
        case 2: // Category
          final categories = [1, 2, 3];
          emit(currentState.copyWith(
              categoryId: categories[preferencesItemIndex]));
          break;
        case 3: // Vehicle
          final vehicles = [1, 2, 3];
          emit(
              currentState.copyWith(vehicleId: vehicles[preferencesItemIndex]));
          break;
      }
    }
  }

  // Установка режима кредитов
  void setCreditsMode(int mode) {
    if (state is QuestCreateScreenInitial) {
      final currentState = state as QuestCreateScreenInitial;
      emit(currentState.copyWith(creditsMode: mode));
    }
  }

  // Добавление изображения мерча
  void addMerchImage(XFile image) {
    if (state is QuestCreateScreenInitial) {
      final currentState = state as QuestCreateScreenInitial;
      final newImages = List<XFile>.from(currentState.merchImages)..add(image);
      emit(currentState.copyWith(merchImages: newImages));
    }
  }

  // Установка наличия ментора
  void setHasMentor(bool hasMentor) {
    if (state is QuestCreateScreenInitial) {
      final currentState = state as QuestCreateScreenInitial;
      emit(currentState.copyWith(hasMentor: hasMentor));
    }
  }

  // Обновление данных точки
  void updatePointData(PointEditData data) {
    if (state is QuestCreateScreenInitial) {
      final currentState = state as QuestCreateScreenInitial;
      final updatedPointEditData =
          List<PointEditData>.from(currentState.pointEditData);

      // Обновляем или добавляем данные точки
      if (data.pointIndex < updatedPointEditData.length) {
        updatedPointEditData[data.pointIndex] = data;
      } else {
        // Расширяем список если нужно
        while (updatedPointEditData.length <= data.pointIndex) {
          updatedPointEditData
              .add(PointEditData(pointIndex: updatedPointEditData.length));
        }
        updatedPointEditData[data.pointIndex] = data;
      }

      emit(currentState.copyWith(pointEditData: updatedPointEditData));
    }
  }

  // Добавление промежуточной точки
  void addPoint() {
    if (state is QuestCreateScreenInitial) {
      final currentState = state as QuestCreateScreenInitial;

      final position = currentState.pointsData.isNotEmpty
          ? currentState.pointsData.length - 1
          : 0;
      final locationItem = QuestEditLocationItem(
          '${LocaleKeys.kTextHalfwayPoint.tr()} ($position)');
      final controller = TextEditingController();

      final updatedPointsData =
          List<QuestEditLocationItem>.from(currentState.pointsData);
      updatedPointsData.insert(position, locationItem);
      pointControllers.insert(position, controller);

      emit(currentState.copyWith(pointsData: updatedPointsData));
    }
  }

  // Удаление точки
  void deletePoint(int index) {
    if (state is QuestCreateScreenInitial) {
      final currentState = state as QuestCreateScreenInitial;

      final updatedPointsData =
          List<QuestEditLocationItem>.from(currentState.pointsData);
      updatedPointsData.removeAt(index);
      pointControllers[index].dispose();
      pointControllers.removeAt(index);

      // Обновляем названия промежуточных точек
      for (int i = 1;
          i <
              (updatedPointsData.length > 1
                  ? updatedPointsData.length - 1
                  : updatedPointsData.length);
          i++) {
        updatedPointsData[i] =
            QuestEditLocationItem('${LocaleKeys.kTextHalfwayPoint.tr()} ($i)');
      }

      emit(currentState.copyWith(pointsData: updatedPointsData));
    }
  }

  // Конвертация файла в base64
  Future<String> _convertFileToBase64(File? file) async {
    if (file == null) return '';

    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      // Определяем MIME тип на основе расширения файла
      String mimeType = 'image/jpeg'; // по умолчанию
      final extension = file.path.split('.').last.toLowerCase();

      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
      }

      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      print('🔍 DEBUG: Error converting file to base64: $e');
      return '';
    }
  }

  // Создание квеста
  Future<void> createQuest(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Сначала получаем данные из текущего состояния
      if (state is! QuestCreateScreenInitial) {
        emit(QuestCreateScreenError(message: 'Неверное состояние формы'));
        return;
      }

      final currentState = state as QuestCreateScreenInitial;

      // Проверяем обязательные поля
      if (nameController.text.trim().isEmpty) {
        emit(QuestCreateScreenError(message: 'Название квеста обязательно'));
        return;
      }

      if (descriptionController.text.trim().isEmpty) {
        emit(QuestCreateScreenError(message: 'Описание квеста обязательно'));
        return;
      }

      // Конвертируем изображение в base64
      final imageBase64 = await _convertFileToBase64(currentState.image);

      // Собираем merchandise данные из формы
      final merchList = <Map<String, dynamic>>[];
      print('🔍 DEBUG: Сбор merchandise данных...');
      print(
          '  - merchDescriptionController.text: "${merchDescriptionController.text}"');
      print('  - merchPriceController.text: "${merchPriceController.text}"');
      print('  - merchImages.length: ${currentState.merchImages.length}');

      if (merchDescriptionController.text.isNotEmpty &&
          merchPriceController.text.isNotEmpty) {
        // Конвертируем merchandise изображение в base64
        String merchImageBase64 = '';
        if (currentState.merchImages.isNotEmpty) {
          final merchFile = File(currentState.merchImages.first.path);
          merchImageBase64 = await _convertFileToBase64(merchFile);
          print('  - merchImageBase64 length: ${merchImageBase64.length}');
        } else {
          print('  - merchImageBase64: пустая строка (нет изображения)');
        }

        merchList.add({
          'description': merchDescriptionController.text.trim(),
          'price': int.tryParse(merchPriceController.text) ?? 0,
          'image': merchImageBase64,
        });
        print('  - Добавлен merchandise item: ${merchList.first}');
      } else {
        print('  - Merchandise данные не заполнены - список остается пустым');
      }
      print('  - Итоговый merchList.length: ${merchList.length}');

      // Собираем данные из формы в соответствии с QuestCreteSchema
      final questData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'image': imageBase64,
        'merch': merchList,
        'credits': {
          'cost': int.tryParse(creditsPaysController.text) ?? 0,
          'reward': int.tryParse(creditsAccrueController.text) ?? 0,
        },
        'main_preferences': {
          'category_id': currentState.categoryId,
          'vehicle_id': currentState.vehicleId,
          'place_id': 1, // TODO: Получить из формы
          'group': _mapGroupType(currentState.groupType),
          'timeframe': _mapTimeframe('ONE_HOUR'), // TODO: Получить из формы
          'level': _mapDifficultyToLevel(currentState.difficultyLevel),
          'mileage': _mapMileage('SHORT'), // TODO: Получить из формы
          'types': [], // TODO: Получить из формы
          'places': [], // TODO: Получить из формы
          'vehicles': [currentState.vehicleId], // Массив с одним vehicle_id
          'tools': [], // TODO: Получить из формы
        },
        'mentor_preference':
            currentState.hasMentor ? 'mentor_required' : 'no_mentor',
        'points': currentState.pointsData.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          final controller = pointControllers[index];
          final editData = currentState.pointEditData.length > index
              ? currentState.pointEditData[index]
              : null;

          return {
            'name_of_location': controller.text.trim(),
            'description': controller.text.trim(),
            'order': index,
            'type_id': editData?.typeId ?? 1,
            'tool_id': editData?.toolId,
            'places':
                editData?.places?.map((place) => place.toJson()).toList() ?? [],
            'file': editData?.file,
            'type_photo': editData?.typePhoto,
            'type_code': editData?.typeCode,
            'type_word': editData?.typeWord,
            'is_divide': editData?.isDivide ?? false,
          };
        }).toList(),
      };

      // Теперь эмитим состояние загрузки
      emit(const QuestCreateScreenLoading());

      print(
          '🔍 DEBUG: QuestCreateScreenCubit.createQuest() - Создаем квест с данными:');
      print('  - name: "${questData['name']}"');
      print('  - description: "${questData['description']}"');
      print('  - image: "${questData['image']}"');
      print(
          '  - main_preferences.category_id: ${(questData['main_preferences'] as Map<String, dynamic>)['category_id']}');
      print(
          '  - main_preferences.vehicle_id: ${(questData['main_preferences'] as Map<String, dynamic>)['vehicle_id']}');
      print(
          '  - main_preferences.place_id: ${(questData['main_preferences'] as Map<String, dynamic>)['place_id']}');
      print(
          '  - main_preferences.group: "${(questData['main_preferences'] as Map<String, dynamic>)['group']}"');
      print(
          '  - main_preferences.level: "${(questData['main_preferences'] as Map<String, dynamic>)['level']}"');
      print(
          '  - main_preferences.mileage: "${(questData['main_preferences'] as Map<String, dynamic>)['mileage']}"');
      print('  - mentor_preference: "${questData['mentor_preference']}"');
      print('  - merch count: ${(questData['merch'] as List).length}');
      if ((questData['merch'] as List).isNotEmpty) {
        final merch =
            (questData['merch'] as List).first as Map<String, dynamic>;
        print('  - merch description: "${merch['description']}"');
        print('  - merch price: ${merch['price']}');
        print('  - merch image: "${merch['image']}"');
      }
      print('  - mentor_preference: "${questData['mentor_preference']}"');
      print('  - currentState.hasMentor: ${currentState.hasMentor}');
      print(
          '  - credits.cost: ${(questData['credits'] as Map<String, dynamic>)['cost']}');
      print(
          '  - credits.reward: ${(questData['credits'] as Map<String, dynamic>)['reward']}');
      print('  - points count: ${(questData['points'] as List).length}');
      for (int i = 0; i < (questData['points'] as List).length; i++) {
        final point = (questData['points'] as List)[i] as Map<String, dynamic>;
        print(
            '  - point[$i]: name_of_location="${point['name_of_location']}", description="${point['description']}", order=${point['order']}');
        print('    - type_id: ${point['type_id']}');
        print('    - tool_id: ${point['tool_id']}');
        print('    - places count: ${(point['places'] as List).length}');
        print('    - file: "${point['file']}"');
        print('    - type_photo: "${point['type_photo']}"');
        print('    - type_code: ${point['type_code']}');
        print('    - type_word: "${point['type_word']}"');
        print('    - is_divide: ${point['is_divide']}');
      }

      // Вызываем use case для создания квеста через API (админский)
      final result = await createQuestUC(questData);

      result.fold(
        (failure) {
          print(
              '🔍 DEBUG: QuestCreateScreenCubit.createQuest() - Failure: $failure');
          emit(QuestCreateScreenError(message: failure.toString()));
        },
        (success) {
          print(
              '🔍 DEBUG: QuestCreateScreenCubit.createQuest() - Success: $success');
          emit(const QuestCreateScreenSuccess(message: 'Квест успешно создан'));

          // Обновляем список квестов в основном экране
          if (_onQuestCreated != null) {
            print('🔍 DEBUG: Calling _onQuestCreated callback');
            _onQuestCreated!();
            print('🔍 DEBUG: _onQuestCreated callback executed');
          } else {
            print('🔍 DEBUG: _onQuestCreated callback is null!');
          }

          // Возвращаемся на предыдущий экран
          Navigator.pop(context);
        },
      );
    } catch (e) {
      print('🔍 DEBUG: QuestCreateScreenCubit.createQuest() - Exception: $e');
      emit(QuestCreateScreenError(message: e.toString()));
    }
  }

  // Сброс состояния
  void resetState() {
    emit(const QuestCreateScreenInitial(
      pointsData: [
        QuestEditLocationItem('Стартовая точка', type: 'start'),
        QuestEditLocationItem('Конечная точка', type: 'finish'),
      ],
    ));
  }

  // Маппинг сложности в формат бэкенда
  String _mapDifficultyToLevel(String? difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 'Easy';
      case 'Medium':
        return 'Medium';
      case 'Hard':
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  // Маппинг типа группы в формат бэкенда
  int _mapGroupType(String? groupType) {
    switch (groupType) {
      case 'Solo':
        return 1;
      case 'Duo':
        return 2;
      case 'Team':
        return 3;
      case 'Family':
        return 4;
      default:
        return 1;
    }
  }

  // Маппинг временных рамок в формат бэкенда
  int _mapTimeframe(String? timeframe) {
    switch (timeframe) {
      case 'ONE_HOUR':
        return 1;
      case 'TWO_HOURS':
        return 3;
      case 'HALF_DAY':
        return 10;
      case 'FULL_DAY':
        return 24;
      default:
        return 1;
    }
  }

  // Маппинг пробега в формат бэкенда
  String _mapMileage(String? mileage) {
    switch (mileage) {
      case 'SHORT':
        return '5-10';
      case 'MEDIUM':
        return '10-30';
      case 'LONG':
        return '30-100';
      case 'EXTRA_LONG':
        return '>100';
      default:
        return '5-10';
    }
  }
}
