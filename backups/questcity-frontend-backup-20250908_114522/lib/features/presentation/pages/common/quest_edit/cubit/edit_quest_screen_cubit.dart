import 'package:bloc/bloc.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/create_quest.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_levels.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_miles.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_places.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_prices.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_vehicles.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/update_quest.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_update_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';

part 'edit_quest_screen_state.dart';

class EditQuestScreenCubit extends Cubit<EditQuestScreenState> {
  final int? questId;
  final GetLevels getLevelsUC;
  final GetPlaces getPlacesUC;
  final GetPrices getPricesUC;
  final GetMiles getMilesUC;
  final GetVehicles getVehiclesUC;
  final CreateQuest createQuestUC;
  final UpdateQuest updateQuestUC;
  final GetQuest getQuestUC;

  TextEditingController merchDescriptionController = TextEditingController();
  TextEditingController merchPriceController = TextEditingController();

  final TextEditingController creditsAccrueController = TextEditingController();
  final TextEditingController creditsPaysController = TextEditingController();
  final TextEditingController payExtraController = TextEditingController();
  final TextEditingController nameCategoryController = TextEditingController();
  final TextEditingController descriptionQuestController =
      TextEditingController();
  final TextEditingController mentorPreferenceController =
      TextEditingController();
  final List<TextEditingController> pointControllers = [
    TextEditingController(),
    TextEditingController()
  ];

  // Callback для обновления списка квестов
  VoidCallback? _onQuestCreated;

  List<QuestPreference> mainPreferencesData = [];

  List<QuestParameterEntity> levels = [];
  List<QuestParameterEntity> places = [];
  List<QuestParameterEntity> prices = [];
  List<QuestParameterEntity> miles = [];
  List<QuestParameterEntity> vehicles = [];

  EditQuestScreenCubit({
    this.questId,
    required this.getLevelsUC,
    required this.getPlacesUC,
    required this.getPricesUC,
    required this.getMilesUC,
    required this.getVehiclesUC,
    required this.createQuestUC,
    required this.updateQuestUC,
    required this.getQuestUC,
    VoidCallback? onQuestCreated,
  }) : super(EditQuestScreenLoading()) {
    // Сохраняем callback для обновления списка квестов
    _onQuestCreated = onQuestCreated;
    print(
        '🔍 DEBUG: EditQuestScreenCubit.constructor() - Кубит создан, questId: $questId');
    print('🔍 DEBUG: EditQuestScreenCubit.constructor() - Вызываем _init()');
    _init();

    print(
        '🔍 DEBUG: EditQuestScreenCubit.constructor() - Добавляем слушатели для валидации');
    // Добавляем слушатели для валидации
    nameCategoryController.addListener(_onFormFieldChanged);
    descriptionQuestController.addListener(_onFormFieldChanged);
    creditsPaysController.addListener(_onFormFieldChanged);
    creditsAccrueController.addListener(_onFormFieldChanged);
    merchDescriptionController.addListener(_onFormFieldChanged);
    merchPriceController.addListener(_onFormFieldChanged);
    mentorPreferenceController.addListener(_onFormFieldChanged);

    // Слушатели для точек будут добавлены в _init() или loadQuestData()

    print(
        '🔍 DEBUG: EditQuestScreenCubit.constructor() - Конструктор завершен');
  }

  Future<void> _init() async {
    print(
        '🚨🚨🚨 DEBUG: EditQuestScreenCubit._init() - НАЧАЛО ИНИЦИАЛИЗАЦИИ 🚨🚨🚨');
    print('🚨🚨🚨 questId = $questId 🚨🚨🚨');

    // Загружаем основные параметры
    await _loadBasicParameters();

    print(
        '🔍 DEBUG: EditQuestScreenCubit._init() - Инициализируем основные данные...');

    // Проверяем, что все необходимые параметры загружены
    if (levels.isEmpty ||
        places.isEmpty ||
        prices.isEmpty ||
        miles.isEmpty ||
        vehicles.isEmpty) {
      print(
          '⚠️ ERROR: EditQuestScreenCubit._init() - Не все параметры загружены:');
      print('  - levels: ${levels.length}');
      print('  - places: ${places.length}');
      print('  - prices: ${prices.length}');
      print('  - miles: ${miles.length}');
      print('  - vehicles: ${vehicles.length}');

      // Продолжаем с пустыми списками, но предупреждаем
      print('⚠️ WARNING: Продолжаем инициализацию с пустыми параметрами');
    }

    await _initMainPrefs();
    List<List<int>> selectedIndexes = await _initSelectedIndexes();

    // Если это создание нового квеста, создаем дефолтные точки
    // Если это редактирование, точки будут загружены в loadQuestData()
    List<QuestEditLocationItem> pointsData;
    List<TextEditingController> initialPointControllers = [];

    if (questId == null) {
      pointsData = [
        QuestEditLocationItem(LocaleKeys.kTextStartPoint.tr()),
        QuestEditLocationItem(LocaleKeys.kTextFinishPoint.tr()),
      ];

      // Создаем контроллеры для дефолтных точек
      initialPointControllers = [
        TextEditingController()..addListener(_onTextChanged),
        TextEditingController()..addListener(_onTextChanged),
      ];

      // Обновляем основной список контроллеров
      pointControllers.clear();
      pointControllers.addAll(initialPointControllers);
    } else {
      // Для редактирования точки будут загружены позже
      pointsData = [];
    }

    print(
        '🔍 DEBUG: EditQuestScreenCubit._init() - Имитируем состояние EditQuestScreenLoaded');
    print('  - selectedIndexes: ${selectedIndexes.length}');
    print('  - pointsData: ${pointsData.length}');
    print('  - levels: ${levels.length}');
    print('  - places: ${places.length}');
    print('  - prices: ${prices.length}');
    print('  - miles: ${miles.length}');
    print('  - vehicles: ${vehicles.length}');

    emit(EditQuestScreenLoaded(
      selectedIndexes: selectedIndexes,
      pointsData: pointsData,
      merchImages: const [],
      creditsRadioIndex: 0,
      isFormValid: false, // Форма изначально невалидна
      validationErrors: const {},
    ));

    // Если это редактирование существующего квеста, загружаем данные
    if (questId != null) {
      print(
          '🔄 DEBUG: EditQuestScreenCubit._init() - questId не null, вызываем loadQuestData()');
      await loadQuestData();
    } else {
      print(
          'ℹ️ DEBUG: EditQuestScreenCubit._init() - questId is null, создаем новый квест');
    }
  }

  Future _loadBasicParameters() async {
    print(
        '🔍 DEBUG: EditQuestScreenCubit._loadBasicParameters() - Начинаем загрузку основных параметров');

    Map<String, UseCase<List<QuestParameterEntity>, NoParams>> paramsMap = {
      'levels': getLevelsUC,
      'places': getPlacesUC,
      'prices': getPricesUC,
      'miles': getMilesUC,
      'vehicles': getVehiclesUC
    };

    print(
        '🔍 DEBUG: EditQuestScreenCubit._loadBasicParameters() - Загружаем параметры...');

    for (var index = 0; index < paramsMap.values.toList().length; index++) {
      print(
          '🔍 DEBUG: EditQuestScreenCubit._loadBasicParameters() - Загружаем параметр $index');

      // Определяем название параметра для логгирования
      String paramName = '';
      switch (index) {
        case 0:
          paramName = 'levels';
          break;
        case 1:
          paramName = 'places';
          break;
        case 2:
          paramName = 'prices';
          break;
        case 3:
          paramName = 'miles';
          break;
        case 4:
          paramName = 'vehicles';
          break;
      }

      print(
          '🔍 DEBUG: EditQuestScreenCubit._loadBasicParameters() - Загружаем $paramName (индекс $index)');

      try {
        final failureOrLoads =
            await paramsMap.values.toList()[index](NoParams());
        print(
            'вњ… DEBUG: EditQuestScreenCubit._loadBasicParameters() - $paramName загружен: ${failureOrLoads.isRight()}');

        failureOrLoads.fold(
          (error) {
            print(
                'вќЊ ERROR: EditQuestScreenCubit._loadBasicParameters() - Ошибка загрузки $paramName: $error');
            emit(EditQuestScreenError('Failed to load $paramName'));
            return;
          },
          (params) {
            print(
                'вњ… DEBUG: EditQuestScreenCubit._loadBasicParameters() - $paramName успешно загружен, элементов: ${params.length}');
            switch (index) {
              case 0:
                levels = params;
                break;
              case 1:
                places = params;
                break;
              case 2:
                prices = params;
                break;
              case 3:
                miles = params;
                break;
              case 4:
                vehicles = params;
                break;
            }
          },
        );
      } catch (e) {
        print(
            'вќЊ ERROR: EditQuestScreenCubit._loadBasicParameters() - Исключение при загрузке $paramName: $e');
        print('вќЊ ERROR: Тип исключения: ${e.runtimeType}');
        print('вќЊ ERROR: Stack trace: ${StackTrace.current}');
        emit(EditQuestScreenError('Failed to load $paramName: $e'));
        return;
      }
    }
    print(
        '🔍 DEBUG: EditQuestScreenCubit._loadBasicParameters() - Основные параметры загружены');
  }

  Future _initMainPrefs() async {
    print(
        '🔍 DEBUG: EditQuestScreenCubit._initMainPrefs() - Начинаем инициализацию основных предпочтений');

    // Проверяем, что все необходимые списки не пустые
    if (levels.isEmpty ||
        places.isEmpty ||
        prices.isEmpty ||
        miles.isEmpty ||
        vehicles.isEmpty) {
      print(
          'вљ пёЏ WARNING: _initMainPrefs() - Некоторые списки пусты, используем дефолтные значения');

      // Создаем дефолтные значения для пустых списков
      if (levels.isEmpty)
        levels = [QuestParameterEntity(id: 1, title: 'Default Level')];
      if (places.isEmpty)
        places = [QuestParameterEntity(id: 1, title: 'Default Place')];
      if (prices.isEmpty)
        prices = [QuestParameterEntity(id: 1, title: 'Default Price')];
      if (miles.isEmpty)
        miles = [QuestParameterEntity(id: 1, title: 'Default Mile')];
      if (vehicles.isEmpty)
        vehicles = [QuestParameterEntity(id: 1, title: 'Default Vehicle')];
    }

    mainPreferencesData = [
      QuestPreference(
        title: LocaleKeys.kTextType.tr(),
        [
          QuestPreferenceItem(
            LocaleKeys.kTextGroup.tr(),
            subitems: const QuestPreferenceSubItem(
              ['2', '3', '4'],
            ),
          ),
          QuestPreferenceItem(LocaleKeys.kTextForOne.tr()),
        ],
      ),
      QuestPreference(
        title: LocaleKeys.kTextVehicle.tr(),
        List.generate(vehicles.length,
            (index) => QuestPreferenceItem(vehicles[index].title)).toList(),
      ),
      QuestPreference(
        title: LocaleKeys.kTextPrice.tr(),
        List.generate(prices.length, (index) {
          if (prices[index].title == 'Pay extra') {
            return QuestPreferenceItem(
              prices[index].title,
              textFieldEntry:
                  QuestPreferenceItemTextField('Cost', payExtraController,
                      keyboardType: TextInputType.number,
                      validator: Utils.validate,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      prefixText: '\$'),
            );
          } else {
            return QuestPreferenceItem(prices[index].title);
          }
        }).toList(),
      ),
      QuestPreference(
        title: LocaleKeys.kTextTime.tr(),
        [
          QuestPreferenceItem(LocaleKeys.kTextUnlimited.tr()),
          QuestPreferenceItem(
            LocaleKeys.kTextTimeframe.tr(),
            subitems: QuestPreferenceSubItem([
              '1 ${LocaleKeys.kTextHour.tr().toLowerCase()}',
              '3 ${LocaleKeys.kTextHours.tr().toLowerCase()}',
              '10 ${LocaleKeys.kTextHours.tr().toLowerCase()}'
            ], isHorizontalDirection: false),
          ),
          QuestPreferenceItem(LocaleKeys.kTextOneDay.tr()),
        ],
      ),
      QuestPreference(
        title: LocaleKeys.kTextLevels.tr(),
        List.generate(levels.length,
            (index) => QuestPreferenceItem(levels[index].title)).toList(),
      ),
      QuestPreference(
        title: LocaleKeys.kTextMilege.tr(),
        List.generate(miles.length,
            (index) => QuestPreferenceItem(miles[index].title)).toList(),
      ),
      QuestPreference(
        title: LocaleKeys.kTextPlaces.tr(),
        List.generate(places.length,
            (index) => QuestPreferenceItem(places[index].title)).toList(),
      ),
    ];

    print(
        '🔍 DEBUG: EditQuestScreenCubit._initMainPrefs() - Основные предпочтения инициализированы: ${mainPreferencesData.length}');
  }

  Future<List<List<int>>> _initSelectedIndexes() async {
    print(
        '🔍 DEBUG: EditQuestScreenCubit._initSelectedIndexes() - Начинаем инициализацию выбранных индексов');

    final result = mainPreferencesData
        .asMap()
        .map((index, preference) {
          if (preference.items.any((item) => item.subitems != null)) {
            if (index == 0) {
              return MapEntry(index, [0, 0]);
            } else {
              return MapEntry(index, [0, 0]);
            }
          } else {
            return MapEntry(index, [0]);
          }
        })
        .values
        .toList();

    print(
        '🔍 DEBUG: EditQuestScreenCubit._initSelectedIndexes() - Выбранные индексы инициализированы: ${result.length}');
    return result;
  }

  void onChangePreferences(int preferencesIndex, int preferencesItemIndex,
      {int? preferencesSubItemIndex, bool preferencesItemHasSubitems = false}) {
    if (state is EditQuestScreenLoaded) {
      EditQuestScreenLoaded currentState = state as EditQuestScreenLoaded;

      // Убираем проверку на -1, чтобы разрешить снятие выбора
      // if (preferencesItemIndex == -1 || preferencesSubItemIndex == -1) return;

      var preferencesItem = currentState.selectedIndexes[preferencesIndex];
      if (preferencesItem == null) {
        preferencesItem = [0];
      }

      // Если снимаем выбор (preferencesItemIndex == -1), устанавливаем первый элемент
      if (preferencesItemIndex == -1) {
        preferencesItem = [0];
      } else if (preferencesItem.length > 1) {
        if (preferencesItemHasSubitems) {
          preferencesItem = [preferencesItemIndex, 0];
        } else {
          preferencesItem = [
            preferencesItemIndex,
            preferencesSubItemIndex ?? 0
          ];
        }
      } else {
        preferencesItem = [preferencesItemIndex];
      }

      final updatedIndexes = List<List<int>>.from(currentState.selectedIndexes);
      updatedIndexes[preferencesIndex] = preferencesItem;

      emit(currentState.copyWith(selectedIndexes: updatedIndexes));
    }
  }

  void onAddPoint() {
    if (state is EditQuestScreenLoaded) {
      EditQuestScreenLoaded currentState = state as EditQuestScreenLoaded;

      final position = currentState.pointsData.isNotEmpty
          ? currentState.pointsData.length - 1
          : 0;
      final locationItem = QuestEditLocationItem(
          '${LocaleKeys.kTextHalfwayPoint.tr()} ($position)');
      final controller = TextEditingController()..addListener(_onTextChanged);

      final updatedPointsData =
          List<QuestEditLocationItem>.from(currentState.pointsData);
      updatedPointsData.insert(position, locationItem);

      // Добавляем контроллер в список
      pointControllers.insert(position, controller);

      emit(currentState.copyWith(pointsData: updatedPointsData));

      // Валидируем форму после изменения
      validateForm();
    }
  }

  void onDeletePoint(int index) {
    if (state is EditQuestScreenLoaded) {
      EditQuestScreenLoaded currentState = state as EditQuestScreenLoaded;

      final updatedPointsData =
          List<QuestEditLocationItem>.from(currentState.pointsData);
      updatedPointsData.removeAt(index);

      // Удаляем контроллер
      if (index < pointControllers.length) {
        pointControllers[index].dispose();
        pointControllers.removeAt(index);
      }

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

      // Валидируем форму после изменения
      validateForm();
    }
  }

  void _onTextChanged() {
    // Валидируем форму при изменении текста
    validateForm();
  }

  /// Обработчик изменения полей формы для валидации
  void _onFormFieldChanged() {
    // Валидируем форму
    validateForm();
  }

  void addMerchImages(XFile image) {
    print('🔍 DEBUG: addMerchImages() - Начинаем добавление изображения');

    if (state is EditQuestScreenLoaded) {
      EditQuestScreenLoaded currentState = state as EditQuestScreenLoaded;
      print(
          '🔍 DEBUG: addMerchImages() - Текущее состояние: ${currentState.runtimeType}');
      print(
          '🔍 DEBUG: addMerchImages() - merchImages: ${currentState.merchImages.length}');

      // Безопасно получаем список изображений, создаем новый, если null
      List<XFile> merchImages = currentState.merchImages ?? [];
      merchImages.add(image);

      print(
          '🔍 DEBUG: addMerchImages() - Добавлено изображение, новый размер: ${merchImages.length}');

      emit(currentState.copyWith(merchImages: merchImages));
      print('🔍 DEBUG: addMerchImages() - Состояние обновлено');
    } else {
      print(
          'вќЊ ERROR: addMerchImages() - Состояние не EditQuestScreenLoaded: ${state.runtimeType}');
    }
  }

  void changeManualOrAutoCreditsRadio(int index) {
    if (state is EditQuestScreenLoaded) {
      EditQuestScreenLoaded currentState = state as EditQuestScreenLoaded;

      emit(currentState.copyWith(creditsRadioIndex: index));
    }
  }

  /// Валидация формы
  void validateForm() {
    print('🔍 DEBUG: validateForm() - Начинаем валидацию формы');

    if (state is EditQuestScreenLoaded) {
      EditQuestScreenLoaded currentState = state as EditQuestScreenLoaded;
      print('🔍 DEBUG: validateForm() - Состояние: EditQuestScreenLoaded');
      print(
          '🔍 DEBUG: validateForm() - merchImages: ${currentState.merchImages.length}');

      final Map<String, String?> errors = {};
      bool isValid = true;

      // Валидация названия квеста
      final name = nameCategoryController.text.trim();
      if (name.isEmpty || name.length < 1) {
        errors['name'] = LocaleKeys.kTextQuestNameRequired.tr();
        isValid = false;
      } else if (name.length > 32) {
        errors['name'] = LocaleKeys.kTextQuestNameTooLong.tr();
        isValid = false;
      } else {
        errors['name'] = null;
      }

      // Валидация описания квеста
      final description = descriptionQuestController.text.trim();
      if (description.isEmpty || description.length < 1) {
        errors['description'] = LocaleKeys.kTextQuestDescriptionRequired.tr();
        isValid = false;
      } else {
        errors['description'] = null;
      }

      // Валидация кредитов (если выбраны)
      if (currentState.creditsRadioIndex == 1) {
        // РџСЂРµРґРїРѕР»Р°РіР°РµРјСЏ РґР»СЏ РїРѕР»РµР№
        final cost = int.tryParse(creditsPaysController.text);
        final reward = int.tryParse(creditsAccrueController.text);

        if (cost == null || cost < 0) {
          errors['credits_cost'] = LocaleKeys.kTextCreditsCostPositive.tr();
          isValid = false;
        } else {
          errors['credits_cost'] = null;
        }

        if (reward == null || reward < 0) {
          errors['credits_reward'] = LocaleKeys.kTextCreditsRewardPositive.tr();
          isValid = false;
        } else {
          errors['credits_reward'] = null;
        }
      }

      // Валидация мерча (если есть)
      if (merchDescriptionController.text.trim().isNotEmpty ||
          merchPriceController.text.trim().isNotEmpty ||
          (currentState.merchImages.isNotEmpty)) {
        if (merchDescriptionController.text.trim().isEmpty) {
          errors['merch_description'] =
              LocaleKeys.kTextMerchDescriptionRequired.tr();
          isValid = false;
        } else {
          errors['merch_description'] = null;
        }

        if (merchPriceController.text.trim().isEmpty) {
          errors['merch_price'] = LocaleKeys.kTextMerchPriceRequired.tr();
          isValid = false;
        } else {
          final price = int.tryParse(merchPriceController.text);
          if (price == null || price < 0) {
            errors['merch_price'] = LocaleKeys.kTextMerchPricePositive.tr();
            isValid = false;
          } else {
            errors['merch_price'] = null;
          }
        }
      }

      // Валидация точек (должно быть хотя бы одна точка с заполненным описанием)
      bool hasValidPoints = false;
      for (int i = 0; i < pointControllers.length; i++) {
        if (pointControllers[i].text.trim().isNotEmpty) {
          hasValidPoints = true;
          break;
        }
      }

      if (!hasValidPoints) {
        errors['points'] = 'At least one point must have a description';
        isValid = false;
      } else {
        errors['points'] = null;
      }

      emit(currentState.copyWith(
        isFormValid: isValid,
        validationErrors: errors,
      ));
    }
  }

  /// Очистка ошибок валидации для поля
  void clearValidationError(String fieldName) {
    if (state is EditQuestScreenLoaded) {
      EditQuestScreenLoaded currentState = state as EditQuestScreenLoaded;
      final updatedErrors =
          Map<String, String?>.from(currentState.validationErrors);
      updatedErrors[fieldName] = null;

      emit(currentState.copyWith(validationErrors: updatedErrors));
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

  Future<void> createQuest() async {
    try {
      // Сначала валидируем форму
      validateForm();

      if (state is EditQuestScreenLoaded) {
        final currentState = state as EditQuestScreenLoaded;

        // Проверяем, что форма валидна
        if (!currentState.isFormValid) {
          emit(EditQuestScreenError(LocaleKeys.kTextPleaseFixFormErrors.tr()));
          return;
        }
      }

      emit(EditQuestScreenLoading());

      // Создаем модель для создания квеста
      final questCreateModel = QuestCreateModel(
        name: nameCategoryController.text.trim(),
        description: descriptionQuestController.text.trim(),
        image:
            'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', // Временное изображение
        credits: CreditsCreate(
          cost: int.tryParse(creditsPaysController.text) ?? 0,
          reward: int.tryParse(creditsAccrueController.text) ?? 0,
        ),
        mainPreferences: MainPreferencesCreate(
          types: [], // Пустой список для создания
          places: [], // Пустой список для создания
          vehicles: [], // Пустой список для создания
          tools: [], // Пустой список для создания
        ),
        points: [
          // Создаем точки на основе данных с формы
          for (int i = 0; i < pointControllers.length; i++)
            if (pointControllers[i].text.isNotEmpty)
              PointCreateItem(
                nameOfLocation:
                    pointControllers[i].text.trim(), // Данные с формы
                description:
                    "Начальная точка квеста", // Пока оставляем как есть
                order: i + 1, // Порядок из индекса
                type: PointTypeCreate(
                  typeId: 1, // Catch a ghost - дефолтный тип активности
                ),
                places: [
                  PlaceCreateItem(
                    longitude: 0.0, // Минимальное значение по схеме
                    latitude: 0.0, // Минимальное значение по схеме
                    detectionsRadius: 5.0, // Минимальное значение по схеме
                    height: 1.8, // Дефолтное значение по схеме
                    interactionInaccuracy: 5.0, // Минимальное значение по схеме
                    // Убираем необязательные поля
                  ),
                ],
                // toolId, file, isDivide имеют дефолтные значения в конструкторе
              ),
        ],
      );

      // Дополнительная проверка модели
      if (!questCreateModel.isValid) {
        final errors = questCreateModel.validationErrors.join(', ');
        emit(EditQuestScreenError('Validation failed: $errors'));
        return;
      }

      // Логируем данные для отладки
      print('🔍 DEBUG: QuestCreateModel data:');
      print('  - name: "${questCreateModel.name}"');
      print('  - description: "${questCreateModel.description}"');
      print('  - image: "${questCreateModel.image}"');
      // Убираем необязательные поля
      print('  - credits: ${questCreateModel.credits.toJson()}');
      print(
          '  - mainPreferences: ${questCreateModel.mainPreferences.toJson()}');
      print('  - points count: ${questCreateModel.points.length}');

      for (var i = 0; i < questCreateModel.points.length; i++) {
        final point = questCreateModel.points[i];
        print('  - Point $i:');
        print('    - nameOfLocation: "${point.nameOfLocation}"');
        print('    - description: "${point.description}"');
        print('    - order: ${point.order}');
        print('    - typeId: ${point.type.typeId}');
        print('    - places count: ${point.places.length}');
        // Убираем необязательные поля

        for (var j = 0; j < point.places.length; j++) {
          final place = point.places[j];
          print('    - Place $j:');
          print('      - longitude: ${place.longitude}');
          print('      - latitude: ${place.latitude}');
          print('      - detectionsRadius: ${place.detectionsRadius}');
          print('      - height: ${place.height}');
          print(
              '      - interactionInaccuracy: ${place.interactionInaccuracy}');
          // Убираем необязательные поля
        }
      }

      final result = await createQuestUC(questCreateModel);

      result.fold(
        (failure) {
          print('🔍 DEBUG: Quest creation failed: ${failure.toString()}');

          // Специальная обработка для ошибок авторизации
          String errorMessage;
          if (failure is UnauthorizedFailure) {
            errorMessage = 'Ошибка авторизации: необходимо войти в систему';
          } else if (failure is ServerFailure) {
            errorMessage = 'Ошибка сервера: попробуйте позже';
          } else {
            errorMessage = 'Ошибка создания квеста: ${failure.toString()}';
          }

          emit(EditQuestScreenError(errorMessage));
        },
        (_) {
          print('🔍 DEBUG: Quest created successfully');
          emit(EditQuestScreenLoaded(
            selectedIndexes: List.generate(5, (index) => [0]),
            pointsData: [],
            merchImages: [],
            creditsRadioIndex: 0,
            hasMentor: false,
          ));

          // Обновляем список квестов в основном экране
          if (_onQuestCreated != null) {
            print('🔍 DEBUG: Calling _onQuestCreated callback');
            _onQuestCreated!();
            print('🔍 DEBUG: _onQuestCreated callback executed');
          } else {
            print('🔍 DEBUG: _onQuestCreated callback is null!');
          }
        },
      );
    } catch (e) {
      emit(EditQuestScreenError('Неожиданная ошибка: $e'));
    }
  }

  Future<void> updateQuest() async {
    print('🚀 DEBUG: updateQuest() - НАЧАЛО ВЫПОЛНЕНИЯ');
    print('  - questId: $questId');
    print('  - nameCategoryController.text: "${nameCategoryController.text}"');
    print(
        '  - descriptionQuestController.text: "${descriptionQuestController.text}"');

    if (questId == null) {
      print('❌ DEBUG: updateQuest() - questId is null, выходим');
      emit(EditQuestScreenError('ID квеста не указан'));
      return;
    }

    try {
      emit(EditQuestScreenLoading());

      // Создаем список точек для обновления
      final List<PointUpdateItem> updatePoints = [];

      for (int i = 0; i < pointControllers.length; i++) {
        final controller = pointControllers[i];
        if (controller.text.isNotEmpty) {
          updatePoints.add(PointUpdateItem(
            nameOfLocation: controller.text,
            description: controller.text,
            order: i + 1,
            type: PointTypeUpdate(typeId: 1), // Дефолтный тип
            places: [
              PlaceUpdateItem(
                longitude: 0.0,
                latitude: 0.0,
                detectionsRadius: 5.0,
                height: 1.8,
                interactionInaccuracy: 5.0,
              ),
            ],
          ));
        }
      }

      // Получаем текущее состояние для доступа к selectedIndexes
      final currentState = state as EditQuestScreenLoaded;

      // Создаем модель для обновления квеста
      final questUpdateModel = QuestUpdateModel(
        id: questId,
        name: nameCategoryController.text.isNotEmpty
            ? nameCategoryController.text
            : null,
        description: descriptionQuestController.text.isNotEmpty
            ? descriptionQuestController.text
            : null,
        image: null, // Не обновляем изображение
        credits: CreditsUpdate(
          cost: int.tryParse(creditsPaysController.text) ?? 0,
          reward: int.tryParse(creditsAccrueController.text) ?? 0,
        ),
        mainPreferences: MainPreferencesUpdate(
          categoryId: currentState.selectedIndexes[0].isNotEmpty
              ? currentState.selectedIndexes[0][0] + 1
              : 1,
          vehicleId: currentState.selectedIndexes[1].isNotEmpty
              ? currentState.selectedIndexes[1][0] + 1
              : 1,
          placeId: currentState.selectedIndexes[6].isNotEmpty
              ? currentState.selectedIndexes[6][0] + 1
              : 1,
          group: _getGroupString(currentState.selectedIndexes[0].isNotEmpty
              ? currentState.selectedIndexes[0][0] + 1
              : 1),
          timeframe: _getTimeframeString(
              currentState.selectedIndexes[3].isNotEmpty
                  ? currentState.selectedIndexes[3][0] + 1
                  : 1),
          level: _getLevelString(currentState.selectedIndexes[4].isNotEmpty
              ? currentState.selectedIndexes[4][0] + 1
              : 1),
          mileage: _getMileageString(currentState.selectedIndexes[5].isNotEmpty
              ? currentState.selectedIndexes[5][0] + 1
              : 1),
        ),
        points: updatePoints,
        merch: merchDescriptionController.text.isNotEmpty
            ? [
                MerchUpdateItem(
                  description: merchDescriptionController.text,
                  price: int.tryParse(merchPriceController.text) ?? 0,
                ),
              ]
            : [],
        mentorPreference:
            currentState.hasMentor ? 'mentor_required' : 'no_mentor',
      );

      // Логируем данные для отправки на бэкенд
      print('🔍 DEBUG: updateQuest() - Отправляем на бэкенд:');
      print('  - questId: $questId');
      print('  - name: "${nameCategoryController.text}"');
      print('  - description: "${descriptionQuestController.text}"');
      print('  - points.length: ${updatePoints.length}');
      for (int i = 0; i < updatePoints.length; i++) {
        final point = updatePoints[i];
        print(
            '  - point[$i]: nameOfLocation="${point.nameOfLocation}", description="${point.description}"');
      }

      final result = await updateQuestUC(questUpdateModel);

      result.fold(
        (failure) {
          emit(EditQuestScreenError(
              'Ошибка обновления квеста: ${failure.toString()}'));
        },
        (_) {
          emit(EditQuestScreenLoaded(
            selectedIndexes: List.generate(5, (index) => [0]),
            pointsData: [],
            merchImages: [],
            creditsRadioIndex: 0,
            isFormValid: true,
            validationErrors: const {},
            hasMentor: false,
          ));

          // Показываем сообщение об успехе
          emit(EditQuestScreenSuccess('Квест успешно обновлен'));
        },
      );
    } catch (e) {
      emit(EditQuestScreenError('Неожиданная ошибка: $e'));
    }
  }

  Future<void> loadQuestData() async {
    print('🚨🚨🚨 loadQuestData() ВЫЗВАН! 🚨🚨🚨');
    print('🚨🚨🚨 questId = $questId 🚨🚨🚨');
    print('  - questId: $questId');

    if (questId == null) {
      print('❌ DEBUG: loadQuestData() - questId is null, выходим');
      return;
    }

    try {
      print('🔄 DEBUG: loadQuestData() - Отправляем EditQuestScreenLoading');
      emit(EditQuestScreenLoading());

      // Загружаем данные существующего квеста
      final quest = await getQuestUC(questId!);

      // Логируем данные квеста для отладки
      print('🔍 DEBUG: loadQuestData() - Данные квеста:');
      print('  - name: "${quest.name}"');
      print('  - shortDescription: "${quest.shortDescription}"');
      print('  - fullDescription: "${quest.fullDescription}"');
      print('  - points.length: ${quest.points.length}');
      print('  - merch.length: ${quest.merch.length}');
      print('  - mentorPreference: "${quest.mentorPreference}"');
      print(
          '  - merch details: ${quest.merch.map((m) => '${m.description}:${m.price}').toList()}');
      print('  - mentorPreference type: ${quest.mentorPreference.runtimeType}');
      print(
          '  - mentorPreference contains "mentor_required": ${quest.mentorPreference?.contains('mentor_required')}');
      for (int i = 0; i < quest.points.length; i++) {
        final point = quest.points[i];
        print(
            '  - point[$i]: name="${point.name}", description="${point.description}"');
      }

      // Заполняем поля формы существующими данными
      nameCategoryController.text = quest.name;

      // Заполняем поле description - используем shortDescription или fullDescription
      if (quest.shortDescription?.isNotEmpty == true) {
        descriptionQuestController.text = quest.shortDescription!;
      } else if (quest.fullDescription?.isNotEmpty == true) {
        descriptionQuestController.text = quest.fullDescription!;
      }

      // Создаем точки на основе существующих данных
      final List<QuestEditLocationItem> existingPoints = [];
      final List<TextEditingController> existingPointControllers = [];

      for (int i = 0; i < quest.points.length; i++) {
        final point = quest.points[i];
        String title;

        if (i == 0) {
          title = LocaleKeys.kTextStartPoint.tr();
        } else if (i == quest.points.length - 1) {
          title = LocaleKeys.kTextFinishPoint.tr();
        } else {
          title = '${LocaleKeys.kTextHalfwayPoint.tr()} ($i)';
        }

        existingPoints.add(QuestEditLocationItem(title));

        // Создаем контроллер для точки и заполняем его названием (name)
        final controller = TextEditingController(text: point.name);
        controller.addListener(_onTextChanged); // Добавляем слушатель
        existingPointControllers.add(controller);
      }

      // Если точек нет, создаем дефолтные
      if (existingPoints.isEmpty) {
        existingPoints.addAll([
          QuestEditLocationItem(LocaleKeys.kTextStartPoint.tr()),
          QuestEditLocationItem(LocaleKeys.kTextFinishPoint.tr()),
        ]);

        existingPointControllers.addAll([
          TextEditingController()..addListener(_onTextChanged),
          TextEditingController()..addListener(_onTextChanged),
        ]);
      }

      // Обновляем контроллеры точек
      pointControllers.clear();
      pointControllers.addAll(existingPointControllers);
      print('🔍 DEBUG: === КОНТРОЛЛЕРЫ ТОЧЕК ОБНОВЛЕНЫ ===');

      // Загружаем merchandise данные
      print('🔍 DEBUG: === НАЧАЛО ЗАГРУЗКИ MERCHANDISE ===');
      print('🔍 DEBUG: Загрузка merchandise данных...');
      print('  - quest.merch.length: ${quest.merch.length}');
      print('  - quest.merch: ${quest.merch}');
      print('  - quest.merch type: ${quest.merch.runtimeType}');

      if (quest.merch.isNotEmpty) {
        final firstMerch = quest.merch.first;
        print('  - firstMerch.description: "${firstMerch.description}"');
        print('  - firstMerch.price: ${firstMerch.price}');
        print('  - firstMerch.image: "${firstMerch.image}"');
        merchDescriptionController.text = firstMerch.description;
        merchPriceController.text = firstMerch.price.toString();
        print(
            '  - merchDescriptionController.text: "${merchDescriptionController.text}"');
        print('  - merchPriceController.text: "${merchPriceController.text}"');
        print('  - Контроллеры заполнены успешно');
      } else {
        print('  - Merchandise список пуст - контроллеры остаются пустыми');
        print(
            '  - merchDescriptionController.text: "${merchDescriptionController.text}"');
        print('  - merchPriceController.text: "${merchPriceController.text}"');
      }

      print('🔍 DEBUG: === ЗАВЕРШЕНИЕ ЗАГРУЗКИ MERCHANDISE ===');

      // Инициализируем основные параметры
      print('🔍 DEBUG: === НАЧАЛО ИНИЦИАЛИЗАЦИИ ОСНОВНЫХ ПАРАМЕТРОВ ===');
      await _initMainPrefs();
      print('🔍 DEBUG: === _initMainPrefs() ЗАВЕРШЕН ===');
      List<List<int>> selectedIndexes = await _initSelectedIndexes();
      print('🔍 DEBUG: === _initSelectedIndexes() ЗАВЕРШЕН ===');

      // Определяем hasMentor на основе mentor_preference из бэкенда
      print('🔍 DEBUG: === НАЧАЛО ЗАГРУЗКИ MENTOR PREFERENCES ===');
      print('🔍 DEBUG: Загрузка mentor preferences...');
      print('  - quest.mentorPreference: "${quest.mentorPreference}"');
      print(
          '  - quest.mentorPreference type: ${quest.mentorPreference.runtimeType}');

      // Проверяем, содержит ли mentor_preference 'mentor_required' (может быть URL)
      bool hasMentor = false;
      if (quest.mentorPreference != null &&
          quest.mentorPreference!.isNotEmpty) {
        hasMentor = quest.mentorPreference!.contains('mentor_required');
        print('  - mentorPreference не пустой, проверяем содержимое');
        print(
            '  - contains "mentor_required": ${quest.mentorPreference!.contains('mentor_required')}');
      } else {
        print('  - mentorPreference пустой или null');
      }
      print('  - hasMentor: $hasMentor');
      print('🔍 DEBUG: === ЗАВЕРШЕНИЕ ЗАГРУЗКИ MENTOR PREFERENCES ===');

      print('🔍 DEBUG: === НАЧАЛО СОЗДАНИЯ СОСТОЯНИЯ ===');
      emit(EditQuestScreenLoaded(
        selectedIndexes: selectedIndexes,
        pointsData: existingPoints,
        merchImages: const [],
        creditsRadioIndex: 0,
        isFormValid: true, // Форма валидна, так как данные загружены
        validationErrors: const {},
        hasMentor: hasMentor,
      ));
      print('🔍 DEBUG: === СОСТОЯНИЕ СОЗДАНО УСПЕШНО ===');

      // Валидируем форму после загрузки данных
      print('🔍 DEBUG: === НАЧАЛО ВАЛИДАЦИИ ФОРМЫ ===');
      validateForm();
      print('🔍 DEBUG: === ВАЛИДАЦИЯ ФОРМЫ ЗАВЕРШЕНА ===');
    } catch (e) {
      print('❌ ERROR: Ошибка загрузки данных квеста: $e');
      emit(EditQuestScreenError('Ошибка загрузки данных квеста: $e'));
    }
  }

  // Методы конвертации для enum'ов
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

  String _getTimeframeString(int timeframeId) {
    switch (timeframeId) {
      case 1:
        return '1-2 hours';
      case 2:
        return '2-4 hours';
      case 3:
        return '4+ hours';
      default:
        return '1-2 hours';
    }
  }

  String _getLevelString(int levelId) {
    switch (levelId) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  String _getMileageString(int mileageId) {
    switch (mileageId) {
      case 1:
        return '5-10';
      case 2:
        return '10-30';
      case 3:
        return '30-100';
      case 4:
        return '>100';
      default:
        return '5-10';
    }
  }

  // Установка наличия ментора
  void setHasMentor(bool hasMentor) {
    if (state is EditQuestScreenLoaded) {
      final currentState = state as EditQuestScreenLoaded;
      emit(currentState.copyWith(hasMentor: hasMentor));
    }
  }

  @override
  Future<void> close() {
    payExtraController.dispose();
    nameCategoryController.dispose();
    descriptionQuestController.dispose();
    mentorPreferenceController.dispose();

    for (TextEditingController controller in pointControllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    return super.close();
  }
}
