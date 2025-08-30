import 'package:los_angeles_quest/features/data/datasources/unlock_requests_datasource.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/unlock_requests.dart';

class UnlockRequestRepository {
  final UnlockRequestsDatasource dataSource;

  UnlockRequestRepository({required this.dataSource});
  Future<List<UnlockRequest>> getUnlockRequests() {
    return dataSource.getUnlockRequests();
  }

  Future<bool> updateRequest(String id, String status) {
    return dataSource.updateRequest(id, status);
  }
}
