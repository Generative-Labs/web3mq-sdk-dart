import 'package:json_annotation/json_annotation.dart';
import 'package:web3mq/src/dapp_connect/model/namespace.dart';
import 'package:web3mq/src/dapp_connect/model/participant.dart';

part 'session.g.dart';

///
@JsonSerializable()
class Session {
  ///
  final String topic;

  ///
  final String pairingTopic;

  ///
  final Participant selfParticipant;

  ///
  final Participant peerParticipant;

  ///
  final String expiryDate;

  ///
  final Map<String, SessionNamespace> namespaces;

  ///
  Session(this.topic, this.pairingTopic, this.selfParticipant,
      this.peerParticipant, this.expiryDate, this.namespaces);

  /// Create a new instance from a json
  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$SessionToJson(this);
}

///
@JsonSerializable()
class SessionProperties {
  ///
  final String expiry;

  ///
  SessionProperties(this.expiry);

  /// Create a new instance from a json
  factory SessionProperties.fromJson(Map<String, dynamic> json) =>
      _$SessionPropertiesFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$SessionPropertiesToJson(this);
}

///
@JsonSerializable(explicitToJson: true)
class SessionProposal {
  ///
  final Map<String, ProposalNamespace> requiredNamespaces;

  ///
  final SessionProperties sessionProperties;

  ///
  SessionProposal(this.requiredNamespaces, this.sessionProperties);

  /// Create a new instance from a json
  factory SessionProposal.fromJson(Map<String, dynamic> json) =>
      _$SessionProposalFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$SessionProposalToJson(this);
}
