// Este archivo se usa en ambas plataformas
// En web, retorna null; en móvil/desktop, crea File/Directory reales
import 'dart:io' if (dart.library.html) 'dart:html' as io_stub;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper para crear File que solo funciona en móvil/desktop
class FileHelperStub {
  static dynamic createFile(String path) {
    if (kIsWeb) {
      return null;
    }
    // En móvil/desktop, io_stub es dart:io, así que File(path) funciona
    // Usar un método que evite problemas de compilación
    return _createFileNative(path);
  }
  
  static dynamic _createFileNative(String path) {
    // Este método solo se ejecuta cuando no estamos en web
    // En móvil/desktop, io_stub.File es File de dart:io
    if (kIsWeb) {
      return null;
    }
    // Necesitamos evitar que el compilador vea esto en web
    // Usar un cast dinámico
    try {
      return io_stub.File(path) as dynamic;
    } catch (e) {
      return null;
    }
  }
  
  static dynamic createDirectory(String path) {
    if (kIsWeb) {
      return null;
    }
    // En móvil/desktop, crear Directory
    return _createDirectoryNative(path);
  }
  
  static dynamic _createDirectoryNative(String path) {
    if (kIsWeb) {
      return null;
    }
    try {
      return io_stub.Directory(path) as dynamic;
    } catch (e) {
      return null;
    }
  }
}

