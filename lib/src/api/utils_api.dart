import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

class TestnetDomain {
  static const String jp1 = 'https://testnet-ap-jp-1.web3mq.com';
  static const String jp2 = 'https://testnet-ap-jp-2.web3mq.com';
  static const String sg1 = 'https://testnet-ap-singapore-1.web3mq.com';
  static const String sg2 = 'https://testnet-ap-singapore-2.web3mq.com';
  static const String us1 = 'https://testnet-us-west-1-1.web3mq.com';
  static const String us2 = 'https://testnet-us-west-1-2.web3mq.com';

  final List<String> all = [sg1, sg2, us1, us2, jp1, jp2];
}

class UtilsApi {
  final dio = Dio();

  /// Get the domain with lowest latency.
  Future<String> findTheLowestLatencyUrl() async {
    final domains = TestnetDomain().all;
    final results = await Future.wait(domains.map((e) => mesure(e)));
    final lowest = results.min;
    return domains[results.indexOf(lowest)];
  }

  Future<int> mesure(String domain) async {
    final stopWatch = Stopwatch();
    stopWatch.start();
    await dio.get('$domain/api/ping/');
    stopWatch.stop();
    return stopWatch.elapsed.inMicroseconds;
  }
}
