# Remote Data Sources

Esta carpeta contiene las implementaciones de Data Sources que se conectan a una API REST.

## Uso

Para activar el uso de la API REST en lugar del almacenamiento local:

1. **Configura la URL base** en `lib/core/config/api_config.dart`:
   ```dart
   static const String baseUrl = 'https://tu-api.com/v1';
   ```

2. **Actualiza `DependencyInjection`** para usar los Remote Data Sources:
   ```dart
   // En lugar de:
   final ovejasDataSource = OvejasDataSourceImpl(_sharedPreferences!);
   
   // Usa:
   final apiClient = ApiClient();
   apiClient.setAuthToken('tu-token-aqui'); // Si requiere autenticación
   final ovejasDataSource = OvejasRemoteDataSource(apiClient);
   ```

3. **Los repositorios no necesitan cambios** ya que implementan la misma interfaz.

## Estructura

- `api_client.dart`: Cliente HTTP genérico que maneja todas las peticiones
- `ovinos/`: Data Sources remotos para el módulo de ovinos
- `bovinos/`: Data Sources remotos para el módulo de bovinos
- `porcinos/`: Data Sources remotos para el módulo de porcinos
- `avicultura/`: Data Sources remotos para el módulo de avicultura
- `trabajadores/`: Data Sources remotos para el módulo de trabajadores

## Notas

- Los Remote Data Sources devuelven `OvejaModel` (y equivalentes) que extienden las entidades
- El `ApiClient` maneja automáticamente la serialización/deserialización JSON
- Los errores se convierten automáticamente en `Failure` apropiados
- El timeout por defecto es de 30 segundos (configurable)

