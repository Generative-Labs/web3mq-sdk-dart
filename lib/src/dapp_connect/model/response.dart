import 'package:json_annotation/json_annotation.dart';

import 'rpc_result.dart';

part 'response.g.dart';

////
@JsonSerializable()
class Response {
  ///
  final String id;

  ///
  final RPCResult result;

  ///
  final String topic;

  ///
  final String publicKey;

  Response(this.id, this.result, this.topic, this.publicKey);

  /// Create a new instance from a json
  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
