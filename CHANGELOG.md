# Registro de Cambios (Changelog)

## NOTA DE ACTUALIZACIÓN: CORRECCIÓN DE ERRORES DE COMPILACIÓN Y ACTUALIZACIÓN DE DEPRECACIONES
ID de la Versión/Commit: 3b61dca

Fecha de Implementación: 14-12-2025

Tipo de Cambio: Corrección de Bug, Refactorización, Mantenimiento

Descripción Funcional (Qué se hizo):
- **Inyección de Dependencias**: Se implementaron métodos factory faltantes en `DependencyInjection` (e.g., `createFarmsCubit`, `createDashboardCubit`) y se corrigieron argumentos posicionales por nombrados en casos de uso de Streams.
- **Base de Datos**: Se añadió la lógica de inicialización y el getter `database` en `AppDatabase` que causaba errores de compilación.
- **Routing**: Se restauró la definición de clase `BovinoDetailScreen` en el Router que impedía la navegación.
- **Deprecaciones de Flutter**: 
  - Se reemplazó masivamente `Color.withOpacity()` por `Color.withValues(alpha: ...)` en 98 archivos para compatibilidad con Flutter 3.27+.
  - Se corrigió el uso de `activeColor` en temas y widgets, revirtiendo cambios incorrectos en `RadioListTile`.
- **Imports**: Se corrigieron rutas de importación relativas rotas en el módulo de Feeding y se agregaron imports de widgets faltantes (`GenealogyWidget`, `TransferTab`).

Justificación/Impacto (Por qué se hizo):
- **Estabilidad**: La aplicación no compilaba debido a errores críticos en la capa de infraestructura (DI y DB). Estos cambios restauran la capacidad de construcción y ejecución.
- **Deuda Técnica**: La eliminación de advertencias de deprecación asegura que la aplicación se mantenga compatible con futuras versiones de Flutter y reduce el "ruido" en el análisis estático.
- **Integridad**: Se validó que los módulos principales (Bovinos, Fincas, Dashboard) tengan sus dependencias correctamente configuradas.

## NOTA DE ACTUALIZACIÓN: CORRECCIÓN DE REGRESIONES EN DI
ID de la Versión/Commit: (Pre-commit)

Fecha de Implementación: 14-12-2025

Tipo de Cambio: Corrección de Bug (Crítico)

Descripción Funcional (Qué se hizo):
- **CattleCubit**: Se corrigieron los nombres de parámetros en `DependencyInjection` para coincidir con el constructor (`getCattleListUseCase`, `getBovineUseCase`, etc.).
- **ProductionFormCubit**: Se eliminaron dependencias no utilizadas (`update`/`delete`) y se agregó `addWeightRecord`.
- **HealthCubit**: Se renombraron parámetros (`getVacunasByBovino` -> `getVacunas`) y se agregó `addVacuna`.
- **ProductionCubit**: Se renombraron parámetros (`getMilkProductions` -> `getProduccionesLeche`, `getWeightRecords` -> `getPesos`).
- **TransferCubit/FarmProductionCubit**: Se completaron los parámetros faltantes (`deleteTransfer`, `addTransfer`, etc.).
- **BovinoDetailScreen**: Se corrigió la ruta de importación de `GenealogyWidget`.
- **FeedingModule**: Se agregó la clase `DatabaseFailure` en `failures.dart` y se corrigió el import de `CustomCard` en `CattleGlobalReportsScreen`.
- **Reports**: Se corrigió el import relativo de Cubits y el uso de `di.sl()` en `CattleGlobalReportsScreen`.
- **UI**: Se corrigió el error `DefaultTabController.of()` en `BovinoDetailScreen` mediante el uso de `Builder` para el FAB.
- **Sanidad**: Se agregaron las registros faltantes en `GetIt` para `GetVacunasByBovino`, `AddVacunaBovino` y `VacunaBovinoRepository`.

Justificación/Impacto (Por qué se hizo):
- **Resolución de Errores de Bloqueo**: Se solucionaron múltiples errores de tiempo de compilación tipo `missing_required_argument` y `undefined_named_parameter` que impedían el build.
