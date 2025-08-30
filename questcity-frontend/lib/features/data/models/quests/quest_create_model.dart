import 'package:equatable/equatable.dart';

class QuestCreateModel extends Equatable {
  final String name;
  final String description;
  final String image;
  final CreditsCreate credits;
  final MainPreferencesCreate mainPreferences;
  final List<PointCreateItem> points;
  // Убираем необязательные поля - они не критичны для создания

  const QuestCreateModel({
    required this.name,
    required this.description,
    required this.image,
    this.credits = const CreditsCreate(),
    this.mainPreferences = const MainPreferencesCreate(),
    this.points = const [],
    // Убираем необязательные параметры
  });

  factory QuestCreateModel.fromJson(Map<String, dynamic> json) =>
      QuestCreateModel(
        name: (json['name'] ?? '').toString().trim(),
        description: (json['description'] ?? '').toString().trim(),
        image: (json['image'] ?? '').toString().trim(),
        credits: CreditsCreate.fromJson(json['credits'] ?? {}),
        mainPreferences:
            MainPreferencesCreate.fromJson(json['mainPreferences'] ?? {}),
        points: (json['points'] as List?)
                ?.map((e) => PointCreateItem.fromJson(e))
                .toList() ??
            [],
        // Убираем необязательные поля
      );

  /// Проверяет, что все обязательные поля заполнены
  bool get isValid {
    return name.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        image.trim().isNotEmpty &&
        points.isNotEmpty; // Точки обязательны
  }

  /// Возвращает список ошибок валидации
  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('Name is required');
    if (description.trim().isEmpty) errors.add('Description is required');
    if (image.trim().isEmpty) errors.add('Image is required');
    if (points.isEmpty) errors.add('At least one point is required');
    return errors;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'image': image,
        'credits': credits.toJson(),
        'main_preferences': mainPreferences.toJson(),
        'points': points.map((e) => e.toJson()).toList(),
        // Убираем необязательные поля
      };

  @override
  List<Object?> get props => [
        name,
        description,
        image,
        credits,
        mainPreferences,
        points,
        // Убираем необязательные поля
      ];
}

class CreditsCreate extends Equatable {
  final int cost;
  final int reward;

  const CreditsCreate({
    this.cost = 0,
    this.reward = 0,
    // Убираем дефолтные значения - 0 по умолчанию
  });

  factory CreditsCreate.fromJson(Map<String, dynamic> json) => CreditsCreate(
        cost: json['cost'] ?? 0,
        reward: json['reward'] ?? 0,
        // Убираем дефолтные значения
      );

  Map<String, dynamic> toJson() => {
        'cost': cost,
        'reward': reward,
        // Упрощено: всегда передаем как есть
      };

  @override
  List<Object?> get props => [cost, reward];
}

class MainPreferencesCreate extends Equatable {
  final List<int> types;
  final List<int> places;
  final List<int> vehicles;
  final List<int> tools;

  const MainPreferencesCreate({
    this.types = const [],
    this.places = const [],
    this.vehicles = const [],
    this.tools = const [],
    // Убираем дефолтные значения - пустые списки по умолчанию
  });

  factory MainPreferencesCreate.fromJson(Map<String, dynamic> json) =>
      MainPreferencesCreate(
        types: (json['types'] as List?)?.cast<int>() ?? [],
        places: (json['places'] as List?)?.cast<int>() ?? [],
        vehicles: (json['vehicles'] as List?)?.cast<int>() ?? [],
        tools: (json['tools'] as List?)?.cast<int>() ?? [],
        // Убираем дефолтные значения
      );

  Map<String, dynamic> toJson() => {
        'types': types,
        'places': places,
        'vehicles': vehicles,
        'tools': tools,
        // Упрощено: всегда передаем как есть
      };

  @override
  List<Object?> get props => [types, places, vehicles, tools];
}

class PointCreateItem extends Equatable {
  final String nameOfLocation;
  final String description;
  final int order;
  final PointTypeCreate type;
  final List<PlaceCreateItem> places;
  // Убираем необязательные поля - они не критичны для создания

  const PointCreateItem({
    required this.nameOfLocation,
    required this.description,
    required this.order,
    required this.type,
    this.places = const [],
    // Убираем необязательные параметры
  });

  factory PointCreateItem.fromJson(Map<String, dynamic> json) =>
      PointCreateItem(
        nameOfLocation: (json['nameOfLocation'] ?? '').toString().trim(),
        description: (json['description'] ?? '').toString().trim(),
        order: json['order'] ?? 0,
        type: PointTypeCreate.fromJson(json['type'] ?? {}),
        places: (json['places'] as List?)
                ?.map((e) => PlaceCreateItem.fromJson(e))
                .toList() ??
            [],
        // Убираем необязательные поля
      );

  Map<String, dynamic> toJson() => {
        'name_of_location': nameOfLocation,
        'description': description,
        'order': order,
        'type': type.toJson(),
        'places': places.map((e) => e.toJson()).toList(),
        // Убираем необязательные поля
      };

  @override
  List<Object?> get props => [
        nameOfLocation,
        description,
        order,
        type,
        places,
        // Убираем необязательные поля
      ];
}

class PointTypeCreate extends Equatable {
  final int typeId;
  // Убираем необязательные поля - они не критичны для создания

  const PointTypeCreate({
    required this.typeId,
    // Убираем необязательные параметры
  });

  factory PointTypeCreate.fromJson(Map<String, dynamic> json) =>
      PointTypeCreate(
        typeId: json['typeId'] ?? json['type_id'] ?? 1,
        // Убираем необязательные поля
      );

  Map<String, dynamic> toJson() => {
        'type_id': typeId,
        // Убираем необязательные поля
      };

  @override
  List<Object?> get props => [
        typeId,
        // Убираем необязательные поля
      ];
}

class PlaceCreateItem extends Equatable {
  final double longitude;
  final double latitude;
  final double detectionsRadius;
  final double height;
  final double interactionInaccuracy;
  // Убираем part и random_occurrence - они не нужны для одного места

  const PlaceCreateItem({
    required this.longitude,
    required this.latitude,
    required this.detectionsRadius,
    required this.height,
    required this.interactionInaccuracy,
    // Убираем необязательные параметры
  });

  factory PlaceCreateItem.fromJson(Map<String, dynamic> json) =>
      PlaceCreateItem(
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        detectionsRadius: (json['detectionsRadius'] ?? 5.0).toDouble(),
        height: (json['height'] ?? 1.8).toDouble(),
        interactionInaccuracy:
            (json['interactionInaccuracy'] ?? 5.0).toDouble(),
        // Убираем необязательные поля
      );

  Map<String, dynamic> toJson() => {
        'longitude': longitude,
        'latitude': latitude,
        'detections_radius': detectionsRadius,
        'height': height,
        'interaction_inaccuracy': interactionInaccuracy,
        // Убираем необязательные поля
      };

  @override
  List<Object?> get props => [
        longitude,
        latitude,
        detectionsRadius,
        height,
        interactionInaccuracy,
        // Убираем необязательные поля
      ];
}
