# 📋 Plan de Migración: Sistema Legacy → Sistema Híbrido (Firestore)

## 📊 Resumen Ejecutivo

- **Total de módulos principales:** 7
- **Módulos migrados a sistema híbrido (Firestore):** 3
- **Módulos en sistema legacy (SharedPreferences):** 4
- **Nivel de acoplamiento legacy:** MEDIO-ALTO

---

## ✅ Módulos Migrados a Sistema Híbrido (Firestore)

### 1. ✅ Bovinos/Cattle
- **Estado:** ✅ Migrado completamente
- **Repositorio:** `CattleHybridRepositoryImpl`
- **Datasource remoto:** `CattleRemoteDataSource` (Firestore)
- **Datasource local:** `CattleLocalDataSource` (SQLite)
- **Funciona en web:** ✅ Sí
- **Funciona offline:** ✅ Sí
- **Dependencias legacy:** Ninguna
- **Acción requerida:** Ninguna

### 2. ✅ Trabajadores (Workers)
- **Estado:** ✅ Migrado (recién actualizado)
- **Repositorio:** `TrabajadoresHybridRepositoryImpl`
- **Datasource remoto:** `TrabajadoresRemoteDataSource` (Firestore)
- **Datasource local:** `TrabajadoresLocalDataSource` (SQLite) + Legacy como fallback
- **Funciona en web:** ✅ Sí
- **Funciona offline:** ✅ Sí
- **Dependencias legacy:** MEDIA (usa `TrabajadoresRepositoryImpl` como fallback offline)
- **Acción requerida:** Reducir dependencia de legacy como fallback

### 3. ⚠️ Ovinos (Ovejas)
- **Estado:** ⚠️ Migrado pero NO ACTIVO
- **Repositorio:** `OvinosHybridRepository` (existe pero no se usa)
- **Datasource remoto:** `OvinosRemoteDataSource` (API REST)
- **Datasource local:** `OvinosLocalDataSource` (SQLite)
- **Funciona en web:** ✅ Sí
- **Funciona offline:** ✅ Sí
- **Dependencias legacy:** ALTA (el sistema legacy sigue siendo el activo en DI)
- **Acción requerida:** 🔴 **ACTIVAR** `OvinosHybridRepository` en `DependencyInjection`

---

## ❌ Módulos en Sistema Legacy (SharedPreferences)

### 4. 🔴 Ovinos (Ovejas) — ACTIVO (debe migrarse)
- **Estado:** Legacy activo
- **Repositorio:** `OvejasRepositoryImpl`
- **Datasource:** `OvejasDataSourceImpl` (SharedPreferences)
- **Problema:** ❌ No persiste en web
- **Nota:** Existe `OvinosHybridRepository` pero no está registrado en DI
- **Acción requerida:** 
  - [ ] Activar `OvinosHybridRepository` en DI
  - [ ] Desactivar `OvejasRepositoryImpl`
  - [ ] Migrar datos existentes de SharedPreferences a Firestore

### 5. ✅ Bovinos (Bovinos) — LEGACY (ELIMINADO)
- **Estado:** ✅ ELIMINADO
- **Repositorio:** `BovinosRepositoryImpl` - ❌ Eliminado de DI
- **Datasource:** `BovinosDataSourceImpl` - ❌ Eliminado de DI
- **Nota:** Usar `CattleHybridRepositoryImpl` (Firestore) que es el sistema nuevo
- **Acción completada:** 
  - [x] **ELIMINADO** sistema legacy de Bovinos de DI
  - [x] Eliminadas referencias en `createDashboardCubit`
  - [x] Comentados imports relacionados
  - [ ] Migrar datos existentes si es necesario (opcional)

### 6. 🔴 Porcinos (Cerdos)
- **Estado:** Legacy
- **Repositorio:** `CerdosRepositoryImpl`
- **Datasource:** `CerdosDataSourceImpl` (SharedPreferences)
- **Problema:** ❌ No persiste en web
- **Acción requerida:** 
  - [ ] Crear `CerdosHybridRepository` (Firestore)
  - [ ] Crear `CerdosRemoteDataSource` (Firestore)
  - [ ] Crear `CerdosLocalDataSource` (SQLite)
  - [ ] Activar en DI
  - [ ] Migrar datos existentes

### 7. 🔴 Avicultura (Gallinas)
- **Estado:** Legacy
- **Repositorio:** `GallinasRepositoryImpl`
- **Datasource:** `GallinasDataSourceImpl` (SharedPreferences)
- **Problema:** ❌ No persiste en web
- **Acción requerida:** 
  - [ ] Crear `GallinasHybridRepository` (Firestore)
  - [ ] Crear `GallinasRemoteDataSource` (Firestore)
  - [ ] Crear `GallinasLocalDataSource` (SQLite)
  - [ ] Activar en DI
  - [ ] Migrar datos existentes

---

## 🔗 Análisis de Acoplamiento Legacy

### Nivel de Compromiso: MEDIO-ALTO

#### Dependencias Directas:
1. **`DependencyInjection.init()`** inicializa todos los datasources legacy:
   ```dart
   _ovejasDataSource = OvejasDataSourceImpl(_sharedPreferences!);
   _bovinosDataSource = BovinosDataSourceImpl(_sharedPreferences!); // ELIMINAR
   _cerdosDataSource = CerdosDataSourceImpl(_sharedPreferences!);
   _trabajadoresDataSource = TrabajadoresDataSourceImpl(_sharedPreferences!);
   _gallinasDataSource = GallinasDataSourceImpl(_sharedPreferences!);
   ```

2. **`TrabajadoresHybridRepositoryImpl`** depende del legacy:
   - Usa `TrabajadoresRepositoryImpl` como fallback offline
   - Mantiene compatibilidad con datos existentes

3. **`FarmProvider`** usa SharedPreferences:
   - Guarda fincas en SharedPreferences
   - Firestore está temporalmente desactivado

#### Dependencias Indirectas:
- Todos los ViewModels/UseCases que usan repositorios legacy
- Pantallas que dependen de estos ViewModels
- Datos existentes en SharedPreferences que necesitan migración

---

## 🚨 Problemas Identificados

### Críticos 🔴
1. **Ovinos:** Existe `OvinosHybridRepository` pero no está activo en DI
2. **Bovinos:** Hay dos sistemas paralelos:
   - `BovinosRepositoryImpl` (legacy, SharedPreferences) - **ELIMINAR**
   - `CattleHybridRepositoryImpl` (nuevo, Firestore) - **MANTENER**
3. **Trabajadores:** Usa legacy como fallback, puede causar inconsistencias

### Importantes 🟡
4. **Porcinos y Avicultura:** Sin migración iniciada
5. **`FarmProvider`:** Firestore desactivado, usa SharedPreferences

---

## 📋 Plan de Acción por Prioridad

### 🔴 Prioridad ALTA (Crítico)

#### 1. Eliminar Sistema Legacy de Bovinos
- [x] Eliminar `BovinosRepositoryImpl` de DI
- [ ] Eliminar `BovinosDataSourceImpl` de DI
- [ ] Verificar que no haya referencias al sistema legacy
- [ ] Eliminar archivos legacy si no se usan
- [ ] Actualizar documentación

#### 2. Activar OvinosHybridRepository
- [ ] Reemplazar `OvejasRepositoryImpl` por `OvinosHybridRepository` en DI
- [ ] Verificar que funcione correctamente
- [ ] Probar en web y móvil
- [ ] Migrar datos existentes de SharedPreferences a Firestore

#### 3. Reducir Dependencia Legacy en Trabajadores
- [ ] Eliminar uso de `TrabajadoresRepositoryImpl` como fallback
- [ ] Usar solo `TrabajadoresLocalDataSource` (SQLite) para offline
- [ ] Verificar que funcione correctamente

### 🟡 Prioridad MEDIA

#### 4. Migrar Porcinos
- [ ] Crear `CerdosHybridRepository`
- [ ] Crear `CerdosRemoteDataSource` (Firestore)
- [ ] Crear `CerdosLocalDataSource` (SQLite)
- [ ] Registrar en DI
- [ ] Migrar datos existentes

#### 5. Migrar Avicultura
- [ ] Crear `GallinasHybridRepository`
- [ ] Crear `GallinasRemoteDataSource` (Firestore)
- [ ] Crear `GallinasLocalDataSource` (SQLite)
- [ ] Registrar en DI
- [ ] Migrar datos existentes

#### 6. Migrar FarmProvider a Firestore
- [ ] Activar Firestore en `FarmProvider`
- [ ] Migrar datos de fincas a Firestore
- [ ] Eliminar dependencia de SharedPreferences

### 🟢 Prioridad BAJA

#### 7. Limpieza Final
- [ ] Eliminar código legacy una vez migrado todo
- [ ] Eliminar datasources legacy no utilizados
- [ ] Documentar arquitectura híbrida final
- [ ] Crear guía de migración para futuros módulos

---

## 📊 Matriz de Estado

| Módulo | Sistema Actual | Persiste en Web | Offline | Migración Necesaria | Estado |
|--------|----------------|-----------------|---------|---------------------|--------|
| **Bovinos (Cattle)** | Híbrido (Firestore) | ✅ Sí | ✅ Sí | ✅ Completa | ✅ LISTO |
| **Trabajadores** | Híbrido (Firestore) | ✅ Sí | ✅ Sí | ⚠️ Parcial | ⚠️ EN PROGRESO |
| **Ovinos** | Legacy (SharedPrefs) | ❌ No | ✅ Sí | 🔴 Crítica | 🔴 PENDIENTE |
| **Bovinos (Legacy)** | Legacy (SharedPrefs) | ❌ No | ✅ Sí | 🗑️ Eliminar | 🗑️ ELIMINAR |
| **Porcinos** | Legacy (SharedPrefs) | ❌ No | ✅ Sí | 🔴 Alta | 🔴 PENDIENTE |
| **Avicultura** | Legacy (SharedPrefs) | ❌ No | ✅ Sí | 🔴 Alta | 🔴 PENDIENTE |
| **Fincas (Farms)** | Legacy (SharedPrefs) | ❌ No | ✅ Sí | 🟡 Media | 🟡 PENDIENTE |

---

## 📝 Notas Importantes

### Arquitectura Híbrida
El sistema híbrido funciona así:
- **Web:** Solo Firestore (SQLite no disponible)
- **Móvil/Desktop con conexión:** Firestore + caché local (SQLite)
- **Móvil/Desktop sin conexión:** Caché local (SQLite) + cola de sincronización

### Migración de Datos
Cuando se migre un módulo:
1. Crear script de migración de SharedPreferences → Firestore
2. Ejecutar migración en primer inicio
3. Mantener datos legacy como backup temporal
4. Eliminar datos legacy después de verificar migración

### Testing
Antes de activar un módulo migrado:
- [ ] Probar creación en web
- [ ] Probar lectura en web
- [ ] Probar actualización en web
- [ ] Probar eliminación en web
- [ ] Probar offline en móvil
- [ ] Probar sincronización

---

## 🎯 Objetivo Final

**Eliminar completamente el sistema legacy (SharedPreferences) y usar solo el sistema híbrido (Firestore + SQLite) para garantizar:**
- ✅ Persistencia en web
- ✅ Funcionamiento offline en móvil/desktop
- ✅ Sincronización automática
- ✅ Consistencia de datos
- ✅ Mejor rendimiento

---

## 📅 Historial de Cambios

### 2024-12-XX
- ✅ Migrado Trabajadores a sistema híbrido
- ✅ Eliminado sistema legacy de Bovinos de DependencyInjection
- ✅ Actualizado DashboardCubit para no usar sistema legacy de bovinos
- ✅ Comentados imports relacionados con sistema legacy de bovinos
- 📝 Creado este documento de migración

---

**Última actualización:** 2024-12-XX

