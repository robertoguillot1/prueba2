import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget para mostrar una tarjeta de resumen en el dashboard
class SummaryCardWidget extends StatelessWidget {
  final IconData? icon;
  final IconData? faIcon;
  final String title;
  final int total;
  final Color color;
  final VoidCallback? onTap;

  const SummaryCardWidget({
    super.key,
    this.icon,
    this.faIcon,
    required this.title,
    required this.total,
    required this.color,
    this.onTap,
  }) : assert(icon != null || faIcon != null, 'Debe proporcionar icon o faIcon');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (faIcon != null)
                FaIcon(
                  faIcon!,
                  size: 40,
                  color: color,
                )
              else
                Icon(
                  icon!,
                  size: 40,
                  color: color,
                ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                total.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

