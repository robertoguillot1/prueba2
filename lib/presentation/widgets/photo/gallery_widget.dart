import 'package:flutter/material.dart';
import 'dart:io';

/// Widget para mostrar una galería de fotos
class GalleryWidget extends StatelessWidget {
  final List<String> photoPaths;
  final Function(String)? onPhotoTap;
  final Function(String)? onPhotoDelete;

  const GalleryWidget({
    super.key,
    required this.photoPaths,
    this.onPhotoTap,
    this.onPhotoDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photoPaths.length,
      itemBuilder: (context, index) {
        final photoPath = photoPaths[index];
        return _PhotoItem(
          photoPath: photoPath,
          onTap: () => onPhotoTap?.call(photoPath),
          onDelete: () => onPhotoDelete?.call(photoPath),
        );
      },
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final String photoPath;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _PhotoItem({
    required this.photoPath,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: File(photoPath).existsSync()
                ? Image.file(
                    File(photoPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

