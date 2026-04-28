import 'dart:async';

import 'package:connectivity/connectivity.dart';

import '../../features/incidents/services/incident_sync_service.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final IncidentSyncService _incidentSyncService = IncidentSyncService();

  StreamSubscription<dynamic>? _subscription;
  bool _isConnected = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    final result = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(result);

    if (_isConnected) {
      await _incidentSyncService.syncPendingChanges();
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) async {
        final hasConnection = _hasConnection(result);

        if (hasConnection && !_isConnected) {
          _isConnected = true;
          await _incidentSyncService.syncPendingChanges();
          return;
        }

        _isConnected = hasConnection;
      },
    );
  }

  bool _hasConnection(dynamic result) {
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }

    if (result is List<ConnectivityResult>) {
      return result.any((value) => value != ConnectivityResult.none);
    }

    return false;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }
}
