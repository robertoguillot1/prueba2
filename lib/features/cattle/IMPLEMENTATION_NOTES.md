# Notas de Implementación - Streams en Tiempo Real

## ✅ Implementación Completada

Se ha implementado **soporte completo para actualizaciones en tiempo real** usando Firestore Streams.

## 🔄 Cómo Funciona

### 1. **Data Source**

`CattleRemoteDataSourceImpl` tiene dos métodos:

```dart
// Consulta única (Future)
Future<List<BovineModel>> getCattleList(String farmId)

// Stream para actualizaciones en tiempo real
Stream<List<BovineModel>> getCattleListStream(String farmId)
```

El stream usa `snapshots()` de Firestore para escuchar cambios en tiempo real:

```dart
_firestore
  .collection('farms')
  .doc(farmId)
  .collection('cattle')
  .orderBy('identifier', descending: false)
  .snapshots() // 👈 Aquí está la magia
  .map((snapshot) => snapshot.docs
      .map((doc) => BovineModel.fromJson({...doc.data(), 'id': doc.id}))
      .toList());
```

### 2. **Repository**

`CattleRepositoryImpl` implementa ambos métodos:

```dart
// Método para consulta única
@override
Future<Either<Failure, List<BovineEntity>>> getCattleList(String farmId)

// Método para stream (retorna Stream directo, no Either)
@override
Stream<List<BovineEntity>> getCattleListStream(String farmId)
```

**Nota:** El stream retorna `Stream<List<BovineEntity>>` directamente (no envuelto en `Either`) porque los errores se manejan dentro del stream mismo usando `Stream.error()`.

### 3. **Cubit**

`CattleCubit` usa una estrategia de **carga inicial + suscripción al stream**:

```dart
Future<void> loadCattle(String farmId) async {
  // 1. Carga inicial usando el Future (rápido)
  final result = await getCattleListUseCase(
    GetCattleListParams(farmId: farmId)
  );

  result.fold(
    (failure) => emit(CattleError(failure.message)),
    (cattleList) {
      emit(CattleLoaded(cattleList)); // Muestra datos inmediatamente

      // 2. Suscribirse al stream para actualizaciones
      _cattleSubscription = repository.getCattleListStream(farmId).listen(
        (cattle) {
          if (!isClosed) {
            emit(CattleLoaded(cattle)); // Actualiza cuando hay cambios
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(CattleError('Error: $error'));
          }
        },
        cancelOnError: false,
      );
    },
  );
}
```

### 4. **Pantalla**

`CattleListScreen` simplemente escucha los cambios del Cubit:

```dart
BlocConsumer<CattleCubit, CattleState>(
  listener: (context, state) {
    if (state is CattleOperationSuccess) {
      // Mostrar notificación
      ScaffoldMessenger.of(context).showSnackBar(...);
      // Recargar para activar el stream
      context.read<CattleCubit>().loadCattle(farmId);
    }
  },
  builder: (context, state) {
    // UI se actualiza automáticamente cuando cambia el estado
  },
)
```

## 🎯 Ventajas de Esta Implementación

### ✅ **Carga Rápida Inicial**
- La primera carga usa `Future` para mostrar datos inmediatamente
- No hay espera innecesaria para la primera suscripción al stream

### ✅ **Actualizaciones en Tiempo Real**
- Después de la carga inicial, el stream mantiene los datos sincronizados
- Si otro usuario agrega/modifica/elimina un bovino, la lista se actualiza automáticamente

### ✅ **Manejo de Errores Robusto**
- La carga inicial usa `Either<Failure, T>` para errores estructurados
- El stream captura errores y los convierte en estados de error

### ✅ **Gestión de Memoria**
- La suscripción se cancela automáticamente cuando el Cubit se cierra
- Solo hay una suscripción activa a la vez (se cancela la anterior al recargar)

### ✅ **Compatible con el Patrón Existente**
- Los use cases siguen el patrón `Either<Failure, T>`
- El stream es una adición, no un reemplazo

## 🧪 Escenarios de Prueba

### Escenario 1: Usuario A agrega un bovino
1. Usuario A está en la pantalla de lista
2. Usuario A presiona "Nuevo Bovino" y crea "Vaca #123"
3. La lista se actualiza inmediatamente mostrando la nueva vaca
4. **Usuario B**, que también está viendo la lista, ve aparecer "Vaca #123" automáticamente

### Escenario 2: Usuario B elimina un bovino
1. Usuario A y Usuario B están viendo la lista
2. Usuario B elimina "Vaca #456"
3. La lista de Usuario A se actualiza automáticamente, removiendo "Vaca #456"

### Escenario 3: Sin conexión a Internet
1. Usuario está en la pantalla de lista
2. Se pierde la conexión
3. El stream emite un error
4. El Cubit emite `CattleError` con el mensaje apropiado
5. La UI muestra el botón "Reintentar"

## 📊 Comparación: Future vs Stream

| Característica | `getCattleList` (Future) | `getCattleListStream` (Stream) |
|---|---|---|
| **Retorno** | `Future<Either<Failure, List>>` | `Stream<List>` |
| **Actualizaciones** | Una sola vez | Continuas |
| **Errores** | `Left(Failure)` | `Stream.error()` |
| **Uso** | Carga inicial | Sincronización en tiempo real |
| **Cancelable** | No (ya completado) | Sí (con `cancel()`) |

## 🔧 Mantenimiento

### Para agregar más funcionalidades con streams:

1. **Agregar filtros en tiempo real:**
   ```dart
   Stream<List<BovineEntity>> getCattleByGender(String farmId, BovineGender gender) {
     return getCattleListStream(farmId)
       .map((list) => list.where((b) => b.gender == gender).toList());
   }
   ```

2. **Agregar búsqueda en tiempo real:**
   ```dart
   Stream<List<BovineEntity>> searchCattle(String farmId, String query) {
     return getCattleListStream(farmId)
       .map((list) => list.where((b) => 
         b.identifier.contains(query) || 
         (b.name?.contains(query) ?? false)
       ).toList());
   }
   ```

3. **Agregar ordenamiento dinámico:**
   ```dart
   Stream<List<BovineEntity>> getCattleSortedBy(String farmId, SortOption option) {
     return getCattleListStream(farmId)
       .map((list) {
         final sorted = List<BovineEntity>.from(list);
         sorted.sort((a, b) => /* lógica de ordenamiento */);
         return sorted;
       });
   }
   ```

## ⚠️ Consideraciones Importantes

### 1. **Costos de Firestore**
- Cada actualización en el stream cuenta como una lectura
- Si hay muchos cambios frecuentes, considera limitar las suscripciones

### 2. **Gestión de Memoria**
- Siempre cancela las suscripciones en `close()`
- Verifica `isClosed` antes de emitir estados

### 3. **Manejo de Estados Transitorios**
- El stream puede emitir múltiples actualizaciones rápidas
- Considera usar `debounce` si es necesario

### 4. **Testing**
- Para tests, puedes mockear el stream fácilmente:
   ```dart
   when(mockRepository.getCattleListStream(any))
     .thenAnswer((_) => Stream.value([mockBovine1, mockBovine2]));
   ```

## 🚀 Próximos Pasos

- [ ] Implementar filtros en tiempo real
- [ ] Implementar búsqueda en tiempo real
- [ ] Agregar indicadores de "actualizando" sutiles
- [ ] Implementar paginación para listas grandes
- [ ] Agregar caché local para modo offline



