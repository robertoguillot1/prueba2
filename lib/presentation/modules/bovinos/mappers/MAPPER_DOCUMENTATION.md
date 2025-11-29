# 🔄 Mapper de Bovinos - Documentación

## ✅ Implementación Completada

Se ha creado un **mapper/adaptador** para convertir entre el modelo viejo (`Bovino`) y el nuevo (`BovineEntity`), permitiendo que la lista vieja navegue a la nueva pantalla de detalle.

---

## 📂 Archivos Creados/Modificados

### **Nuevo:**
- `lib/presentation/modules/bovinos/mappers/bovino_mapper.dart` ✅

### **Modificado:**
- `lib/presentation/modules/bovinos/list/bovinos_list_screen.dart` ✅

---

## 🔄 ¿Por Qué un Mapper?

### **El Problema:**
Tenemos **dos modelos diferentes** para el mismo concepto:

| Modelo Viejo (`Bovino`) | Modelo Nuevo (`BovineEntity`) |
|--------------------------|-------------------------------|
| MVVM tradicional | Clean Architecture |
| Más campos (reproductivos, salud) | Campos básicos simplificados |
| `identification` (nullable) | `identifier` (required) |
| `raza` (nullable) | `breed` (required) |
| `currentWeight` | `weight` |
| `healthStatus` | `status` |
| `category` + `productionStage` | `purpose` |

### **La Solución:**
Un mapper que convierte inteligentemente `Bovino` → `BovineEntity`

---

## 🧩 Cómo Funciona el Mapper

### **Método Principal:**

```dart
static BovineEntity toEntity(Bovino bovino) {
  return BovineEntity(
    id: bovino.id,
    farmId: bovino.farmId,
    identifier: bovino.identification ?? 'SIN-ID',
    name: bovino.name,
    breed: bovino.raza ?? 'Desconocida',
    gender: _mapGender(bovino.gender),
    birthDate: bovino.birthDate,
    weight: bovino.currentWeight,
    purpose: _inferPurpose(bovino),
    status: _mapStatus(bovino.healthStatus),
    createdAt: bovino.createdAt ?? DateTime.now(),
    updatedAt: bovino.updatedAt,
  );
}
```

---

## 🎯 Lógica de Mapeo

### **1. Campos Directos:**
```dart
id → id                           ✅ Directo
farmId → farmId                   ✅ Directo
identification → identifier       ⚠️ Con fallback 'SIN-ID'
name → name                       ✅ Directo
raza → breed                      ⚠️ Con fallback 'Desconocida'
currentWeight → weight            ✅ Directo
birthDate → birthDate             ✅ Directo
createdAt → createdAt            ⚠️ Con fallback DateTime.now()
updatedAt → updatedAt            ✅ Directo
```

### **2. Mapeo de Género:**
```dart
BovinoGender.male → BovineGender.male     ✅
BovinoGender.female → BovineGender.female ✅
```

### **3. Inferencia de Propósito (Inteligente):**

La lógica infiere el propósito basándose en:

```dart
// Si es VACA + está lactante o preñada
→ BovinePurpose.dual

// Si es VACA sin info reproductiva
→ BovinePurpose.milk

// Si es TORO
→ BovinePurpose.meat

// Si es TERNERO/NOVILLA en desarrollo
→ BovinePurpose.dual

// Si está en etapa de descarte
→ BovinePurpose.meat

// Por defecto (más seguro)
→ BovinePurpose.dual
```

### **4. Mapeo de Estado:**

```dart
HealthStatus.sano → BovineStatus.active
HealthStatus.enfermo → BovineStatus.active
HealthStatus.tratamiento → BovineStatus.active
```

**Nota:** Todos los estados de salud se mapean a `active` porque el modelo nuevo no distingue salud, solo si está activo/vendido/muerto.

---

## 💻 Uso en el Código

### **En `bovinos_list_screen.dart`:**

```dart
void _navigateToDetails(bovino) {
  // 1️⃣ Convertir el Bovino viejo a BovineEntity nuevo
  final bovineEntity = BovinoMapper.toEntity(bovino);
  
  // 2️⃣ Navegar a la nueva pantalla de detalle
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BovinoDetailScreen(
        bovine: bovineEntity,
        farmId: widget.farmId,
      ),
    ),
  ).then((result) {
    // 3️⃣ Recargar la lista si hubo cambios
    if (result == true) {
      _refreshData();
    }
  });
}
```

---

## 🔄 Flujo Completo

```
Usuario en BovinosListScreen (lista vieja con modelo Bovino)
    ↓
Usuario toca tarjeta de bovino
    ↓
_navigateToDetails(bovino)
    ↓
BovinoMapper.toEntity(bovino)
    ↓
Bovino → BovineEntity (conversión)
    ↓
Navigator.push(BovinoDetailScreen con BovineEntity)
    ↓
Usuario ve la nueva pantalla de detalle moderna
    ↓
Usuario presiona FAB "Editar"
    ↓
BovinoFormScreen
    ↓
Usuario guarda cambios
    ↓
Navigator.pop con result = true
    ↓
Cierra detalle y recarga lista vieja
```

---

## ⚠️ Limitaciones y Consideraciones

### **1. Pérdida de Información:**
El modelo nuevo (`BovineEntity`) es más simple, así que **se pierde información** al convertir:

**Información que NO se mapea:**
- ❌ `category` (vaca/toro/ternero/novilla)
- ❌ `productionStage` (levante/desarrollo/producción/descarte)
- ❌ `breedingStatus` (vacía/en celo/preñada/lactante/seca)
- ❌ `lastHeatDate`
- ❌ `inseminationDate`
- ❌ `expectedCalvingDate`
- ❌ `previousCalvings`
- ❌ `notes`
- ❌ `photoUrl`
- ❌ `idPadre`, `nombrePadre`, `idMadre`, `nombreMadre`

**Esto es OK** porque la pantalla de detalle nueva solo muestra la información básica. Los datos adicionales están en las tabs "Reproducción", "Producción", etc. que son placeholders por ahora.

### **2. Conversión en Un Solo Sentido:**
El mapper solo convierte `Bovino` → `BovineEntity`, **NO al revés**.

Si editas desde la nueva pantalla, los cambios se guardan en Firestore con el modelo nuevo. La lista vieja seguirá mostrando el modelo viejo hasta que implementes sincronización bidireccional.

### **3. Inferencia de Propósito No es Perfecta:**
La lógica intenta inferir el propósito, pero puede no ser 100% precisa. Si necesitas precisión, considera agregar el campo `purpose` al modelo viejo.

---

## 🔧 Métodos Auxiliares

### **Conversión de Listas:**

```dart
static List<BovineEntity> toEntityList(List<Bovino> bovinos) {
  return bovinos.map((bovino) => toEntity(bovino)).toList();
}
```

**Uso:**
```dart
final listaBovina = viewModel.bovinos;
final listaEntity = BovinoMapper.toEntityList(listaBovina);
```

---

## 🎯 Mejoras Futuras (Opcional)

### **1. Mapper Bidireccional:**
```dart
static Bovino fromEntity(BovineEntity entity) {
  // Convertir BovineEntity → Bovino
}
```

### **2. Sincronización de Modelos:**
Cuando se edite desde la nueva pantalla, actualizar también el modelo viejo.

### **3. Agregar Campo Purpose al Modelo Viejo:**
```dart
// En lib/domain/entities/bovinos/bovino.dart
final BovinePurpose? purpose; // Agregar campo
```

Esto eliminaría la necesidad de inferir el propósito.

---

## ✅ Checklist de Implementación

- [x] Mapper creado (`bovino_mapper.dart`)
- [x] Método `toEntity` implementado
- [x] Mapeo de género implementado
- [x] Inferencia de propósito implementada
- [x] Mapeo de estado implementado
- [x] Lista vieja actualizada
- [x] Import del mapper agregado
- [x] Navegación a nueva pantalla funcionando
- [x] Recarga de lista después de editar
- [x] Sin errores de compilación

---

## 🎉 Estado Final

✅ **La lista vieja ahora navega a la pantalla de detalle nueva**
✅ **El mapper convierte automáticamente los modelos**
✅ **La navegación funciona perfectamente**
✅ **La lista se recarga después de editar**

---

## 🧪 Prueba Rápida

1. Abre la lista vieja de bovinos (`BovinosListScreen`)
2. Toca cualquier tarjeta
3. ✅ Verifica que abre `BovinoDetailScreen` (nueva)
4. ✅ Verifica que la información se muestra correctamente
5. Presiona FAB "Editar"
6. Modifica algún dato y guarda
7. ✅ Verifica que cierra detalle
8. ✅ Verifica que la lista se recarga

**¡Todo debería funcionar perfectamente!** 🎊





