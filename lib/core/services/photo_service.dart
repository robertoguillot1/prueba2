import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Servicio para manejo de fotos
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Toma una foto desde la cámara
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      return null;
    }
  }

  /// Selecciona una foto de la galería
  Future<File?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      return null;
    }
  }

  /// Comprime una imagen
  Future<File?> compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
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
      final fileName = path.basename(imageFile.path);
      final compressedFile = File(path.join(tempDir.path, 'compressed_$fileName'));
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      return imageFile; // Retornar original si falla
    }
  }

  /// Guarda una foto en el directorio de la app
  Future<String?> savePhoto(File photoFile, String entityId, String module) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(appDir.path, 'photos', module));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final fileName = '${entityId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File(path.join(photosDir.path, fileName));
      await photoFile.copy(savedFile.path);

      return savedFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene la ruta de una foto
  Future<String?> getPhotoPath(String entityId, String module) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(appDir.path, 'photos', module));
      if (!await photosDir.exists()) return null;

      final files = photosDir.listSync();
      for (final file in files) {
        if (file.path.contains(entityId)) {
          return file.path;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Elimina una foto
  Future<bool> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

