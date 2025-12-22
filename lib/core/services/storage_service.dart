import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Servicio para subir archivos a Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una imagen a Firebase Storage
  /// 
  /// [file] - El archivo de imagen a subir (solo en móvil/desktop, debe ser File de dart:io)
  /// [path] - La ruta en Storage donde se guardará (ej: 'transfers/guides/transfer_123.jpg')
  /// 
  /// Retorna la URL de descarga de la imagen subida
  Future<String?> uploadImage(dynamic file, String storagePath) async {
    if (kIsWeb) {
      // En web, no podemos usar File, usar uploadImageFromBytes en su lugar
      return null;
    }
    try {
      // En móvil/desktop, file es File de dart:io (a través de io.File)
      // Necesitamos hacer un cast dinámico porque el compilador no sabe que no estamos en web
      // Crear referencia al archivo en Storage
      final ref = _storage.ref().child(storagePath);
      
      // Subir el archivo (putFile espera File de dart:io)
      // Usar un cast dinámico para evitar problemas de tipo en tiempo de compilación
      final uploadTask = ref.putFile(file as dynamic);
      
      // Esperar a que termine la subida
      final snapshot = await uploadTask;
      
      // Obtener la URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('❌ [StorageService] Error al subir imagen: $e');
      return null;
    }
  }

  /// Sube una imagen desde bytes
  /// 
  /// [bytes] - Los bytes de la imagen
  /// [storagePath] - La ruta en Storage donde se guardará
  /// [contentType] - El tipo de contenido (ej: 'image/jpeg')
  /// 
  /// Retorna la URL de descarga de la imagen subida
  Future<String?> uploadImageFromBytes(
    List<int> bytes,
    String storagePath, {
    String contentType = 'image/jpeg',
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final metadata = SettableMetadata(contentType: contentType);
      
      final uploadTask = ref.putData(
        Uint8List.fromList(bytes),
        metadata,
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('❌ [StorageService] Error al subir imagen desde bytes: $e');
      return null;
    }
  }

  /// Elimina un archivo de Firebase Storage
  /// 
  /// [storagePath] - La ruta del archivo en Storage
  Future<bool> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
      return true;
    } catch (e) {
      print('❌ [StorageService] Error al eliminar archivo: $e');
      return false;
    }
  }

  /// Genera una ruta única para una guía de movilización
  /// 
  /// [transferId] - El ID de la transferencia
  /// [farmId] - El ID de la finca
  /// 
  /// Retorna una ruta como: 'transfers/{farmId}/guides/{transferId}_{timestamp}.jpg'
  String generateMobilizationGuidePath(String transferId, String farmId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = 'jpg';
    return 'transfers/$farmId/guides/${transferId}_$timestamp.$extension';
  }
}

