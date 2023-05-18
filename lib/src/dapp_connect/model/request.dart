import 'package:json_annotation/json_annotation.dart';

part 'request.g.dart';

///
@JsonSerializable()
class Request {
  ///
  final String id;

  ///
  final String method;

  ///
  final dynamic params;

  ///
  final String topic;

  ///
  final String publicKey;

  ///
  Request(this.id, this.method, this.params, this.topic, this.publicKey);

  /// Create a new instance from a json
  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
