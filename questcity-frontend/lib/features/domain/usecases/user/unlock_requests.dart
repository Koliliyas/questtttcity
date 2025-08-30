import 'package:los_angeles_quest/features/data/repositories/unlock_request_repository.dart';

class UnlockRequests {
  final UnlockRequestRepository repository;

  UnlockRequests(this.repository);

  Future<List<UnlockRequest>> getUnlockRequests() async {
    return await repository.getUnlockRequests();
  }

  Future<bool> updateRequest(String id, String status) async {
    return await repository.updateRequest(id, status);
  }
}

class UnlockRequest {
  final String id;
  final String email;
  final String reason;
  final String status;
  final String message;
  final String createdAt;
  final String updatedAt;

  UnlockRequest({
    required this.id,
    required this.email,
    required this.reason,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnlockRequest.fromJson(Map<String, dynamic> json) {
    return UnlockRequest(
      id: json['id'],
      email: json['email'],
      reason: json['reason'],
      status: json['status'],
      message: json['message'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
