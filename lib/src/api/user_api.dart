import 'dart:async';

import 'package:web3mq/src/api/responses.dart';

import '../error/error.dart';
import '../http/http_client.dart';

class UserApi {
  /// Initialize a new user api
  UserApi(this._client);

  final Web3MQHttpClient _client;

  Future<UserRegisterResponse> register(
      String didType,
      String didValue,
      String userId,
      String pubKey,
      String pubKeyType,
      String signatureRaw,
      String signature,
      DateTime timestamp,
      String accessKey) async {
    final response = await _client.post(
      '/api/user_register_v2/',
      data: {
        'userid': userId,
        "did_type": didType,
        "did_value": didValue,
        "did_signature": signature,
        "pubkey_value": pubKey,
        "pubkey_type": pubKeyType,
        "timestamp": timestamp.millisecondsSinceEpoch,
        "signature_content": signatureRaw,
        "testnet_access_key": accessKey
      },
    );
    final res = Web3MQResponse<UserRegisterResponse>.fromJson(
        response.data, (json) => UserRegisterResponse.fromJson(json));
    final data = res.data;
    if (res.code == 0 && null != data) {
      return data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  Future<UserLoginResponse> login(
      String userId,
      String didType,
      String didValue,
      String signature,
      String signatureRaw,
      String mainPublicKey,
      String publicKey,
      String publicKeyType,
      int timestamp,
      int publicKeyExpiredTimestamp) async {
    final response = await _client.post("/api/user_login_v2/", data: {
      "userid": userId,
      "did_type": didType,
      "did_value": didValue,
      "login_signature": signature,
      "signature_content": signatureRaw,
      "main_pubkey": mainPublicKey,
      "pubkey_value": publicKey,
      "pubkey_type": publicKeyType,
      "timestamp": timestamp,
      "pubkey_expired_timestamp": publicKeyExpiredTimestamp
    });

    final res = Web3MQResponse<UserLoginResponse>.fromJson(
        response.data, (json) => UserLoginResponse.fromJson(json));
    final data = res.data;
    if (res.code == 0 && null != data) {
      return data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  Future<UserInfo?> userInfo(String didType, String didValue) async {
    final response = await _client.post("/api/get_user_info/", data: {
      "did_type": didType,
      "did_value": didValue,
      "timestamp": DateTime.now().millisecondsSinceEpoch
    });
    final res = Web3MQResponse<UserInfo>.fromJson(
        response.data, (json) => UserInfo.fromJson(json));
    final data = res.data;
    if (res.code == 0) {
      return data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Follow a user
  Future<void> follow(String targetUserId, String message) async {}
}
