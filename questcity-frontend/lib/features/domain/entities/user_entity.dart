import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String createdAt;
  final int role;
  final String username;
  final String updatedAt;
  final String email;
  final bool isActive;
  final bool isVerified;
  final String? photoPath;
  final String? instagram;
  final int profileId;

  const UserEntity(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.createdAt,
      required this.role,
      required this.username,
      required this.updatedAt,
      required this.email,
      required this.isActive,
      required this.isVerified,
      required this.photoPath,
      required this.instagram,
      required this.profileId});

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        createdAt,
        role,
        username,
        updatedAt,
        email,
        isActive,
        isVerified,
        instagram,
        photoPath,
        profileId
      ];
}
