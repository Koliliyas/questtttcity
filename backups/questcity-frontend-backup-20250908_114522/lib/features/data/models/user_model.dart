import 'package:los_angeles_quest/features/data/models/person_model.dart';
import 'package:los_angeles_quest/features/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.createdAt,
    required super.role,
    required super.username,
    required super.updatedAt,
    required super.email,
    required super.isActive,
    required super.isVerified,
    required super.photoPath,
    required super.instagram,
    required super.profileId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: json['createdAt'],
      role: json['role'],
      username: json['username'],
      updatedAt: json['updatedAt'],
      email: json['email'],
      isActive: json['isActive'],
      isVerified: json['isVerified'],
      instagram: json['profile']['instagramUsername'],
      photoPath: json['profile']['avatarUrl'],
      profileId: json['profile']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': super.id,
      'firstName': super.firstName,
      'lastName': super.lastName,
      'createdAt': super.createdAt,
      'role': super.role,
      'username': super.username,
      'updatedAt': super.updatedAt,
      'email': super.email,
      'isActive': super.isActive,
      'isVerified': super.isVerified,
      'profile': {
        'avatarUrl': super.photoPath,
        'instagramUsername': super.instagram,
        'id': super.profileId,
      },
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      createdAt: entity.createdAt,
      role: entity.role,
      username: entity.username,
      updatedAt: entity.updatedAt,
      email: entity.email,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
      photoPath: entity.photoPath,
      instagram: entity.instagram,
      profileId: entity.profileId,
    );
  }

  factory UserModel.fromPerson(PersonModel model) {
    return UserModel(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      createdAt: model.createdAt.toIso8601String(),
      role: model.role,
      username: model.username,
      updatedAt: model.updatedAt.toIso8601String(),
      email: model.email,
      isActive: model.isActive,
      isVerified: model.isVerified,
      photoPath: model.profile.avatarUrl,
      instagram: model.profile.instagramUsername,
      profileId: model.profile.id,
    );
  }
}
