// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      json['id'] as String,
      RPCResult.fromJson(json['result'] as Map<String, dynamic>),
      json['topic'] as String,
      json['publicKey'] as String,
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'id': instance.id,
      'result': instance.result,
      'topic': instance.topic,
      'publicKey': instance.publicKey,
    };
