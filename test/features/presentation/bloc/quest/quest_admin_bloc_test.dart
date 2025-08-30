import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:los_angeles_quest/core/error/failures.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_api_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_request_model.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_admin_bloc.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_admin_event.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_admin_state.dart';
import '../../../../helpers/test_helpers.dart';
import '../../../../helpers/mock_helpers.dart';

void main() {
  late QuestAdminBloc questAdminBloc;
  late MockQuestApiRepository mockRepository;

  setUp(() {
    mockRepository = MockFactory.createMockRepository();
    questAdminBloc = QuestAdminBloc(questApiRepository: mockRepository);
  });

  tearDown(() {
    questAdminBloc.close();
  });

  final tQuest = QuestApiModel.fromJson(TestHelpers.questDetailJson());
  final tCreateRequest = QuestCreateRequestModel.fromJson(TestHelpers.questCreateRequestJson());
  const tUpdateRequest = QuestUpdateRequestModel(name: 'Updated Quest');
  const tQuestId = 1;

  group('QuestAdminBloc', () {
    test('initial state should be QuestAdminInitial', () {
      expect(questAdminBloc.state, equals(const QuestAdminInitial()));
    });

    group('QuestAdminCreateRequested', () {
      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminCreated] when creation is successful',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => Right(tQuest));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest)),
        expect: () => [
          const QuestAdminLoading(),
          QuestAdminCreated(quest: tQuest),
        ],
        verify: (bloc) {
          verify(mockRepository.createQuest(tCreateRequest));
        },
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when creation fails with ServerFailure',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => const Left(ServerFailure('Ошибка сервера. Попробуйте позже')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Ошибка сервера. Попробуйте позже'),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when creation fails with ConflictFailure',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => const Left(ConflictFailure('Квест с таким названием уже существует')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Квест с таким названием уже существует'),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when creation fails with ForbiddenFailure',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => const Left(ForbiddenFailure('Нет доступа к данному ресурсу')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Нет доступа к данному ресурсу'),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when creation fails with UnauthorizedFailure',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => const Left(UnauthorizedFailure('Ошибка авторизации. Войдите в аккаунт')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Ошибка авторизации. Войдите в аккаунт'),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when creation fails with NetworkFailure',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => const Left(NetworkFailure('Проверьте подключение к интернету')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Проверьте подключение к интернету'),
        ],
      );
    });

    group('QuestAdminUpdateRequested', () {
      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminUpdated] when update is successful',
        build: () {
          when(mockRepository.updateQuest(any, any))
              .thenAnswer((_) async => Right(tQuest));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(const QuestAdminUpdateRequested(
          questId: tQuestId,
          updateRequest: tUpdateRequest,
        )),
        expect: () => [
          const QuestAdminLoading(),
          QuestAdminUpdated(quest: tQuest),
        ],
        verify: (bloc) {
          verify(mockRepository.updateQuest(tQuestId, tUpdateRequest));
        },
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when update fails with NotFoundFailure',
        build: () {
          when(mockRepository.updateQuest(any, any))
              .thenAnswer((_) async => const Left(NotFoundFailure('Квест не найден')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(const QuestAdminUpdateRequested(
          questId: tQuestId,
          updateRequest: tUpdateRequest,
        )),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Квест не найден'),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when update fails with ForbiddenFailure',
        build: () {
          when(mockRepository.updateQuest(any, any))
              .thenAnswer((_) async => const Left(ForbiddenFailure('Нет доступа к данному ресурсу')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(const QuestAdminUpdateRequested(
          questId: tQuestId,
          updateRequest: tUpdateRequest,
        )),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Нет доступа к данному ресурсу'),
        ],
      );
    });

    group('QuestAdminDeleteRequested', () {
      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminDeleted] when deletion is successful',
        build: () {
          when(mockRepository.deleteQuest(any))
              .thenAnswer((_) async => const Right(unit));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(const QuestAdminDeleteRequested(questId: tQuestId)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminDeleted(questId: tQuestId),
        ],
        verify: (bloc) {
          verify(mockRepository.deleteQuest(tQuestId));
        },
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when deletion fails with NotFoundFailure',
        build: () {
          when(mockRepository.deleteQuest(any))
              .thenAnswer((_) async => const Left(NotFoundFailure('Квест не найден')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(const QuestAdminDeleteRequested(questId: tQuestId)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Квест не найден'),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should emit [QuestAdminLoading, QuestAdminError] when deletion fails with ForbiddenFailure',
        build: () {
          when(mockRepository.deleteQuest(any))
              .thenAnswer((_) async => const Left(ForbiddenFailure('Нет доступа к данному ресурсу')));
          return questAdminBloc;
        },
        act: (bloc) => bloc.add(const QuestAdminDeleteRequested(questId: tQuestId)),
        expect: () => [
          const QuestAdminLoading(),
          const QuestAdminError(message: 'Нет доступа к данному ресурсу'),
        ],
      );
    });

    group('QuestAdminStateCleared', () {
      blocTest<QuestAdminBloc, QuestAdminState>(
        'should clear error and return to initial state',
        build: () => questAdminBloc,
        seed: () => const QuestAdminError(message: 'Test error'),
        act: (bloc) => bloc.add(const QuestAdminStateCleared()),
        expect: () => [
          const QuestAdminInitial(),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should clear created state and return to initial state',
        build: () => questAdminBloc,
        seed: () => QuestAdminCreated(quest: tQuest),
        act: (bloc) => bloc.add(const QuestAdminStateCleared()),
        expect: () => [
          const QuestAdminInitial(),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should clear updated state and return to initial state',
        build: () => questAdminBloc,
        seed: () => QuestAdminUpdated(quest: tQuest),
        act: (bloc) => bloc.add(const QuestAdminStateCleared()),
        expect: () => [
          const QuestAdminInitial(),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should clear deleted state and return to initial state',
        build: () => questAdminBloc,
        seed: () => const QuestAdminDeleted(questId: tQuestId),
        act: (bloc) => bloc.add(const QuestAdminStateCleared()),
        expect: () => [
          const QuestAdminInitial(),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should not emit state when already in initial state',
        build: () => questAdminBloc,
        seed: () => const QuestAdminInitial(),
        act: (bloc) => bloc.add(const QuestAdminStateCleared()),
        expect: () => [],
      );
    });

    group('state management', () {
      test('should properly manage questApiRepository', () {
        expect(questAdminBloc.questApiRepository, equals(mockRepository));
      });

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should handle multiple operations sequentially',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => Right(tQuest));
          when(mockRepository.updateQuest(any, any))
              .thenAnswer((_) async => Right(tQuest));
          when(mockRepository.deleteQuest(any))
              .thenAnswer((_) async => const Right(unit));
          return questAdminBloc;
        },
        act: (bloc) {
          bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest));
          bloc.add(const QuestAdminUpdateRequested(
            questId: tQuestId,
            updateRequest: tUpdateRequest,
          ));
          bloc.add(const QuestAdminDeleteRequested(questId: tQuestId));
        },
        expect: () => [
          const QuestAdminLoading(),
          QuestAdminCreated(quest: tQuest),
          const QuestAdminLoading(),
          QuestAdminUpdated(quest: tQuest),
          const QuestAdminLoading(),
          const QuestAdminDeleted(questId: tQuestId),
        ],
      );
    });

    group('edge cases', () {
      blocTest<QuestAdminBloc, QuestAdminState>(
        'should handle concurrent admin operations',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => Right(tQuest));
          when(mockRepository.deleteQuest(any))
              .thenAnswer((_) async => const Right(unit));
          return questAdminBloc;
        },
        act: (bloc) {
          bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest));
          bloc.add(const QuestAdminDeleteRequested(questId: tQuestId));
        },
        expect: () => [
          const QuestAdminLoading(),
          QuestAdminCreated(quest: tQuest),
          const QuestAdminLoading(),
          const QuestAdminDeleted(questId: tQuestId),
        ],
      );

      blocTest<QuestAdminBloc, QuestAdminState>(
        'should handle state clearing during operations',
        build: () {
          when(mockRepository.createQuest(any))
              .thenAnswer((_) async => Right(tQuest));
          return questAdminBloc;
        },
        act: (bloc) {
          bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest));
          bloc.add(const QuestAdminStateCleared());
        },
        expect: () => [
          const QuestAdminLoading(),
          QuestAdminCreated(quest: tQuest),
          const QuestAdminInitial(),
        ],
      );
    });

    group('error message mapping', () {
      final errorMappingTests = [
        (ServerFailure('Ошибка сервера. Попробуйте позже'), 'Ошибка сервера. Попробуйте позже'),
        (UnauthorizedFailure('Ошибка авторизации. Войдите в аккаунт'), 'Ошибка авторизации. Войдите в аккаунт'),
        (NotFoundFailure('Квест не найден'), 'Квест не найден'),
        (ForbiddenFailure('Нет доступа к данному ресурсу'), 'Нет доступа к данному ресурсу'),
        (ConflictFailure('Квест с таким названием уже существует'), 'Квест с таким названием уже существует'),
        (NetworkFailure('Проверьте подключение к интернету'), 'Проверьте подключение к интернету'),
      ];

      for (final (failure, expectedMessage) in errorMappingTests) {
        blocTest<QuestAdminBloc, QuestAdminState>(
          'should map ${failure.runtimeType} to correct error message',
          build: () {
            when(mockRepository.createQuest(any))
                .thenAnswer((_) async => Left(failure));
            return questAdminBloc;
          },
          act: (bloc) => bloc.add(QuestAdminCreateRequested(createRequest: tCreateRequest)),
          expect: () => [
            const QuestAdminLoading(),
            QuestAdminError(message: expectedMessage),
          ],
        );
      }
    });
  });
} 