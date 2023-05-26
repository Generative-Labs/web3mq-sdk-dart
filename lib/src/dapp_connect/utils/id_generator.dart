import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';

///
abstract class IdGenerator {
  ///
  String next();
}

///
class DappConnectRequestIdGenerator extends IdGenerator {
  ///
  @override
  String next() {
    final timestamp = DateTime.now().millisecondsSinceEpoch * 1000;
    final random = Random().nextInt(1000);
    return '$random$timestamp';
  }
}

///
class UserIdGenerator {
  ///
  static Future<String> create(
      String appId, String publicKeyBase64String) async {
    final pre = "$appId@$publicKeyBase64String";
    final algorithm = Sha1();
    final bytes = utf8.encode(pre);
    final hash = await algorithm.hash(bytes);
    final hexString = hex.encode(hash.bytes);
    return 'bridge:$hexString';
  }
}
