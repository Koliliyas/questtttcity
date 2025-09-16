import 'package:los_angeles_quest/features/domain/entities/person_entity.dart';

class PersonModel extends PersonEntity {
  final Profile profile;
  const PersonModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required this.profile,
    required super.role,
    required super.isActive,
    required super.isVerified,
    required super.createdAt,
    required super.updatedAt,
  }) : super(
            password: '');

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      role: json['role'] as int,
      isActive: json['isActive'] as bool,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'profile': profile.toJson(),
        'role': role,
        'isActive': isActive,
        'isVerified': isVerified,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class Profile {
  final String? avatarUrl;
  final int id;
  final String? instagramUsername;

  const Profile({required this.avatarUrl, required this.id, this.instagramUsername});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      avatarUrl: json['avatarUrl'] as String?,
      id: json['id'] as int,
      instagramUsername: json['instagramUsername'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'avatarUrl': avatarUrl,
        'id': id,
        'instagramUsername': instagramUsername,
      };
}

extension PersonModelParsing on PersonModel {
  static PersonModel fromJsonWithDate(Map<String, dynamic> json) {
    json['createdAt'] = DateTime.parse(json['createdAt']);
    json['updatedAt'] = DateTime.parse(json['updatedAt']);
    return PersonModel.fromJson(json);
  }
}

extension ProfileParsing on Profile {
  static Profile fromMap(Map<String, dynamic> json) {
    return Profile.fromJson(json);
  }
}
