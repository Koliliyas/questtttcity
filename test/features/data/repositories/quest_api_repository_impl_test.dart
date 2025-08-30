import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failures.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/quest_api_datasource.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_api_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_request_model.dart';
import 'package:los_angeles_quest/features/data/repositories/quest_api_repository_impl.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/mock_helpers.dart';

void main() {
  late QuestApiRepositoryImpl repository;
  late MockQuestApiDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockDataSource = MockFactory.createMockDataSource();
    mockNetworkInfo = MockFactory.createMockNetworkInfo();
    repository = QuestApiRepositoryImpl(
      remoteDataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('QuestApiRepositoryImpl', () {
    group('getAllQuests', () {
      final tQuestList = [
        QuestListItemApiModel.fromJson(TestHelpers.questListItemJson()),
        QuestListItemApiModel.fromJson({
          ...TestHelpers.questListItemJson(),
          'id': 2,
          'name': 'Second Quest'
        }),
      ];

      runTestsOnline(() {
        test('should return list of quests when the call to remote data source is successful', () async {
          // arrange
          when(mockDataSource.getAllQuests())
              .thenAnswer((_) async => tQuestList);

          // act
          final result = await repository.getAllQuests();

          // assert
          verify(mockDataSource.getAllQuests());
          expect(result, equals(Right(tQuestList)));
        });

        test('should return ServerFailure when the call to remote data source throws ServerException', () async {
          // arrange
          when(mockDataSource.getAllQuests())
              .thenThrow(ServerException());

          // act
          final result = await repository.getAllQuests();

          // assert
          verify(mockDataSource.getAllQuests());
          expect(result, equals(const Left(ServerFailure('Ошибка сервера. Попробуйте позже'))));
        });

        test('should return UnauthorizedFailure when the call throws UnauthorizedException', () async {
          // arrange
          when(mockDataSource.getAllQuests())
              .thenThrow(UnauthorizedException());

          // act
          final result = await repository.getAllQuests();

          // assert
          expect(result, equals(const Left(UnauthorizedFailure('Ошибка авторизации. Войдите в аккаунт'))));
        });
      });

      runTestsOffline(() {
        test('should return NetworkFailure when the device has no internet connection', () async {
          // act
          final result = await repository.getAllQuests();

          // assert
          verifyZeroInteractions(mockDataSource);
          expect(result, equals(const Left(NetworkFailure('Проверьте подключение к интернету'))));
        });
      });
    });

    group('getQuestById', () {
      const tQuestId = 1;
      final tQuest = QuestApiModel.fromJson(TestHelpers.questDetailJson());

      runTestsOnline(() {
        test('should return quest when the call to remote data source is successful', () async {
          // arrange
          when(mockDataSource.getQuestById(any))
              .thenAnswer((_) async => tQuest);

          // act
          final result = await repository.getQuestById(tQuestId);

          // assert
          verify(mockDataSource.getQuestById(tQuestId));
          expect(result, equals(Right(tQuest)));
        });

        test('should return NotFoundFailure when the call throws NotFoundException', () async {
          // arrange
          when(mockDataSource.getQuestById(any))
              .thenThrow(NotFoundException());

          // act
          final result = await repository.getQuestById(tQuestId);

          // assert
          expect(result, equals(const Left(NotFoundFailure('Квест не найден'))));
        });

        test('should return ForbiddenFailure when the call throws ForbiddenException', () async {
          // arrange
          when(mockDataSource.getQuestById(any))
              .thenThrow(ForbiddenException());

          // act
          final result = await repository.getQuestById(tQuestId);

          // assert
          expect(result, equals(const Left(ForbiddenFailure('Нет доступа к данному ресурсу'))));
        });
      });

      runTestsOffline(() {
        test('should return NetworkFailure when the device has no internet connection', () async {
          // act
          final result = await repository.getQuestById(tQuestId);

          // assert
          verifyZeroInteractions(mockDataSource);
          expect(result, equals(const Left(NetworkFailure('Проверьте подключение к интернету'))));
        });
      });
    });

    group('getQuestWorking', () {
      const tQuestId = 1;
      final tQuest = QuestApiModel.fromJson(TestHelpers.questDetailJson());

      runTestsOnline(() {
        test('should return quest from working endpoint when successful', () async {
          // arrange
          when(mockDataSource.getQuestWorking(any))
              .thenAnswer((_) async => tQuest);

          // act
          final result = await repository.getQuestWorking(tQuestId);

          // assert
          verify(mockDataSource.getQuestWorking(tQuestId));
          expect(result, equals(Right(tQuest)));
        });
      });
    });

    group('createQuest', () {
      final tCreateRequest = QuestCreateRequestModel.fromJson(
          TestHelpers.questCreateRequestJson());
      final tCreatedQuest = QuestApiModel.fromJson(TestHelpers.questDetailJson());

      runTestsOnline(() {
        test('should return created quest when the call to remote data source is successful', () async {
          // arrange
          when(mockDataSource.createQuest(any))
              .thenAnswer((_) async => tCreatedQuest);

          // act
          final result = await repository.createQuest(tCreateRequest);

          // assert
          verify(mockDataSource.createQuest(tCreateRequest));
          expect(result, equals(Right(tCreatedQuest)));
        });

        test('should return ConflictFailure when the call throws ConflictException', () async {
          // arrange
          when(mockDataSource.createQuest(any))
              .thenThrow(ConflictException());

          // act
          final result = await repository.createQuest(tCreateRequest);

          // assert
          expect(result, equals(const Left(ConflictFailure('Квест с таким названием уже существует'))));
        });

        test('should return ForbiddenFailure when user has no permission to create quest', () async {
          // arrange
          when(mockDataSource.createQuest(any))
              .thenThrow(ForbiddenException());

          // act
          final result = await repository.createQuest(tCreateRequest);

          // assert
          expect(result, equals(const Left(ForbiddenFailure('Нет доступа к данному ресурсу'))));
        });
      });

      runTestsOffline(() {
        test('should return NetworkFailure when the device has no internet connection', () async {
          // act
          final result = await repository.createQuest(tCreateRequest);

          // assert
          verifyZeroInteractions(mockDataSource);
          expect(result, equals(const Left(NetworkFailure('Проверьте подключение к интернету'))));
        });
      });
    });

    group('updateQuest', () {
      const tQuestId = 1;
      const tUpdateRequest = QuestUpdateRequestModel(name: 'Updated Quest');
      final tUpdatedQuest = QuestApiModel.fromJson(TestHelpers.questDetailJson());

      runTestsOnline(() {
        test('should return updated quest when the call to remote data source is successful', () async {
          // arrange
          when(mockDataSource.updateQuest(any, any))
              .thenAnswer((_) async => tUpdatedQuest);

          // act
          final result = await repository.updateQuest(tQuestId, tUpdateRequest);

          // assert
          verify(mockDataSource.updateQuest(tQuestId, tUpdateRequest));
          expect(result, equals(Right(tUpdatedQuest)));
        });

        test('should return NotFoundFailure when quest does not exist', () async {
          // arrange
          when(mockDataSource.updateQuest(any, any))
              .thenThrow(NotFoundException());

          // act
          final result = await repository.updateQuest(tQuestId, tUpdateRequest);

          // assert
          expect(result, equals(const Left(NotFoundFailure('Квест не найден'))));
        });

        test('should return ForbiddenFailure when user has no permission to update quest', () async {
          // arrange
          when(mockDataSource.updateQuest(any, any))
              .thenThrow(ForbiddenException());

          // act
          final result = await repository.updateQuest(tQuestId, tUpdateRequest);

          // assert
          expect(result, equals(const Left(ForbiddenFailure('Нет доступа к данному ресурсу'))));
        });
      });

      runTestsOffline(() {
        test('should return NetworkFailure when the device has no internet connection', () async {
          // act
          final result = await repository.updateQuest(tQuestId, tUpdateRequest);

          // assert
          verifyZeroInteractions(mockDataSource);
          expect(result, equals(const Left(NetworkFailure('Проверьте подключение к интернету'))));
        });
      });
    });

    group('deleteQuest', () {
      const tQuestId = 1;

      runTestsOnline(() {
        test('should return Right(unit) when the call to remote data source is successful', () async {
          // arrange
          when(mockDataSource.deleteQuest(any))
              .thenAnswer((_) async {});

          // act
          final result = await repository.deleteQuest(tQuestId);

          // assert
          verify(mockDataSource.deleteQuest(tQuestId));
          expect(result, equals(const Right(unit)));
        });

        test('should return NotFoundFailure when quest does not exist', () async {
          // arrange
          when(mockDataSource.deleteQuest(any))
              .thenThrow(NotFoundException());

          // act
          final result = await repository.deleteQuest(tQuestId);

          // assert
          expect(result, equals(const Left(NotFoundFailure('Квест не найден'))));
        });

        test('should return ForbiddenFailure when user has no permission to delete quest', () async {
          // arrange
          when(mockDataSource.deleteQuest(any))
              .thenThrow(ForbiddenException());

          // act
          final result = await repository.deleteQuest(tQuestId);

          // assert
          expect(result, equals(const Left(ForbiddenFailure('Нет доступа к данному ресурсу'))));
        });
      });

      runTestsOffline(() {
        test('should return NetworkFailure when the device has no internet connection', () async {
          // act
          final result = await repository.deleteQuest(tQuestId);

          // assert
          verifyZeroInteractions(mockDataSource);
          expect(result, equals(const Left(NetworkFailure('Проверьте подключение к интернету'))));
        });
      });
    });

    group('exception to failure mapping', () {
      test('should map ServerException to ServerFailure', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.getAllQuests()).thenThrow(ServerException());

        // act
        final result = await repository.getAllQuests();

        // assert
        expect(result, equals(const Left(ServerFailure('Ошибка сервера. Попробуйте позже'))));
      });

      test('should map UnauthorizedException to UnauthorizedFailure', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.getAllQuests()).thenThrow(UnauthorizedException());

        // act
        final result = await repository.getAllQuests();

        // assert
        expect(result, equals(const Left(UnauthorizedFailure('Ошибка авторизации. Войдите в аккаунт'))));
      });

      test('should map NotFoundException to NotFoundFailure', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.getQuestById(1)).thenThrow(NotFoundException());

        // act
        final result = await repository.getQuestById(1);

        // assert
        expect(result, equals(const Left(NotFoundFailure('Квест не найден'))));
      });

      test('should map ForbiddenException to ForbiddenFailure', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.getQuestById(1)).thenThrow(ForbiddenException());

        // act
        final result = await repository.getQuestById(1);

        // assert
        expect(result, equals(const Left(ForbiddenFailure('Нет доступа к данному ресурсу'))));
      });

      test('should map ConflictException to ConflictFailure', () async {
        // arrange
        final createRequest = QuestCreateRequestModel.fromJson(
            TestHelpers.questCreateRequestJson());
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.createQuest(any)).thenThrow(ConflictException());

        // act
        final result = await repository.createQuest(createRequest);

        // assert
        expect(result, equals(const Left(ConflictFailure('Квест с таким названием уже существует'))));
      });

      test('should map general Exception to ServerFailure', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.getAllQuests()).thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.getAllQuests();

        // assert
        expect(result, equals(const Left(ServerFailure('Ошибка сервера. Попробуйте позже'))));
      });
    });

    group('network connectivity check', () {
      test('should check if the device is connected to internet', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.getAllQuests()).thenAnswer((_) async => []);

        // act
        await repository.getAllQuests();

        // assert
        verify(mockNetworkInfo.isConnected);
      });
    });
  });
} 