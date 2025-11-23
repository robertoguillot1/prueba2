import 'package:flutter/material.dart';

class ModuleItem {
  final String id;
  final String name;
  final String icon;
  final int order;
  final bool isEnabled;

  ModuleItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'order': order,
      'isEnabled': isEnabled,
    };
  }

  factory ModuleItem.fromJson(Map<String, dynamic> json) {
    return ModuleItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      order: json['order'] as int,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  // Getters para compatibilidad con código existente
  String get type => id;
  Color get color => _getColorForModule(id);
  String get title => name;
  String get subtitle => '';
  IconData get iconData => _getIconForModule(icon);
  
  static IconData _getIconForModule(String iconName) {
    // Mapeo de iconos por nombre
    switch (iconName) {
      case 'cow':
        return Icons.agriculture;
      case 'pig':
        return Icons.pets;
      case 'workers':
        return Icons.people;
      case 'loans':
        return Icons.account_balance_wallet;
      case 'payments':
        return Icons.payment;
      case 'expenses':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

  static Color _getColorForModule(String moduleId) {
    // Mapeo de colores por módulo
    switch (moduleId) {
      case 'ganaderia':
        return const Color(0xFF4CAF50);
      case 'porcicultura':
        return const Color(0xFF2196F3);
      case 'trabajadores':
        return const Color(0xFFFF9800);
      case 'prestamos':
        return const Color(0xFF9C27B0);
      case 'pagos':
        return const Color(0xFF00BCD4);
      case 'gastos':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  ModuleItem copyWith({
    String? id,
    String? name,
    String? icon,
    int? order,
    bool? isEnabled,
  }) {
    return ModuleItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  static List<ModuleItem> getDefaultModules() {
    return [
      ModuleItem(id: 'ganaderia', name: 'Ganadería', icon: 'cow', order: 0),
      ModuleItem(id: 'porcicultura', name: 'Porcicultura', icon: 'pig', order: 1),
      ModuleItem(id: 'trabajadores', name: 'Trabajadores', icon: 'workers', order: 2),
      ModuleItem(id: 'prestamos', name: 'Préstamos', icon: 'loans', order: 3),
      ModuleItem(id: 'pagos', name: 'Pagos', icon: 'payments', order: 4),
      ModuleItem(id: 'gastos', name: 'Gastos', icon: 'expenses', order: 5),
    ];
  }
}





