// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenResponseModel _$TokenResponseModelFromJson(Map<String, dynamic> json) =>
    TokenResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: (json['expires_in'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TokenResponseModelToJson(TokenResponseModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };
