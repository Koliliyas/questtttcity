import 'package:equatable/equatable.dart';

class CreditsUpdate extends Equatable {
  final bool auto;
  final int cost;
  final int reward;

  const CreditsUpdate({
    this.auto = false,
    this.cost = 0,
    this.reward = 0,
  });

  factory CreditsUpdate.fromJson(Map<String, dynamic> json) => CreditsUpdate(
        auto: json['auto'] ?? false,
        cost: json['cost'] ?? 0,
        reward: json['reward'] ?? 0,
      );

  Map<String, dynamic> toJson() {
    final result = {
      'auto': auto, // Используем реальное значение auto
      'cost': cost,
      'reward': reward,
    };
    print('🔍 DEBUG: CreditsUpdate.toJson() -> $result');
    return result;
  }

  @override
  List<Object?> get props => [auto, cost, reward];
}

class MainPreferencesUpdate extends Equatable {
  final int categoryId;
  final int vehicleId;
  final int placeId;
  final String group;
  final String timeframe;
  final String level;
  final String mileage;
  final List<int> types;
  final List<int> places;
  final List<int> vehicles;
  final List<int> tools;

  const MainPreferencesUpdate({
    this.categoryId = 1,
    this.vehicleId = 1,
    this.placeId = 1,
    this.group = 'Solo',
    this.timeframe = '1-2 hours',
    this.level = 'Easy',
    this.mileage = '5-10',
    this.types = const [],
    this.places = const [],
    this.vehicles = const [],
    this.tools = const [],
  });

  factory MainPreferencesUpdate.fromJson(Map<String, dynamic> json) =>
      MainPreferencesUpdate(
        categoryId: json['category_id'] ?? 1, // snake_case для бэкенда
        vehicleId: json['vehicle_id'] ?? 1, // snake_case для бэкенда
        placeId: json['place_id'] ?? 1, // snake_case для бэкенда
        group: json['group'] ?? 'Solo',
        timeframe: json['timeframe'] ?? '1-2 hours',
        level: json['level'] ?? 'Easy',
        mileage: json['mileage'] ?? '5-10',
        types: (json['types'] as List?)?.cast<int>() ?? [],
        places: (json['places'] as List?)?.cast<int>() ?? [],
        vehicles: (json['vehicles'] as List?)?.cast<int>() ?? [],
        tools: (json['tools'] as List?)?.cast<int>() ?? [],
      );

  Map<String, dynamic> toJson() {
    final result = {
      'category_id': categoryId, // snake_case для бэкенда
      'vehicle_id': vehicleId, // snake_case для бэкенда
      'place_id': placeId, // snake_case для бэкенда
      'group': _convertGroupToNumber(group), // Конвертируем в число
      'timeframe': _convertTimeframeToNumber(timeframe), // Конвертируем в число
      'level': level, // Отправляем строку как есть
      'mileage': mileage, // Отправляем строку как есть
      'types': types,
      'places': places,
      'vehicles': vehicles,
      'tools': tools,
    };
    print('🔍 DEBUG: MainPreferencesUpdate.toJson() -> $result');
    return result;
  }

  // Вспомогательные методы для конвертации
  int _convertGroupToNumber(String group) {
    switch (group) {
      case 'Solo':
        return 1; // ALONE
      case 'Duo':
        return 2; // TWO
      case 'Team':
        return 3; // THREE
      case 'Family':
        return 4; // FOUR
      default:
        return 1;
    }
  }

  int _convertTimeframeToNumber(String timeframe) {
    switch (timeframe) {
      case '1-2 hours':
        return 1;
      case '2-4 hours':
        return 2;
      case '4+ hours':
        return 3;
      default:
        return 1;
    }
  }

  int _convertLevelToNumber(String level) {
    switch (level) {
      case 'Easy':
        return 1;
      case 'Medium':
        return 2;
      case 'Hard':
        return 3;
      default:
        return 1;
    }
  }

  int _convertMileageToNumber(String mileage) {
    switch (mileage) {
      case '5-10':
        return 1;
      case '10-20':
        return 2;
      case '20+':
        return 3;
      default:
        return 1;
    }
  }

  @override
  List<Object?> get props => [
        categoryId,
        vehicleId,
        placeId,
        group,
        timeframe,
        level,
        mileage,
        types,
        places,
        vehicles,
        tools,
      ];
}

class QuestUpdateModel extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final CreditsUpdate credits;
  final MainPreferencesUpdate mainPreferences;
  final List<PointUpdateItem> points;
  final List<MerchUpdateItem> merch;
  final String? mentorPreference;

  const QuestUpdateModel({
    this.id,
    this.name,
    this.description,
    this.image,
    this.credits = const CreditsUpdate(),
    this.mainPreferences = const MainPreferencesUpdate(),
    this.points = const [],
    this.merch = const [],
    this.mentorPreference,
  });

  factory QuestUpdateModel.fromJson(Map<String, dynamic> json) =>
      QuestUpdateModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        image: json['image'],
        credits: CreditsUpdate.fromJson(json['credits'] ?? {}),
        mainPreferences: MainPreferencesUpdate.fromJson(
            json['main_preferences'] ?? {}), // snake_case для бэкенда
        points: (json['points'] as List?)
                ?.map((e) => PointUpdateItem.fromJson(e))
                .toList() ??
            [],
        merch: (json['merch'] as List?)
                ?.map((e) => MerchUpdateItem.fromJson(e))
                .toList() ??
            [],
        mentorPreference: json['mentor_preference'], // snake_case для бэкенда
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (image != null) data['image'] = image;
    data['credits'] = credits.toJson();
    data['main_preferences'] =
        mainPreferences.toJson(); // snake_case для бэкенда
    if (merch.isNotEmpty) data['merch'] = merch.map((e) => e.toJson()).toList();
    if (points.isNotEmpty)
      data['points'] = points.map((e) => e.toJson()).toList();
    if (mentorPreference != null)
      data['mentor_preference'] = mentorPreference; // snake_case для бэкенда

    print('🔍 DEBUG: QuestUpdateModel.toJson() -> $data');
    return data;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        credits,
        mainPreferences,
        points,
        merch,
        mentorPreference,
      ];
}

class PointUpdateItem extends Equatable {
  final int? id;
  final String nameOfLocation;
  final String description;
  final int order;
  final PointTypeUpdate type;
  final List<PlaceUpdateItem> places;
  final int? toolId;
  final String? file;
  final bool? isDivide;

  const PointUpdateItem({
    this.id,
    required this.nameOfLocation,
    required this.description,
    required this.order,
    required this.type,
    this.places = const [],
    this.toolId,
    this.file,
    this.isDivide,
  });

  factory PointUpdateItem.fromJson(Map<String, dynamic> json) =>
      PointUpdateItem(
        id: json['id'],
        nameOfLocation: json['name'] ?? '', // camelCase из бэкенда
        description: json['description'] ?? '',
        order: json['order'] ?? 0,
        type: PointTypeUpdate(
            typeId: json['typeId'] ?? 1), // camelCase из бэкенда
        places: (json['places'] as List?)
                ?.map((e) => PlaceUpdateItem.fromJson(e))
                .toList() ??
            [],
        toolId: json['toolId'], // camelCase из бэкенда
        file: json['file'],
        isDivide: json['is_divide'] ?? false, // snake_case для бэкенда
      );

  Map<String, dynamic> toJson() => {
        'id': id, // Отправляем реальный ID или null
        'name_of_location': nameOfLocation, // snake_case для бэкенда
        'description': description,
        'order': order,
        'type_id': type.typeId, // ТОЛЬКО type_id, убираем объект type
        'places': places.map((e) => e.toJson()).toList(),
        'tool_id': toolId, // Всегда отправляем tool_id (может быть null)
        'file': file,
        'is_divide': isDivide ?? false, // Если null, отправляем false
      };

  @override
  List<Object?> get props => [
        id,
        nameOfLocation,
        description,
        order,
        type,
        places,
        toolId,
        file,
        isDivide,
      ];
}

class PointTypeUpdate extends Equatable {
  final int typeId;
  final String? typePhoto;
  final String? typeCode;
  final String? typeWord;

  const PointTypeUpdate({
    required this.typeId,
    this.typePhoto,
    this.typeCode,
    this.typeWord,
  });

  factory PointTypeUpdate.fromJson(Map<String, dynamic> json) =>
      PointTypeUpdate(
        typeId: json['type_id'] ?? 0, // snake_case для бэкенда
        typePhoto: json['type_photo'], // snake_case для бэкенда
        typeCode: json['type_code'], // snake_case для бэкенда
        typeWord: json['type_word'], // snake_case для бэкенда
      );

  Map<String, dynamic> toJson() => {
        'type_id': typeId, // snake_case для бэкенда
        'type_photo': typePhoto, // snake_case для бэкенда
        'type_code': typeCode, // snake_case для бэкенда
        'type_word': typeWord, // snake_case для бэкенда
      };

  @override
  List<Object?> get props => [typeId, typePhoto, typeCode, typeWord];
}

class PlaceUpdateItem extends Equatable {
  final int? id;
  final double longitude;
  final double latitude;
  final double detectionsRadius;
  final double height;
  final double interactionInaccuracy;
  final int? part;
  final double? randomOccurrence;

  const PlaceUpdateItem({
    this.id,
    required this.longitude,
    required this.latitude,
    required this.detectionsRadius,
    required this.height,
    required this.interactionInaccuracy,
    this.part,
    this.randomOccurrence,
  });

  factory PlaceUpdateItem.fromJson(Map<String, dynamic> json) =>
      PlaceUpdateItem(
        id: json['id'],
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        detectionsRadius: (json['detections_radius'] ?? 0.0).toDouble(),
        height: (json['height'] ?? 0.0).toDouble(),
        interactionInaccuracy:
            (json['interaction_inaccuracy'] ?? 0.0).toDouble(),
        part: json['part'],
        randomOccurrence: (json['random_occurrence'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id, // Отправляем реальный ID или null
        'longitude': longitude,
        'latitude': latitude,
        'detections_radius': detectionsRadius,
        'height': height,
        'interaction_inaccuracy': interactionInaccuracy,
        'part': part, // Отправляем реальный part или null
        'random_occurrence': randomOccurrence,
      };

  @override
  List<Object?> get props => [
        id,
        longitude,
        latitude,
        detectionsRadius,
        height,
        interactionInaccuracy,
        part,
        randomOccurrence,
      ];
}

class MerchUpdateItem extends Equatable {
  final int? id;
  final String description;
  final int price;
  final String? image;

  const MerchUpdateItem({
    this.id,
    required this.description,
    required this.price,
    this.image,
  });

  factory MerchUpdateItem.fromJson(Map<String, dynamic> json) =>
      MerchUpdateItem(
        id: json['id'],
        description: json['description'] ?? '',
        price: json['price'] ?? 0,
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'price': price,
        'image': image,
      };

  @override
  List<Object?> get props => [id, description, price, image];
}
