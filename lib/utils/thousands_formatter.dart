import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remover todos los caracteres que no sean dígitos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Formatear con separador de miles usando puntos
    final formatter = NumberFormat('#,###', 'es'); // Usar locale español
    var formatted = formatter.format(int.parse(digitsOnly));
    // Asegurar que use puntos en lugar de comas (algunos locales usan comas)
    formatted = formatted.replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String getNumericValue(String formattedValue) {
    // Remover todos los caracteres que no sean dígitos (puntos, comas, espacios, etc.)
    return formattedValue.replaceAll(RegExp(r'[^\d]'), '');
  }
}

