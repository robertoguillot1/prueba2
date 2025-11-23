/// Validadores reutilizables para formularios
class FormValidators {
  /// Valida que un campo no esté vacío
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es obligatorio';
    }
    return null;
  }

  /// Valida que un número sea positivo
  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Si es opcional, no validar
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }
    if (number <= 0) {
      return '${fieldName ?? 'Este campo'} debe ser mayor a 0';
    }
    return null;
  }

  /// Valida que un número entero sea positivo o cero
  static String? positiveInteger(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Si es opcional, no validar
    }
    final number = int.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número entero válido';
    }
    if (number < 0) {
      return '${fieldName ?? 'Este campo'} debe ser mayor o igual a 0';
    }
    return null;
  }

  /// Valida que un número esté en un rango
  static String? numberRange(
    String? value, {
    required double min,
    required double max,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }
    if (number < min || number > max) {
      return '${fieldName ?? 'Este campo'} debe estar entre $min y $max';
    }
    return null;
  }

  /// Valida que una fecha no sea futura
  static String? notFuture(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return null; // Si es opcional, no validar
    }
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return '${fieldName ?? 'La fecha'} no puede ser futura';
    }
    return null;
  }

  /// Valida que una fecha no sea pasada
  static String? notPast(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return null;
    }
    final now = DateTime.now();
    if (date.isBefore(now)) {
      return '${fieldName ?? 'La fecha'} no puede ser pasada';
    }
    return null;
  }

  /// Valida que una fecha esté en un rango
  static String? dateRange(
    DateTime? date, {
    DateTime? min,
    DateTime? max,
    String? fieldName,
  }) {
    if (date == null) {
      return null;
    }
    if (min != null && date.isBefore(min)) {
      return '${fieldName ?? 'La fecha'} no puede ser anterior a ${_formatDate(min)}';
    }
    if (max != null && date.isAfter(max)) {
      return '${fieldName ?? 'La fecha'} no puede ser posterior a ${_formatDate(max)}';
    }
    return null;
  }

  /// Valida longitud mínima de texto
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Valida longitud máxima de texto
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede tener más de $maxLength caracteres';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  /// Valida formato de teléfono
  static String? phone(String? value, {int minLength = 7}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'El teléfono solo puede contener números';
    }
    if (value.trim().length < minLength) {
      return 'El teléfono debe tener al menos $minLength dígitos';
    }
    return null;
  }

  /// Valida que un peso sea razonable para el tipo de animal
  static String? animalWeight(String? value, {required String animalType}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'El peso debe ser mayor a 0';
    }

    // Límites razonables según el tipo de animal
    switch (animalType.toLowerCase()) {
      case 'oveja':
      case 'ovino':
        if (weight > 150) {
          return 'El peso parece excesivo para una oveja';
        }
        break;
      case 'bovino':
      case 'vaca':
      case 'toro':
        if (weight > 1000) {
          return 'El peso parece excesivo para un bovino';
        }
        break;
      case 'cerdo':
      case 'porcino':
        if (weight > 300) {
          return 'El peso parece excesivo para un cerdo';
        }
        break;
      case 'gallina':
        if (weight > 5) {
          return 'El peso parece excesivo para una gallina';
        }
        break;
    }
    return null;
  }

  /// Valida que una producción sea no negativa
  static String? nonNegative(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }
    if (number < 0) {
      return '${fieldName ?? 'Este campo'} no puede ser negativo';
    }
    return null;
  }

  /// Valida que una edad sea razonable
  static String? reasonableAge(DateTime? birthDate, {required String animalType}) {
    if (birthDate == null) {
      return null;
    }
    final now = DateTime.now();
    final age = now.difference(birthDate).inDays;
    final ageYears = age / 365;

    // Edades máximas razonables según el tipo de animal
    switch (animalType.toLowerCase()) {
      case 'oveja':
      case 'ovino':
        if (ageYears > 15) {
          return 'La edad parece excesiva para una oveja';
        }
        break;
      case 'bovino':
      case 'vaca':
      case 'toro':
        if (ageYears > 25) {
          return 'La edad parece excesiva para un bovino';
        }
        break;
      case 'cerdo':
      case 'porcino':
        if (ageYears > 10) {
          return 'La edad parece excesiva para un cerdo';
        }
        break;
      case 'gallina':
        if (ageYears > 8) {
          return 'La edad parece excesiva para una gallina';
        }
        break;
    }
    return null;
  }

  /// Valida identificación (mínimo 3 caracteres)
  static String? identification(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 3) {
      return 'La identificación debe tener al menos 3 caracteres';
    }
    return null;
  }

  /// Valida que un nombre tenga al menos 2 caracteres
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 2) {
      return '${fieldName ?? 'El nombre'} debe tener al menos 2 caracteres';
    }
    return null;
  }

  /// Helper para formatear fecha
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

