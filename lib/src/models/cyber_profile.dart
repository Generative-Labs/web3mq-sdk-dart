import 'package:json_annotation/json_annotation.dart';

part 'cyber_profile.g.dart';

@JsonSerializable()
class MetadataInfo {
  final String avatar;

  final String displayName;

  MetadataInfo(this.avatar, this.displayName);

  /// Create a new instance from a json
  factory MetadataInfo.fromJson(Map<String, dynamic> json) =>
      _$MetadataInfoFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$MetadataInfoToJson(this);
}

///
@JsonSerializable()
class CyberProfile {
  @JsonKey(name: 'profileID')
  final String id;

  final String avatar;

  ///
  final bool isPrimary;

  ///
  final MetadataInfo metadataInfo;

  ///
  CyberProfile(this.id, this.avatar, this.isPrimary, this.metadataInfo);

  /// Create a new instance from a json
  factory CyberProfile.fromJson(Map<String, dynamic> json) =>
      _$CyberProfileFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$CyberProfileToJson(this);
}
