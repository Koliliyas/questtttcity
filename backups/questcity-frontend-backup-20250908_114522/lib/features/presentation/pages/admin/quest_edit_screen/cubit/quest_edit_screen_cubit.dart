import 'package:bloc/bloc.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_levels.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_miles.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_places.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_prices.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest_admin.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_vehicles.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/update_quest.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_update_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_detail_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/core/error/failure.dart';

part 'quest_edit_screen_state.dart';

class QuestEditScreenCubit extends Cubit<QuestEditScreenState> {
  final int questId;
  final GetLevels getLevelsUC;
  final GetPlaces getPlacesUC;
  final GetPrices getPricesUC;
  final GetMiles getMilesUC;
  final GetVehicles getVehiclesUC;
  final UpdateQuest updateQuestUC;
  final GetQuestAdmin getQuestUC;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController merchDescriptionController = TextEditingController();
  TextEditingController merchPriceController = TextEditingController();
  TextEditingController creditsAccrueController = TextEditingController();
  TextEditingController creditsPaysController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController mentorPreferenceController = TextEditingController();

  final List<TextEditingController> pointControllers = [
    TextEditingController(),
    TextEditingController()
  ];

  // Сохраняем ID точек для редактирования
  final List<int> pointIds = [];

  List<QuestPreference> mainPreferencesData = [];

  List<QuestParameterEntity> levels = [];
  List<QuestParameterEntity> places = [];
  List<QuestParameterEntity> prices = [];
  List<QuestParameterEntity> miles = [];
  List<QuestParameterEntity> vehicles = [];

  QuestEditScreenCubit({
    required this.questId,
    required this.getLevelsUC,
    required this.getPlacesUC,
    required this.getPricesUC,
    required this.getMilesUC,
    required this.getVehiclesUC,
    required this.updateQuestUC,
    required this.getQuestUC,
  }) : super(QuestEditScreenLoading()) {
    print(
        '🚨🚨🚨 DEBUG: QuestEditScreenCubit.constructor() - Кубит создан! 🚨🚨🚨');
    print('🚨🚨🚨 questId = $questId 🚨🚨🚨');

    _init();

    // Добавляем слушатели для валидации
    nameController.addListener(_onFormFieldChanged);
    descriptionController.addListener(_onFormFieldChanged);
    creditsPaysController.addListener(_onFormFieldChanged);
    creditsAccrueController.addListener(_onFormFieldChanged);
    merchDescriptionController.addListener(_onFormFieldChanged);
    merchPriceController.addListener(_onFormFieldChanged);
    mentorPreferenceController.addListener(_onFormFieldChanged);

    for (TextEditingController controller in pointControllers) {
      controller.addListener(_onTextChanged);
    }

    print(
        '🔍 DEBUG: QuestEditScreenCubit.constructor() - Конструктор завершен');
  }

  Future<void> _init() async {
    print(
        '🚨🚨🚨 DEBUG: QuestEditScreenCubit._init() - НАЧАЛО ИНИЦИАЛИЗАЦИИ! 🚨🚨🚨');
    print('🚨🚨🚨 questId = $questId 🚨🚨🚨');

    try {
      // Загружаем параметры квеста
      print('🔍 DEBUG: Загружаем параметры квеста...');
      await _loadQuestParameters();

      // Загружаем данные квеста
      print('🔍 DEBUG: Загружаем данные квеста...');
      await _loadQuestData();
    } catch (e) {
      print('🔍 DEBUG: Error in _init: $e');
      // Не эмитим ошибку, показываем загруженное состояние с дефолтными значениями
      emit(QuestEditScreenLoaded(
        selectedIndexes: [
          [0],
          [0],
          [0],
          [0]
        ],
        pointsData: [
          QuestEditLocationItem(LocaleKeys.kTextStartPoint.tr()),
          QuestEditLocationItem(LocaleKeys.kTextFinishPoint.tr()),
        ],
        merchImages: [],
        creditsRadioIndex: 0,
        image: null,
        imageUrl: null,
        difficultyLevel: 'Easy',
        groupType: 'Solo',
        categoryId: 1,
        vehicleId: 1,
        hasMentor: false,
      ));
    }
  }

  Future<void> _loadQuestParameters() async {
    try {
      final levelsResult = await getLevelsUC(NoParams());
      final placesResult = await getPlacesUC(NoParams());
      final pricesResult = await getPricesUC(NoParams());
      final milesResult = await getMilesUC(NoParams());
      final vehiclesResult = await getVehiclesUC(NoParams());

      levelsResult.fold(
        (failure) {
          print('🔍 DEBUG: Failed to load levels: $failure');
          levels = []; // Используем пустой список вместо ошибки
        },
        (levelsData) => levels = levelsData,
      );

      placesResult.fold(
        (failure) {
          print('🔍 DEBUG: Failed to load places: $failure');
          places = []; // Используем пустой список вместо ошибки
        },
        (placesData) => places = placesData,
      );

      pricesResult.fold(
        (failure) {
          print('🔍 DEBUG: Failed to load prices: $failure');
          prices = []; // Используем пустой список вместо ошибки
        },
        (pricesData) => prices = pricesData,
      );

      milesResult.fold(
        (failure) {
          print('🔍 DEBUG: Failed to load miles: $failure');
          miles = []; // Используем пустой список вместо ошибки
        },
        (milesData) => miles = milesData,
      );

      vehiclesResult.fold(
        (failure) {
          print('🔍 DEBUG: Failed to load vehicles: $failure');
          vehicles = []; // Используем пустой список вместо ошибки
        },
        (vehiclesData) => vehicles = vehiclesData,
      );
    } catch (e) {
      print('🔍 DEBUG: Error loading quest parameters: $e');
      // Не эмитим ошибку, используем дефолтные значения
      levels = [];
      places = [];
      prices = [];
      miles = [];
      vehicles = [];
    }
  }

  Future<void> _loadQuestData() async {
    try {
      print('🚨🚨🚨 DEBUG: _loadQuestData() ВЫЗВАН! 🚨🚨🚨');
      print('🚨🚨🚨 questId = $questId 🚨🚨🚨');
      print('🔍 DEBUG: Loading quest data for questId: $questId');
      final questResult = await getQuestUC(questId);

      // Обрабатываем результат
      questResult.fold(
        (failure) {
          print('🔍 DEBUG: Failed to load quest: $failure');
          throw Exception('Failed to load quest');
        },
        (questData) {
          print('🔍 DEBUG: Quest data loaded successfully: ${questData.keys}');
          // Парсим данные в QuestDetailModel
          final quest = QuestDetailModel.fromJson(questData);
          print('🔍 DEBUG: Quest parsed successfully: ${quest.title}');

          // Логируем данные квеста для отладки
          print('🔍 DEBUG: Данные квеста:');
          print('  - title: "${quest.title}"');
          print('  - shortDescription: "${quest.shortDescription}"');
          print('  - fullDescription: "${quest.fullDescription}"');
          print('  - points.length: ${quest.points.length}');
          for (int i = 0; i < quest.points.length; i++) {
            final point = quest.points[i];
            print(
                '  - point[$i]: nameOfLocation="${point.nameOfLocation}", order=${point.order}');
          }

          // Заполняем контроллеры данными квеста
          nameController.text = quest.title;

          // Заполняем поле description - используем shortDescription или fullDescription
          if (quest.shortDescription.isNotEmpty) {
            descriptionController.text = quest.shortDescription;
            print(
                '🔍 DEBUG: Используем shortDescription: "${quest.shortDescription}"');
          } else if (quest.fullDescription.isNotEmpty) {
            descriptionController.text = quest.fullDescription;
            print(
                '🔍 DEBUG: Используем fullDescription: "${quest.fullDescription}"');
          } else {
            descriptionController.text = '';
            print('🔍 DEBUG: Оба поля description пустые');
          }

          // Инициализируем основные настройки
          _initializeMainPreferences(quest);

          // Инициализируем точки
          _initializePoints(quest);

          print('🔍 DEBUG: Controllers initialized:');
          print('  - name: ${nameController.text}');
          print('  - description: ${descriptionController.text}');
          print('  - credits cost: ${creditsPaysController.text}');
          print('  - credits reward: ${creditsAccrueController.text}');
          print('  - points count: ${pointControllers.length}');
          print('🔍 DEBUG: === КОНТРОЛЛЕРЫ ТОЧЕК ОБНОВЛЕНЫ ===');
          print('🔍 DEBUG: === НАЧАЛО ЗАГРУЗКИ ИЗОБРАЖЕНИЯ ===');

          // Загружаем изображение по URL, если оно есть
          File? questImage;
          String? imageUrl;
          if (quest.imageUrl.isNotEmpty && quest.imageUrl != 'default.jpg') {
            print('🔍 DEBUG: === ОБРАБОТКА ИЗОБРАЖЕНИЯ ===');
            try {
              // Сохраняем URL изображения для отображения
              imageUrl = quest.imageUrl;
              // Здесь можно добавить логику загрузки изображения по URL
              // Пока оставляем null
              questImage = null;
              print('🔍 DEBUG: === ИЗОБРАЖЕНИЕ ОБРАБОТАНО ===');
            } catch (e) {
              print('🔍 DEBUG: Failed to load quest image: $e');
              questImage = null;
              imageUrl = null;
            }
          } else {
            print('🔍 DEBUG: === ИЗОБРАЖЕНИЕ НЕ ТРЕБУЕТСЯ ===');
          }
          print('🔍 DEBUG: === НАЧАЛО СОЗДАНИЯ СОСТОЯНИЯ ===');
          print('🔍 DEBUG: === ПОДГОТОВКА ПАРАМЕТРОВ ===');

          print('🔍 DEBUG: === СОЗДАНИЕ selectedIndexes ===');
          final selectedIndexes = _getSelectedIndexes(quest);
          print('🔍 DEBUG: === СОЗДАНИЕ pointsData ===');
          final pointsData = _getPointsData(quest);
          print('🔍 DEBUG: === СОЗДАНИЕ creditsRadioIndex ===');
          final creditsRadioIndex = quest.credits?.auto == true ? 1 : 0;
          print('🔍 DEBUG: === СОЗДАНИЕ difficultyLevel ===');
          final difficultyLevel = quest.difficulty;
          print('🔍 DEBUG: === СОЗДАНИЕ groupType ===');
          final groupType = _getGroupString(quest.mainPreferences?.group ?? 1);
          print('🔍 DEBUG: === СОЗДАНИЕ categoryId ===');
          final categoryId = quest.categoryId;
          print('🔍 DEBUG: === СОЗДАНИЕ vehicleId ===');
          final vehicleId = quest.mainPreferences?.vehicleId ?? 1;

          // Определяем hasMentor на основе mentorPreference из бэкенда
          print('🔍 DEBUG: === СОЗДАНИЕ hasMentor ===');
          print('  - quest.mentorPreference: "${quest.mentorPreference}"');
          bool hasMentor = false;
          if (quest.mentorPreference != null &&
              quest.mentorPreference!.isNotEmpty) {
            hasMentor = quest.mentorPreference!.contains('mentor_required');
            print(
                '  - mentorPreference содержит "mentor_required": $hasMentor');
          } else {
            print('  - mentorPreference пустой или null');
          }
          print('  - hasMentor: $hasMentor');

          print('🔍 DEBUG: === ВСЕ ПАРАМЕТРЫ ПОДГОТОВЛЕНЫ ===');

          emit(QuestEditScreenLoaded(
            selectedIndexes: selectedIndexes,
            pointsData: pointsData,
            merchImages: [],
            creditsRadioIndex: creditsRadioIndex,
            image: questImage, // Передаем загруженное изображение
            imageUrl: imageUrl, // Передаем URL изображения
            difficultyLevel: difficultyLevel,
            groupType: groupType,
            categoryId: categoryId,
            vehicleId: vehicleId,
            hasMentor: hasMentor,
          ));
          print('🔍 DEBUG: === СОСТОЯНИЕ СОЗДАНО УСПЕШНО ===');
        },
      );
    } catch (e) {
      print('🔍 DEBUG: Error loading quest data: $e');
      // Не эмитим ошибку, а показываем загруженное состояние с дефолтными значениями
      emit(QuestEditScreenLoaded(
        selectedIndexes: [
          [0],
          [0],
          [0],
          [0]
        ],
        pointsData: [
          QuestEditLocationItem(LocaleKeys.kTextStartPoint.tr()),
          QuestEditLocationItem(LocaleKeys.kTextFinishPoint.tr()),
        ],
        merchImages: [],
        creditsRadioIndex: 0,
        image: null,
        imageUrl: null,
        difficultyLevel: 'Easy',
        groupType: 'Solo',
        categoryId: 1,
        vehicleId: 1,
        hasMentor: false,
      ));
    }
  }

  void _initializeMainPreferences(QuestDetailModel quest) {
    print(
        '🔍 DEBUG: _initializeMainPreferences() - Начинаем инициализацию основных настроек');

    // Инициализация основных настроек квеста
    if (quest.mainPreferences != null) {
      print('  - mainPreferences не null');

      // Инициализируем кредиты
      if (quest.credits != null) {
        print(
            '  - Инициализируем кредиты: cost=${quest.credits!.cost}, reward=${quest.credits!.reward}');
        creditsAccrueController.text = quest.credits!.reward.toString();
        creditsPaysController.text = quest.credits!.cost.toString();
      } else {
        print('  - credits is null');
      }

      // Инициализируем мерч
      if (quest.merchList.isNotEmpty) {
        print('  - Инициализируем мерч: ${quest.merchList.length} элементов');
        // Берем первый мерч для примера
        final firstMerch = quest.merchList.first;
        merchDescriptionController.text = firstMerch.description;
        merchPriceController.text = firstMerch.price.toString();
      } else {
        print('  - merchList пустой');
      }
    } else {
      print('  - mainPreferences is null');
    }
  }

  void _initializePoints(QuestDetailModel quest) {
    print('🔍 DEBUG: _initializePoints() - Начинаем инициализацию точек');
    print('  - quest.points.length: ${quest.points.length}');

    // Инициализация точек квеста
    if (quest.points.isNotEmpty) {
      // Очищаем существующие контроллеры и ID
      for (var controller in pointControllers) {
        controller.dispose();
      }
      pointControllers.clear();
      pointIds.clear();

      // Создаем новые контроллеры для каждой точки и сохраняем ID
      for (int i = 0; i < quest.points.length; i++) {
        final point = quest.points[i];
        print(
            '  - Создаем контроллер для точки[$i]: id=${point.id}, nameOfLocation="${point.nameOfLocation}"');
        final controller = TextEditingController(text: point.nameOfLocation);
        pointControllers.add(controller);
        pointIds.add(point.id);
      }

      print('  - Создано контроллеров: ${pointControllers.length}');
      print('  - Сохранено ID точек: $pointIds');
    } else {
      print('  - Точки пустые, используем дефолтные');
    }
  }

  List<List<int>> _getSelectedIndexes(QuestDetailModel quest) {
    // Возвращаем выбранные индексы на основе данных квеста
    // Структура должна соответствовать _getMainPreferences():
    // Index 0: Difficulty Level, Index 1: Group Type, Index 2: Category, Index 3: Vehicle

    if (quest.mainPreferences != null) {
      // Index 0: Difficulty Level (Easy=0, Medium=1, Hard=2)
      int difficultyIndex = 0; // Default to Easy
      if (quest.difficulty == 'Medium') {
        difficultyIndex = 1;
      } else if (quest.difficulty == 'Hard') {
        difficultyIndex = 2;
      }

      final selectedIndexes = [
        [difficultyIndex], // Difficulty Level
        [
          quest.mainPreferences!.group - 1
        ], // Group Type (group начинается с 1, а индексы с 0)
        [
          quest.mainPreferences!.categoryId - 1
        ], // Category (categoryId начинается с 1, а индексы с 0)
        [
          quest.mainPreferences!.vehicleId - 1
        ], // Vehicle (vehicleId начинается с 1, а индексы с 0)
      ];

      print(
          '🔍 DEBUG: _getSelectedIndexes - quest.difficulty: ${quest.difficulty}');
      print(
          '🔍 DEBUG: _getSelectedIndexes - quest.mainPreferences.group: ${quest.mainPreferences!.group}');
      print(
          '🔍 DEBUG: _getSelectedIndexes - quest.mainPreferences.categoryId: ${quest.mainPreferences!.categoryId}');
      print(
          '🔍 DEBUG: _getSelectedIndexes - quest.mainPreferences.vehicleId: ${quest.mainPreferences!.vehicleId}');
      print(
          '🔍 DEBUG: _getSelectedIndexes - difficultyIndex: $difficultyIndex');
      print(
          '🔍 DEBUG: _getSelectedIndexes - selectedIndexes: $selectedIndexes');

      return selectedIndexes;
    }
    return [
      [0], // Difficulty Level (Easy)
      [0], // Group Type (Solo)
      [0], // Category (Adventure)
      [0] // Vehicle (On Foot)
    ];
  }

  List<QuestEditLocationItem> _getPointsData(QuestDetailModel quest) {
    // Возвращаем данные точек на основе квеста
    if (quest.points.isNotEmpty) {
      return quest.points
          .map((point) => QuestEditLocationItem(
                point.nameOfLocation,
                typeId: point.typeId,
                toolId: point.toolId,
              ))
          .toList();
    }
    return [
      QuestEditLocationItem(LocaleKeys.kTextStartPoint.tr()),
      QuestEditLocationItem(LocaleKeys.kTextFinishPoint.tr()),
    ];
  }

  void updateMainPreference(int preferencesIndex, int preferencesItemIndex,
      int? preferencesSubItemIndex) {
    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
      final updatedIndexes = List<List<int>>.from(currentState.selectedIndexes);

      if (preferencesIndex < updatedIndexes.length) {
        // Если снимаем выбор (preferencesItemIndex == -1), устанавливаем первый элемент
        if (preferencesItemIndex == -1) {
          updatedIndexes[preferencesIndex] = [0];
        } else {
          updatedIndexes[preferencesIndex] = [preferencesItemIndex];
        }
      }

      // Обновляем difficultyLevel, если изменился Difficulty Level (preferencesIndex == 0)
      String updatedDifficultyLevel = currentState.difficultyLevel;
      if (preferencesIndex == 0) {
        // preferencesIndex 0 = Difficulty Level
        final difficultyIndex =
            preferencesItemIndex == -1 ? 0 : preferencesItemIndex;
        switch (difficultyIndex) {
          case 0:
            updatedDifficultyLevel = 'Easy';
            break;
          case 1:
            updatedDifficultyLevel = 'Medium';
            break;
          case 2:
            updatedDifficultyLevel = 'Hard';
            break;
          default:
            updatedDifficultyLevel = 'Easy';
        }
        print(
            '🔍 DEBUG: updateMainPreference - обновляем difficultyLevel: $updatedDifficultyLevel (индекс: $difficultyIndex)');
      }

      // Обновляем groupType, если изменился Group Type (preferencesIndex == 1)
      String updatedGroupType = currentState.groupType;
      if (preferencesIndex == 1) {
        // preferencesIndex 1 = Group Type
        final groupIndex =
            preferencesItemIndex == -1 ? 0 : preferencesItemIndex;
        switch (groupIndex) {
          case 0:
            updatedGroupType = 'Solo';
            break;
          case 1:
            updatedGroupType = 'Duo';
            break;
          case 2:
            updatedGroupType = 'Team';
            break;
          case 3:
            updatedGroupType = 'Family';
            break;
          default:
            updatedGroupType = 'Solo';
        }
        print(
            '🔍 DEBUG: updateMainPreference - обновляем groupType: $updatedGroupType (индекс: $groupIndex)');
      }

      // Обновляем categoryId, если изменилась Category (preferencesIndex == 2)
      int updatedCategoryId = currentState.categoryId;
      if (preferencesIndex == 2) {
        // preferencesIndex 2 = Category
        final categoryIndex =
            preferencesItemIndex == -1 ? 0 : preferencesItemIndex;
        updatedCategoryId = categoryIndex + 1; // ID начинаются с 1
        print(
            '🔍 DEBUG: updateMainPreference - обновляем categoryId: $updatedCategoryId (индекс: $categoryIndex)');
      }

      // Обновляем vehicleId, если изменился Vehicle (preferencesIndex == 3)
      int updatedVehicleId = currentState.vehicleId;
      if (preferencesIndex == 3) {
        // preferencesIndex 3 = Vehicle
        final vehicleIndex =
            preferencesItemIndex == -1 ? 0 : preferencesItemIndex;
        updatedVehicleId = vehicleIndex + 1; // ID начинаются с 1
        print(
            '🔍 DEBUG: updateMainPreference - обновляем vehicleId: $updatedVehicleId (индекс: $vehicleIndex)');
      }

      emit(currentState.copyWith(
        selectedIndexes: updatedIndexes,
        difficultyLevel: updatedDifficultyLevel,
        groupType: updatedGroupType,
        categoryId: updatedCategoryId,
        vehicleId: updatedVehicleId,
      ));
    }
  }

  void setCreditsMode(int radioIndex) {
    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
      emit(currentState.copyWith(creditsRadioIndex: radioIndex));
    }
  }

  void setHasMentor(bool hasMentor) {
    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
      emit(currentState.copyWith(hasMentor: hasMentor));
    }
  }

  void addMerchImage(XFile image) {
    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
      final updatedImages = List<XFile>.from(currentState.merchImages)
        ..add(image);
      emit(currentState.copyWith(merchImages: updatedImages));
    }
  }

  void addPoint() {
    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
      final updatedPointsData =
          List<QuestEditLocationItem>.from(currentState.pointsData);

      final position = updatedPointsData.length - 1;
      final locationItem = QuestEditLocationItem(
          '${LocaleKeys.kTextHalfwayPoint.tr()} ($position)');
      updatedPointsData.insert(position, locationItem);

      final controller = TextEditingController();
      pointControllers.insert(position, controller);

      emit(currentState.copyWith(pointsData: updatedPointsData));
    }
  }

  void deletePoint(int index) {
    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
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

  void pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && state is QuestEditScreenLoaded) {
        final currentState = state as QuestEditScreenLoaded;
        // Конвертируем XFile в File
        final file = File(image.path);
        emit(currentState.copyWith(image: file));
      }
    } catch (e) {
      emit(QuestEditScreenError('Failed to pick image: $e'));
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

  Future<void> updateQuest(BuildContext context) async {
    print('🚨🚨🚨 DEBUG: updateQuest() ВЫЗВАН! 🚨🚨🚨');
    print('🔍 DEBUG: Текущее состояние: ${state.runtimeType}');
    print('🔍 DEBUG: questId: $questId');

    if (!formKey.currentState!.validate()) {
      print('🔍 DEBUG: Валидация формы не прошла');
      return;
    }

    try {
      // Получаем текущее состояние для доступа к данным ДО эмита
      print('🔍 DEBUG: Проверяем состояние ДО эмита: ${state.runtimeType}');

      // Безопасная проверка состояния
      QuestEditScreenLoaded? currentState;
      if (state is QuestEditScreenLoaded) {
        currentState = state as QuestEditScreenLoaded;
        print('🔍 DEBUG: Состояние QuestEditScreenLoaded, сохраняем его...');
      } else {
        print(
            '❌ DEBUG: Неверное состояние для updateQuest: ${state.runtimeType}');
        print('  - Ожидалось: QuestEditScreenLoaded');
        print('  - Получено: ${state.runtimeType}');
        emit(QuestEditScreenError(
            'Invalid state for update: ${state.runtimeType}'));
        return;
      }

      print('🔍 DEBUG: Эмитим QuestEditScreenLoading');
      emit(QuestEditScreenLoading());

      // Конвертируем новое изображение в base64, если оно есть
      String imageToSend = currentState.imageUrl ?? '';
      if (currentState.image != null) {
        // Если есть новое изображение, конвертируем его в base64
        imageToSend = await _convertFileToBase64(currentState.image);
        print('🔍 DEBUG: Конвертировано новое изображение в base64');
      } else if (currentState.imageUrl != null &&
          currentState.imageUrl!.isNotEmpty) {
        // Если нет нового изображения, но есть URL, используем его
        imageToSend = currentState.imageUrl!;
        print('🔍 DEBUG: Используем существующий URL изображения');
      }

      // Создаем модель для обновления квеста со всеми полями
      final mentorPref = currentState.hasMentor
          ? 'mentor_required'
          : 'no_mentor'; // Всегда отправляем значение
      print(
          '🔍 DEBUG: mentorPreference: $mentorPref (hasMentor: ${currentState.hasMentor})');

      // ВАЖНО: Проверяем questId перед отправкой
      print('🚨🚨🚨 КРИТИЧЕСКИЙ DEBUG: questId = $questId 🚨🚨🚨');
      if (questId == 0) {
        print('❌❌❌ ОШИБКА: Попытка обновить квест с questId = 0! ❌❌❌');
        print('❌ Это может вызвать ошибку duplicate key constraint!');
        emit(QuestEditScreenError('Ошибка: questId не может быть 0'));
        return;
      }

      final updateModel = QuestUpdateModel(
        id: questId,
        name: nameController.text.trim(), // Убираем лишние пробелы
        description:
            descriptionController.text.trim(), // Убираем лишние пробелы
        image: imageToSend,
        credits: _buildCreditsUpdate(),
        mainPreferences: _buildMainPreferencesUpdate(currentState),
        points: _buildPointsUpdate(currentState),
        mentorPreference: mentorPref, // Теперь всегда будет валидное значение
      );

      print('🔍 DEBUG: Создана модель обновления:');
      print('  - id: ${updateModel.id}');
      print('  - name: "${updateModel.name}"');
      print('  - description: "${updateModel.description}"');
      print('  - points.length: ${updateModel.points.length}');

      // Логируем полный JSON объект
      print('🔍 DEBUG: ===== ПОЛНЫЙ JSON ОБЪЕКТ =====');
      final jsonData = updateModel.toJson();
      print('🔍 DEBUG: JSON ключи: ${jsonData.keys.toList()}');
      print('🔍 DEBUG: Полный JSON: ${jsonData.toString()}');

      // Логируем каждое поле отдельно
      print('🔍 DEBUG: ===== ДЕТАЛЬНЫЙ АНАЛИЗ =====');
      print(
          '🔍 DEBUG: id: ${jsonData['id']} (тип: ${jsonData['id'].runtimeType})');
      print(
          '🔍 DEBUG: name: ${jsonData['name']} (тип: ${jsonData['name'].runtimeType})');
      print(
          '🔍 DEBUG: description: ${jsonData['description']} (тип: ${jsonData['description'].runtimeType})');
      print(
          '🔍 DEBUG: image: ${jsonData['image']} (тип: ${jsonData['image'].runtimeType})');

      if (jsonData['credits'] != null) {
        print('🔍 DEBUG: credits: ${jsonData['credits']}');
      }

      if (jsonData['merch'] != null) {
        print('🔍 DEBUG: merch: ${jsonData['merch']}');
      }

      if (jsonData['main_preferences'] != null) {
        print('🔍 DEBUG: main_preferences: ${jsonData['main_preferences']}');
      }

      if (jsonData['points'] != null) {
        print('🔍 DEBUG: points: ${jsonData['points']}');
        final points = jsonData['points'] as List;
        for (int i = 0; i < points.length; i++) {
          print('🔍 DEBUG:   point[$i]: ${points[i]}');
        }
      }

      if (jsonData['mentor_preference'] != null) {
        print('🔍 DEBUG: mentor_preference: ${jsonData['mentor_preference']}');
      }

      print('🔍 DEBUG: ===== КОНЕЦ АНАЛИЗА =====');
      print('🔍 DEBUG: Вызываем updateQuestUC...');

      final result = await updateQuestUC(updateModel);
      print('🔍 DEBUG: updateQuestUC вернул результат: ${result.runtimeType}');

      result.fold(
        (failure) {
          print('🔍 DEBUG: Update failed: $failure');
          print('🔍 DEBUG: Тип ошибки: ${failure.runtimeType}');

          // Детальное логирование ошибки
          if (failure is ServerFailure) {
            print('🔍 DEBUG: ServerFailure - ошибка сервера');
          } else if (failure is CacheFailure) {
            print('🔍 DEBUG: CacheFailure - ошибка кэша');
          } else if (failure is InternetConnectionFailure) {
            print(
                '🔍 DEBUG: InternetConnectionFailure - ошибка интернет-соединения');
          } else if (failure is ConnectionFailure) {
            print('🔍 DEBUG: ConnectionFailure - ошибка соединения');
          } else if (failure is TimeoutFailure) {
            print('🔍 DEBUG: TimeoutFailure - ошибка таймаута');
          } else if (failure is ValidationFailure) {
            print('🔍 DEBUG: ValidationFailure - ошибка валидации');
          } else if (failure is UnauthorizedFailure) {
            print('🔍 DEBUG: UnauthorizedFailure - ошибка авторизации');
          } else if (failure is NotFoundFailure) {
            print('🔍 DEBUG: NotFoundFailure - ресурс не найден');
          } else {
            print('🔍 DEBUG: Неизвестный тип ошибки: ${failure.runtimeType}');
          }

          emit(QuestEditScreenError('Failed to update quest: $failure'));
        },
        (_) {
          print('🔍 DEBUG: Quest updated successfully');
          // Успешное обновление
          Navigator.pop(context);
        },
      );
    } catch (e) {
      print('🔍 DEBUG: Update error: $e');
      emit(QuestEditScreenError('Failed to update quest: $e'));
    }
  }

  // Обновление данных точки
  void updatePointData(PointEditData data) {
    print('🔍 DEBUG: updatePointData - Начало выполнения');
    print('  - Текущее состояние: ${state.runtimeType}');

    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
      final updatedPointsData =
          List<QuestEditLocationItem>.from(currentState.pointsData);

      // Обновляем данные точки
      if (data.pointIndex < updatedPointsData.length) {
        updatedPointsData[data.pointIndex] = QuestEditLocationItem(
          updatedPointsData[data.pointIndex].title,
          typeId: data.typeId,
          toolId: data.toolId,
          places: data.places,
          file: data.file,
          typePhoto: data.typePhoto,
          typeCode: data.typeCode,
          typeWord: data.typeWord,
          isDivide: data.isDivide,
        );

        print(
            '🔍 DEBUG: updatePointData - Обновлена точка ${data.pointIndex}: typeId=${data.typeId}, toolId=${data.toolId}');
      }

      emit(currentState.copyWith(pointsData: updatedPointsData));
      print('🔍 DEBUG: updatePointData - Состояние обновлено');
    } else {
      print(
          '❌ DEBUG: updatePointData - Неверное состояние: ${state.runtimeType}');
      print('  - Ожидалось: QuestEditScreenLoaded');
      print('  - Получено: ${state.runtimeType}');
    }
  }

  void resetState() {
    emit(QuestEditScreenLoading());
    _init();
  }

  void _onFormFieldChanged() {
    _validateForm();
  }

  void _onTextChanged() {
    _validateForm();
  }

  void _validateForm() {
    if (state is QuestEditScreenLoaded) {
      final currentState = state as QuestEditScreenLoaded;
      // Проверяем валидность формы
      nameController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty &&
          pointControllers.every((controller) => controller.text.isNotEmpty);

      // Обновляем состояние без isFormValid, так как этот параметр не определен
      emit(currentState.copyWith());
    }
  }

  /// Строит модель обновления кредитов из UI данных
  CreditsUpdate _buildCreditsUpdate() {
    return CreditsUpdate(
      cost: int.tryParse(creditsPaysController.text) ?? 0,
      reward: int.tryParse(creditsAccrueController.text) ?? 0,
    );
  }

  /// Строит модель обновления основных предпочтений из UI данных
  MainPreferencesUpdate _buildMainPreferencesUpdate(
      QuestEditScreenLoaded currentState) {
    // Получаем выбранные индексы
    final selectedIndexes = currentState.selectedIndexes;

    // Структура selectedIndexes: [Difficulty, Group, Category, Vehicle]
    // Безопасно получаем индексы, добавляя 1 (так как UI индексы начинаются с 0, а ID с 1)
    final categoryId =
        selectedIndexes.length > 2 && selectedIndexes[2].isNotEmpty
            ? selectedIndexes[2][0] + 1
            : 1;
    final vehicleId =
        selectedIndexes.length > 3 && selectedIndexes[3].isNotEmpty
            ? selectedIndexes[3][0] + 1
            : 1;
    final placeId = 1; // Пока используем дефолтное значение
    final group = selectedIndexes.length > 1 && selectedIndexes[1].isNotEmpty
        ? selectedIndexes[1][0] + 1
        : 1;

    // Конвертируем difficulty level в правильный формат
    String level = 'Easy';
    if (currentState.difficultyLevel == 'Medium') {
      level = 'Medium';
    } else if (currentState.difficultyLevel == 'Hard') {
      level = 'Hard';
    }

    final groupString = _getGroupString(group);
    final timeframeString = _getTimeframeString(currentState.difficultyLevel);
    final mileageString = _getMileageString(currentState.difficultyLevel);

    print(
        '🔍 DEBUG: _buildMainPreferencesUpdate - selectedIndexes: $selectedIndexes');
    print(
        '🔍 DEBUG: _buildMainPreferencesUpdate - difficultyLevel: ${currentState.difficultyLevel}');
    print(
        '🔍 DEBUG: _buildMainPreferencesUpdate - categoryId: $categoryId, vehicleId: $vehicleId, group: $group');
    print(
        '🔍 DEBUG: _buildMainPreferencesUpdate - groupString: $groupString, timeframeString: $timeframeString, level: $level, mileageString: $mileageString');

    return MainPreferencesUpdate(
      categoryId: categoryId,
      vehicleId: vehicleId,
      placeId: placeId,
      group: groupString,
      timeframe: timeframeString,
      level: level,
      mileage: mileageString,
      types: [], // Пока пустой, можно добавить логику позже
      places: [], // Пока пустой, можно добавить логику позже
      vehicles: [vehicleId],
      tools: [], // Пока пустой, можно добавить логику позже
    );
  }

  /// Строит модель обновления точек из UI данных
  List<PointUpdateItem> _buildPointsUpdate(QuestEditScreenLoaded currentState) {
    final points = <PointUpdateItem>[];

    // Используем переданное состояние вместо приведения типов

    for (int i = 0; i < pointControllers.length; i++) {
      final controller = pointControllers[i];
      if (controller.text.isNotEmpty) {
        // Используем сохраненный ID точки, если он есть
        final pointId = i < pointIds.length ? pointIds[i] : null;

        // Получаем typeId и toolId из pointsData
        final typeId = i < currentState.pointsData.length
            ? currentState.pointsData[i].typeId ?? 1
            : 1;
        final toolId = i < currentState.pointsData.length
            ? currentState.pointsData[i].toolId
            : null;

        print(
            '🔍 DEBUG: _buildPointsUpdate - Точка $i: typeId=$typeId, toolId=$toolId');

        points.add(PointUpdateItem(
          id: pointId, // Добавляем реальный ID точки
          nameOfLocation: controller.text,
          description: controller.text, // Используем название как описание
          order: i,
          type: PointTypeUpdate(
            typeId: typeId, // Используем реальный typeId из pointsData
            typePhoto: null,
            typeCode: null,
            typeWord: null,
          ),
          places: [], // Пока пустой, можно добавить логику позже
          toolId: toolId, // Используем реальный toolId из pointsData
          file: null,
          isDivide: false,
        ));
      }
    }

    return points;
  }

  /// Преобразует числовой ID группы в строку
  String _getGroupString(int groupId) {
    switch (groupId) {
      case 1:
        return 'Solo'; // ALONE
      case 2:
        return 'Duo'; // TWO
      case 3:
        return 'Team'; // THREE
      case 4:
        return 'Family'; // FOUR
      default:
        return 'Solo';
    }
  }

  /// Преобразует уровень сложности в timeframe
  String _getTimeframeString(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return '1-2 hours';
      case 'Medium':
        return '2-4 hours';
      case 'Hard':
        return '4+ hours';
      default:
        return '1-2 hours';
    }
  }

  /// Преобразует уровень сложности в mileage
  String _getMileageString(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return '5-10';
      case 'Medium':
        return '10-30';
      case 'Hard':
        return '30-100';
      case 'Very Hard':
        return '>100';
      default:
        return '5-10';
    }
  }

  @override
  Future<void> close() {
    // Освобождаем ресурсы
    nameController.dispose();
    descriptionController.dispose();
    creditsAccrueController.dispose();
    creditsPaysController.dispose();
    merchDescriptionController.dispose();
    merchPriceController.dispose();
    mentorPreferenceController.dispose();

    for (final controller in pointControllers) {
      controller.dispose();
    }

    return super.close();
  }
}
