import 'package:shared_preferences/shared_preferences.dart';

///
abstract class TokenProvider {
  ///
  Future<String?> fetchToken() {
    throw UnimplementedError();
  }

  ///
  void saveToken(String token) {
    throw UnimplementedError();
  }
}

///
class CyberTokenProvider extends TokenProvider {
  CyberTokenProvider(this.userId);

  final String userId;

  static final String _cacheKey = 'com.web3mq.cyber_token';

  String get _finalCacheKey {
    return _cacheKey + userId;
  }

  @override
  Future<String?> fetchToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_finalCacheKey);
  }

  @override
  void saveToken(String token) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_finalCacheKey, token);
  }
}
