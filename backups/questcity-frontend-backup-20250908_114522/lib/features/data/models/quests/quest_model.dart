import 'package:equatable/equatable.dart';

class QuestModel extends Equatable {
  final String name;
  final String? shortDescription;
  final String? fullDescription;
  final String image;
  final List<MerchItem> merch;
  final Credits credits;
  final List<Review> reviews;
  final MainPreferences mainPreferences;
  final List<QuestPoint> points;
  final String? mentorPreference; // Добавляем mentorPreference

  const QuestModel({
    required this.name,
    this.shortDescription,
    this.fullDescription,
    required this.image,
    required this.merch,
    required this.credits,
    required this.reviews,
    required this.mainPreferences,
    required this.points,
    this.mentorPreference, // Добавляем параметр
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      throw ArgumentError('JSON cannot be null for QuestModel');
    }

    // Отладочная информация для merchandise
    print('🔍 DEBUG: QuestModel.fromJson - Парсинг merchandise данных');
    print('  - json["merchList"]: ${json['merchList']}');
    print('  - json["merchList"] type: ${json['merchList']?.runtimeType}');

    final merchList = json['merchList'] as List?;
    print('  - merchList: $merchList');
    print('  - merchList length: ${merchList?.length}');

    final parsedMerch =
        merchList?.map((e) => MerchItem.fromJson(e)).toList() ?? [];
    print('  - parsedMerch length: ${parsedMerch.length}');
    if (parsedMerch.isNotEmpty) {
      print(
          '  - firstMerch: description="${parsedMerch.first.description}", price=${parsedMerch.first.price}');
    }

    return QuestModel(
      name: json['title'] ?? json['name'] ?? 'Без названия',
      shortDescription: json['shortDescription'],
      fullDescription: json['fullDescription'],
      image: json['imageUrl'] ?? json['image'] ?? 'default.jpg',
      merch: parsedMerch,
      credits: Credits.fromJson(json['credits'] ?? {}),
      reviews:
          (json['reviews'] as List?)?.map((e) => Review.fromJson(e)).toList() ??
              [],
      mainPreferences: MainPreferences.fromJson(json['mainPreferences'] ?? {}),
      points: (json['points'] as List?)
              ?.map((e) => QuestPoint.fromJson(e))
              .toList() ??
          [],
      mentorPreference:
          json['mentorPreference'], // Исправляем: mentorPreference (camelCase)
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'shortDescription': shortDescription,
        'fullDescription': fullDescription,
        'image': image,
        'merch': merch.map((e) => e.toJson()).toList(),
        'credits': credits.toJson(),
        'reviews': reviews.map((e) => e.toJson()).toList(),
        'mainPreferences': mainPreferences.toJson(),
        'points': points.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        name,
        shortDescription,
        fullDescription,
        image,
        merch,
        credits,
        reviews,
        mainPreferences,
        points,
        mentorPreference, // Добавляем mentorPreference
      ];
}

class MerchItem extends Equatable {
  final String description;
  final int price;
  final String image;

  const MerchItem({
    required this.description,
    required this.price,
    required this.image,
  });

  factory MerchItem.fromJson(Map<String, dynamic> json) {
    // Отладочная информация
    print('🔍 DEBUG: MerchItem.fromJson');
    print('  - json: $json');
    print('  - json type: ${json.runtimeType}');

    // Безопасная обработка null значений
    if (json == null) {
      print('  - json is null, returning empty MerchItem');
      return const MerchItem(
        description: '',
        price: 0,
        image: '',
      );
    }

    final description = json['description'] ?? '';
    final price = json['price'] ?? 0;
    final image = json['image'] ?? '';

    print(
        '  - parsed: description="$description", price=$price, image="$image"');

    return MerchItem(
      description: description,
      price: price,
      image: image,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'price': price,
        'image': image,
      };

  @override
  List<Object?> get props => [description, price, image];
}

class Credits extends Equatable {
  final bool auto;
  final int cost;
  final int reward;

  const Credits({
    required this.auto,
    required this.cost,
    required this.reward,
  });

  factory Credits.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      return const Credits(auto: false, cost: 0, reward: 0);
    }

    return Credits(
      auto: json['auto'] ?? false,
      cost: json['cost'] ?? 0,
      reward: json['reward'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'auto': auto,
        'cost': cost,
        'reward': reward,
      };

  @override
  List<Object?> get props => [auto, cost, reward];
}

class QuestPoint extends Equatable {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final int order;

  const QuestPoint({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory QuestPoint.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      return const QuestPoint(
        name: '',
        description: '',
        latitude: 0.0,
        longitude: 0.0,
        order: 0,
      );
    }

    // Получаем координаты из places
    double latitude = 0.0;
    double longitude = 0.0;
    if (json['places'] != null &&
        json['places'] is List &&
        (json['places'] as List).isNotEmpty) {
      final place = (json['places'] as List).first;
      if (place is Map<String, dynamic>) {
        latitude = (place['latitude'] ?? 0.0).toDouble();
        longitude = (place['longitude'] ?? 0.0).toDouble();
      }
    }

    return QuestPoint(
      name: json['name'] ?? '',
      description: json['description'] ??
          json['name'] ??
          '', // Используем name как fallback для description
      latitude: latitude,
      longitude: longitude,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'order': order,
      };

  @override
  List<Object?> get props => [name, description, latitude, longitude, order];
}

class Review extends Equatable {
  final String author;
  final String text;
  final double rating;
  final String date;

  const Review({
    required this.date,
    required this.author,
    required this.text,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      return const Review(
        author: '',
        text: '',
        rating: 0.0,
        date: '',
      );
    }

    return Review(
      author: json['author'] ?? '',
      text: json['text'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'text': text,
        'rating': rating,
        'date': date,
      };

  @override
  List<Object?> get props => [author, text, rating, date];
}

class MainPreferences extends Equatable {
  final int categoryId;
  final int? group;
  final int vehicleId;
  final Price price;
  final int? timeframe;
  final String level;
  final String milege;
  final int placeId;

  const MainPreferences({
    required this.categoryId,
    required this.group,
    required this.vehicleId,
    required this.price,
    required this.timeframe,
    required this.level,
    required this.milege,
    required this.placeId,
  });

  factory MainPreferences.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      return MainPreferences(
        categoryId: 0,
        group: null,
        vehicleId: 0,
        price: Price.fromJson({}),
        timeframe: null,
        level: 'beginner',
        milege: 'local',
        placeId: 0,
      );
    }

    return MainPreferences(
      categoryId: json['categoryId'] ?? 0,
      group: json['group'],
      vehicleId: json['vehicleId'] ?? 0,
      price: Price.fromJson(json['price'] ?? {}),
      timeframe: json['timeframe'],
      level: json['level'] ?? 'beginner',
      milege: json['milege'] ?? 'local',
      placeId: json['placeId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'group': group,
        'vehicleId': vehicleId,
        'price': price.toJson(),
        'timeframe': timeframe,
        'level': level,
        'milege': milege,
        'placeId': placeId,
      };

  @override
  List<Object?> get props => [
        categoryId,
        group,
        vehicleId,
        price,
        timeframe,
        level,
        milege,
        placeId,
      ];
}

class Price extends Equatable {
  final int? amount;
  final String currency;
  final bool isSubscription;

  const Price({
    this.amount,
    this.currency = 'USD',
    this.isSubscription = false,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      return const Price(amount: 0, currency: 'USD', isSubscription: false);
    }

    return Price(
      amount: json['amount'],
      currency: json['currency'] ?? 'USD',
      isSubscription: json['isSubscription'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'isSubscription': isSubscription,
      };

  @override
  List<Object?> get props => [amount, currency, isSubscription];
}
