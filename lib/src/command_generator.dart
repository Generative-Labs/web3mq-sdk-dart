import 'package:web3mq/src/signer.dart';
import 'package:web3mq/src/ws/models/connect_request_message.dart';

///
class WebSocketMessageGenerator {
  ///
  static Future<ConnectRequestMessage> connectMessage(Signer signer) async {
    final result = await signer.signatureForConnectRequest();
    return ConnectRequestMessage(
        result.nodeId, result.userId, result.timestamp, result.signature);
  }
}
