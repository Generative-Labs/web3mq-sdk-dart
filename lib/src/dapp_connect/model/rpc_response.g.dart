// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpc_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPCResponse _$RPCResponseFromJson(Map<String, dynamic> json) => RPCResponse(
      json['id'] as String,
      json['method'] as String?,
      json['result'],
      json['error'] == null
          ? null
          : RPCError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RPCResponseToJson(RPCResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'method': instance.method,
      'result': readonly(instance.result),
      'error': readonly(instance.error),
    };
