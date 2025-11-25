/// Configuración de la API REST
/// 
/// Esta clase centraliza todos los endpoints y configuraciones de la API.
/// Para cambiar de entorno (desarrollo/producción), simplemente modifica
/// la variable `baseUrl`.
class ApiConfig {
  // Base URL de la API
  // Cambia esta URL según tu entorno (desarrollo, staging, producción)
  static const String baseUrl = 'https://api.ganaderia.com/v1';
  
  // Timeout para las peticiones HTTP
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers comunes
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers con autenticación
  static Map<String, String> headersWithAuth(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
  
  // Endpoints por módulo
  static String ovejas(String farmId) => '/farms/$farmId/ovinos';
  static String oveja(String farmId, String id) => '/farms/$farmId/ovinos/$id';
  
  static String bovinos(String farmId) => '/farms/$farmId/bovinos';
  static String bovino(String farmId, String id) => '/farms/$farmId/bovinos/$id';
  
  static String cerdos(String farmId) => '/farms/$farmId/porcinos';
  static String cerdo(String farmId, String id) => '/farms/$farmId/porcinos/$id';
  
  static String gallinas(String farmId) => '/farms/$farmId/avicultura';
  static String gallina(String farmId, String id) => '/farms/$farmId/avicultura/$id';
  
  static String trabajadores(String farmId) => '/farms/$farmId/trabajadores';
  static String trabajador(String farmId, String id) => '/farms/$farmId/trabajadores/$id';
  
  // Endpoints adicionales
  static String produccionLeche(String farmId) => '/farms/$farmId/bovinos/produccion-leche';
  static String pesoBovino(String farmId) => '/farms/$farmId/bovinos/pesos';
  static String vacunasBovino(String farmId) => '/farms/$farmId/bovinos/vacunas';
  
  static String partosOveja(String farmId) => '/farms/$farmId/ovinos/partos';
  static String pesoOveja(String farmId) => '/farms/$farmId/ovinos/pesos';
  
  static String produccionHuevos(String farmId) => '/farms/$farmId/avicultura/produccion';
  static String alimentacionGallina(String farmId) => '/farms/$farmId/avicultura/alimentacion';
  
  static String alimentacionCerdo(String farmId) => '/farms/$farmId/porcinos/alimentacion';
  static String pesoCerdo(String farmId) => '/farms/$farmId/porcinos/pesos';
  
  static String tareas(String farmId) => '/farms/$farmId/trabajadores/tareas';
  static String asistencia(String farmId) => '/farms/$farmId/trabajadores/asistencia';
}

