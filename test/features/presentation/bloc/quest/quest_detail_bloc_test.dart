import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:los_angeles_quest/core/error/failures.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_api_model.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_detail_bloc.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_detail_event.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_detail_state.dart';
import '../../../../helpers/test_helpers.dart';
import '../../../../helpers/mock_helpers.dart';

void main() {
  late QuestDetailBloc questDetailBloc;
  late MockQuestApiRepository mockRepository;

  setUp(() {
    mockRepository = MockFactory.createMockRepository();
    questDetailBloc = QuestDetailBloc(questApiRepository: mockRepository);
  });

  tearDown(() {
    questDetailBloc.close();
  });

  final tQuest = QuestApiModel.fromJson(TestHelpers.questDetailJson());
  const tQuestId = 1;

  group('QuestDetailBloc', () {
    test('initial state should be QuestDetailInitial', () {
      expect(questDetailBloc.state, equals(const QuestDetailInitial()));
    });

    group('QuestDetailLoadRequested', () {
      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailLoaded] when data is gotten successfully',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => Right(tQuest));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          QuestDetailLoaded(quest: tQuest),
        ],
        verify: (bloc) {
          verify(mockRepository.getQuestById(tQuestId));
        },
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailError] when getting data fails',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => const Left(ServerFailure('Ошибка сервера. Попробуйте позже')));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          const QuestDetailError(message: 'Ошибка сервера. Попробуйте позже'),
        ],
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailError] when quest not found',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => const Left(NotFoundFailure('Квест не найден')));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          const QuestDetailError(message: 'Квест не найден'),
        ],
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailError] when unauthorized',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => const Left(UnauthorizedFailure('Ошибка авторизации. Войдите в аккаунт')));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          const QuestDetailError(message: 'Ошибка авторизации. Войдите в аккаунт'),
        ],
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailError] when forbidden',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => const Left(ForbiddenFailure('Нет доступа к данному ресурсу')));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          const QuestDetailError(message: 'Нет доступа к данному ресурсу'),
        ],
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailError] when network failure',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => const Left(NetworkFailure('Проверьте подключение к интернету')));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          const QuestDetailError(message: 'Проверьте подключение к интернету'),
        ],
      );
    });

    group('QuestDetailRefreshRequested', () {
      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailRefreshing, QuestDetailLoaded] when refresh is successful',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => Right(tQuest));
          return questDetailBloc;
        },
        seed: () => QuestDetailLoaded(quest: tQuest),
        act: (bloc) => bloc.add(const QuestDetailRefreshRequested(questId: tQuestId)),
        expect: () => [
          QuestDetailRefreshing(quest: tQuest),
          QuestDetailLoaded(quest: tQuest),
        ],
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailRefreshing, QuestDetailError] when refresh fails',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => const Left(ServerFailure('Ошибка сервера. Попробуйте позже')));
          return questDetailBloc;
        },
        seed: () => QuestDetailLoaded(quest: tQuest),
        act: (bloc) => bloc.add(const QuestDetailRefreshRequested(questId: tQuestId)),
        expect: () => [
          QuestDetailRefreshing(quest: tQuest),
          const QuestDetailError(message: 'Ошибка сервера. Попробуйте позже'),
        ],
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should not emit refreshing state when not in loaded state',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => Right(tQuest));
          return questDetailBloc;
        },
        seed: () => const QuestDetailInitial(),
        act: (bloc) => bloc.add(const QuestDetailRefreshRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          QuestDetailLoaded(quest: tQuest),
        ],
      );
    });

    group('QuestDetailLoadWorkingRequested', () {
      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailLoaded] when working endpoint is successful',
        build: () {
          when(mockRepository.getQuestWorking(any))
              .thenAnswer((_) async => Right(tQuest));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadWorkingRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          QuestDetailLoaded(quest: tQuest),
        ],
        verify: (bloc) {
          verify(mockRepository.getQuestWorking(tQuestId));
        },
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should emit [QuestDetailLoading, QuestDetailError] when working endpoint fails',
        build: () {
          when(mockRepository.getQuestWorking(any))
              .thenAnswer((_) async => const Left(ServerFailure('Ошибка сервера. Попробуйте позже')));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadWorkingRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          const QuestDetailError(message: 'Ошибка сервера. Попробуйте позже'),
        ],
      );
    });

    group('QuestDetailErrorCleared', () {
      blocTest<QuestDetailBloc, QuestDetailState>(
        'should clear error and return to initial state',
        build: () => questDetailBloc,
        seed: () => const QuestDetailError(message: 'Test error'),
        act: (bloc) => bloc.add(const QuestDetailErrorCleared()),
        expect: () => [
          const QuestDetailInitial(),
        ],
      );

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should not emit state when not in error state',
        build: () => questDetailBloc,
        seed: () => const QuestDetailInitial(),
        act: (bloc) => bloc.add(const QuestDetailErrorCleared()),
        expect: () => [],
      );
    });

    group('error handling', () {
      blocTest<QuestDetailBloc, QuestDetailState>(
        'should handle multiple failure types correctly',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => const Left(ConflictFailure('Квест с таким названием уже существует')));
          return questDetailBloc;
        },
        act: (bloc) => bloc.add(const QuestDetailLoadRequested(questId: tQuestId)),
        expect: () => [
          const QuestDetailLoading(),
          const QuestDetailError(message: 'Квест с таким названием уже существует'),
        ],
      );
    });

    group('state management', () {
      test('should properly manage questApiRepository', () {
        expect(questDetailBloc.questApiRepository, equals(mockRepository));
      });

      blocTest<QuestDetailBloc, QuestDetailState>(
        'should handle multiple load requests correctly',
        build: () {
          when(mockRepository.getQuestById(1))
              .thenAnswer((_) async => Right(tQuest));
          when(mockRepository.getQuestById(2))
              .thenAnswer((_) async => Right(tQuest.copyWith(id: 2)));
          return questDetailBloc;
        },
        act: (bloc) {
          bloc.add(const QuestDetailLoadRequested(questId: 1));
          bloc.add(const QuestDetailLoadRequested(questId: 2));
        },
        expect: () => [
          const QuestDetailLoading(),
          QuestDetailLoaded(quest: tQuest),
          const QuestDetailLoading(),
          QuestDetailLoaded(quest: QuestApiModel(
            id: 2,
            title: tQuest.title,
            shortDescription: tQuest.shortDescription,
            fullDescription: tQuest.fullDescription,
            imageUrl: tQuest.imageUrl,
            categoryId: tQuest.categoryId,
            categoryTitle: tQuest.categoryTitle,
            categoryImageUrl: tQuest.categoryImageUrl,
            difficulty: tQuest.difficulty,
            price: tQuest.price,
            duration: tQuest.duration,
            playerLimit: tQuest.playerLimit,
            ageLimit: tQuest.ageLimit,
            isForAdvUsers: tQuest.isForAdvUsers,
            type: tQuest.type,
            credits: tQuest.credits,
            merchList: tQuest.merchList,
            mainPreferences: tQuest.mainPreferences,
            points: tQuest.points,
            placeSettings: tQuest.placeSettings,
            priceSettings: tQuest.priceSettings,
          )),
        ],
      );
    });

    group('edge cases', () {
      blocTest<QuestDetailBloc, QuestDetailState>(
        'should handle concurrent load and refresh requests',
        build: () {
          when(mockRepository.getQuestById(any))
              .thenAnswer((_) async => Right(tQuest));
          return questDetailBloc;
        },
        seed: () => QuestDetailLoaded(quest: tQuest),
        act: (bloc) {
          bloc.add(const QuestDetailLoadRequested(questId: tQuestId));
          bloc.add(const QuestDetailRefreshRequested(questId: tQuestId));
        },
        expect: () => [
          const QuestDetailLoading(),
          QuestDetailLoaded(quest: tQuest),
          QuestDetailRefreshing(quest: tQuest),
          QuestDetailLoaded(quest: tQuest),
        ],
      );
    });
  });
} 