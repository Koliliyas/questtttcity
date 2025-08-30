import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/features/data/datasources/quest_api_datasource.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_api_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_request_model.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/mock_helpers.dart';

void main() {
  late QuestApiDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockHttpClient = MockFactory.createMockHttpClient();
    mockSecureStorage = MockFactory.createMockSecureStorage();
    dataSource = QuestApiDataSourceImpl(
      client: mockHttpClient,
      secureStorage: mockSecureStorage,
    );
  });

  void setUpMockHttpClientSuccess200(String responseBody) {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(responseBody, 200));
  }

  void setUpMockHttpClientPost200(String responseBody) {
    when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(responseBody, 200));
  }

  void setUpMockHttpClientPatch200(String responseBody) {
    when(mockHttpClient.patch(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(responseBody, 200));
  }

  void setUpMockHttpClientDelete204() {
    when(mockHttpClient.delete(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('', 204));
  }

  void setUpMockSecureStorage() {
    when(mockSecureStorage.read(key: anyNamed('key')))
        .thenAnswer((_) async => 'test_token');
  }

  group('QuestApiDataSourceImpl', () {
    group('getAllQuests', () {
      test('should return list of quest items when the response code is 200', () async {
        // arrange
        final questList = TestHelpers.questListJson();
        setUpMockHttpClientSuccess200(json.encode(questList));
        setUpMockSecureStorage();

        // act
        final result = await dataSource.getAllQuests();

        // assert
        expect(result, isA<List<QuestListItemApiModel>>());
        expect(result, hasLength(2));
        expect(result.first.name, equals('Test Quest'));
        expect(result.first.id, equals(1));
      });

      test('should throw UnauthorizedException when the response code is 401', () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Unauthorized', 401));
        setUpMockSecureStorage();

        // act
        final call = dataSource.getAllQuests;

        // assert
        expect(() => call(), throwsA(isA<UnauthorizedException>()));
      });

      test('should throw ServerException when the response code is 500', () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Server Error', 500));
        setUpMockSecureStorage();

        // act
        final call = dataSource.getAllQuests;

        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      });

      test('should call the correct URL with proper headers', () async {
        // arrange
        final questList = TestHelpers.questListJson();
        setUpMockHttpClientSuccess200(json.encode(questList));
        setUpMockSecureStorage();

        // act
        await dataSource.getAllQuests();

        // assert
        verify(mockHttpClient.get(
          Uri.parse('http://localhost:8000/api/v1/quests/'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test_token',
          },
        ));
      });
    });

    group('getQuestById', () {
      test('should return quest detail when the response code is 200', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        setUpMockHttpClientSuccess200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        final result = await dataSource.getQuestById(1);

        // assert
        expect(result, isA<QuestApiModel>());
        expect(result.id, equals(1));
        expect(result.title, equals('Test Quest Detail'));
      });

      test('should throw NotFoundException when the response code is 404', () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));
        setUpMockSecureStorage();

        // act
        final call = () => dataSource.getQuestById(1);

        // assert
        expect(call, throwsA(isA<NotFoundException>()));
      });

      test('should call the correct URL with quest ID', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        setUpMockHttpClientSuccess200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        await dataSource.getQuestById(1);

        // assert
        verify(mockHttpClient.get(
          Uri.parse('http://localhost:8000/api/v1/quests/1'),
          headers: anyNamed('headers'),
        ));
      });
    });

    group('getQuestWorking', () {
      test('should return quest detail from working endpoint', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        setUpMockHttpClientSuccess200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        final result = await dataSource.getQuestWorking(1);

        // assert
        expect(result, isA<QuestApiModel>());
        expect(result.id, equals(1));
      });

      test('should call the working endpoint URL', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        setUpMockHttpClientSuccess200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        await dataSource.getQuestWorking(1);

        // assert
        verify(mockHttpClient.get(
          Uri.parse('http://localhost:8000/api/v1/quests/working/1'),
          headers: anyNamed('headers'),
        ));
      });
    });

    group('createQuest', () {
      test('should return created quest when the response code is 201', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        final createRequest = QuestCreateRequestModel.fromJson(
            TestHelpers.questCreateRequestJson());
        setUpMockHttpClientPost200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        final result = await dataSource.createQuest(createRequest);

        // assert
        expect(result, isA<QuestApiModel>());
        expect(result.id, equals(1));
      });

      test('should throw ForbiddenException when the response code is 403', () async {
        // arrange
        final createRequest = QuestCreateRequestModel.fromJson(
            TestHelpers.questCreateRequestJson());
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('Forbidden', 403));
        setUpMockSecureStorage();

        // act
        final call = () => dataSource.createQuest(createRequest);

        // assert
        expect(call, throwsA(isA<ForbiddenException>()));
      });

      test('should throw ConflictException when the response code is 409', () async {
        // arrange
        final createRequest = QuestCreateRequestModel.fromJson(
            TestHelpers.questCreateRequestJson());
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('Conflict', 409));
        setUpMockSecureStorage();

        // act
        final call = () => dataSource.createQuest(createRequest);

        // assert
        expect(call, throwsA(isA<ConflictException>()));
      });

      test('should call POST with correct URL and body', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        final createRequest = QuestCreateRequestModel.fromJson(
            TestHelpers.questCreateRequestJson());
        setUpMockHttpClientPost200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        await dataSource.createQuest(createRequest);

        // assert
        verify(mockHttpClient.post(
          Uri.parse('http://localhost:8000/api/v1/quests/'),
          headers: anyNamed('headers'),
          body: json.encode(createRequest.toJson()),
        ));
      });
    });

    group('updateQuest', () {
      test('should return updated quest when the response code is 200', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        const updateRequest = QuestUpdateRequestModel(name: 'Updated Quest');
        setUpMockHttpClientPatch200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        final result = await dataSource.updateQuest(1, updateRequest);

        // assert
        expect(result, isA<QuestApiModel>());
        expect(result.id, equals(1));
      });

      test('should throw NotFoundException when the response code is 404', () async {
        // arrange
        const updateRequest = QuestUpdateRequestModel(name: 'Updated Quest');
        when(mockHttpClient.patch(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('Not Found', 404));
        setUpMockSecureStorage();

        // act
        final call = () => dataSource.updateQuest(1, updateRequest);

        // assert
        expect(call, throwsA(isA<NotFoundException>()));
      });

      test('should call PATCH with correct URL and body', () async {
        // arrange
        final questDetail = TestHelpers.questDetailJson();
        const updateRequest = QuestUpdateRequestModel(name: 'Updated Quest');
        setUpMockHttpClientPatch200(json.encode(questDetail));
        setUpMockSecureStorage();

        // act
        await dataSource.updateQuest(1, updateRequest);

        // assert
        verify(mockHttpClient.patch(
          Uri.parse('http://localhost:8000/api/v1/quests/1'),
          headers: anyNamed('headers'),
          body: json.encode(updateRequest.toJson()),
        ));
      });
    });

    group('deleteQuest', () {
      test('should complete successfully when the response code is 204', () async {
        // arrange
        setUpMockHttpClientDelete204();
        setUpMockSecureStorage();

        // act & assert
        expect(() => dataSource.deleteQuest(1), returnsNormally);
      });

      test('should throw NotFoundException when the response code is 404', () async {
        // arrange
        when(mockHttpClient.delete(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));
        setUpMockSecureStorage();

        // act
        final call = () => dataSource.deleteQuest(1);

        // assert
        expect(call, throwsA(isA<NotFoundException>()));
      });

      test('should call DELETE with correct URL', () async {
        // arrange
        setUpMockHttpClientDelete204();
        setUpMockSecureStorage();

        // act
        await dataSource.deleteQuest(1);

        // assert
        verify(mockHttpClient.delete(
          Uri.parse('http://localhost:8000/api/v1/quests/1'),
          headers: anyNamed('headers'),
        ));
      });
    });

    group('headers', () {
      test('should include authorization header when token is available', () async {
        // arrange
        final questList = TestHelpers.questListJson();
        setUpMockHttpClientSuccess200(json.encode(questList));
        when(mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => 'test_token');

        // act
        await dataSource.getAllQuests();

        // assert
        verify(mockHttpClient.get(
          any,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test_token',
          },
        ));
      });

      test('should not include authorization header when token is null', () async {
        // arrange
        final questList = TestHelpers.questListJson();
        setUpMockHttpClientSuccess200(json.encode(questList));
        when(mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => null);

        // act
        await dataSource.getAllQuests();

        // assert
        verify(mockHttpClient.get(
          any,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));
      });
    });

    group('error handling', () {
      test('should throw ServerException for unexpected HTTP status codes', () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Bad Request', 400));
        setUpMockSecureStorage();

        // act
        final call = dataSource.getAllQuests;

        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException when HTTP request fails', () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));
        setUpMockSecureStorage();

        // act
        final call = dataSource.getAllQuests;

        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException when JSON parsing fails', () async {
        // arrange
        setUpMockHttpClientSuccess200('invalid json');
        setUpMockSecureStorage();

        // act
        final call = dataSource.getAllQuests;

        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      });
    });
  });
} 