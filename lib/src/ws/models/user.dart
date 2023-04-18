import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

/// The Did info which contains [type] and [value].
@JsonSerializable()
class DID extends Equatable {
  /// The did type, eg. `eth`.
  final String type;

  /// The did value,
  ///
  /// if [type] is `eth`, then [value] should be the address
  /// of the eth wallet.
  final String value;

  ///
  DID(this.type, this.value);

  @override
  List<Object?> get props => [type, value];
}

///
@JsonSerializable()
class User {
  ///
  final String userId;

  ///
  final DID did;

  ///
  final String sessionKey;

  ///
  User(this.userId, this.did, this.sessionKey);
}

extension PublicKey on User {
  /// Public key with hex encoded.
  Future<String?> get publicKey async {
    final keyPair = await Ed25519().newKeyPairFromSeed(hex.decode(sessionKey));
    final publicKey = await keyPair.extractPublicKey();
    return hex.encode(publicKey.bytes);
  }
}
