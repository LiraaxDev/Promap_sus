import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitor de conectividade (online/offline).
abstract class ConnectivityMonitor {
  Future<bool> isOnline();

  /// Emite `true` quando há rede (Wi-Fi/4G/Ethernet) e `false` quando não há.
  Stream<bool> get onChange;
}

class ConnectivityPlusMonitor implements ConnectivityMonitor {
  ConnectivityPlusMonitor([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  bool _temRede(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async =>
      _temRede(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onChange =>
      _connectivity.onConnectivityChanged.map(_temRede).distinct();
}
