import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final String email;
  final String password1;
  final String password2;
  final String username;
  final String firstName;
  final String lastName;

  const RegisterRequestModel({
    required this.email,
    required this.password1,
    required this.password2,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}
