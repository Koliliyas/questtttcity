import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_api_model.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('QuestApiModel', () {
    late Map<String, dynamic> questJson;
    late QuestApiModel questModel;

    setUp(() {
      questJson = TestHelpers.questDetailJson();
      questModel = QuestApiModel.fromJson(questJson);
    });

    group('fromJson', () {
      test('should return a valid QuestApiModel from JSON', () {
        // act
        final result = QuestApiModel.fromJson(questJson);

        // assert
        expect(result, isA<QuestApiModel>());
        expect(result.id, equals(1));
        expect(result.title, equals('Test Quest Detail'));
        expect(result.shortDescription, equals('Short test description'));
        expect(result.fullDescription, equals('Full test description'));
        expect(result.imageUrl, equals('https://example.com/image.jpg'));
        expect(result.categoryId, equals(1));
        expect(result.categoryTitle, equals('Adventure'));
        expect(result.categoryImageUrl, equals('https://example.com/category.jpg'));
        expect(result.difficulty, equals('Easy'));
        expect(result.price, equals(29.99));
        expect(result.duration, equals('2-3 hours'));
        expect(result.playerLimit, equals(4));
        expect(result.ageLimit, equals(12));
        expect(result.isForAdvUsers, equals(false));
        expect(result.type, equals('Solo'));
      });

      test('should handle optional fields correctly', () {
        // arrange
        final jsonWithoutOptionalFields = {
          'id': 1,
          'title': 'Test Quest',
          'short_description': 'Short desc',
          'full_description': 'Full desc',
          'image_url': 'image.jpg',
          'category_id': 1,
          'difficulty': 'Easy',
          'price': 19.99,
          'duration': '1 hour',
          'type': 'Solo',
        };

        // act
        final result = QuestApiModel.fromJson(jsonWithoutOptionalFields);

        // assert
        expect(result.categoryTitle, isNull);
        expect(result.categoryImageUrl, isNull);
        expect(result.playerLimit, equals(0)); // default value
        expect(result.ageLimit, equals(0)); // default value
        expect(result.isForAdvUsers, equals(false)); // default value
        expect(result.credits, isA<CreditsApiModel>());
        expect(result.merchList, isEmpty);
        expect(result.points, isEmpty);
      });

      test('should parse nested objects correctly', () {
        // act
        final result = QuestApiModel.fromJson(questJson);

        // assert
        expect(result.credits, isA<CreditsApiModel>());
        expect(result.credits.cost, equals(10));
        expect(result.credits.reward, equals(50));

        expect(result.mainPreferences, isA<MainPreferencesApiModel>());
        expect(result.mainPreferences.types, equals([1, 2]));
        expect(result.mainPreferences.places, equals([1]));

        expect(result.merchList, hasLength(1));
        expect(result.merchList.first.id, equals(1));
        expect(result.merchList.first.description, equals('Test merch item'));

        expect(result.points, hasLength(1));
        expect(result.points.first.name, equals('Start Point'));
        expect(result.points.first.latitude, equals(34.0522));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // act
        final result = questModel.toJson();

        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals(1));
        expect(result['title'], equals('Test Quest Detail'));
        expect(result['short_description'], equals('Short test description'));
        expect(result['difficulty'], equals('Easy'));
        expect(result['price'], equals(29.99));
      });

      test('should correctly serialize nested objects', () {
        // act
        final result = questModel.toJson();

        // assert
        expect(result['credits'], isA<Map<String, dynamic>>());
        expect(result['credits']['cost'], equals(10));
        expect(result['credits']['reward'], equals(50));

        expect(result['main_preferences'], isA<Map<String, dynamic>>());
        expect(result['main_preferences']['types'], equals([1, 2]));

        expect(result['merch_list'], isA<List>());
        expect(result['merch_list'], hasLength(1));

        expect(result['points'], isA<List>());
        expect(result['points'], hasLength(1));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final questModel1 = QuestApiModel.fromJson(questJson);
        final questModel2 = QuestApiModel.fromJson(questJson);

        // assert
        expect(questModel1, equals(questModel2));
        expect(questModel1.hashCode, equals(questModel2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final questModel1 = QuestApiModel.fromJson(questJson);
        final differentJson = {...questJson, 'title': 'Different Title'};
        final questModel2 = QuestApiModel.fromJson(differentJson);

        // assert
        expect(questModel1, isNot(equals(questModel2)));
      });
    });
  });

  group('QuestListItemApiModel', () {
    late Map<String, dynamic> questListItemJson;

    setUp(() {
      questListItemJson = TestHelpers.questListItemJson();
    });

    test('should create from JSON correctly', () {
      // act
      final result = QuestListItemApiModel.fromJson(questListItemJson);

      // assert
      expect(result.id, equals(1));
      expect(result.name, equals('Test Quest'));
      expect(result.image, equals('https://example.com/image.jpg'));
      expect(result.rating, equals(4.5));
      expect(result.mainPreferences.types, equals([1, 2]));
    });

    test('should convert to JSON correctly', () {
      // arrange
      final model = QuestListItemApiModel.fromJson(questListItemJson);

      // act
      final result = model.toJson();

      // assert
      expect(result['id'], equals(1));
      expect(result['name'], equals('Test Quest'));
      expect(result['rating'], equals(4.5));
      expect(result['main_preferences'], isA<Map<String, dynamic>>());
    });
  });

  group('CreditsApiModel', () {
    test('should create with default values', () {
      // act
      const credits = CreditsApiModel();

      // assert
      expect(credits.cost, equals(0));
      expect(credits.reward, equals(0));
    });

    test('should create from JSON', () {
      // arrange
      final json = {'cost': 10, 'reward': 50};

      // act
      final result = CreditsApiModel.fromJson(json);

      // assert
      expect(result.cost, equals(10));
      expect(result.reward, equals(50));
    });
  });

  group('MainPreferencesApiModel', () {
    test('should create with default empty lists', () {
      // act
      const preferences = MainPreferencesApiModel();

      // assert
      expect(preferences.types, isEmpty);
      expect(preferences.places, isEmpty);
      expect(preferences.vehicles, isEmpty);
      expect(preferences.tools, isEmpty);
    });

    test('should create from JSON with data', () {
      // arrange
      final json = {
        'types': [1, 2, 3],
        'places': [1],
        'vehicles': [1, 2],
        'tools': [1, 2, 3, 4]
      };

      // act
      final result = MainPreferencesApiModel.fromJson(json);

      // assert
      expect(result.types, equals([1, 2, 3]));
      expect(result.places, equals([1]));
      expect(result.vehicles, equals([1, 2]));
      expect(result.tools, equals([1, 2, 3, 4]));
    });
  });

  group('MerchApiModel', () {
    test('should create from JSON correctly', () {
      // arrange
      final json = {
        'id': 1,
        'description': 'Test merch',
        'price': 25,
        'image': 'merch.jpg'
      };

      // act
      final result = MerchApiModel.fromJson(json);

      // assert
      expect(result.id, equals(1));
      expect(result.description, equals('Test merch'));
      expect(result.price, equals(25));
      expect(result.image, equals('merch.jpg'));
    });
  });

  group('PointApiModel', () {
    test('should create from JSON correctly', () {
      // arrange
      final json = {
        'id': 1,
        'name': 'Test Point',
        'description': 'Test Description',
        'latitude': 34.0522,
        'longitude': -118.2437,
        'order': 1
      };

      // act
      final result = PointApiModel.fromJson(json);

      // assert
      expect(result.id, equals(1));
      expect(result.name, equals('Test Point'));
      expect(result.description, equals('Test Description'));
      expect(result.latitude, equals(34.0522));
      expect(result.longitude, equals(-118.2437));
      expect(result.order, equals(1));
    });
  });
} 