import 'package:shared_preferences/shared_preferences.dart';

///
abstract class TokenProvider {
  ///
  static Future<String?> fetchToken() {
    throw UnimplementedError();
  }

  ///
  static void saveToken(String token) {
    throw UnimplementedError();
  }
}

///
class CyberTokenProvider extends TokenProvider {
  static final String _cacheKey = 'com.web3mq.cyber_token';

  static Future<String?> fetchToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_cacheKey);
  }

  static void saveToken(String token) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_cacheKey, token);
  }
}
