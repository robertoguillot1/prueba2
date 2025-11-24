import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/services/photo_service.dart';

/// Widget para subir/seleccionar imágenes
class ImageUploader extends StatefulWidget {
  final String? currentPhotoPath;
  final Function(String) onPhotoSelected;
  final String? label;

  const ImageUploader({
    super.key,
    this.currentPhotoPath,
    required this.onPhotoSelected,
    this.label,
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final PhotoService _photoService = PhotoService();
  String? _selectedPhotoPath;

  @override
  void initState() {
    super.initState();
    _selectedPhotoPath = widget.currentPhotoPath;
  }

  Future<void> _takePhoto() async {
    final photo = await _photoService.takePhoto();
    if (photo != null) {
      final compressed = await _photoService.compressImage(photo);
      if (compressed != null) {
        setState(() {
          _selectedPhotoPath = compressed.path;
        });
        widget.onPhotoSelected(compressed.path);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final photo = await _photoService.pickFromGallery();
    if (photo != null) {
      final compressed = await _photoService.compressImage(photo);
      if (compressed != null) {
        setState(() {
          _selectedPhotoPath = compressed.path;
        });
        widget.onPhotoSelected(compressed.path);
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (_selectedPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPhotoPath = null;
                  });
                  widget.onPhotoSelected('');
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        GestureDetector(
          onTap: _showPhotoOptions,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedPhotoPath != null && File(_selectedPhotoPath!).existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedPhotoPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para agregar foto',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}




