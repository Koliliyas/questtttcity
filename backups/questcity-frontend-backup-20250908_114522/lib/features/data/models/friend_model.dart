
abstract class IFriendModel {
  final Object id;
  final String firstName;
  final String lastName;
  final String createdAt;
  final String updatedAt;
  // final String? photoPath;

  IFriendModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
  });
}

class FriendModel extends IFriendModel {
  // final String role;
  // final String username;
  // final String email;
  // final bool isActive;
  // final bool isVerified;
  // final String? instagram;

  FriendModel({
    required super.id,
    // required this.role,
    // required this.username,
    // required this.email,
    // required this.isActive,
    // required this.isVerified,
    // required super.photoPath,
    // required this.instagram,

    required super.firstName,
    required super.lastName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: json['createdAt'],
      // role: json['role'],
      // username: json['username'],
      updatedAt: json['updatedAt'],
      // email: json['email'],
      // isActive: json['isActive'],
      // isVerified: json['isVerified'],
      // photoPath: '',
      // instagram: ''
      // photoPath: json['profile']['avatarUrl'],
      // instagram: json['instagramUsername'],
    );
  }
}

class FriendRequestModel extends IFriendModel {
  final String recipientId;
  final String status;

  FriendRequestModel({
    required this.recipientId,
    required this.status,
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      recipientId: json['requesterId'] ?? json['recipientId'],
      status: json['status'],
      // photoPath: json['profile']['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'recipientId': recipientId,
      'status': status,
    };
  }
}
