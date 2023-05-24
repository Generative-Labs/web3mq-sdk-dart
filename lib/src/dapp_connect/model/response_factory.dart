import 'package:web3mq/src/dapp_connect/model/response.dart';
import 'package:web3mq/src/dapp_connect/model/rpc_result.dart';
import 'package:web3mq/src/dapp_connect/model/session.dart';

///
class ResponseFactory {
  ///
  static Response createResponseByProposal(
      SessionProposal proposal, RPCResult result, String publicKey) {
    return Response(proposal.id, result, proposal.pairingTopic, publicKey);
  }
}
