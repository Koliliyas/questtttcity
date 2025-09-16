import 'package:los_angeles_quest/features/data/datasources/quest_detail_remote_data_source.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_detail_repository.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';

class QuestDetailRepositoryImpl implements QuestDetailRepository {
  final QuestDetailRemoteDataSource _remoteDataSource;

  QuestDetailRepositoryImpl(this._remoteDataSource);

  @override
  Future<QuestDetails> getQuestDetail(int questId) async {
    try {
      final response = await _remoteDataSource.getQuestDetail(questId);
      
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      return _mapResponseToQuestDetails(response);
    } catch (e) {
      throw Exception('Failed to get quest detail: $e');
    }
  }

  QuestDetails _mapResponseToQuestDetails(Map<String, dynamic> response) {
    // Маппинг данных из API в модель QuestDetails
    final points = (response['points'] as List<dynamic>? ?? [])
        .map((point) => QuestPoint(
              id: point['id'] ?? 0,
              name: point['name'] ?? '',
              description: point['description'] ?? '',
              image: point['image'] ?? '',
              latitude: point['places']?.isNotEmpty == true 
                  ? (point['places'][0]['latitude'] ?? 0.0).toDouble()
                  : 0.0,
              longitude: point['places']?.isNotEmpty == true 
                  ? (point['places'][0]['longitude'] ?? 0.0).toDouble()
                  : 0.0,
              type: _getPointType(point['order'] ?? 0),
            ))
        .toList();

    final merch = (response['merch'] as List<dynamic>? ?? [])
        .map((item) => QuestMerchandise(
              id: item['id'] ?? 0,
              name: item['description'] ?? '',
              description: item['description'] ?? '',
              image: item['image'] ?? '',
              price: item['price'] ?? 0,
            ))
        .toList();

    final reviews = (response['reviews'] as List<dynamic>? ?? [])
        .map((review) => QuestReview(
              id: review['id'] ?? 0,
              userName: review['userName'] ?? 'Anonymous',
              text: review['text'] ?? '',
              rating: review['rating'] ?? 0,
              createdAt: review['createdAt'] ?? '',
            ))
        .toList();

    final mainPreferences = MainPreferences(
      categoryId: response['mainPreferences']?['categoryId'] ?? 0,
      group: response['mainPreferences']?['group'],
      vehicleId: response['mainPreferences']?['vehicleId'] ?? 0,
      price: Price(
        amount: response['mainPreferences']?['price']?['amount'] ?? 0,
        isSubscription: response['mainPreferences']?['price']?['isSubscription'] ?? false,
      ),
      timeframe: response['mainPreferences']?['timeframe'],
      level: response['mainPreferences']?['level'] ?? 'beginner',
      milege: response['mainPreferences']?['mileage'] ?? 'local',
      placeId: response['mainPreferences']?['placeId'] ?? 0,
    );

    final credits = QuestCredits(
      cost: response['credits']?['cost'] ?? 0,
      reward: response['credits']?['reward'] ?? 0,
      autoAccrual: response['credits']?['auto'] ?? false,
    );

    return QuestDetails(
      id: response['id'] ?? 0,
      name: response['name'] ?? '',
      description: response['description'] ?? '',
      image: response['image'] ?? '',
      rating: (response['rating'] ?? 0.0).toDouble(),
      mainPreferences: mainPreferences,
      points: points,
      reviews: reviews,
      merch: merch,
      credits: credits,
    );
  }

  String _getPointType(int order) {
    if (order == 1) return 'start';
    if (order == 2) return 'halfway';
    return 'end';
  }
}
