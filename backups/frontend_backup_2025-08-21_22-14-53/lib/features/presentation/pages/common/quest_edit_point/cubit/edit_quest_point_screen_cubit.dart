import 'package:bloc/bloc.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

part 'edit_quest_point_screen_state.dart';

class EditQuestPointScreenCubit extends Cubit<EditQuestPointScreenState> {
  EditQuestPointScreenCubit({required this.pointIndex, PointEditData? editData})
      : super(EditQuestPointScreenInitial()) {
    _initializeData();
    if (editData != null) {
      _initializeFromEditData(editData);
    }
  }

  final int pointIndex;
  int radiusOrRandomOccurrenceValue = 0;

  List<String> chipNames = [
    LocaleKeys.kTextType.tr(),
    LocaleKeys.kTextTools.tr(),
    LocaleKeys.kTextPlace.tr(),
    LocaleKeys.kTextFiles.tr()
  ];
  List<String> partPlaceChipNames = [
    '${LocaleKeys.kTextPart.tr()}1',
    '${LocaleKeys.kTextPart.tr()}2',
    '${LocaleKeys.kTextPart.tr()}3'
  ];
  int selectedPartPlace = 0;
  TypeChip typeChip = TypeChip.Type;
  TypeArtefact typeArtefact = TypeArtefact.GHOST;

  List<List<int>> selectedTypeIndexes = [
    [0, 0]
  ];

  List<List<int>> selectedToolsIndexes = [
    [0]
  ];

  List<List<int>> selectedFilesIndexes = [
    [0, 0]
  ];

  late List<QuestPreference> typeData;
  late List<QuestPreference> toolsData;
  late List<QuestPreference> filesData;

  TextEditingController coordinate1Controller = TextEditingController();
  TextEditingController coordinate2Controller = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController wordController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  FocusNode searchFocusNode = FocusNode();
  bool isFirstCoordinatePasting = true;
  XFile? photoImage;
  int ghostFiles = 0;
  int downloadFilesCount = 0;

  // РёРЅРёС†РёР°Р»РёР·РёСЂСѓРµРј РґР°РЅРЅС‹Рµ
  void _initializeData() {
    typeData = [
      QuestPreference(
        title: LocaleKeys.kTextActivityType.tr(),
        [
          QuestPreferenceItem(LocaleKeys.kTextCatchGhost.tr()),
          QuestPreferenceItem(
            LocaleKeys.kTextTakePhoto.tr(),
            subitems: QuestPreferenceSubItem([
              LocaleKeys.kTextFaceVerification.tr(),
              LocaleKeys.kTextPhotoDirectionCheck.tr(),
              LocaleKeys.kTextPhotoMatching.tr()
            ], isHorizontalDirection: false, isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(LocaleKeys.kTextDownloadFile.tr()),
          QuestPreferenceItem(LocaleKeys.kTextScanQRCode.tr()),
          QuestPreferenceItem(
            LocaleKeys.kTextEnterCode.tr(),
            textFieldEntry: QuestPreferenceItemTextField('Code', codeController,
                keyboardType: TextInputType.number,
                validator: Utils.validate,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp(r'\s'),
                  ),
                  FilteringTextInputFormatter.digitsOnly
                ],
                isVisibleTextFieldWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextEnterWord.tr(),
            textFieldEntry: QuestPreferenceItemTextField(
                LocaleKeys.kTextWord.tr(), wordController,
                validator: Utils.validate,
                isVisibleTextFieldWhenCheckedParent: true),
          ),
          QuestPreferenceItem(LocaleKeys.kTextPickArtifact.tr()),
        ],
      )
    ];

    toolsData = [
      QuestPreference(
        title: LocaleKeys.kTextToolType.tr(),
        [
          QuestPreferenceItem(LocaleKeys.kTextNone.tr()),
          QuestPreferenceItem(
              LocaleKeys.kTextScreenIllustrationDescriptor.tr()),
          QuestPreferenceItem(LocaleKeys.kTextBeepingRadar.tr()),
          QuestPreferenceItem(LocaleKeys.kTextOrbitalRadar.tr()),
          QuestPreferenceItem(LocaleKeys.kTextMileOrbitalRadar.tr()),
          QuestPreferenceItem(LocaleKeys.kTextUnlimOrbitalRadar.tr()),
          QuestPreferenceItem(LocaleKeys.kTextTargetCompass.tr()),
          QuestPreferenceItem(LocaleKeys.kTextRangefinder.tr()),
          QuestPreferenceItem(LocaleKeys.kTextRangefinderUnlim.tr()),
          QuestPreferenceItem(LocaleKeys.kTextEcholocationScreen.tr()),
          QuestPreferenceItem(LocaleKeys.kTextQRScanner.tr()),
          QuestPreferenceItem(LocaleKeys.kTextCameraTool.tr()),
          QuestPreferenceItem(LocaleKeys.kTextWordLocker.tr()),
        ],
      ),
    ];

    filesData = [
      QuestPreference(
        [
          QuestPreferenceItem(
            LocaleKeys.kTextScreenIllustrationDescriptor.tr(),
            image: Paths.artifactBinoculusIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextBeepingRadar.tr(),
            image: Paths.artifactBeepingRadarIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextOrbitalRadar.tr(),
            image: Paths.artifactOrbitalRadarIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextMileOrbitalRadar.tr(),
            image: Paths.artifactMileOrbitalRadarIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextUnlimOrbitalRadar.tr(),
            image: Paths.artifactUnlimOrbitalRadarIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextTargetCompass.tr(),
            image: Paths.artifactCompassIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextRangefinder.tr(),
            image: Paths.artifactRangefinderIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextRangefinderUnlim.tr(),
            image: Paths.artifactRangefinderIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextEcholocationScreen.tr(),
            image: Paths.artifactEcholocationScreenIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextQRScanner.tr(),
            image: Paths.artifactQrScannerIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextCameraTool.tr(),
            image: Paths.artifactCameraIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextWordLocker.tr(),
            image: Paths.artifactWordLockerIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextCombinationLocker.tr(),
            image: Paths.artifactCombinationLockerIconI,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextDownloader.tr(),
            image: Paths.artifactDownloaderIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
          QuestPreferenceItem(
            LocaleKeys.kTextQuestMap.tr(),
            image: Paths.artifactQuestMapIcon,
            subitems: QuestPreferenceSubItem(
                [LocaleKeys.kTextWhole.tr(), LocaleKeys.kTextInParts.tr()],
                isVisibleWhenCheckedParent: true),
          ),
        ],
      ),
    ];
  }

  onTapChip(int index) {
    if (chipNames[index] == LocaleKeys.kTextType.tr()) {
      typeChip = TypeChip.Type;
    } else if (chipNames[index] == LocaleKeys.kTextTools.tr()) {
      typeChip = TypeChip.Tools;
    } else if (chipNames[index] == LocaleKeys.kTextPlace.tr()) {
      typeChip = TypeChip.Place;
    } else {
      typeChip = TypeChip.Files;
    }

    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  // РјРµС‚РѕРґ РґР»СЏ РѕР±РЅРѕРІР»РµРЅРёСЏ РЅР°СЃС‚СЂРѕРµРє РєРІРµСЃС‚Р°
  onChangePreferences(List<List<int>> selectedIndexes, int preferencesIndex,
      int preferencesItemIndex,
      {int? preferencesSubItemIndex, bool preferencesItemHasSubitems = false}) {
    // РµСЃР»Рё РЅР°Р¶Р°Р»Рё РЅР° Р°РєС‚РёРІРЅС‹Р№ СЌР»РµРјРµРЅС‚ (РІСЃРµРіРґР° РґРѕР»Р¶РµРЅ Р±С‹С‚СЊ С…РѕС‚СЊ 1 Р°РєС‚РёРІРЅС‹Р№)
    if (preferencesItemIndex == -1 || preferencesSubItemIndex == -1) return;

    var preferencesItem = selectedIndexes[preferencesIndex];
    // РµСЃР»Рё РЅР°Р№СЃС‚СЂРѕР№РєР° РёРјРµРµС‚ РїРѕРґРЅР°СЃС‚СЂРѕР№РєРё
    if (preferencesItem.length > 1) {
      // Р·РґРµСЃСЊ РјС‹ СЂР°Р·Р»РёС‡Р°РµРј РЅР°Р¶Р°С‚РёРµ РїРѕ РЅР°СЃС‚СЂРѕР№РєРµ Рё РїРѕРґРЅР°СЃС‚СЂРѕР№РєРµ
      if (preferencesItemHasSubitems) {
        // РµСЃР»Рё РєР»РёРєРЅСѓР»Рё РїРѕ РЅР°СЃС‚СЂРѕР№РєРµ, РіРґРµ РµСЃС‚СЊ РїРѕРґРЅР°СЃС‚СЂРѕР№РєРё, С‚Рѕ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё Р°РєС‚РёРІРёСЂСѓРµС‚СЃСЏ 1 РїРѕРґРЅР°СЃС‚СЂРѕР№РєР°
        preferencesItem = [preferencesItemIndex, 0];
      } else {
        // РЅР°Р¶Р°С‚РёРµ РїРѕ РїРѕРґРЅР°СЃС‚СЂРѕР№РєРµ
        preferencesItem = [preferencesItemIndex, preferencesSubItemIndex ?? 0];
      }
    } else {
      // РЅР°Р¶Р°С‚РёРµ РЅР° РЅР°СЃС‚СЂРѕР№РєСѓ, РіРґРµ РЅРµС‚ РїРѕРґРЅР°СЃС‚СЂРѕРµРє
      preferencesItem = [preferencesItemIndex];
    }

    selectedIndexes[preferencesIndex] = preferencesItem;

    if (typeChip == TypeChip.Type) {
      switch (preferencesItem.isNotEmpty ? preferencesItem.first : 0) {
        // Catch a ghost
        case 0:
          typeArtefact = TypeArtefact.GHOST;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextTools.tr(),
            LocaleKeys.kTextPlace.tr(),
            LocaleKeys.kTextFiles.tr()
          ];
          break;
        // Take a photo
        case 1:
          typeArtefact = TypeArtefact.PHOTO;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextPlace.tr(),
            LocaleKeys.kTextFiles.tr()
          ];
          break;
        // Download the file
        case 2:
          typeArtefact = TypeArtefact.DOWNLOAD_FILE;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextTools.tr(),
            LocaleKeys.kTextPlace.tr(),
            LocaleKeys.kTextFiles.tr()
          ];
          break;
        // Scan Qr-code
        case 3:
          typeArtefact = TypeArtefact.QR;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextTools.tr(),
            LocaleKeys.kTextPlace.tr(),
            LocaleKeys.kTextFiles.tr()
          ];
          break;
        // Enter the code
        case 4:
          typeArtefact = TypeArtefact.CODE;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextTools.tr(),
            LocaleKeys.kTextPlace.tr()
          ];
          break;
        // Enter the word
        case 5:
          typeArtefact = TypeArtefact.WORD;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextTools.tr(),
            LocaleKeys.kTextPlace.tr()
          ];
          break;
        // Pick up an artifact
        case 6:
          typeArtefact = TypeArtefact.ARTIFACTS;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextFiles.tr(),
            LocaleKeys.kTextPlace.tr(),
            LocaleKeys.kTextTools.tr()
          ];
          break;
        default:
          typeArtefact = TypeArtefact.GHOST;
          chipNames = [
            LocaleKeys.kTextType.tr(),
            LocaleKeys.kTextTools.tr(),
            LocaleKeys.kTextPlace.tr(),
            LocaleKeys.kTextFiles.tr()
          ];
          break;
      }
    }

    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  onTapCoordinateField(bool isFirstCoordinate) {
    searchFocusNode.requestFocus();
    isFirstCoordinatePasting = isFirstCoordinate;
  }

  onChangeCoordinateField(String text) {
    isFirstCoordinatePasting
        ? coordinate1Controller.text = text
        : coordinate2Controller.text = text;
    searchController.clear();
  }

  onChangeRadiusOrRandomOccurrenceValue(int index) {
    if (index == -1) return;

    radiusOrRandomOccurrenceValue = index;
    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  onChangePhotoFile(XFile photoImage) {
    this.photoImage = photoImage;

    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  onChangeGhostFiles(bool isAddFile) {
    if (ghostFiles == 0 && !isAddFile) return;

    isAddFile ? ghostFiles += 1 : ghostFiles -= 1;

    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  onChangeDownloadFile(bool isAddFile) {
    if (downloadFilesCount == 0 && !isAddFile) return;
    isAddFile ? downloadFilesCount += 1 : downloadFilesCount -= 1;

    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  // Метод для инициализации данных из PointEditData
  void _initializeFromEditData(PointEditData editData) {
    print(
        '🔍 DEBUG: _initializeFromEditData - Инициализируем данные из editData');
    print('  - typeId: ${editData.typeId}');
    print('  - toolId: ${editData.toolId}');

    // Инициализируем type
    if (editData.typeId != null) {
      print('  - Инициализируем type с typeId: ${editData.typeId}');
      _initializeTypeFromId(editData.typeId!);
      print(
          '  - После инициализации type: typeArtefact=$typeArtefact, selectedTypeIndexes=$selectedTypeIndexes');
    }

    // Инициализируем tool
    if (editData.toolId != null) {
      print('  - Инициализируем tool с toolId: ${editData.toolId}');
      _initializeToolFromId(editData.toolId!);
      print(
          '  - После инициализации tool: selectedToolsIndexes=$selectedToolsIndexes');
    }

    // Инициализируем другие поля если нужно
    if (editData.typeCode != null) {
      codeController.text = editData.typeCode.toString();
    }
    if (editData.typeWord != null) {
      wordController.text = editData.typeWord!;
    }

    print('  - Инициализация завершена');
  }

  // Инициализация типа активности по ID
  void _initializeTypeFromId(int typeId) {
    print('🔍 DEBUG: _initializeTypeFromId - typeId: $typeId');

    // Маппинг ID на TypeArtefact
    switch (typeId) {
      case 1:
        typeArtefact = TypeArtefact.GHOST;
        selectedTypeIndexes = [
          [0, 0]
        ];
        print(
            '  - Установлен GHOST, selectedTypeIndexes: $selectedTypeIndexes');
        break;
      case 2:
        typeArtefact = TypeArtefact.PHOTO;
        selectedTypeIndexes = [
          [1, 0]
        ];
        print(
            '  - Установлен PHOTO, selectedTypeIndexes: $selectedTypeIndexes');
        break;
      case 3:
        typeArtefact = TypeArtefact.DOWNLOAD_FILE;
        selectedTypeIndexes = [
          [2, 0]
        ];
        print(
            '  - Установлен DOWNLOAD_FILE, selectedTypeIndexes: $selectedTypeIndexes');
        break;
      case 4:
        typeArtefact = TypeArtefact.QR;
        selectedTypeIndexes = [
          [3, 0]
        ];
        print('  - Установлен QR, selectedTypeIndexes: $selectedTypeIndexes');
        break;
      case 5:
        typeArtefact = TypeArtefact.CODE;
        selectedTypeIndexes = [
          [4, 0]
        ];
        print('  - Установлен CODE, selectedTypeIndexes: $selectedTypeIndexes');
        break;
      case 6:
        typeArtefact = TypeArtefact.WORD;
        selectedTypeIndexes = [
          [5, 0]
        ];
        print('  - Установлен WORD, selectedTypeIndexes: $selectedTypeIndexes');
        break;
      case 7:
        typeArtefact = TypeArtefact.ARTIFACTS;
        selectedTypeIndexes = [
          [6, 0]
        ];
        print(
            '  - Установлен ARTIFACTS, selectedTypeIndexes: $selectedTypeIndexes');
        break;
      default:
        typeArtefact = TypeArtefact.GHOST;
        selectedTypeIndexes = [
          [0, 0]
        ];
        print(
            '  - Установлен GHOST (default), selectedTypeIndexes: $selectedTypeIndexes');
    }

    // Обновляем chipNames в зависимости от типа
    _updateChipNames();
    print(
        '  - После _updateChipNames: typeArtefact=$typeArtefact, selectedTypeIndexes=$selectedTypeIndexes');

    // Обновляем UI после изменения состояния
    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  // Инициализация инструмента по ID
  void _initializeToolFromId(int toolId) {
    print('🔍 DEBUG: _initializeToolFromId - toolId: $toolId');

    // Маппинг ID на индекс (ID начинаются с 1, индексы с 0)
    int toolIndex = toolId - 1;
    if (toolIndex >= 0 && toolIndex < toolsData[0].items.length) {
      selectedToolsIndexes = [
        [toolIndex]
      ];
      print('  - Установлен selectedToolsIndexes: $selectedToolsIndexes');
    } else {
      print('  - Индекс инструмента вне диапазона: $toolIndex');
      selectedToolsIndexes = [
        [0]
      ];
    }

    // Обновляем UI после изменения состояния
    emit(EditQuestPointScreenUpdating());
    emit(EditQuestPointScreenInitial());
  }

  // Обновление chipNames в зависимости от типа активности
  void _updateChipNames() {
    switch (typeArtefact) {
      case TypeArtefact.GHOST:
        chipNames = [
          LocaleKeys.kTextType.tr(),
          LocaleKeys.kTextTools.tr(),
          LocaleKeys.kTextPlace.tr(),
          LocaleKeys.kTextFiles.tr()
        ];
        break;
      case TypeArtefact.PHOTO:
        chipNames = [
          LocaleKeys.kTextType.tr(),
          LocaleKeys.kTextPlace.tr(),
          LocaleKeys.kTextFiles.tr()
        ];
        break;
      case TypeArtefact.DOWNLOAD_FILE:
        chipNames = [
          LocaleKeys.kTextType.tr(),
          LocaleKeys.kTextTools.tr(),
          LocaleKeys.kTextPlace.tr(),
          LocaleKeys.kTextFiles.tr()
        ];
        break;
      case TypeArtefact.QR:
        chipNames = [
          LocaleKeys.kTextType.tr(),
          LocaleKeys.kTextTools.tr(),
          LocaleKeys.kTextPlace.tr(),
          LocaleKeys.kTextFiles.tr()
        ];
        break;
      case TypeArtefact.CODE:
        chipNames = [
          LocaleKeys.kTextType.tr(),
          LocaleKeys.kTextTools.tr(),
          LocaleKeys.kTextPlace.tr()
        ];
        break;
      case TypeArtefact.WORD:
        chipNames = [
          LocaleKeys.kTextType.tr(),
          LocaleKeys.kTextTools.tr(),
          LocaleKeys.kTextPlace.tr()
        ];
        break;
      case TypeArtefact.ARTIFACTS:
        chipNames = [
          LocaleKeys.kTextType.tr(),
          LocaleKeys.kTextTools.tr(),
          LocaleKeys.kTextPlace.tr(),
          LocaleKeys.kTextFiles.tr()
        ];
        break;
    }
  }

  // Метод для сохранения данных точки
  PointEditData savePointData() {
    // Получаем ID типа активности на основе выбранного типа
    int? typeId = _getSelectedTypeId();

    // Получаем ID инструмента на основе выбранного инструмента
    int? toolId = _getSelectedToolId();

    // Получаем данные мест
    List<PlaceData>? places = _getPlacesData();

    // Получаем данные файла
    String? file = _getFileData();

    // Получаем дополнительные данные типа
    String? typePhoto = _getTypePhoto();
    int? typeCode = _getTypeCode();
    String? typeWord = _getTypeWord();
    bool? isDivide = _getIsDivide();

    return PointEditData(
      pointIndex: pointIndex,
      typeId: typeId,
      toolId: toolId,
      places: places,
      file: file,
      typePhoto: typePhoto,
      typeCode: typeCode,
      typeWord: typeWord,
      isDivide: isDivide,
    );
  }

  // Вспомогательные методы для получения данных
  int? _getSelectedTypeId() {
    // Маппинг типов активности на ID
    switch (typeArtefact) {
      case TypeArtefact.GHOST:
        return 1; // Catch a ghost
      case TypeArtefact.PHOTO:
        return 2; // Take a photo
      case TypeArtefact.DOWNLOAD_FILE:
        return 3; // Download file
      case TypeArtefact.QR:
        return 4; // Scan QR code
      case TypeArtefact.CODE:
        return 5; // Enter code
      case TypeArtefact.WORD:
        return 6; // Enter word
      case TypeArtefact.ARTIFACTS:
        return 7; // Pick artifact
      default:
        return 1;
    }
  }

  int? _getSelectedToolId() {
    if (selectedToolsIndexes.isEmpty || selectedToolsIndexes[0].isEmpty) {
      return null;
    }
    // Маппинг инструментов на ID в соответствии с бэкендом
    int selectedIndex = selectedToolsIndexes[0][0];
    // Индексы начинаются с 0, но ID в БД начинаются с 1
    return selectedIndex + 1;
  }

  List<PlaceData>? _getPlacesData() {
    if (coordinate1Controller.text.isEmpty ||
        coordinate2Controller.text.isEmpty) {
      return null;
    }

    try {
      double longitude = double.parse(coordinate1Controller.text);
      double latitude = double.parse(coordinate2Controller.text);

      return [
        PlaceData(
          longitude: longitude,
          latitude: latitude,
          detectionsRadius: 5.0, // Дефолтное значение
          height: 1.8, // Дефолтное значение
          interactionInaccuracy: 5.0, // Дефолтное значение
          randomOccurrence:
              radiusOrRandomOccurrenceValue == 0, // Yes = 0, No = 1
          randomOccurrenceRadius:
              radiusOrRandomOccurrenceValue == 0 ? 5.0 : null,
        ),
      ];
    } catch (e) {
      return null;
    }
  }

  String? _getFileData() {
    if (photoImage != null) {
      return photoImage!.path;
    }
    if (ghostFiles > 0) {
      return "ghost_files_$ghostFiles";
    }
    if (downloadFilesCount > 0) {
      return "download_files_$downloadFilesCount";
    }
    return null;
  }

  String? _getTypePhoto() {
    if (typeArtefact == TypeArtefact.PHOTO) {
      // Возвращаем тип фото на основе выбранных подтипов
      if (selectedTypeIndexes.isNotEmpty && selectedTypeIndexes[0].length > 1) {
        switch (selectedTypeIndexes[0][1]) {
          case 0:
            return "FACE_VERIFICATION";
          case 1:
            return "DIRECTION_CHECK";
          case 2:
            return "MATCHING";
          default:
            return null;
        }
      }
    }
    return null;
  }

  int? _getTypeCode() {
    if (typeArtefact == TypeArtefact.CODE && codeController.text.isNotEmpty) {
      return int.tryParse(codeController.text);
    }
    return null;
  }

  String? _getTypeWord() {
    if (typeArtefact == TypeArtefact.WORD && wordController.text.isNotEmpty) {
      return wordController.text;
    }
    return null;
  }

  bool? _getIsDivide() {
    // Определяем, нужно ли разделение артефакта
    // Это зависит от количества мест и наличия файла
    if (_getPlacesData() != null && _getPlacesData()!.length > 1) {
      return true;
    }
    return false;
  }

  @override
  Future<void> close() {
    codeController.dispose();
    wordController.dispose();
    return super.close();
  }
}

enum TypeChip { Type, Tools, Place, Files }

enum TypeArtefact { GHOST, PHOTO, DOWNLOAD_FILE, QR, CODE, WORD, ARTIFACTS }
