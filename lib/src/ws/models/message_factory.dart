import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:web3mq/src/ws/models/buffer_convertible.dart';
import 'package:web3mq/src/ws/models/pb/message.pb.dart';
import 'package:web3mq/src/ws/models/ws_models.dart';

import '../../utils/message_id_generator.dart';
import '../../utils/private_key_utils.dart';

enum PayloadType {
  text(value: "text/plain; charset=utf-8"),
  bytes(value: "application/json");

  final String value;

  const PayloadType({required this.value});
}

///
class ChatMessage extends Web3MQWebSocketMessage with Web3MQBufferConvertible {
  final Web3MQRequestMessage message;

  ChatMessage(this.message);

  @override
  GeneratedMessage toProto3Object() {
    return message;
  }

  @override
  WSCommandType get commandType => WSCommandType.message;
}

/// A message factory
class MessageFactory {
  /// Generate a [ChatMessage]
  static Future<ChatMessage> fromText(String text, String topic,
      String senderUserId, String privateKey, String nodeId,
      {bool needStore = true,
      String cipherSuite = "NONE",
      String? threadId}) async {
    var message = Web3MQRequestMessage();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = utf8.encode(text);
    final messageId = MessageIdGenerator.generate(
        senderUserId, topic, timestamp, Uint8List.fromList(payload));
    message.messageId = messageId;
    message.version = 1;
    message.payload = payload;
    message.payloadType = PayloadType.text.value;
    message.comeFrom = senderUserId;
    message.messageType =
        threadId != null ? MessageType.thread : MessageType.common;
    final ed25519 = Ed25519();
    final content = "$messageId$senderUserId$topic$nodeId$timestamp";
    final keyPair = await KeyPairUtils.keyPairFromPrivateKeyHex(privateKey);
    final signature =
        await ed25519.sign(utf8.encode(content), keyPair: keyPair);
    message.fromSign = base64Encode(signature.bytes);
    print("debug:contentTopic:$topic");
    message.contentTopic = topic;
    message.cipherSuite = cipherSuite;
    message.timestamp = Int64(timestamp);
    message.needStore = needStore;
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    message.validatePubKey = base64Encode(privateKeyBytes);
    return ChatMessage(message);
  }
}
