import 'package:graphql/client.dart';
import 'package:logging/logging.dart';
import 'package:web3mq/src/api/cyber_auth_api.dart';
import 'package:web3mq/src/api/cyber_profile_api.dart';

/// a Cyber Service
class CyberService {
  final String _apiKey = 'g088Mb6LN2QYNhW0H2NDQTwtl5sZ7o8D';
  final String _endpoint = 'https://api.cyberconnect.dev/testnet/';

  /// Initialize a new CyberConnect service
  CyberService(String? accessToken, {Logger? logger}) {
    final httpLink =
        HttpLink(_endpoint, defaultHeaders: {'X-API-KEY': _apiKey});

    final authLink = AuthLink(
      getToken: () async => 'bearer $accessToken',
    );

    _link = authLink.concat(httpLink);
  }

  ///
  late final Link _link;

  CyberAuthApi? _auth;

  CyberProfileApi? _profile;

  /// Api for auth.
  CyberAuthApi get auth => _auth ??= CyberAuthApi(_link);

  /// Api for auth.
  CyberProfileApi get profile => _profile ??= CyberProfileApi(_link);
}
