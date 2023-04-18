import 'package:web3mq/src/client.dart';
import 'package:web3mq/src/ws/models/user.dart';

Future<void> main() async {
  final client = Web3MQClient('b67pax5b2wdq');

  await client.connectUser(User(
      "user:7c0b577c0786e51f90522f833bf8ac8749cb32d681e7eccedba1dcc45f9a5173",
      DID("eth",
          "0x7c0b577c0786e51f90522f833bf8ac8749cb32d681e7eccedba1dcc45f9a5173"),
      "0bf8eae8be0e7d364710ad1027598bb273e8122f75d4b70886f6ad855c03a991"));

  client.notificationStream.listen((event) {
    // handle with the notifications.
  });
}
