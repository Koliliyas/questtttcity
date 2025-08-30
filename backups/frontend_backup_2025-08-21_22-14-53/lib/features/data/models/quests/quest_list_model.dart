import 'package:equatable/equatable.dart';

class QuestListModel extends Equatable {
  final List<QuestItem> items;

  const QuestListModel({required this.items});

  factory QuestListModel.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null и пустых значений
    if (json == null) {
      print('🔍 DEBUG: QuestListModel.fromJson received null JSON');
      return QuestListModel(items: <QuestItem>[]);
    }

    final itemsJson = json['items'];
    if (itemsJson == null || itemsJson is! List) {
      print(
          '🔍 DEBUG: QuestListModel.fromJson items field is null or not a list: $itemsJson');
      return QuestListModel(items: <QuestItem>[]);
    }

    final items = <QuestItem>[];
    for (int i = 0; i < itemsJson.length; i++) {
      try {
        final item = itemsJson[i];
        if (item != null && item is Map<String, dynamic>) {
          final questItem = QuestItem.fromJson(item);
          items.add(questItem);
        } else {
          print('🔍 DEBUG: Skipping invalid item at index $i: $item');
        }
      } catch (e) {
        print('🔍 DEBUG: Error parsing item at index $i: $e');
        // Продолжаем обработку других элементов
      }
    }

    print(
        '🔍 DEBUG: QuestListModel.fromJson successfully parsed ${items.length} items');
    return QuestListModel(items: items);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [items];
}

class QuestItem extends Equatable {
  final int id;
  final String name;
  final String image;
  final double? rating;
  final MainPreferences mainPreferences;

  const QuestItem({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.mainPreferences,
  });

  factory QuestItem.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      throw ArgumentError('JSON cannot be null for QuestItem');
    }

    // Проверяем обязательные поля
    final id = json['id'];
    final name = json['name'];
    final image = json['image'];
    final mainPreferences = json['mainPreferences'];

    // Если обязательные поля отсутствуют, создаем дефолтные значения
    if (id == null ||
        name == null ||
        image == null ||
        mainPreferences == null) {
      print('🔍 DEBUG: Missing required fields in QuestItem JSON: $json');
      return QuestItem(
        id: 0,
        name: 'Unknown Quest',
        image: '',
        rating: null,
        mainPreferences: MainPreferences.fromJson(<String, dynamic>{}),
      );
    }

    return QuestItem(
      id: id.toInt() ?? 0,
      name: name.toString(),
      image: image.toString(),
      rating: json['rating']?.toDouble(),
      mainPreferences: MainPreferences.fromJson(mainPreferences),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'mainPreferences': mainPreferences.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, name, image, rating, mainPreferences];
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
      throw ArgumentError('JSON cannot be null for MainPreferences');
    }

    // Проверяем обязательные поля
    final categoryId = json['category_id'];
    final vehicleId = json['vehicle_id'];
    final placeId = json['place_id'];
    final price = json['price'];

    // Если обязательные поля отсутствуют, создаем дефолтные значения
    if (categoryId == null ||
        vehicleId == null ||
        placeId == null ||
        price == null) {
      print('🔍 DEBUG: Missing required fields in MainPreferences JSON: $json');
      return MainPreferences(
        categoryId: 0,
        group: null,
        vehicleId: 0,
        price: Price.fromJson(<String, dynamic>{}),
        timeframe: null,
        level: 'beginner',
        milege: 'local',
        placeId: 0,
      );
    }

    return MainPreferences(
      categoryId: categoryId.toInt() ?? 0,
      group: json['group']?.toInt(),
      vehicleId: vehicleId.toInt() ?? 0,
      price: Price.fromJson(price),
      timeframe: json['timeframe']?.toInt(),
      level: json['level']?.toString() ?? 'beginner',
      milege: json['milage']?.toString() ?? 'local',
      placeId: placeId.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'group': group,
      'vehicle_id': vehicleId,
      'price': price.toJson(),
      'timeframe': timeframe,
      'level': level,
      'milege': milege,
      'place_id': placeId,
    };
  }

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

enum GroupType { single, couple, family, friends }

enum LevelType { beginner, intermediate, advanced, expert }

enum MilegeType { local, nearby, faraway }

class Price extends Equatable {
  final int? amount;
  final bool? isSubscription;

  const Price({
    required this.amount,
    required this.isSubscription,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    // Безопасная обработка null значений
    if (json == null) {
      return Price(amount: null, isSubscription: null);
    }

    return Price(
      amount: json['pay_extra']?.toInt(),
      isSubscription: json['is_subscription']?.toBool(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pay_extra': amount,
      'is_subscription': isSubscription,
    };
  }

  @override
  List<Object?> get props => [amount, isSubscription];
}
