import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3mq/src/dapp_connect/model/session.dart';

/// Session proposal storage.
abstract class SessionProposalStorage {
  /// Set session proposal.
  void setSessionProposal(String proposalId, SessionProposal sessionProposal);

  /// Get session proposal.
  SessionProposal? getSessionProposal(String proposalId);

  /// Remove session proposal.
  void removeSessionProposal(String proposalId);

  /// Clear all session proposals.
  void clear();
}

///
class Web3MQSessionProposalStorage extends SessionProposalStorage {
  final SharedPreferences prefs;

  Web3MQSessionProposalStorage(this.prefs);

  @override
  SessionProposal? getSessionProposal(String proposalId) {
    final jsonString = prefs.getString(_getCacheKey(proposalId));
    if (jsonString == null) {
      return null;
    }
    final json = jsonDecode(jsonString);
    return SessionProposal.fromJson(json);
  }

  @override
  void removeSessionProposal(String proposalId) {
    prefs.remove(_getCacheKey(proposalId));
  }

  @override
  void setSessionProposal(String proposalId, SessionProposal sessionProposal) {
    prefs.setString(_getCacheKey(proposalId), jsonEncode(sessionProposal));
  }

  @override
  void clear() {
    prefs.getKeys().forEach((key) {
      if (key.startsWith(_cachePrefix)) {
        prefs.remove(key);
      }
    });
  }

  final _cachePrefix = 'com.web3mq.session_proposal_';

  ///
  String _getCacheKey(String proposalId) => "$_cachePrefix$proposalId";
}
