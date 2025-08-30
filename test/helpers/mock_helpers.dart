import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/quest_api_datasource.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_api_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mock_helpers.mocks.dart';

// Аннотации для генерации mock классов
@GenerateMocks([
  http.Client,
  FlutterSecureStorage,
  InternetConnectionChecker,
  NetworkInfo,
  QuestApiDataSource,
  QuestApiRepository,
])
void main() {}

/// Фабрика для создания mock объектов
class MockFactory {
  static MockHttpClient createMockHttpClient() => MockHttpClient();
  static MockFlutterSecureStorage createMockSecureStorage() => MockFlutterSecureStorage();
  static MockInternetConnectionChecker createMockConnectionChecker() => MockInternetConnectionChecker();
  static MockNetworkInfo createMockNetworkInfo() => MockNetworkInfo();
  static MockQuestApiDataSource createMockDataSource() => MockQuestApiDataSource();
  static MockQuestApiRepository createMockRepository() => MockQuestApiRepository();
} 