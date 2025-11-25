# Módulo de Bovinos (Cattle) - Clean Architecture

## 📋 Resumen

Este módulo implementa la gestión completa de bovinos siguiendo los principios de Clean Architecture.

## 🏗️ Estructura Completa

```
lib/features/cattle/
├── domain/                      # Capa de Dominio (Lógica de Negocio)
│   ├── entities/
│   │   └── bovine_entity.dart  # Entidad de dominio para Bovino
│   ├── repositories/
│   │   └── cattle_repository.dart  # Contrato abstracto del repositorio
│   └── usecases/               # Casos de uso
│       ├── usecase.dart        # Interfaz base para casos de uso
│       ├── get_cattle_list.dart
│       ├── get_bovine.dart
│       ├── add_bovine.dart
│       ├── update_bovine.dart
│       ├── delete_bovine.dart
│       └── usecases.dart       # Barrel file
│
├── data/                        # Capa de Datos (Implementación)
│   ├── models/
│   │   ├── bovine_model.dart   # Modelo con serialización Firestore
│   │   └── models.dart         # Barrel file
│   ├── datasources/
│   │   ├── cattle_remote_datasource.dart  # Interfaz + Implementación Firebase
│   │   └── datasources.dart    # Barrel file
│   ├── repositories/
│   │   ├── cattle_repository_impl.dart  # Implementación del repositorio
│   │   └── repositories.dart   # Barrel file
│   └── data.dart               # Barrel file
│
├── presentation/                # Capa de Presentación (UI + State)
│   ├── cubit/                  # State Management con Cubit
│   │   ├── cattle_cubit.dart   # Lógica de estado
│   │   ├── cattle_state.dart   # Estados posibles
│   │   └── cubit.dart          # Barrel file
│   └── screens/                # Pantallas de UI
│       ├── cattle_list_screen.dart  # Pantalla de listado
│       └── screens.dart        # Barrel file
│
└── cattle.dart                 # Exportación centralizada del módulo
```

## 🎨 Pantalla de Lista (CattleListScreen)

### Características Implementadas

✅ **Estados Manejados:**
- **CattleLoading:** Muestra un indicador de carga circular
- **CattleError:** Muestra mensaje de error con botón de reintentar
- **CattleLoaded (Lista Vacía):** Muestra mensaje amigable con icono de vaca y botón para agregar
- **CattleLoaded (Con Datos):** Lista con tarjetas visuales de cada bovino
- **CattleOperationSuccess:** Muestra notificación y actualiza la lista automáticamente

✅ **Diseño de las Tarjetas:**
- Avatar circular con icono de género (♂/♀) y colores distintivos
- Información principal: Identificador/Nombre, Raza, Edad, Peso
- Chips visuales para Propósito (Carne/Leche/Dual)
- Iconos de estado (Activo/Vendido/Muerto)
- Responsive y adaptable al tema claro/oscuro

✅ **Funcionalidades:**
- 🔄 **Actualizaciones en Tiempo Real:** La lista se actualiza automáticamente cuando hay cambios en Firestore
- 🔃 Pull to refresh para recargar datos
- ➕ FloatingActionButton para agregar nuevo bovino
- 👆 Navegación a detalles al tocar una tarjeta (por implementar)
- 🔍 Filtros en el AppBar (por implementar)

### Cómo Navegar a la Pantalla

Desde cualquier parte de la app, usa:

```dart
Navigator.pushNamed(
  context,
  '/cattle/list',
  arguments: {'farmId': 'TU_FARM_ID'},
);
```

### Ejemplo de Navegación desde Dashboard

En `dashboard_screen.dart`, puedes agregar:

```dart
// Dentro de las quick actions o botones del dashboard
onTap: () {
  Navigator.pushNamed(
    context,
    '/cattle/list',
    arguments: {'farmId': currentFarmId},
  );
},
```

## 🔧 Inyección de Dependencias

Todo el módulo está registrado en `lib/core/di/dependency_injection.dart`:

- **DataSource:** `CattleRemoteDataSourceImpl` (LazySingleton)
- **Repository:** `CattleRepositoryImpl` (LazySingleton) - ✅ **Con soporte para Streams**
- **UseCases:** Todos registrados como LazySingleton
- **Cubit:** Factory method `createCattleCubit()` - ✅ **Inyecta repository para streams en tiempo real**

## 📦 Estructura de Datos en Firestore

```
farms/
  └── {farmId}/
      └── cattle/
          └── {bovineId}/
              ├── farmId: String
              ├── identifier: String
              ├── name: String? (opcional)
              ├── breed: String
              ├── gender: String ("male" | "female")
              ├── birthDate: Timestamp
              ├── weight: Number
              ├── purpose: String ("meat" | "milk" | "dual")
              ├── status: String ("active" | "sold" | "dead")
              ├── createdAt: Timestamp
              └── updatedAt: Timestamp?
```

## 🚀 Próximos Pasos

### Por Implementar:

1. **Pantalla de Detalles:** `cattle_detail_screen.dart`
   - Ver información completa del bovino
   - Editar información
   - Ver historial de eventos

2. **Pantalla de Formulario:** `cattle_form_screen.dart`
   - Crear nuevo bovino
   - Editar bovino existente
   - Validación de campos

3. **Filtros y Búsqueda:**
   - Filtrar por género, propósito, estado
   - Búsqueda por identificador o nombre
   - Ordenar por diferentes criterios

4. **Reportes:**
   - Estadísticas del ganado
   - Gráficas de peso
   - Reportes de producción

## 🧪 Cómo Probar

1. Asegúrate de tener datos de bovinos en Firestore
2. Navega a la pantalla usando la ruta `/cattle/list` con un `farmId` válido
3. Verifica que se cargan los datos correctamente
4. Prueba el pull-to-refresh
5. Verifica el estado vacío si no hay datos
6. Prueba el botón de agregar (mostrará un mensaje por ahora)

## 📱 Ejemplos Visuales de Estados

### Estado de Carga
```
┌─────────────────────┐
│   [AppBar]          │
├─────────────────────┤
│                     │
│         ⭕         │
│   Cargando...      │
│                     │
└─────────────────────┘
```

### Estado Vacío
```
┌─────────────────────┐
│   [AppBar]          │
├─────────────────────┤
│                     │
│        🐄          │
│                     │
│ No hay bovinos     │
│  registrados       │
│                     │
│  [Agregar Bovino]  │
│                     │
└─────────────────────┘
```

### Estado con Datos
```
┌─────────────────────┐
│   [AppBar] [🔍]     │
├─────────────────────┤
│ ┌─────────────────┐ │
│ │ ♂ #001 | Angus │ │
│ │ 2 años | 450 kg│ │
│ │ [Carne] ✓      │ │
│ └─────────────────┘ │
│ ┌─────────────────┐ │
│ │ ♀ #002 | Holstein│
│ │ 3 años | 520 kg│ │
│ │ [Leche] ✓      │ │
│ └─────────────────┘ │
└─────────────────────┘
            [+]
```

## 💡 Notas Importantes

- La pantalla usa `BlocProvider` y `BlocBuilder` para manejar el estado
- Los datos se cargan automáticamente al entrar a la pantalla
- El cubit se crea usando el factory del DI
- Los errores se manejan mediante el estado `CattleError`
- Las operaciones exitosas se notifican con SnackBar

## 🐛 Solución de Problemas

**Problema:** La lista no carga datos
- Verifica que el `farmId` sea correcto
- Revisa la consola para ver logs de errores
- Asegúrate de que Firebase esté configurado correctamente

**Problema:** Errores de compilación
- Ejecuta `flutter pub get`
- Verifica que `dartz` y `flutter_bloc` estén en `pubspec.yaml`

**Problema:** La navegación no funciona
- Verifica que la ruta `/cattle/list` esté registrada en `AppRouter`
- Asegúrate de pasar `farmId` en los argumentos

