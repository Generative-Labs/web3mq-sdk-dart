import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'session.dart';

part 'rpc_request.g.dart';

///
@JsonSerializable()
class RPCRequest extends Equatable {
  ///
  final String id;

  ///
  final String jsonrpc = '2.0';

  ///
  final String method;

  ///
  final dynamic params;

  /// Create a new instance
  RPCRequest(this.id, this.method, this.params);

  /// Create a new instance from a json
  factory RPCRequest.fromJson(Map<String, dynamic> json) =>
      _$RPCRequestFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$RPCRequestToJson(this);

  @override
  List<Object?> get props => [id, jsonrpc, method, params];
}

///
@JsonSerializable(explicitToJson: true)
class SessionProposalRPCRequest {
  ///
  final String id;

  ///
  final String jsonrpc = '2.0';

  ///
  final String method;

  ///
  final SessionProposal params;

  ///
  SessionProposalRPCRequest(this.id, this.method, this.params);

  /// Create a new instance from a json
  factory SessionProposalRPCRequest.fromJson(Map<String, dynamic> json) =>
      _$SessionProposalRPCRequestFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$SessionProposalRPCRequestToJson(this);
}
