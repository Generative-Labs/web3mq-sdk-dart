import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import '../ws/models/user.dart';

///
class SignTextFactory {
  ///
  static String forRegister(String walletTypeName, String didValue,
      String domainUrl, String nonceContent, String formattedDateString) {
    return """
Web3MQ wants you to sign in with your $walletTypeName account:
$didValue
For Web3MQ register
URI: $domainUrl
Version: 1

Nonce: $nonceContent
Issued At: $formattedDateString
""";
  }

  ///
  static String forMainPrivateKey(DID did, String password) {
    final walletType = did.type;
    final walletAddress = did.value;
    final keyIndex = 1;
    final keyMSG = "$walletType:$walletAddress$keyIndex$password";
    final magicString = "\$web3mq${keyMSG}web3mq\$";
    final sha224 = Digest("SHA3-224");
    final hashed = sha224.process(Uint8List.fromList(utf8.encode(magicString)));
    final hashedMagicString = base64Encode(hashed);
    return """
Signing this message will allow this app to decrypt messages in the Web3MQ protocol for the following address: $walletAddress. This won’t cost you anything.

If your Web3MQ wallet-associated password and this signature is exposed to any malicious app, this would result in exposure of Web3MQ account access and encryption keys, and the attacker would be able to read your messages.

In the event of such an incident, don’t panic. You can call Web3MQ’s key revoke API and service to revoke access to the exposed encryption key and generate a new one!

Nonce: $hashedMagicString
""";
  }
}
