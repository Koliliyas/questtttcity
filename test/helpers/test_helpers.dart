import 'dart:convert';
import 'dart:io';

/// Helper функции для unit тестов
class TestHelpers {
  /// Загружает JSON из файла в папке test/fixtures/
  static String fixture(String name) {
    return File('test/fixtures/$name').readAsStringSync();
  }

  /// Загружает и парсит JSON из файла
  static Map<String, dynamic> fixtureMap(String name) {
    return json.decode(fixture(name));
  }

  /// Создает тестовые данные для quest list item
  static Map<String, dynamic> questListItemJson() {
    return {
      'id': 1,
      'name': 'Test Quest',
      'image': 'https://example.com/image.jpg',
      'rating': 4.5,
      'main_preferences': {
        'types': [1, 2],
        'places': [1],
        'vehicles': [1],
        'tools': [1, 2, 3]
      }
    };
  }

  /// Создает тестовые данные для quest detail
  static Map<String, dynamic> questDetailJson() {
    return {
      'id': 1,
      'title': 'Test Quest Detail',
      'short_description': 'Short test description',
      'full_description': 'Full test description',
      'image_url': 'https://example.com/image.jpg',
      'category_id': 1,
      'category_title': 'Adventure',
      'category_image_url': 'https://example.com/category.jpg',
      'difficulty': 'Easy',
      'price': 29.99,
      'duration': '2-3 hours',
      'player_limit': 4,
      'age_limit': 12,
      'is_for_adv_users': false,
      'type': 'Solo',
      'credits': {
        'cost': 10,
        'reward': 50
      },
      'merch_list': [
        {
          'id': 1,
          'description': 'Test merch item',
          'price': 15,
          'image': 'https://example.com/merch.jpg'
        }
      ],
      'main_preferences': {
        'types': [1, 2],
        'places': [1],
        'vehicles': [1],
        'tools': [1, 2]
      },
      'points': [
        {
          'id': 1,
          'name': 'Start Point',
          'description': 'Starting location',
          'latitude': 34.0522,
          'longitude': -118.2437,
          'order': 1
        }
      ],
      'place_settings': {
        'type': 'default',
        'settings': {
          'id': 1,
          'title': 'Los Angeles'
        }
      },
      'price_settings': {
        'type': 'default',
        'is_subscription': false,
        'pay_extra': 0.0
      }
    };
  }

  /// Создает тестовые данные для quest create request
  static Map<String, dynamic> questCreateRequestJson() {
    return {
      'name': 'New Test Quest',
      'description': 'Test quest description',
      'image': 'base64encodedimage',
      'merch': [
        {
          'description': 'Test merch',
          'price': 20,
          'image': 'base64encodedimage'
        }
      ],
      'credits': {
        'cost': 15,
        'reward': 75
      },
      'main_preferences': {
        'types': [1],
        'places': [1],
        'vehicles': [1],
        'tools': [1]
      },
      'mentor_preferences': 'base64encodedfile',
      'points': [
        {
          'name': 'Test Point',
          'description': 'Test point description',
          'latitude': 34.0522,
          'longitude': -118.2437,
          'order': 1
        }
      ]
    };
  }

  /// Создает список квестов для тестирования
  static List<Map<String, dynamic>> questListJson() {
    return [
      questListItemJson(),
      {
        ...questListItemJson(),
        'id': 2,
        'name': 'Second Test Quest',
        'rating': 3.8
      }
    ];
  }
} 