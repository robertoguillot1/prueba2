/// Claves para almacenamiento local
class StorageKeys {
  // Ovinos
  static String ovejasKey(String farmId) => 'ovejas_$farmId';
  static String partosOvejaKey(String farmId) => 'partos_oveja_$farmId';
  static String registrosPesoOvejaKey(String farmId) => 'registros_peso_oveja_$farmId';
  static String enfermedadesOvejaKey(String farmId) => 'enfermedades_oveja_$farmId';
  
  // Avicultura
  static String gallinasKey(String farmId) => 'gallinas_$farmId';
  static String produccionHuevosKey(String farmId) => 'produccion_huevos_$farmId';
  static String alimentacionGallinaKey(String farmId) => 'alimentacion_gallina_$farmId';
  static String mortalidadGallinaKey(String farmId) => 'mortalidad_gallina_$farmId';
  
  // Bovinos
  static String bovinosKey(String farmId) => 'bovinos_$farmId';
  static String produccionLecheKey(String farmId) => 'produccion_leche_$farmId';
  static String pesoBovinoKey(String farmId) => 'peso_bovino_$farmId';
  static String vacunasBovinoKey(String farmId) => 'vacunas_bovino_$farmId';
  static String partosBovinoKey(String farmId) => 'partos_bovino_$farmId';
  
  // Porcinos
  static String cerdosKey(String farmId) => 'cerdos_$farmId';
  static String alimentacionCerdoKey(String farmId) => 'alimentacion_cerdo_$farmId';
  static String pesoCerdoKey(String farmId) => 'peso_cerdo_$farmId';
  static String vacunaCerdoKey(String farmId) => 'vacuna_cerdo_$farmId';
  
  // Trabajadores
  static String trabajadoresKey(String farmId) => 'trabajadores_$farmId';
  static String tareasKey(String farmId) => 'tareas_$farmId';
  static String asistenciaKey(String farmId) => 'asistencia_$farmId';
  static String pagosKey(String farmId) => 'pagos_$farmId';
}

