import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int role;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String password;

  const PersonEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        role,
        isActive,
        isVerified,
        createdAt,
        updatedAt,
      ];

  PersonEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    int? role,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? password,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      password: password ?? this.password,
    );
  }
}
