import 'package:graphql/client.dart';
import 'package:web3mq/src/models/cyber_profile.dart';

///
class CyberProfileApi {
  /// Initialize a new cyber profile api
  CyberProfileApi(Link link) {
    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  late final GraphQLClient _client;

  Future<CyberProfile> getProfileByAddress(String address) async {
    final QueryOptions options = QueryOptions(
      document: gql(_getProfileByAddressQuery),
      variables: <String, dynamic>{'address': address},
    );
    final QueryResult result = await _client.query(options);
    final Map<String, dynamic> repositories = result.data?['wallet']['profiles']
        ['edges']['node'] as Map<String, dynamic>;
    return CyberProfile.fromJson(repositories);
  }

  final _getProfileByAddressQuery = r'''
query getProfileByAddress($address: AddressEVM!) {
      address(address: $address) {
        wallet {
          profiles {
            edges {
              node {
                profileID
                handle
                avatar
                isPrimary
                metadataInfo {
                  avatar
                  displayName
                }
              }
            }
          }
        }
      }
    }
''';
}
