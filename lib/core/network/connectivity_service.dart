import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para verificar el estado de la conectividad
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Verifica si hay conexión a internet
  Future<bool> hasConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  /// Stream de cambios en la conectividad
  Stream<bool> get connectionStream async* {
    await for (final List<ConnectivityResult> results in _connectivity.onConnectivityChanged) {
      yield _isConnected(results);
    }
  }

  /// Determina si hay conexión basándose en la lista de resultados
  /// 
  /// Si la lista contiene ConnectivityResult.none y es el único elemento, está desconectado.
  /// Si contiene mobile, wifi o ethernet (incluso junto con none), está conectado.
  bool _isConnected(List<ConnectivityResult> results) {
    // Si la lista está vacía, considerar desconectado
    if (results.isEmpty) {
      return false;
    }
    
    // Verificar si tiene algún tipo de conexión válido (mobile, wifi, ethernet)
    final hasValidConnection = results.any((result) => 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
    
    // Si tiene conexión válida, está conectado (incluso si también tiene none)
    if (hasValidConnection) {
      return true;
    }
    
    // Si solo tiene none o no tiene conexiones válidas, está desconectado
    return false;
  }
}

