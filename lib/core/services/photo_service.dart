import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'file_helper_stub.dart' if (dart.library.html) 'file_helper_stub_web.dart' as file_helper;

// Tipo que funciona en ambas plataformas
// En móvil: io.File es File de dart:io
// En web: retornamos null y trabajamos solo con bytes
typedef PlatformFile = dynamic;

/// Servicio para manejo de fotos
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Toma una foto desde la cámara
  /// En web retorna null, usar XFile directamente
  Future<PlatformFile?> takePhoto() async {
    if (kIsWeb) {
      return null;
    }
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (photo == null) return null;
      // Solo en móvil/desktop, donde io.File es File de dart:io
      // Necesitamos usar un cast explícito porque el compilador no sabe que no estamos en web
      return _createFile(photo.path);
    } catch (e) {
      return null;
    }
  }

  /// Selecciona una foto de la galería
  /// En web retorna null, usar XFile directamente
  Future<PlatformFile?> pickFromGallery() async {
    if (kIsWeb) {
      return null;
    }
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (photo == null) return null;
      // Solo en móvil/desktop
      return _createFile(photo.path);
    } catch (e) {
      return null;
    }
  }

  /// Crea un File solo cuando no estamos en web
  /// Esto evita problemas con el import condicional
  dynamic _createFile(String filePath) {
    if (kIsWeb) {
      return null;
    }
    // En móvil/desktop, io es dart:io, así que File existe
    // Necesitamos hacer un cast dinámico para evitar errores de compilación
      return file_helper.FileHelperStub.createFile(filePath);
  }

  /// Comprime una imagen
  /// En web retorna null, trabajar directamente con bytes
  Future<PlatformFile?> compressImage(PlatformFile imageFile) async {
    if (kIsWeb || imageFile == null) {
      return null;
    }
    try {
      // En móvil/desktop, imageFile es io.File (que es File de dart:io)
      final file = imageFile as dynamic;
      final bytes = await _readFileBytes(file);
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Redimensionar si es muy grande
      img.Image resized = image;
      if (image.width > 1920 || image.height > 1080) {
        resized = img.copyResize(
          image,
          width: image.width > 1920 ? 1920 : null,
          height: image.height > 1080 ? 1080 : null,
        );
      }

      // Comprimir
      final compressedBytes = img.encodeJpg(resized, quality: 85);
      
      // Guardar en directorio temporal
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(_getFilePath(file));
      final compressedFile = file_helper.FileHelperStub.createFile(path.join(tempDir.path, 'compressed_$fileName'));
      await _writeFileBytes(compressedFile, compressedBytes);
      
      return compressedFile;
    } catch (e) {
      return imageFile; // Retornar original si falla
    }
  }

  /// Lee bytes de un archivo (solo móvil/desktop)
  Future<Uint8List> _readFileBytes(dynamic file) async {
    if (kIsWeb) {
      throw UnsupportedError('No se puede leer archivos en web');
    }
    // En móvil/desktop, file tiene readAsBytes()
    return await (file as dynamic).readAsBytes();
  }

  /// Escribe bytes a un archivo (solo móvil/desktop)
  Future<void> _writeFileBytes(dynamic file, Uint8List bytes) async {
    if (kIsWeb) {
      throw UnsupportedError('No se puede escribir archivos en web');
    }
    // En móvil/desktop, file tiene writeAsBytes()
    await (file as dynamic).writeAsBytes(bytes);
  }

  /// Obtiene la ruta de un archivo (solo móvil/desktop)
  String _getFilePath(dynamic file) {
    if (kIsWeb) {
      return '';
    }
    // En móvil/desktop, file tiene path
    return (file as dynamic).path as String;
  }

  /// Guarda una foto en el directorio de la app
  /// En web retorna null
  Future<String?> savePhoto(PlatformFile photoFile, String entityId, String module) async {
    if (kIsWeb || photoFile == null) {
      return null;
    }
    try {
      // En móvil/desktop, photoFile es io.File (que es File de dart:io)
      final file = photoFile as dynamic;
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = file_helper.FileHelperStub.createDirectory(path.join(appDir.path, 'photos', module));
      if (!await _directoryExists(photosDir)) {
        await _createDirectory(photosDir);
      }

      final fileName = '${entityId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = file_helper.FileHelperStub.createFile(path.join(_getDirectoryPath(photosDir), fileName));
      await _copyFile(file, savedFile);

      return _getFilePath(savedFile);
    } catch (e) {
      return null;
    }
  }

  /// Verifica si un directorio existe (solo móvil/desktop)
  Future<bool> _directoryExists(dynamic dir) async {
    if (kIsWeb) return false;
    return await (dir as dynamic).exists();
  }

  /// Crea un directorio (solo móvil/desktop)
  Future<void> _createDirectory(dynamic dir) async {
    if (kIsWeb) return;
    await (dir as dynamic).create(recursive: true);
  }

  /// Obtiene la ruta de un directorio (solo móvil/desktop)
  String _getDirectoryPath(dynamic dir) {
    if (kIsWeb) return '';
    return (dir as dynamic).path as String;
  }

  /// Copia un archivo (solo móvil/desktop)
  Future<void> _copyFile(dynamic source, dynamic dest) async {
    if (kIsWeb) return;
    await (source as dynamic).copy(_getFilePath(dest));
  }

  /// Obtiene la ruta de una foto
  Future<String?> getPhotoPath(String entityId, String module) async {
    if (kIsWeb) {
      return null;
    }
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = file_helper.FileHelperStub.createDirectory(path.join(appDir.path, 'photos', module));
      if (!await _directoryExists(photosDir)) return null;

      final files = await _listDirectory(photosDir);
      for (final file in files) {
        final filePath = _getFilePath(file);
        if (filePath.contains(entityId)) {
          return filePath;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Lista el contenido de un directorio (solo móvil/desktop)
  Future<List<dynamic>> _listDirectory(dynamic dir) async {
    if (kIsWeb) return [];
    return (dir as dynamic).listSync().toList();
  }

  /// Elimina una foto
  Future<bool> deletePhoto(String photoPath) async {
    if (kIsWeb) {
      return false;
    }
    try {
      final file = file_helper.FileHelperStub.createFile(photoPath);
      if (await _fileExists(file)) {
        await _deleteFile(file);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si un archivo existe (solo móvil/desktop)
  Future<bool> _fileExists(dynamic file) async {
    if (kIsWeb) return false;
    return await (file as dynamic).exists();
  }

  /// Elimina un archivo (solo móvil/desktop)
  Future<void> _deleteFile(dynamic file) async {
    if (kIsWeb) return;
    await (file as dynamic).delete();
  }
}

