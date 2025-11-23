import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para verificar el estado de la conectividad
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Verifica si hay conexión a internet
  Future<bool> hasConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile ||
           result == ConnectivityResult.wifi ||
           result == ConnectivityResult.ethernet;
  }

  /// Stream de cambios en la conectividad
  Stream<bool> get connectionStream async* {
    await for (final ConnectivityResult result in _connectivity.onConnectivityChanged) {
      yield result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet;
    }
  }
}

