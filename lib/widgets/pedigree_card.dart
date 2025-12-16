import 'package:flutter/material.dart';
import '../models/cattle.dart';

class PedigreeCard extends StatelessWidget {
  final Cattle? animal;
  final String relationship;
  final Color primaryColor;
  final bool isCurrent;
  final VoidCallback? onTap;

  const PedigreeCard({
    super.key,
    this.animal,
    required this.relationship,
    this.primaryColor = Colors.blue,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnknown = animal == null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCurrent
              ? primaryColor.withValues(alpha: 0.15)
              : isUnknown
                  ? Colors.grey.shade100
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCurrent
                ? primaryColor
                : isUnknown
                    ? Colors.grey.shade300
                    : Colors.grey.shade300,
            width: isCurrent ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrent
                  ? primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isCurrent ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Foto o ícono
            CircleAvatar(
              radius: 28,
              backgroundColor: isCurrent
                  ? primaryColor.withValues(alpha: 0.2)
                  : isUnknown
                      ? Colors.grey.shade300
                      : Colors.grey.shade200,
              backgroundImage: !isUnknown && animal!.photoUrl != null
                  ? NetworkImage(animal!.photoUrl!)
                  : null,
              child: isUnknown
                  ? Icon(
                      Icons.help_outline,
                      color: Colors.grey.shade600,
                      size: 24,
                    )
                  : animal!.photoUrl == null
                      ? Icon(
                          animal!.gender == CattleGender.male
                              ? Icons.male
                              : Icons.female,
                          color: isCurrent ? primaryColor : Colors.grey.shade600,
                          size: 26,
                        )
                      : null,
            ),
            const SizedBox(height: 6),
            // Nombre
            Text(
              isUnknown
                  ? 'Desconocido'
                  : animal!.name ?? animal!.identification ?? 'Sin ID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isCurrent
                    ? primaryColor
                    : isUnknown
                        ? Colors.grey.shade600
                        : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Raza (si existe y no es desconocido)
            if (!isUnknown && animal!.raza != null && animal!.raza!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                animal!.raza!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 3),
            // Relación
            Text(
              relationship,
              style: TextStyle(
                fontSize: 10,
                color: isUnknown ? Colors.grey.shade500 : Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            // Indicador de clic (si es navegable)
            if (onTap != null && !isUnknown) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.touch_app,
                size: 12,
                color: primaryColor.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

