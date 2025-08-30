import 'package:equatable/equatable.dart';

/// Модель для получения деталей квеста - соответствует QuestReadSchema с бэкенда
class QuestDetailModel extends Equatable {
  final int id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final String imageUrl;
  final int categoryId;
  final String? categoryTitle;
  final String? categoryImageUrl;
  final String difficulty;
  final double price;
  final String duration;
  final int playerLimit;
  final int ageLimit;
  final bool isForAdvUsers;
  final String type;
  final CreditsDetail? credits;
  final String? mentorPreference;
  final List<MerchDetailModel> merchList;
  final MainPreferencesDetail? mainPreferences;
  final List<PointDetailModel> points;
  final PlaceSettingsDetail? placeSettings;
  final PriceSettingsDetail? priceSettings;

  const QuestDetailModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.imageUrl,
    required this.categoryId,
    this.categoryTitle,
    this.categoryImageUrl,
    required this.difficulty,
    required this.price,
    required this.duration,
    this.playerLimit = 0,
    this.ageLimit = 0,
    this.isForAdvUsers = false,
    required this.type,
    this.credits,
    this.mentorPreference,
    this.merchList = const [],
    this.mainPreferences,
    this.points = const [],
    this.placeSettings,
    this.priceSettings,
  });

  factory QuestDetailModel.fromJson(Map<String, dynamic> json) =>
      QuestDetailModel(
        id: json['id'] ?? 0,
        title: (json['title'] ?? '').toString().trim(),
        shortDescription: (json['shortDescription'] ?? '').toString().trim(),
        fullDescription: (json['fullDescription'] ?? '').toString().trim(),
        imageUrl: (json['imageUrl'] ?? '').toString().trim(),
        categoryId: json['categoryId'] ?? 1,
        categoryTitle: json['categoryTitle'],
        categoryImageUrl: json['categoryImageUrl'],
        difficulty: (json['difficulty'] ?? 'Easy').toString(),
        price: (json['price'] ?? 0.0).toDouble(),
        duration: (json['duration'] ?? '1-2 hours').toString(),
        playerLimit: json['playerLimit'] ?? 0,
        ageLimit: json['ageLimit'] ?? 0,
        isForAdvUsers: json['isForAdvUsers'] ?? false,
        type: (json['type'] ?? 'Solo').toString(),
        credits: json['credits'] != null
            ? CreditsDetail.fromJson(json['credits'])
            : null,
        mentorPreference: json['mentorPreference'],
        merchList: (json['merchList'] as List?)
                ?.map((e) => MerchDetailModel.fromJson(e))
                .toList() ??
            [],
        mainPreferences: json['mainPreferences'] != null
            ? MainPreferencesDetail.fromJson(json['mainPreferences'])
            : null,
        points: (json['points'] as List?)
                ?.map((e) => PointDetailModel.fromJson(e))
                .toList() ??
            [],
        placeSettings: json['placeSettings'] != null
            ? PlaceSettingsDetail.fromJson(json['placeSettings'])
            : null,
        priceSettings: json['priceSettings'] != null
            ? PriceSettingsDetail.fromJson(json['priceSettings'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'shortDescription': shortDescription,
        'fullDescription': fullDescription,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'categoryTitle': categoryTitle,
        'categoryImageUrl': categoryImageUrl,
        'difficulty': difficulty,
        'price': price,
        'duration': duration,
        'playerLimit': playerLimit,
        'ageLimit': ageLimit,
        'isForAdvUsers': isForAdvUsers,
        'type': type,
        'credits': credits?.toJson(),
        'merchList': merchList.map((e) => e.toJson()).toList(),
        'mainPreferences': mainPreferences?.toJson(),
        'points': points.map((e) => e.toJson()).toList(),
        'placeSettings': placeSettings?.toJson(),
        'priceSettings': priceSettings?.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        title,
        shortDescription,
        fullDescription,
        imageUrl,
        categoryId,
        categoryTitle,
        categoryImageUrl,
        difficulty,
        price,
        duration,
        playerLimit,
        ageLimit,
        isForAdvUsers,
        type,
        credits,
        merchList,
        mainPreferences,
        points,
        placeSettings,
        priceSettings,
      ];

  /// Создает копию с обновленными полями
  QuestDetailModel copyWith({
    int? id,
    String? title,
    String? shortDescription,
    String? fullDescription,
    String? imageUrl,
    int? categoryId,
    String? categoryTitle,
    String? categoryImageUrl,
    String? difficulty,
    double? price,
    String? duration,
    int? playerLimit,
    int? ageLimit,
    bool? isForAdvUsers,
    String? type,
    CreditsDetail? credits,
    List<MerchDetailModel>? merchList,
    MainPreferencesDetail? mainPreferences,
    List<PointDetailModel>? points,
    PlaceSettingsDetail? placeSettings,
    PriceSettingsDetail? priceSettings,
  }) {
    return QuestDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categoryImageUrl: categoryImageUrl ?? this.categoryImageUrl,
      difficulty: difficulty ?? this.difficulty,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      playerLimit: playerLimit ?? this.playerLimit,
      ageLimit: ageLimit ?? this.ageLimit,
      isForAdvUsers: isForAdvUsers ?? this.isForAdvUsers,
      type: type ?? this.type,
      credits: credits ?? this.credits,
      merchList: merchList ?? this.merchList,
      mainPreferences: mainPreferences ?? this.mainPreferences,
      points: points ?? this.points,
      placeSettings: placeSettings ?? this.placeSettings,
      priceSettings: priceSettings ?? this.priceSettings,
    );
  }
}

/// Кредиты для деталей квеста
class CreditsDetail extends Equatable {
  final bool auto;
  final int cost;
  final int reward;

  const CreditsDetail({
    this.auto = false,
    this.cost = 0,
    this.reward = 0,
  });

  factory CreditsDetail.fromJson(Map<String, dynamic> json) => CreditsDetail(
        auto: json['auto'] ?? false,
        cost: json['cost'] ?? 0,
        reward: json['reward'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'auto': auto,
        'cost': cost,
        'reward': reward,
      };

  @override
  List<Object?> get props => [auto, cost, reward];
}

/// Мерч для деталей квеста
class MerchDetailModel extends Equatable {
  final int id;
  final String description;
  final int price;
  final String image;

  const MerchDetailModel({
    required this.id,
    required this.description,
    required this.price,
    required this.image,
  });

  factory MerchDetailModel.fromJson(Map<String, dynamic> json) =>
      MerchDetailModel(
        id: json['id'] ?? 0,
        description: (json['description'] ?? '').toString().trim(),
        price: json['price'] ?? 0,
        image: (json['image'] ?? '').toString().trim(),
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

/// Основные предпочтения для деталей квеста
class MainPreferencesDetail extends Equatable {
  final int categoryId;
  final int vehicleId;
  final int placeId;
  final int group;
  final int? timeframe;
  final String level;
  final String mileage;
  final List<int> types;
  final List<int> places;
  final List<int> vehicles;
  final List<int> tools;

  const MainPreferencesDetail({
    required this.categoryId,
    required this.vehicleId,
    required this.placeId,
    required this.group,
    this.timeframe,
    required this.level,
    required this.mileage,
    this.types = const [],
    this.places = const [],
    this.vehicles = const [],
    this.tools = const [],
  });

  factory MainPreferencesDetail.fromJson(Map<String, dynamic> json) =>
      MainPreferencesDetail(
        categoryId: json['category_id'] ?? 1,
        vehicleId: json['vehicle_id'] ?? 1,
        placeId: json['place_id'] ?? 1,
        group: json['group'] ?? 1,
        timeframe: json['timeframe'],
        level: (json['level'] ?? 'Easy').toString(),
        mileage: (json['mileage'] ?? '5-10').toString(),
        types: (json['types'] as List?)?.cast<int>() ?? [],
        places: (json['places'] as List?)?.cast<int>() ?? [],
        vehicles: (json['vehicles'] as List?)?.cast<int>() ?? [],
        tools: (json['tools'] as List?)?.cast<int>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'vehicle_id': vehicleId,
        'place_id': placeId,
        'group': group,
        'timeframe': timeframe,
        'level': level,
        'mileage': mileage,
        'types': types,
        'places': places,
        'vehicles': vehicles,
        'tools': tools,
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
        types,
        places,
        vehicles,
        tools,
      ];
}

/// Точка для деталей квеста
class PointDetailModel extends Equatable {
  final int id;
  final String nameOfLocation;
  final int order;
  final String description;
  final int? typeId;
  final int? toolId;
  final List<PlaceModel> places;

  const PointDetailModel({
    required this.id,
    required this.nameOfLocation,
    required this.order,
    this.description = '',
    this.typeId,
    this.toolId,
    this.places = const [],
  });

  factory PointDetailModel.fromJson(Map<String, dynamic> json) =>
      PointDetailModel(
        id: json['id'] ?? 0,
        nameOfLocation: (json['name'] ?? '').toString().trim(),
        order: json['order'] ?? 0,
        description: (json['description'] ?? '').toString().trim(),
        typeId: json['typeId'],
        toolId: json['toolId'],
        places: (json['places'] as List?)
                ?.map((e) => PlaceModel.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': nameOfLocation,
        'order': order,
        'description': description,
        'typeId': typeId,
        'toolId': toolId,
        'places': places.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [id, nameOfLocation, order, description, typeId, toolId, places];
}

/// Место для деталей квеста
class PlaceModel extends Equatable {
  final double latitude;
  final double longitude;

  const PlaceModel({
    required this.latitude,
    required this.longitude,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Настройки места для деталей квеста
class PlaceSettingsDetail extends Equatable {
  final String type;
  final PlaceModel? settings;

  const PlaceSettingsDetail({
    this.type = 'default',
    this.settings,
  });

  factory PlaceSettingsDetail.fromJson(Map<String, dynamic> json) =>
      PlaceSettingsDetail(
        type: (json['type'] ?? 'default').toString(),
        settings: json['settings'] != null
            ? PlaceModel.fromJson(json['settings'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'settings': settings?.toJson(),
      };

  @override
  List<Object?> get props => [type, settings];
}

/// Настройки цены для деталей квеста
class PriceSettingsDetail extends Equatable {
  final String type;
  final bool isSubscription;
  final double amount;

  const PriceSettingsDetail({
    this.type = 'default',
    this.isSubscription = false,
    this.amount = 0.0,
  });

  factory PriceSettingsDetail.fromJson(Map<String, dynamic> json) =>
      PriceSettingsDetail(
        type: (json['type'] ?? 'default').toString(),
        isSubscription: json['is_subscription'] ?? false,
        amount: (json['amount'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'is_subscription': isSubscription,
        'amount': amount,
      };

  @override
  List<Object?> get props => [type, isSubscription, amount];
}
