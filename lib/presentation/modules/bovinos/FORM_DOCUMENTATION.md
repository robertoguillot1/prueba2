# 📝 Formulario de Bovinos - Documentación

## ✅ Implementación Completada

Se ha implementado el **formulario completo** para crear y editar bovinos siguiendo Clean Architecture.

---

## 📂 Estructura de Archivos

```
lib/presentation/modules/bovinos/
├── cubits/
│   └── form/
│       ├── bovino_form_state.dart    ✅ Estados del formulario
│       └── bovino_form_cubit.dart    ✅ Lógica del formulario
└── screens/
    └── bovino_form_screen.dart       ✅ UI del formulario
```

---

## 🎯 Características Implementadas

### 1️⃣ **Estados del Formulario**

```dart
// Estados disponibles
- BovinoFormInitial      // Formulario vacío (modo creación)
- BovinoFormLoaded       // Formulario pre-cargado (modo edición)
- BovinoFormLoading      // Guardando datos
- BovinoFormSuccess      // Operación exitosa
- BovinoFormError        // Error con mensaje
```

### 2️⃣ **Cubit - Lógica de Negocio**

**Métodos Principales:**

```dart
// Inicializa el formulario
void initialize(BovineEntity? bovine)

// Envía el formulario
Future<void> submit({
  required String farmId,
  required String identifier,
  String? name,
  required String breed,
  required BovineGender gender,
  required DateTime birthDate,
  required double weight,
  required BovinePurpose purpose,
  required BovineStatus status,
})

// Resetea el formulario
void reset()
```

**Validaciones en el Cubit:**
- ✅ Identificador no vacío
- ✅ Raza no vacía
- ✅ Peso mayor a 0
- ✅ Fecha de nacimiento no puede ser futura

### 3️⃣ **Pantalla - UI Completa**

**Campos del Formulario:**

| Campo | Tipo | Obligatorio | Validación |
|-------|------|-------------|------------|
| **Identificador** | TextFormField | ✅ Sí | No vacío |
| **Nombre** | TextFormField | ❌ No | - |
| **Raza** | TextFormField | ✅ Sí | No vacío |
| **Género** | FilterChip | ✅ Sí | Macho/Hembra |
| **Propósito** | DropdownButton | ✅ Sí | Carne/Leche/Dual |
| **Estado** | DropdownButton | ✅ Sí | Activo/Vendido/Muerto |
| **Fecha de Nacimiento** | DatePicker | ✅ Sí | No futura |
| **Peso** | TextFormField | ✅ Sí | > 0, decimal |

**Características de la UI:**
- 📱 Diseño moderno con Material Design 3
- 🌓 Adaptable a tema claro/oscuro
- ✅ Validación en tiempo real
- 🎨 Secciones organizadas con títulos
- 💾 Botón de guardado con spinner
- 🔄 Feedback visual inmediato
- ↩️ Cierra automáticamente al guardar

---

## 🔄 Flujo de Datos

### **Modo Creación:**
```
Usuario abre formulario
    ↓
BovinoFormCubit.initialize(null)
    ↓
Estado: BovinoFormInitial
    ↓
Usuario llena campos
    ↓
Usuario presiona "Crear Bovino"
    ↓
Validación del formulario (UI)
    ↓
BovinoFormCubit.submit(...)
    ↓
Estado: BovinoFormLoading
    ↓
AddBovine UseCase
    ↓
Either<Failure, BovineEntity>
    ↓
Estado: BovinoFormSuccess o BovinoFormError
    ↓
Si Success → Navigator.pop(context, true)
```

### **Modo Edición:**
```
Usuario abre formulario con bovine
    ↓
BovinoFormCubit.initialize(bovine)
    ↓
Estado: BovinoFormLoaded(bovine)
    ↓
Campos se pre-llenan con datos
    ↓
Usuario modifica campos
    ↓
Usuario presiona "Actualizar Bovino"
    ↓
Validación del formulario (UI)
    ↓
BovinoFormCubit.submit(...)
    ↓
Estado: BovinoFormLoading
    ↓
UpdateBovine UseCase
    ↓
Either<Failure, BovineEntity>
    ↓
Estado: BovinoFormSuccess o BovinoFormError
    ↓
Si Success → Navigator.pop(context, true)
```

---

## 🚀 Cómo Usar

### **1. Para Crear un Nuevo Bovino:**

```dart
// Navega al formulario sin pasar bovine
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BovinoFormScreen(
      farmId: 'farm-id-123',
      // bovine: null (no se pasa)
    ),
  ),
);
```

### **2. Para Editar un Bovino Existente:**

```dart
// Navega al formulario pasando el bovine
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BovinoFormScreen(
      farmId: 'farm-id-123',
      bovine: bovineToEdit, // Pasa el bovino a editar
    ),
  ),
);
```

### **3. Recibir el Resultado:**

```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BovinoFormScreen(
      farmId: farmId,
      bovine: bovine,
    ),
  ),
);

if (result == true) {
  // La operación fue exitosa
  // Recargar la lista de bovinos
  cattleCubit.loadCattle(farmId);
}
```

---

## 🎨 Secciones del Formulario

### **Identificación**
- Identificador / Arete
- Nombre (opcional)
- Raza

### **Características**
- Género (Macho/Hembra) con chips
- Propósito (Carne/Leche/Dual) con dropdown
- Estado (Activo/Vendido/Muerto) con dropdown

### **Datos Físicos**
- Fecha de Nacimiento con DatePicker
- Peso en kilogramos

---

## 🔧 Integración con DI

El cubit se crea usando el factory method:

```dart
// En lib/core/di/dependency_injection.dart
static BovinoFormCubit createBovinoFormCubit() {
  return BovinoFormCubit(
    addBovineUseCase: sl<AddBovine>(),
    updateBovineUseCase: sl<UpdateBovine>(),
  );
}
```

Y se usa en el screen:

```dart
BlocProvider(
  create: (_) => di.DependencyInjection.createBovinoFormCubit()
    ..initialize(bovine),
  child: _BovinoFormContent(...)
)
```

---

## 📊 Validaciones Implementadas

### **En el Cubit:**
```dart
✓ Identificador no vacío
✓ Raza no vacía
✓ Peso > 0
✓ Fecha de nacimiento no futura
```

### **En la UI (FormValidation):**
```dart
✓ Identificador no vacío (TextFormField)
✓ Raza no vacía (TextFormField)
✓ Peso válido y > 0 (TextFormField)
✓ Peso formato decimal correcto (InputFormatter)
```

---

## 🎯 Ejemplo Completo

### Desde `CattleListScreen`, al presionar el FAB:

```dart
FloatingActionButton.extended(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinoFormScreen(
          farmId: farmId,
          // No se pasa bovine = Modo Creación
        ),
      ),
    );
    
    if (result == true) {
      // Recargar la lista
      context.read<CattleCubit>().loadCattle(farmId);
    }
  },
  icon: const Icon(Icons.add),
  label: const Text('Nuevo Bovino'),
)
```

### Desde `CattleListScreen`, al tocar una tarjeta:

```dart
_BovineCard(
  bovine: bovine,
  onTap: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinoFormScreen(
          farmId: farmId,
          bovine: bovine, // Se pasa el bovino = Modo Edición
        ),
      ),
    );
    
    if (result == true) {
      // Recargar la lista
      context.read<CattleCubit>().loadCattle(farmId);
    }
  },
)
```

---

## 🧪 Testing

Para probar el formulario:

1. **Modo Creación:**
   - Presiona el FAB en `CattleListScreen`
   - Llena todos los campos obligatorios
   - Presiona "Crear Bovino"
   - Verifica que aparece en la lista

2. **Modo Edición:**
   - Toca una tarjeta en `CattleListScreen`
   - Verifica que los campos están pre-llenados
   - Modifica algún campo
   - Presiona "Actualizar Bovino"
   - Verifica que los cambios se reflejan

3. **Validaciones:**
   - Intenta enviar el formulario vacío
   - Intenta poner peso 0 o negativo
   - Verifica los mensajes de error

---

## ✅ Checklist de Implementación

- [x] BovinoFormState creado con todos los estados
- [x] BovinoFormCubit con lógica de creación y edición
- [x] BovinoFormScreen con UI completa
- [x] Validaciones en Cubit y UI
- [x] Factory method en DI
- [x] Imports agregados
- [x] Sin errores de compilación
- [x] Documentación completa

---

## 🎉 ¡Todo Listo!

El formulario de bovinos está **100% funcional** y listo para usar. Puedes:
- ✅ Crear nuevos bovinos
- ✅ Editar bovinos existentes
- ✅ Validar datos antes de guardar
- ✅ Ver feedback visual inmediato
- ✅ Recibir notificaciones de éxito/error

**Próximo paso:** Actualiza `CattleListScreen` para navegar al formulario cuando se presione el FAB o se toque una tarjeta.

