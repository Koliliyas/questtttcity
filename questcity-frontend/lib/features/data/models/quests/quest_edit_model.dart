import 'package:equatable/equatable.dart';

/// Модель для редактирования квеста - точно соответствует QuestCreteSchema с бэкенда
class QuestEditModel extends Equatable {
  final String name;
  final String description;
  final String image;
  final CreditsEdit credits;
  final MainPreferencesEdit mainPreferences;
  final String mentorPreference;
  final List<PointEditItem> points;

  const QuestEditModel({
    required this.name,
    required this.description,
    required this.image,
    this.credits = const CreditsEdit(),
    this.mainPreferences = const MainPreferencesEdit(),
    this.mentorPreference = '',
    this.points = const [],
  });

  factory QuestEditModel.fromJson(Map<String, dynamic> json) => QuestEditModel(
        name: (json['name'] ?? '').toString().trim(),
        description: (json['description'] ?? '').toString().trim(),
        image: (json['image'] ?? '').toString().trim(),
        credits: CreditsEdit.fromJson(json['credits'] ?? {}),
        mainPreferences: MainPreferencesEdit.fromJson(json['main_preferences'] ?? {}),
        mentorPreference: (json['mentor_preference'] ?? '').toString().trim(),
        points: (json['points'] as List?)
                ?.map((e) => PointEditItem.fromJson(e))
                .toList() ??
            [],
      );

  /// Проверяет, что все обязательные поля заполнены
  bool get isValid {
    return name.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        image.trim().isNotEmpty;
  }

  /// Возвращает список ошибок валидации
  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('Name is required');
    if (description.trim().isEmpty) errors.add('Description is required');
    if (image.trim().isEmpty) errors.add('Image is required');
    return errors;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'image': image,
        'credits': credits.toJson(),
        'main_preferences': mainPreferences.toJson(),
        'mentor_preference': mentorPreference,
        'points': points.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        name,
        description,
        image,
        credits,
        mainPreferences,
        mentorPreference,
        points,
      ];

  /// Создает копию с обновленными полями
  QuestEditModel copyWith({
    String? name,
    String? description,
    String? image,
    CreditsEdit? credits,
    MainPreferencesEdit? mainPreferences,
    String? mentorPreference,
    List<PointEditItem>? points,
  }) {
    return QuestEditModel(
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      credits: credits ?? this.credits,
      mainPreferences: mainPreferences ?? this.mainPreferences,
      mentorPreference: mentorPreference ?? this.mentorPreference,
      points: points ?? this.points,
    );
  }
}

/// Кредиты для редактирования - соответствует Credits с бэкенда
class CreditsEdit extends Equatable {
  final int cost;
  final int reward;

  const CreditsEdit({
    this.cost = 0,
    this.reward = 0,
  });

  factory CreditsEdit.fromJson(Map<String, dynamic> json) => CreditsEdit(
        cost: json['cost'] ?? 0,
        reward: json['reward'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'cost': cost,
        'reward': reward,
      };

  @override
  List<Object?> get props => [cost, reward];

  CreditsEdit copyWith({
    int? cost,
    int? reward,
  }) {
    return CreditsEdit(
      cost: cost ?? this.cost,
      reward: reward ?? this.reward,
    );
  }
}

/// Основные предпочтения для редактирования - соответствует MainPreferences с бэкенда
class MainPreferencesEdit extends Equatable {
  final int categoryId;
  final int vehicleId;
  final int placeId;
  final int group;
  final int timeframe;
  final String level;
  final String mileage;

  const MainPreferencesEdit({
    this.categoryId = 1,
    this.vehicleId = 1,
    this.placeId = 1,
    this.group = 1,
    this.timeframe = 10,
    this.level = 'Easy',
    this.mileage = '5-10',
  });

  factory MainPreferencesEdit.fromJson(Map<String, dynamic> json) =>
      MainPreferencesEdit(
        categoryId: json['category_id'] ?? 1,
        vehicleId: json['vehicle_id'] ?? 1,
        placeId: json['place_id'] ?? 1,
        group: json['group'] ?? 1,
        timeframe: json['timeframe'] ?? 10,
        level: json['level'] ?? 'Easy',
        mileage: json['mileage'] ?? '5-10',
      );

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'vehicle_id': vehicleId,
        'place_id': placeId,
        'group': group,
        'timeframe': timeframe,
        'level': level,
        'mileage': mileage,
      };

  @override
  List<Object?> get props => [
        categoryId,
        vehicleId,
        placeId,
        group,
        timeframe,
        level,
        mileage,
      ];

  MainPreferencesEdit copyWith({
    int? categoryId,
    int? vehicleId,
    int? placeId,
    int? group,
    int? timeframe,
    String? level,
    String? mileage,
  }) {
    return MainPreferencesEdit(
      categoryId: categoryId ?? this.categoryId,
      vehicleId: vehicleId ?? this.vehicleId,
      placeId: placeId ?? this.placeId,
      group: group ?? this.group,
      timeframe: timeframe ?? this.timeframe,
      level: level ?? this.level,
      mileage: mileage ?? this.mileage,
    );
  }
}

/// Точка для редактирования - соответствует PointCreateSchema с бэкенда
class PointEditItem extends Equatable {
  final String nameOfLocation;
  final String description;
  final int order;
  final int typeId;
  final int? toolId;
  final List<PlaceEditItem> places;
  final String? file;
  final bool? isDivide;

  const PointEditItem({
    required this.nameOfLocation,
    required this.description,
    required this.order,
    required this.typeId,
    this.toolId,
    this.places = const [],
    this.file,
    this.isDivide,
  });

  factory PointEditItem.fromJson(Map<String, dynamic> json) => PointEditItem(
        nameOfLocation: (json['name_of_location'] ?? '').toString().trim(),
        description: (json['description'] ?? '').toString().trim(),
        order: json['order'] ?? 0,
        typeId: json['type_id'] ?? 1,
        toolId: json['tool_id'],
        places: (json['places'] as List?)
                ?.map((e) => PlaceEditItem.fromJson(e))
                .toList() ??
            [],
        file: json['file'],
        isDivide: json['is_divide'],
      );

  Map<String, dynamic> toJson() => {
        'name_of_location': nameOfLocation,
        'description': description,
        'order': order,
        'type_id': typeId,
        'tool_id': toolId,
        'places': places.map((e) => e.toJson()).toList(),
        'file': file,
        'is_divide': isDivide,
      };

  @override
  List<Object?> get props => [
        nameOfLocation,
        description,
        order,
        typeId,
        toolId,
        places,
        file,
        isDivide,
      ];

  PointEditItem copyWith({
    String? nameOfLocation,
    String? description,
    int? order,
    int? typeId,
    int? toolId,
    List<PlaceEditItem>? places,
    String? file,
    bool? isDivide,
  }) {
    return PointEditItem(
      nameOfLocation: nameOfLocation ?? this.nameOfLocation,
      description: description ?? this.description,
      order: order ?? this.order,
      typeId: typeId ?? this.typeId,
      toolId: toolId ?? this.toolId,
      places: places ?? this.places,
      file: file ?? this.file,
      isDivide: isDivide ?? this.isDivide,
    );
  }
}

/// Место для редактирования - соответствует PlaceSettings с бэкенда
class PlaceEditItem extends Equatable {
  final double longitude;
  final double latitude;
  final double detectionsRadius;
  final double height;
  final double interactionInaccuracy;
  final int? part;
  final double? randomOccurrence;

  const PlaceEditItem({
    required this.longitude,
    required this.latitude,
    required this.detectionsRadius,
    this.height = 1.8,
    required this.interactionInaccuracy,
    this.part,
    this.randomOccurrence,
  });

  factory PlaceEditItem.fromJson(Map<String, dynamic> json) => PlaceEditItem(
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        detectionsRadius: (json['detections_radius'] ?? 5.0).toDouble(),
        height: (json['height'] ?? 1.8).toDouble(),
        interactionInaccuracy:
            (json['interaction_inaccuracy'] ?? 5.0).toDouble(),
        part: json['part'],
        randomOccurrence: json['random_occurrence']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'longitude': longitude,
        'latitude': latitude,
        'detections_radius': detectionsRadius,
        'height': height,
        'interaction_inaccuracy': interactionInaccuracy,
        'part': part,
        'random_occurrence': randomOccurrence,
      };

  @override
  List<Object?> get props => [
        longitude,
        latitude,
        detectionsRadius,
        height,
        interactionInaccuracy,
        part,
        randomOccurrence,
      ];

  PlaceEditItem copyWith({
    double? longitude,
    double? latitude,
    double? detectionsRadius,
    double? height,
    double? interactionInaccuracy,
    int? part,
    double? randomOccurrence,
  }) {
    return PlaceEditItem(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      detectionsRadius: detectionsRadius ?? this.detectionsRadius,
      height: height ?? this.height,
      interactionInaccuracy: interactionInaccuracy ?? this.interactionInaccuracy,
      part: part ?? this.part,
      randomOccurrence: randomOccurrence ?? this.randomOccurrence,
    );
  }
}
