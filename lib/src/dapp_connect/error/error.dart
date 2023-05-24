import '../../error/error.dart';

///
class DappConnectError extends Web3MQError {
  DappConnectError(super.message);

  ///
  factory DappConnectError.proposalNotFound() {
    return DappConnectError("Proposal not found");
  }
}
