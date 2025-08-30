import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:los_angeles_quest/core/error/failures.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_api_model.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_list_bloc.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_list_event.dart';
import 'package:los_angeles_quest/features/presentation/bloc/quest/quest_list_state.dart';
import '../../../../helpers/test_helpers.dart';
import '../../../../helpers/mock_helpers.dart';

void main() {
  late QuestListBloc questListBloc;
  late MockQuestApiRepository mockRepository;

  setUp(() {
    mockRepository = MockFactory.createMockRepository();
    questListBloc = QuestListBloc(questApiRepository: mockRepository);
  });

  tearDown(() {
    questListBloc.close();
  });

  final tQuestList = [
    QuestListItemApiModel.fromJson(TestHelpers.questListItemJson()),
    QuestListItemApiModel.fromJson({
      ...TestHelpers.questListItemJson(),
      'id': 2,
      'name': 'Second Quest',
      'rating': 3.8
    }),
  ];

  group('QuestListBloc', () {
    test('initial state should be QuestListInitial', () {
      expect(questListBloc.state, equals(const QuestListInitial()));
    });

    group('QuestListLoadRequested', () {
      blocTest<QuestListBloc, QuestListState>(
        'should emit [QuestListLoading, QuestListLoaded] when data is gotten successfully',
        build: () {
          when(mockRepository.getAllQuests())
              .thenAnswer((_) async => Right(tQuestList));
          return questListBloc;
        },
        act: (bloc) => bloc.add(const QuestListLoadRequested()),
        expect: () => [
          const QuestListLoading(),
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: tQuestList,
            searchQuery: '',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
        ],
        verify: (bloc) {
          verify(mockRepository.getAllQuests());
        },
      );

      blocTest<QuestListBloc, QuestListState>(
        'should emit [QuestListLoading, QuestListEmpty] when no quests are returned',
        build: () {
          when(mockRepository.getAllQuests())
              .thenAnswer((_) async => const Right([]));
          return questListBloc;
        },
        act: (bloc) => bloc.add(const QuestListLoadRequested()),
        expect: () => [
          const QuestListLoading(),
          const QuestListEmpty(),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should emit [QuestListLoading, QuestListError] when getting data fails',
        build: () {
          when(mockRepository.getAllQuests())
              .thenAnswer((_) async => const Left(ServerFailure('Ошибка сервера. Попробуйте позже')));
          return questListBloc;
        },
        act: (bloc) => bloc.add(const QuestListLoadRequested()),
        expect: () => [
          const QuestListLoading(),
          const QuestListError(message: 'Ошибка сервера. Попробуйте позже'),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should emit [QuestListLoading, QuestListError] when unauthorized',
        build: () {
          when(mockRepository.getAllQuests())
              .thenAnswer((_) async => const Left(UnauthorizedFailure('Ошибка авторизации. Войдите в аккаунт')));
          return questListBloc;
        },
        act: (bloc) => bloc.add(const QuestListLoadRequested()),
        expect: () => [
          const QuestListLoading(),
          const QuestListError(message: 'Ошибка авторизации. Войдите в аккаунт'),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should emit [QuestListLoading, QuestListError] when network failure',
        build: () {
          when(mockRepository.getAllQuests())
              .thenAnswer((_) async => const Left(NetworkFailure('Проверьте подключение к интернету')));
          return questListBloc;
        },
        act: (bloc) => bloc.add(const QuestListLoadRequested()),
        expect: () => [
          const QuestListLoading(),
          const QuestListError(message: 'Проверьте подключение к интернету'),
        ],
      );
    });

    group('QuestListRefreshRequested', () {
      blocTest<QuestListBloc, QuestListState>(
        'should emit [QuestListRefreshing, QuestListLoaded] when refresh is successful',
        build: () {
          when(mockRepository.getAllQuests())
              .thenAnswer((_) async => Right(tQuestList));
          return questListBloc;
        },
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListRefreshRequested()),
        expect: () => [
          QuestListRefreshing(
            quests: tQuestList,
            filteredQuests: tQuestList,
            searchQuery: '',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: tQuestList,
            searchQuery: '',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should emit [QuestListRefreshing, QuestListError] when refresh fails',
        build: () {
          when(mockRepository.getAllQuests())
              .thenAnswer((_) async => const Left(ServerFailure('Ошибка сервера. Попробуйте позже')));
          return questListBloc;
        },
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListRefreshRequested()),
        expect: () => [
          QuestListRefreshing(
            quests: tQuestList,
            filteredQuests: tQuestList,
            searchQuery: '',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
          const QuestListError(message: 'Ошибка сервера. Попробуйте позже'),
        ],
      );
    });

    group('QuestListSearchRequested', () {
      blocTest<QuestListBloc, QuestListState>(
        'should filter quests by search query',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListSearchRequested(query: 'Test')),
        expect: () => [
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: [tQuestList.first], // Only "Test Quest" should match
            searchQuery: 'Test',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should show empty result when no quests match search query',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListSearchRequested(query: 'NonExistentQuest')),
        expect: () => [
          const QuestListEmpty(),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should clear search and show all quests when query is empty',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: [tQuestList.first],
          searchQuery: 'Test',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListSearchRequested(query: '')),
        expect: () => [
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: tQuestList,
            searchQuery: '',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
        ],
      );
    });

    group('QuestListFilterRequested', () {
      blocTest<QuestListBloc, QuestListState>(
        'should apply difficulty filter',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListFilterRequested(
          filterType: QuestFilterType.difficulty,
          filterValue: 'Easy',
        )),
        expect: () => [
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: tQuestList, // Both test quests don't have difficulty in the test data
            searchQuery: '',
            selectedFilters: const {'difficulty': 'Easy'},
            hasReachedMax: false,
          ),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should apply rating filter',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListFilterRequested(
          filterType: QuestFilterType.rating,
          filterValue: '4+',
        )),
        expect: () => [
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: [tQuestList.first], // Only first quest has rating 4.5
            searchQuery: '',
            selectedFilters: const {'rating': '4+'},
            hasReachedMax: false,
          ),
        ],
      );
    });

    group('QuestListFiltersCleared', () {
      blocTest<QuestListBloc, QuestListState>(
        'should clear all filters and show all quests',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: [tQuestList.first],
          searchQuery: 'Test',
          selectedFilters: const {'difficulty': 'Easy', 'rating': '4+'},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListFiltersCleared()),
        expect: () => [
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: tQuestList,
            searchQuery: '',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
        ],
      );
    });

    group('QuestListErrorCleared', () {
      blocTest<QuestListBloc, QuestListState>(
        'should clear error and return to initial state',
        build: () => questListBloc,
        seed: () => const QuestListError(message: 'Test error'),
        act: (bloc) => bloc.add(const QuestListErrorCleared()),
        expect: () => [
          const QuestListInitial(),
        ],
      );
    });

    group('edge cases', () {
      blocTest<QuestListBloc, QuestListState>(
        'should handle multiple rapid search requests',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {},
          hasReachedMax: false,
        ),
        act: (bloc) {
          bloc.add(const QuestListSearchRequested(query: 'T'));
          bloc.add(const QuestListSearchRequested(query: 'Te'));
          bloc.add(const QuestListSearchRequested(query: 'Test'));
        },
        expect: () => [
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: [tQuestList.first],
            searchQuery: 'T',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: [tQuestList.first],
            searchQuery: 'Te',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: [tQuestList.first],
            searchQuery: 'Test',
            selectedFilters: const {},
            hasReachedMax: false,
          ),
        ],
      );

      blocTest<QuestListBloc, QuestListState>(
        'should handle search with filters applied',
        build: () => questListBloc,
        seed: () => QuestListLoaded(
          quests: tQuestList,
          filteredQuests: tQuestList,
          searchQuery: '',
          selectedFilters: const {'rating': '4+'},
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const QuestListSearchRequested(query: 'Test')),
        expect: () => [
          QuestListLoaded(
            quests: tQuestList,
            filteredQuests: [tQuestList.first], // Search + rating filter should return first quest
            searchQuery: 'Test',
            selectedFilters: const {'rating': '4+'},
            hasReachedMax: false,
          ),
        ],
      );
    });

    group('state management', () {
      test('should properly manage questApiRepository', () {
        expect(questListBloc.questApiRepository, equals(mockRepository));
      });

      blocTest<QuestListBloc, QuestListState>(
        'should not emit new state if already in same state',
        build: () => questListBloc,
        seed: () => const QuestListInitial(),
        act: (bloc) => bloc.add(const QuestListErrorCleared()),
        expect: () => [],
      );
    });
  });
} 