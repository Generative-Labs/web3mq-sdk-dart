import 'package:graphql/client.dart';

import '../models/cyber_user_follow_status.dart';

///
class CyberConnectionApi {
  /// Initialize a new cyber connection api
  CyberConnectionApi(Link link) {
    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  late final GraphQLClient _client;

  ///
  Future<List<CyberFollowStatus>> batchAddressesFollowStatus(
      String me, List<String> addresses) async {
    final QueryOptions options = QueryOptions(
      document: gql(_batchAddressesFollowStatusQuery),
      variables: <String, dynamic>{'toAddrList': addresses, 'me': me},
    );
    final QueryResult result = await _client.query(options);
    print('result.data: ${result.data}');
    if (result.hasException) {
      return [];
    }

    final items = result.data?["batchGetAddresses"] as List<dynamic>?;

    if (items is List<dynamic> && items.isNotEmpty) {
      List<CyberFollowStatus> results = [];
      for (var status in items) {
        final address = status['address'] as String?;
        final isFollowedByMe =
            status['wallet']?['primaryProfile']?['isFollowedByMe'] as bool?;
        if (address is String && isFollowedByMe is bool) {
          results.add(CyberFollowStatus(address, isFollowedByMe));
        }
      }
      return results;
    } else {
      return [];
    }
  }

  final String _batchAddressesFollowStatusQuery =
      r'''
query BatchAddressesFollowStatus($me: AddressEVM!, $toAddrList: [AddressEVM!]!) {
  batchGetAddresses(addresses: $toAddrList) {
    address
    wallet {
      primaryProfile {
        isFollowedByMe(me: $me)
      }
    }
  }
}
''';
}
