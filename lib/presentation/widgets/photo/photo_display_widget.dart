import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../core/services/photo_service.dart';
import '../../../core/di/dependency_injection.dart';

/// Widget para mostrar la foto de un animal
class PhotoDisplayWidget extends StatelessWidget {
  final String? photoUrl;
  final String? photoPath;
  final String entityId;
  final String module;
  final double size;
  final VoidCallback? onTap;
  final Widget? placeholder;

  const PhotoDisplayWidget({
    super.key,
    this.photoUrl,
    this.photoPath,
    required this.entityId,
    required this.module,
    this.size = 100,
    this.onTap,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getPhotoPath(),
      builder: (context, snapshot) {
        final path = snapshot.data;
        
        if (path == null) {
          return _buildPlaceholder(context);
        }
        
        // En web, las fotos pueden ser URLs de blob o http
        if (kIsWeb) {
          if (path.startsWith('blob:') || path.startsWith('http') || path.startsWith('data:')) {
            return GestureDetector(
              onTap: onTap,
              child: ClipOval(
                child: Image.network(
                  path,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(context);
                  },
                ),
              ),
            );
          }
          // Si no es una URL válida, mostrar placeholder
          return _buildPlaceholder(context);
        }
        
        // Para móvil/desktop, usar File
        if (File(path).existsSync()) {
          return GestureDetector(
            onTap: onTap,
            child: ClipOval(
              child: Image.file(
                File(path),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(context);
                },
              ),
            ),
          );
        }
        
        return _buildPlaceholder(context);
      },
    );
  }

  Future<String?> _getPhotoPath() async {
    // En web, photoUrl puede ser una URL de blob o http directamente
    if (kIsWeb) {
      if (photoUrl != null && (photoUrl!.startsWith('blob:') || photoUrl!.startsWith('http') || photoUrl!.startsWith('data:'))) {
        return photoUrl;
      }
      if (photoPath != null && (photoPath!.startsWith('blob:') || photoPath!.startsWith('http') || photoPath!.startsWith('data:'))) {
        return photoPath;
      }
      // En web, no podemos usar PhotoService.getPhotoPath porque no hay sistema de archivos
      return photoUrl ?? photoPath;
    }
    
    // Para móvil/desktop, usar el sistema de archivos
    if (photoPath != null && File(photoPath!).existsSync()) {
      return photoPath;
    }
    
    if (photoUrl != null && photoUrl!.startsWith('/')) {
      // Es una ruta local
      if (File(photoUrl!).existsSync()) {
        return photoUrl;
      }
    }
    
    // Intentar obtener desde PhotoService
    final photoService = DependencyInjection.photoService;
    return await photoService.getPhotoPath(entityId, module);
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.pets,
          size: size * 0.5,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

