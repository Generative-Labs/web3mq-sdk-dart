import 'package:graphql/client.dart';
import 'package:logging/logging.dart';
import 'package:web3mq/src/api/cyber_auth_api.dart';

/// a Cyber Service
class CyberService {
  final String _apiKey = 'g088Mb6LN2QYNhW0H2NDQTwtl5sZ7o8D';
  final String _endpoint = 'https://api.cyberconnect.dev/testnet/';

  /// Initialize a new CyberConnect service
  CyberService(String? accessToken, {GraphQLClient? client, Logger? logger}) {
    if (null != client) {
      _client = client;
      _link = client.link;
    } else {
      final httpLink =
          HttpLink(_endpoint, defaultHeaders: {'X-API-KEY': _apiKey});

      final authLink = AuthLink(
        getToken: () async => 'bearer $accessToken',
      );

      _link = authLink.concat(httpLink);

      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: _link,
      );
    }
  }

  ///
  late final Link _link;

  ///
  late final GraphQLClient _client;

  CyberAuthApi? _auth;

  /// Api for utils.
  CyberAuthApi get auth => _auth ??= CyberAuthApi(_link);
}
