# 🐄 App Ganadera - Gestión Integral de Fincas

Aplicación Flutter profesional para la gestión completa de fincas ganaderas, desarrollada con **Clean Architecture**, **MVVM** y **Provider** para el manejo de estado.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Módulos Implementados](#-módulos-implementados)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Uso](#-uso)
- [API REST](#-api-rest)
- [Modo Offline/Online](#-modo-offlineonline)
- [Autenticación](#-autenticación)
- [Fotos y Multimedia](#-fotos-y-multimedia)
- [Reportes](#-reportes)
- [Funcionalidades Inteligentes](#-funcionalidades-inteligentes)
- [UI/UX](#-uiux)
- [Dependencias](#-dependencias)
- [Plataformas Soportadas](#-plataformas-soportadas)
- [Notas Importantes](#-notas-importantes)

## ✨ Características

### 🎯 Gestión Completa de Animales
- **Ovinos**: Gestión de ovejas con seguimiento reproductivo, partos y pesos
- **Bovinos**: Control de ganado bovino con producción de leche, vacunas y pesos
- **Porcinos**: Administración de cerdos con etapas de alimentación
- **Avicultura**: Gestión de gallinas con producción de huevos y lotes

### 👷 Gestión de Trabajadores
- Registro completo de trabajadores
- Control de asistencia y tareas
- Seguimiento de rendimiento

### 📊 Funcionalidades Avanzadas
- **Modo Offline/Online**: Sincronización automática cuando hay conexión
- **Autenticación Profesional**: Sistema de login con roles (admin, trabajador, invitado)
- **Fotos y Multimedia**: Captura y almacenamiento de fotos por animal
- **Reportes PDF y CSV**: Exportación de inventarios y reportes de producción
- **Gráficas y Dashboards**: Visualización de datos con `fl_chart`
- **Cálculos Inteligentes**: Ganancia de peso, fechas probables de parto, alertas automáticas

## 🏗️ Arquitectura

La aplicación sigue los principios de **Clean Architecture** y **MVVM**:

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (Screens, ViewModels, Widgets)        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          DOMAIN LAYER                   │
│  (Entities, Repositories, Use Cases)   │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│           DATA LAYER                    │
│  (Models, Data Sources, Repositories) │
└─────────────────────────────────────────┘
```

### Capas

1. **Presentation Layer**: 
   - Screens (UI)
   - ViewModels (lógica de presentación)
   - Widgets reutilizables

2. **Domain Layer**:
   - Entities (objetos de negocio puros)
   - Repositories (interfaces)
   - Use Cases (lógica de negocio)

3. **Data Layer**:
   - Models (DTOs que extienden entities)
   - Data Sources (local y remoto)
   - Repository Implementations

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── config/              # Configuración (API, endpoints)
│   ├── di/                  # Dependency Injection
│   ├── errors/              # Failures y manejo de errores
│   ├── network/             # ConnectivityService
│   ├── providers/           # ThemeProvider
│   ├── services/            # AuthService, PhotoService, ReportService
│   ├── theme/               # AppTheme (light/dark)
│   └── utils/               # Validators, Calculations, Result, etc.
│
├── data/
│   ├── database/            # AppDatabase (SQLite)
│   ├── datasources/
│   │   ├── local/           # Data Sources locales (SQLite)
│   │   └── remote/          # Data Sources remotos (API REST)
│   ├── models/              # Modelos (DTOs)
│   ├── repositories_impl/   # Implementaciones de repositorios
│   ├── repositories/
│   │   └── hybrid/          # Repositorios híbridos (online/offline)
│   └── sync/                # SyncManager
│
├── domain/
│   ├── entities/            # Entidades de dominio
│   ├── repositories/        # Interfaces de repositorios
│   └── usecases/            # Casos de uso
│
└── presentation/
    ├── modules/             # Módulos por funcionalidad
    │   ├── ovinos/
    │   │   ├── create/
    │   │   ├── details/
    │   │   ├── edit/
    │   │   ├── list/
    │   │   ├── viewmodels/
    │   │   └── widgets/
    │   ├── bovinos/
    │   ├── porcinos/
    │   ├── avicultura/
    │   └── trabajadores/
    ├── screens/
    │   ├── auth/             # LoginScreen
    │   ├── dashboard/        # DashboardScreen
    │   └── home/             # HomeScreen (navegación)
    └── widgets/              # Widgets reutilizables
        ├── charts/           # Gráficas
        └── photo/            # Widgets de fotos
```

## 🎯 Módulos Implementados

### 1. Ovinos (Ovejas)
- ✅ CRUD completo
- ✅ Seguimiento reproductivo (vacía, gestante, lactante)
- ✅ Registro de partos
- ✅ Control de pesos
- ✅ Cálculo de fecha probable de parto
- ✅ Alertas de partos próximos

### 2. Bovinos
- ✅ CRUD completo
- ✅ Producción de leche
- ✅ Registro de vacunas
- ✅ Control de pesos
- ✅ Seguimiento reproductivo
- ✅ Genealogía (padre/madre)

### 3. Porcinos (Cerdos)
- ✅ CRUD completo
- ✅ Etapas de alimentación
- ✅ Control de pesos
- ✅ Cálculo de días hasta destete

### 4. Avicultura (Gallinas)
- ✅ CRUD completo
- ✅ Producción de huevos
- ✅ Gestión de lotes
- ✅ Control de mortalidad
- ✅ Alimentación

### 5. Trabajadores
- ✅ CRUD completo
- ✅ Control de asistencia
- ✅ Registro de tareas
- ✅ Cálculo de horas trabajadas
- ✅ Seguimiento de rendimiento

## 🚀 Instalación

### Requisitos Previos
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Pasos

1. **Clonar el repositorio**:
   ```bash
   git clone <url-del-repositorio>
   cd ganaderia
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase** (opcional):
   - Copiar `firebase_options.dart` a `lib/`
   - O crear uno nuevo con `flutterfire configure`

4. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## ⚙️ Configuración

### API REST

Edita `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://tu-api.com/v1';
  static const Duration timeout = Duration(seconds: 30);
}
```

### Autenticación

La aplicación soporta autenticación con tokens JWT. El token se almacena automáticamente en `SharedPreferences` y se incluye en todas las peticiones.

### Tema

El tema se puede cambiar desde la configuración de la aplicación. Soporta modo claro y oscuro con detección automática del sistema.

## 📖 Uso

### Navegación Principal

La aplicación tiene una navegación inferior con las siguientes secciones:

1. **Dashboard**: Vista general con resumen y gráficas
2. **Ovinos**: Gestión de ovejas
3. **Bovinos**: Gestión de ganado bovino
4. **Porcinos**: Gestión de cerdos
5. **Avicultura**: Gestión de gallinas
6. **Trabajadores**: Gestión de personal

### Operaciones CRUD

Cada módulo permite:
- **Listar**: Ver todos los registros con búsqueda y filtros
- **Crear**: Agregar nuevos registros con validaciones
- **Editar**: Modificar registros existentes
- **Eliminar**: Borrar registros con confirmación
- **Detalles**: Ver información completa con historial

## 🌐 API REST

### Configuración

La aplicación está preparada para conectarse a una API REST. Para activarla:

1. Configura la URL base en `lib/core/config/api_config.dart`
2. Los Remote Data Sources están listos para usar
3. El `ApiClient` maneja automáticamente:
   - Serialización/deserialización JSON
   - Manejo de errores
   - Timeouts
   - Autenticación con tokens

### Endpoints

La aplicación espera los siguientes endpoints:

```
GET    /farms/{farmId}/ovinos
GET    /farms/{farmId}/ovinos/{id}
POST   /farms/{farmId}/ovinos
PUT    /farms/{farmId}/ovinos/{id}
DELETE /farms/{farmId}/ovinos/{id}

GET    /farms/{farmId}/bovinos
GET    /farms/{farmId}/bovinos/{id}
POST   /farms/{farmId}/bovinos
PUT    /farms/{farmId}/bovinos/{id}
DELETE /farms/{farmId}/bovinos/{id}

# Similar para porcinos, avicultura, trabajadores
```

## 📱 Modo Offline/Online

### Funcionamiento

La aplicación implementa un sistema híbrido:

- **Con Internet**: Usa la API REST
- **Sin Internet**: Usa base de datos local (SQLite)
- **Sincronización**: Cuando vuelve la conexión, sincroniza automáticamente

### Base de Datos Local

- **Móvil/Desktop**: SQLite con `sqflite`
- **Web**: No disponible (usa solo modo online)

### SyncManager

El `SyncManager` se encarga de:
- Detectar cambios en la conectividad
- Sincronizar operaciones pendientes
- Resolver conflictos
- Limpiar operaciones sincronizadas

## 🔐 Autenticación

### Roles

- **Admin**: Acceso completo
- **Trabajador**: Crear/editar registros
- **Invitado**: Solo lectura

### Funcionalidades

- Login con email y contraseña
- Persistencia de sesión
- Logout
- Recuperación de contraseña (opcional)

## 📸 Fotos y Multimedia

### Características

- Captura de fotos desde cámara
- Selección desde galería
- Compresión automática de imágenes
- Almacenamiento local
- Sincronización con servidor (cuando hay conexión)

### Uso

En las pantallas de detalles de cada animal, hay un botón para tomar/seleccionar fotos. Las fotos se guardan localmente y se suben al servidor cuando hay conexión.

## 📊 Reportes

### Tipos de Reportes

1. **PDF**:
   - Reporte de inventario por módulo
   - Reporte de producción
   - Reporte sanitario

2. **CSV**:
   - Exportación de datos para análisis en Excel

### Generación

Los reportes se generan desde el Dashboard o desde las pantallas de lista de cada módulo.

## 🧠 Funcionalidades Inteligentes

### Cálculos Automáticos

#### Ovinos/Bovinos
- Ganancia diaria de peso
- Fecha probable de parto
- Clasificación por edad (cría, novillo, adulto)
- Alertas de peso bajo
- Días restantes hasta parto

#### Porcinos
- Índice de conversión alimenticia
- Días hasta destete
- Peso estimado según edad

#### Avicultura
- Producción diaria/semanal/mensual de huevos
- Alertas de baja producción
- Consumo de alimento por lote

#### Trabajadores
- Horas trabajadas
- Rendimiento
- Registro de tareas

## 🎨 UI/UX

### Material 3

La aplicación usa Material Design 3 con:
- Cards modernas con bordes redondeados
- ListView.separated para mejor separación visual
- Chips para estados
- Iconos consistentes
- Animaciones sutiles

### Tema

- Modo claro y oscuro
- Detección automática del sistema
- Persistencia de preferencias

### Widgets Reutilizables

- `CustomButton`: Botones estilizados
- `InfoCard`: Tarjetas de información
- `StatusChip`: Chips de estado
- `SearchBar`: Barra de búsqueda
- `PhotoDisplayWidget`: Visualización de fotos
- `LoadingWidget`, `ErrorWidget`, `EmptyStateWidget`: Estados de carga

## 📦 Dependencias Principales

```yaml
# State Management
provider: ^6.1.1

# HTTP & API
http: ^1.1.0

# Database
sqflite: ^2.3.0
path: ^1.8.3

# Connectivity
connectivity_plus: ^5.0.2

# Image Handling
image_picker: ^1.0.7
image: ^4.1.3

# PDF & CSV
pdf: ^3.10.7
csv: ^5.0.2

# Charts
fl_chart: ^0.66.0

# Local Storage
shared_preferences: ^2.2.2

# Firebase (opcional)
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.13.6

# Utilities
intl: ^0.19.0
```

## 🖥️ Plataformas Soportadas

- ✅ **Android**: Soporte completo
- ✅ **iOS**: Soporte completo
- ✅ **Web**: Modo online solamente (sin base de datos local)
- ✅ **Windows**: Soporte completo
- ✅ **Linux**: Soporte completo
- ✅ **macOS**: Soporte completo

## ⚠️ Notas Importantes

### Web

- La base de datos local (SQLite) **no está disponible en web**
- En web, la aplicación funciona solo en **modo online**
- Para usar la base de datos local, ejecuta la app en móvil o desktop

### Base de Datos

- En móvil/desktop: SQLite funciona normalmente
- En web: Se desactiva automáticamente y se usa solo la API

### Sincronización

- Las operaciones offline se guardan en una cola de sincronización
- Cuando hay conexión, se sincronizan automáticamente
- Los conflictos se resuelven dando prioridad al servidor

### Fotos

- Las fotos se guardan localmente primero
- Se suben al servidor cuando hay conexión
- En web, las fotos se suben inmediatamente

## 🔧 Desarrollo

### Estructura de Commits

Se recomienda usar commits semánticos:
- `feat:` Nueva funcionalidad
- `fix:` Corrección de bugs
- `docs:` Documentación
- `refactor:` Refactorización
- `test:` Tests
- `chore:` Tareas de mantenimiento

### Testing

```bash
# Ejecutar tests
flutter test

# Análisis de código
flutter analyze

# Formatear código
flutter format .
```

## 📝 Licencia

[Especificar licencia]

## 👥 Contribuidores

[Agregar contribuidores]

## 📞 Soporte

Para reportar bugs o solicitar funcionalidades, abre un issue en el repositorio.

---

**Desarrollado con ❤️ usando Flutter**
