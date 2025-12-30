// Stub para web que retorna null para todas las operaciones
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper para crear File que solo funciona en móvil/desktop
/// En web, todos los métodos retornan null
class FileHelperStub {
  static dynamic createFile(String path) {
    return null;
  }
  
  static dynamic createDirectory(String path) {
    return null;
  }
}



