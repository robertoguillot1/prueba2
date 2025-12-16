import 'package:flutter/material.dart';
import '../../../../domain/entities/bovinos/bovino.dart';

/// Widget para mostrar una tarjeta de animal en el árbol genealógico
class PedigreeCard extends StatelessWidget {
  final Bovino? bovino;
  final String? relationship; // "Padre", "Madre", "Abuelo Paterno", etc.
  final VoidCallback? onTap;
  final Color? primaryColor;
  final bool isHighlighted; // Si es el animal actual

  const PedigreeCard({
    super.key,
    this.bovino,
    this.relationship,
    this.onTap,
    this.primaryColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    if (bovino == null) {
      // Mostrar "Desconocido" si no hay datos
      return _buildUnknownCard(color);
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? color.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted
                ? color
                : isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Foto o ícono
            CircleAvatar(
              radius: 30,
              backgroundColor: bovino!.gender == BovinoGender.male
                  ? Colors.blue.shade100
                  : Colors.pink.shade100,
              child: Icon(
                bovino!.gender == BovinoGender.male
                    ? Icons.male
                    : Icons.female,
                color: bovino!.gender == BovinoGender.male
                    ? Colors.blue.shade700
                    : Colors.pink.shade700,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            // Nombre o ID
            Text(
              bovino!.name ?? bovino!.identification ?? 'Sin ID',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? color : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Raza
            if (bovino!.raza != null && bovino!.raza!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                bovino!.raza!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Relación
            if (relationship != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  relationship!,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownCard(Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.help_outline,
            size: 30,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Desconocido',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          if (relationship != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                relationship!,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

