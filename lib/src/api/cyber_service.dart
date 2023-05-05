import 'package:graphql/client.dart';
import 'package:logging/logging.dart';
import 'package:web3mq/src/api/cyber_auth_api.dart';
import 'package:web3mq/src/api/cyber_connection_api.dart';
import 'package:web3mq/src/api/cyber_profile_api.dart';

/// a Cyber Service
class CyberService {
  final String _apiKey = 'g088Mb6LN2QYNhW0H2NDQTwtl5sZ7o8D';
  final String _endpoint = 'https://api.cyberconnect.dev/testnet/';

  /// Initialize a new CyberConnect service
  CyberService(this.accessToken, {Logger? logger}) {
    final httpLink =
        HttpLink(_endpoint, defaultHeaders: {'X-API-KEY': _apiKey});

    final authLink = AuthLink(
      getToken: () async => 'bearer $accessToken',
    );

    _link = authLink.concat(httpLink);
  }

  String? accessToken;

  ///
  late final Link _link;

  CyberAuthApi? _auth;

  CyberProfileApi? _profile;

  CyberConnectionApi? _connection;

  /// Api for auth.
  CyberAuthApi get auth => _auth ??= CyberAuthApi(_link);

  /// Api for profile.
  CyberProfileApi get profile => _profile ??= CyberProfileApi(_link);

  /// Api for connection.
  CyberConnectionApi get connection =>
      _connection ??= CyberConnectionApi(_link);
}
