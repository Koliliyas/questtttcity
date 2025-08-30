import 'package:flutter_test/flutter_test.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_request_model.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('QuestCreateRequestModel', () {
    late Map<String, dynamic> createRequestJson;
    late QuestCreateRequestModel createRequestModel;

    setUp(() {
      createRequestJson = TestHelpers.questCreateRequestJson();
      createRequestModel = QuestCreateRequestModel.fromJson(createRequestJson);
    });

    group('fromJson', () {
      test('should return a valid QuestCreateRequestModel from JSON', () {
        // act
        final result = QuestCreateRequestModel.fromJson(createRequestJson);

        // assert
        expect(result, isA<QuestCreateRequestModel>());
        expect(result.name, equals('New Test Quest'));
        expect(result.description, equals('Test quest description'));
        expect(result.image, equals('base64encodedimage'));
        expect(result.mentorPreferences, equals('base64encodedfile'));
        expect(result.merch, hasLength(1));
        expect(result.points, hasLength(1));
      });

      test('should parse nested objects correctly', () {
        // act
        final result = QuestCreateRequestModel.fromJson(createRequestJson);

        // assert
        expect(result.credits, isA<CreditsRequestModel>());
        expect(result.credits.cost, equals(15));
        expect(result.credits.reward, equals(75));

        expect(result.mainPreferences, isA<MainPreferencesRequestModel>());
        expect(result.mainPreferences.types, equals([1]));
        expect(result.mainPreferences.places, equals([1]));

        expect(result.merch.first, isA<MerchRequestModel>());
        expect(result.merch.first.description, equals('Test merch'));
        expect(result.merch.first.price, equals(20));

        expect(result.points.first, isA<PointCreateRequestModel>());
        expect(result.points.first.name, equals('Test Point'));
        expect(result.points.first.latitude, equals(34.0522));
      });

      test('should handle empty merch list', () {
        // arrange
        final jsonWithoutMerch = {...createRequestJson};
        jsonWithoutMerch.remove('merch');

        // act
        final result = QuestCreateRequestModel.fromJson(jsonWithoutMerch);

        // assert
        expect(result.merch, isEmpty);
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // act
        final result = createRequestModel.toJson();

        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['name'], equals('New Test Quest'));
        expect(result['description'], equals('Test quest description'));
        expect(result['image'], equals('base64encodedimage'));
        expect(result['mentor_preferences'], equals('base64encodedfile'));
      });

      test('should correctly serialize nested objects', () {
        // act
        final result = createRequestModel.toJson();

        // assert
        expect(result['credits'], isA<Map<String, dynamic>>());
        expect(result['credits']['cost'], equals(15));
        expect(result['credits']['reward'], equals(75));

        expect(result['main_preferences'], isA<Map<String, dynamic>>());
        expect(result['main_preferences']['types'], equals([1]));

        expect(result['merch'], isA<List>());
        expect(result['merch'], hasLength(1));

        expect(result['points'], isA<List>());
        expect(result['points'], hasLength(1));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final model1 = QuestCreateRequestModel.fromJson(createRequestJson);
        final model2 = QuestCreateRequestModel.fromJson(createRequestJson);

        // assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final model1 = QuestCreateRequestModel.fromJson(createRequestJson);
        final differentJson = {...createRequestJson, 'name': 'Different Name'};
        final model2 = QuestCreateRequestModel.fromJson(differentJson);

        // assert
        expect(model1, isNot(equals(model2)));
      });
    });
  });

  group('QuestUpdateRequestModel', () {
    test('should create with all optional fields', () {
      // arrange
      final json = {
        'name': 'Updated Quest',
        'description': 'Updated description'
      };

      // act
      final result = QuestUpdateRequestModel.fromJson(json);

      // assert
      expect(result.name, equals('Updated Quest'));
      expect(result.description, equals('Updated description'));
      expect(result.image, isNull);
      expect(result.credits, isNull);
      expect(result.mainPreferences, isNull);
      expect(result.mentorPreferences, isNull);
      expect(result.merch, isEmpty);
      expect(result.points, isEmpty);
    });

    test('should handle partial updates', () {
      // arrange
      final json = {
        'name': 'New Name Only'
      };

      // act
      final result = QuestUpdateRequestModel.fromJson(json);

      // assert
      expect(result.name, equals('New Name Only'));
      expect(result.description, isNull);
    });
  });

  group('MerchRequestModel', () {
    test('should create from JSON correctly', () {
      // arrange
      final json = {
        'description': 'Test merch item',
        'price': 30,
        'image': 'base64image'
      };

      // act
      final result = MerchRequestModel.fromJson(json);

      // assert
      expect(result.description, equals('Test merch item'));
      expect(result.price, equals(30));
      expect(result.image, equals('base64image'));
    });

    test('should convert to JSON correctly', () {
      // arrange
      const model = MerchRequestModel(
        description: 'Test item',
        price: 25,
        image: 'test_image'
      );

      // act
      final result = model.toJson();

      // assert
      expect(result['description'], equals('Test item'));
      expect(result['price'], equals(25));
      expect(result['image'], equals('test_image'));
    });
  });

  group('UpdateMerchRequestModel', () {
    test('should create with default values', () {
      // arrange
      final json = <String, dynamic>{};

      // act
      final result = UpdateMerchRequestModel.fromJson(json);

      // assert
      expect(result.id, isNull);
      expect(result.description, isNull);
      expect(result.price, isNull);
      expect(result.image, isNull);
      expect(result.isDelete, equals(false)); // default value
    });

    test('should create from JSON with all fields', () {
      // arrange
      final json = {
        'id': 1,
        'description': 'Updated merch',
        'price': 35,
        'image': 'new_image',
        'is_delete': true
      };

      // act
      final result = UpdateMerchRequestModel.fromJson(json);

      // assert
      expect(result.id, equals(1));
      expect(result.description, equals('Updated merch'));
      expect(result.price, equals(35));
      expect(result.image, equals('new_image'));
      expect(result.isDelete, equals(true));
    });
  });

  group('CreditsRequestModel', () {
    test('should create with default values', () {
      // act
      const credits = CreditsRequestModel();

      // assert
      expect(credits.cost, equals(0));
      expect(credits.reward, equals(0));
    });

    test('should create from JSON', () {
      // arrange
      final json = {'cost': 20, 'reward': 100};

      // act
      final result = CreditsRequestModel.fromJson(json);

      // assert
      expect(result.cost, equals(20));
      expect(result.reward, equals(100));
    });
  });

  group('MainPreferencesRequestModel', () {
    test('should create with default empty lists', () {
      // act
      const preferences = MainPreferencesRequestModel();

      // assert
      expect(preferences.types, isEmpty);
      expect(preferences.places, isEmpty);
      expect(preferences.vehicles, isEmpty);
      expect(preferences.tools, isEmpty);
    });

    test('should create from JSON with data', () {
      // arrange
      final json = {
        'types': [1, 2],
        'places': [1, 2, 3],
        'vehicles': [1],
        'tools': [1, 2, 3, 4, 5]
      };

      // act
      final result = MainPreferencesRequestModel.fromJson(json);

      // assert
      expect(result.types, equals([1, 2]));
      expect(result.places, equals([1, 2, 3]));
      expect(result.vehicles, equals([1]));
      expect(result.tools, equals([1, 2, 3, 4, 5]));
    });
  });

  group('PointCreateRequestModel', () {
    test('should create from JSON correctly', () {
      // arrange
      final json = {
        'name': 'New Point',
        'description': 'Point description',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'order': 2
      };

      // act
      final result = PointCreateRequestModel.fromJson(json);

      // assert
      expect(result.name, equals('New Point'));
      expect(result.description, equals('Point description'));
      expect(result.latitude, equals(40.7128));
      expect(result.longitude, equals(-74.0060));
      expect(result.order, equals(2));
    });
  });

  group('PointUpdateRequestModel', () {
    test('should create with all optional fields', () {
      // arrange
      final json = <String, dynamic>{};

      // act
      final result = PointUpdateRequestModel.fromJson(json);

      // assert
      expect(result.id, isNull);
      expect(result.name, isNull);
      expect(result.description, isNull);
      expect(result.latitude, isNull);
      expect(result.longitude, isNull);
      expect(result.order, isNull);
      expect(result.isDelete, equals(false)); // default value
    });

    test('should create from JSON with all fields', () {
      // arrange
      final json = {
        'id': 1,
        'name': 'Updated Point',
        'description': 'Updated description',
        'latitude': 35.6762,
        'longitude': 139.6503,
        'order': 3,
        'is_delete': true
      };

      // act
      final result = PointUpdateRequestModel.fromJson(json);

      // assert
      expect(result.id, equals(1));
      expect(result.name, equals('Updated Point'));
      expect(result.description, equals('Updated description'));
      expect(result.latitude, equals(35.6762));
      expect(result.longitude, equals(139.6503));
      expect(result.order, equals(3));
      expect(result.isDelete, equals(true));
    });
  });
} 