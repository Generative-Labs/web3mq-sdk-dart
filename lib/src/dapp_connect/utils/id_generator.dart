import 'dart:math';

///
abstract class IdGenerator {
  ///
  String next();
}

///
class DappConnectIdGenerator extends IdGenerator {
  ///
  @override
  String next() {
    final timestamp = DateTime.now().millisecondsSinceEpoch * 1000;
    final random = Random().nextInt(1000);
    return '$random$timestamp';
  }
}
