# 🌾 Gestión de Fincas - Sistema Completo de Ganadería

Una aplicación móvil completa desarrollada en Flutter para la gestión integral de fincas ganaderas, incluyendo múltiples tipos de animales, trabajadores, control financiero, vacunación y análisis de producción.

## 📱 Características Principales

### 🏡 **Gestión de Fincas**
- **Crear, editar y eliminar fincas** con información completa
- **Perfiles independientes** - cada finca funciona como un entorno separado
- **Personalización visual** con colores distintivos para cada finca
- **Información detallada**: nombre, ubicación, descripción, fecha de creación
- **Módulos personalizables** con ordenamiento personalizado

### 👷‍♂️ **Módulo de Trabajadores**
- **Registro completo de trabajadores** con datos personales y laborales
- **Tipos de contrato**:
  - Indefinido/Fijo (salario quincenal)
  - Prestación de Servicios/Contrato (pago por actividades)
- **Campos incluidos**:
  - Nombre completo
  - Cédula o identificación
  - Cargo o función en la finca
  - Salario (quincenal o por actividad)
  - Fecha de ingreso
  - Estado (activo/inactivo)
- **Búsqueda avanzada** por nombre, cédula o cargo
- **Perfil individual** con historial completo de pagos y préstamos

### 💰 **Módulo de Pagos**
- **Registro detallado de pagos** con múltiples tipos:
  - Pago completo (auto-completa con salario neto)
  - Anticipo
- **Información incluida**:
  - Fecha del pago
  - Monto pagado
  - Observaciones
  - Tipo de pago
- **Cálculo automático** de salario neto (salario - préstamos pendientes)
- **Historial cronológico** de todos los pagos
- **Edición y eliminación** de pagos registrados

### 💵 **Módulo de Préstamos**
- **Registro completo de préstamos** a trabajadores
- **Campos incluidos**:
  - Fecha del préstamo
  - Monto prestado
  - Descripción o motivo
  - Estado (pendiente/pagado)
  - Fecha de pago (si aplica)
  - Notas adicionales
- **Impacto automático en salarios**: Los préstamos pendientes se deducen del salario neto
- **Restauración automática** del salario al pagar préstamos
- **Seguimiento completo** del estado de cada préstamo
- **Edición y eliminación** de préstamos

### 🐷 **Módulo de Porcicultura**
- **Inventario completo de cerdos** con información detallada
- **Registro de animales** con:
  - Identificación única
  - Género (Macho/Hembra)
  - Fecha de nacimiento
  - Peso actual
  - Etapa de alimentación (Inicio, Levante, Engorde)
  - Notas adicionales
- **Perfil individual** de cada cerdo
- **Control de peso** con registro histórico
- **Sistema de vacunación**:
  - Registro de vacunas aplicadas
  - Historial completo de vacunación
  - Próximas dosis programadas
  - Módulo centralizado de vacunas
- **Gestión de Alimento**:
  - Análisis de consumo por etapa
  - Registro de compras de alimento
  - Cálculo de días hasta que se acabe el alimento
  - Costos de alimentación

### 🐐🐑 **Módulo de Control Ovino/Caprino (Chivos/Ovejas)**
- **Inventario completo** de chivos y ovejas
- **Registro de animales** con:
  - Chapeta (identificador visual obligatorio)
  - Tipo (Chivo/Oveja)
  - Género (Macho/Hembra)
  - Estado reproductivo (solo hembras):
    - Vacía
    - Gestante
    - Lactancia
  - Fecha de monta (si está gestante)
  - Fecha probable de parto (calculada automáticamente: +150 días)
- **Alertas visuales**:
  - Alerta cuando faltan menos de 10 días para el parto
  - Tarjetas destacadas para animales próximos a parir
- **Sistema de vacunación**:
  - Registro de vacunas aplicadas
  - Historial completo por animal
  - Módulo centralizado de vacunas
- **Perfil individual** de cada animal con historial completo

### 🐄 **Módulo de Ganado (Cattle)**
- **Inventario completo** de ganado bovino
- **Registro de animales** con información detallada
- **Control de peso** con registros históricos
- **Sistema de vacunación** completo
- **Producción de leche**:
  - Registro diario de producción
  - Análisis de producción
  - Seguimiento de rendimiento
- **Eventos reproductivos**:
  - Montas
  - Partos
  - Gestaciones
- **Transferencias y viajes** del ganado

### 🐔 **Módulo de Avicultura**

#### **Pollos de Engorde (BroilerBatch)**
- **Gestión por lotes** (no animales individuales)
- **Registro de lotes** con:
  - Nombre del lote
  - Fecha de ingreso
  - Cantidad inicial y actual de pollos
  - Edad inicial en días
  - Peso promedio actual (en gramos)
  - Meta de peso (en gramos, por defecto 3000g = 3kg)
  - Meta de sacrificio (días, por defecto 45)
  - Costo de compra del lote
- **Control automático de alimentación**:
  - Tabla de consumo diario por día de vida
  - Etapas de alimentación:
    - Preinicio (días 2-11): 26.4g/ave/día
    - Inicio (días 12-21): 62.7g/ave/día
    - Engorde (días 22-34): 154.2g/ave/día
    - Finalizador (días 35-42): 161.4g/ave/día
  - Sugerencia automática de tipo de alimento según etapa
  - Cálculo de bultos necesarios por etapa (40kg por bulto)
- **Stock de alimento automático**:
  - Disminuye automáticamente según consumo diario
  - Actualización en tiempo real
  - Alertas cuando el stock es bajo
- **Sistema financiero completo**:
  - Registro de gastos por categoría:
    - Alimento
    - Medicina
    - Vacunas
    - Insumos
    - Mano de Obra
    - Otros
  - Registro de ventas del lote
  - Balance financiero detallado:
    - Ingresos (venta del lote)
    - Egresos desglosados por categoría
    - Utilidad neta (verde si hay ganancia, rojo si hay pérdida)
  - Gráfico circular de distribución de gastos
  - Cálculo de rentabilidad y costo de producción por pollo
- **Estadísticas y gráficos**:
  - Curva de crecimiento (peso vs días de vida)
  - Gráfico de mortalidad (vivos vs muertos)
  - Progreso del lote con barra visual
  - Comparación peso actual vs peso esperado
- **Cierre de lote**:
  - Registro de venta con peso total, precio por kilo y cantidad vendida
  - Cálculo automático de total de venta
  - Cambio de estado a "Cerrado/Vendido"

#### **Gallinas Ponedoras (LayerBatch)**
- **Gestión por lotes** de gallinas ponedoras
- **Registro de lotes** con:
  - Fecha de nacimiento
  - Fecha de ingreso al lote
  - Cantidad de gallinas
  - Precio por cartón de huevos
- **Registro diario de producción**:
  - Cantidad de huevos recogidos
  - Cantidad de huevos rotos
  - Alimento consumido (kg)
  - Observaciones
- **Análisis de producción**:
  - Conversión automática a cartones (30 huevos = 1 cartón)
  - Porcentaje de postura calculado automáticamente
  - Alertas visuales por rendimiento:
    - Verde: >90% (Excelente)
    - Amarillo: 70-90% (Normal)
    - Rojo: <70% (Alerta)
  - Estimación de ganancia diaria
- **Estadísticas y gráficos**:
  - Curva de postura (porcentaje vs semanas de vida)
  - Alertas visuales en caídas bruscas de producción (>5%)
  - Análisis de tendencias

### 💉 **Sistema de Vacunación**
- **Módulos de vacunación** para:
  - Cerdos
  - Chivos/Ovejas
  - Ganado
- **Registro completo** de vacunas con:
  - Nombre de la vacuna
  - Fecha de aplicación
  - Número de lote
  - Próxima dosis programada
  - Administrado por
  - Observaciones
- **Historial por animal** en el perfil individual
- **Vista centralizada** de todas las vacunas por tipo de animal
- **Alertas** de próximas vacunas programadas

### 📊 **Gestión de Alimento**
- **Módulo unificado** de análisis y costos de alimento
- **Registro de compras**:
  - Fecha de compra
  - Cantidad y unidad (kg, toneladas, bultos)
  - Precio total
  - Proveedor
- **Análisis de consumo**:
  - Consumo diario por etapa de alimentación
  - Días hasta que se acabe el alimento
  - Inventario actual en kg y bultos
- **Costos de alimentación**:
  - Registro de gastos en alimento
  - Análisis de costos por tipo de animal
  - Tendencias de precios

### 📈 **Estadísticas y Análisis**
- **Dashboard completo** con métricas clave por módulo
- **Gráficos interactivos**:
  - Curvas de crecimiento (pollos)
  - Curvas de postura (gallinas)
  - Gráficos de mortalidad
  - Distribución de gastos (gráficos circulares)
  - Análisis financiero por lote
- **Resúmenes mensuales**:
  - Total de pagos
  - Total de préstamos pendientes
  - Producción total
  - Análisis de rentabilidad

### 💸 **Gastos y Finanzas**
- **Registro de gastos normales** de la finca
- **Categorización** de gastos
- **Análisis financiero** por categoría
- **Control de gastos** por módulo (especialmente en avicultura)

## 🛠️ **Tecnologías Utilizadas**

- **Flutter**: Framework de desarrollo móvil multiplataforma
- **Provider**: Gestión de estado de la aplicación
- **SharedPreferences**: Almacenamiento local de datos
- **FL Chart**: Gráficos y visualizaciones avanzadas
- **Intl**: Formateo de fechas, monedas y números
- **Material Design 3**: Diseño moderno y consistente
- **Firebase** (opcional): Sincronización en la nube

## 📁 **Estructura del Proyecto**

```
lib/
├── models/
│   ├── farm.dart                    # Modelo de finca
│   ├── worker.dart                  # Modelo de trabajador
│   ├── payment.dart                 # Modelo de pago
│   ├── loan.dart                    # Modelo de préstamo
│   ├── pig.dart                     # Modelo de cerdo
│   ├── pig_vaccine.dart             # Modelo de vacuna de cerdo
│   ├── goat_sheep.dart              # Modelo de chivo/oveja
│   ├── goat_sheep_vaccine.dart      # Modelo de vacuna de chivo/oveja
│   ├── cattle.dart                   # Modelo de ganado
│   ├── cattle_vaccine.dart           # Modelo de vacuna de ganado
│   ├── broiler_batch.dart           # Modelo de lote de pollos de engorde
│   ├── layer_batch.dart              # Modelo de lote de gallinas ponedoras
│   ├── layer_production_record.dart  # Modelo de registro de producción
│   ├── batch_expense.dart           # Modelo de gasto de lote
│   ├── batch_sale.dart              # Modelo de venta de lote
│   ├── food_purchase.dart           # Modelo de compra de alimento
│   └── expense.dart                 # Modelo de gasto general
├── providers/
│   ├── farm_provider.dart           # Gestión de estado principal
│   └── auth_provider.dart           # Gestión de autenticación
├── screens/
│   ├── farms_list_screen.dart       # Listado de fincas
│   ├── farm_profile_screen.dart     # Perfil de finca
│   ├── workers_list_screen.dart     # Listado de trabajadores
│   ├── worker_profile_screen.dart   # Perfil de trabajador
│   ├── pigs_inventory_screen.dart   # Inventario de cerdos
│   ├── pig_profile_screen.dart      # Perfil de cerdo
│   ├── goat_sheep_inventory_screen.dart  # Inventario de chivos/ovejas
│   ├── goat_sheep_home_screen.dart  # Home de chivos/ovejas
│   ├── poultry_home_screen.dart     # Home de avicultura
│   ├── broiler_batch_detail_screen.dart  # Detalle de lote de engorde
│   ├── layer_batch_detail_screen.dart    # Detalle de lote de ponedoras
│   ├── batch_balance_screen.dart    # Balance financiero de lote
│   └── ... (más pantallas)
└── widgets/
    ├── broiler_growth_chart.dart    # Gráfico de crecimiento
    ├── broiler_mortality_chart.dart # Gráfico de mortalidad
    ├── layer_production_chart.dart  # Gráfico de producción
    ├── batch_financial_summary.dart # Resumen financiero
    └── ... (más widgets)
```

## 🚀 **Funcionalidades Destacadas**

### **Sistema de Perfiles Independientes**
- Cada finca mantiene sus propios datos completamente separados
- Múltiples tipos de animales por finca
- Configuración individual por finca

### **Gestión Financiera Avanzada**
- Cálculo automático de salarios netos
- Sistema financiero completo para lotes de pollos
- Análisis de rentabilidad detallado
- Control de gastos por categoría

### **Control Automático de Alimentación**
- Tablas de consumo automáticas según edad/etapa
- Sugerencias de tipo de alimento según etapa
- Cálculo de bultos necesarios
- Stock automático que disminuye según consumo

### **Sistema de Alertas Inteligentes**
- Alertas de partos próximos (chivos/ovejas)
- Alertas de stock bajo de alimento
- Alertas de producción baja (gallinas)
- Alertas de próximas vacunas

### **Visualización de Datos**
- Gráficos interactivos con FL Chart
- Curvas de crecimiento y producción
- Análisis financiero visual
- Dashboards por módulo

### **Interfaz Intuitiva**
- Diseño moderno con Material Design 3
- Navegación fluida entre módulos
- Búsqueda y filtrado avanzado
- Confirmaciones de seguridad para acciones críticas
- Formularios inteligentes con validación en tiempo real

## 📱 **Experiencia de Usuario**

### **Flujo Principal por Módulo**

#### **Trabajadores**
1. Crear finca
2. Registrar trabajadores con tipo de contrato
3. Registrar pagos quincenales o por actividad
4. Gestionar préstamos cuando sea necesario
5. Analizar estadísticas financieras

#### **Porcicultura**
1. Registrar cerdos con información completa
2. Registrar vacunas aplicadas
3. Registrar compras de alimento
4. Analizar consumo y costos

#### **Chivos/Ovejas**
1. Registrar animales con chapeta
2. Gestionar estado reproductivo
3. Registrar vacunas
4. Monitorear partos próximos

#### **Avicultura - Pollos de Engorde**
1. Crear lote con información inicial
2. El sistema calcula automáticamente el consumo según edad
3. Registrar gastos (alimento, medicina, etc.)
4. El stock disminuye automáticamente
5. Registrar venta al cerrar el lote
6. Ver balance financiero completo

#### **Avicultura - Gallinas Ponedoras**
1. Crear lote de gallinas
2. Registrar producción diaria
3. Analizar porcentaje de postura
4. Ver gráficos de producción

### **Características de Usabilidad**
- **Pantallas de estado vacío** con guías para el usuario
- **Validación robusta** de formularios
- **Mensajes informativos** y confirmaciones
- **Navegación contextual** entre módulos relacionados
- **Búsqueda rápida** en listados extensos
- **Actualización automática** de datos calculados

## 🔧 **Instalación y Configuración**

1. **Clonar el repositorio**
   ```bash
   git clone [url-del-repositorio]
   cd ganaderia
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

4. **Configurar Firebase** (opcional)
   - Seguir las instrucciones en `FIREBASE_SETUP.md`
   - Configurar Firestore para sincronización en la nube

## 📊 **Métricas y Análisis**

La aplicación proporciona análisis completos incluyendo:

### **Financiero**
- Resumen mensual de pagos y gastos
- Análisis por trabajador con métricas individuales
- Estado de préstamos con seguimiento detallado
- Rentabilidad por lote de pollos
- Costos de producción

### **Producción**
- Producción de leche (ganado)
- Producción de huevos (gallinas)
- Crecimiento de pollos (gráficos)
- Mortalidad por lote

### **Alimentación**
- Consumo diario por tipo de animal
- Días hasta que se acabe el alimento
- Costos de alimentación
- Bultos necesarios por etapa

### **Salud**
- Historial de vacunación
- Próximas vacunas programadas
- Alertas de salud

## 🎯 **Casos de Uso**

- **Fincas ganaderas** que necesitan gestionar múltiples tipos de animales
- **Granjas avícolas** con producción de pollos de engorde y gallinas ponedoras
- **Fincas porcinas** con control de alimentación y vacunación
- **Fincas mixtas** con ganado, cerdos, aves y pequeños rumiantes
- **Empresas rurales** con personal y control financiero
- **Cooperativas** que manejan múltiples propiedades
- **Administradores** que requieren control detallado de producción y finanzas

## 🔒 **Seguridad y Privacidad**

- **Datos locales**: Toda la información se almacena localmente por defecto
- **Sin conexión**: Funciona completamente offline
- **Firebase opcional**: Sincronización en la nube cuando se configura
- **Confirmaciones**: Acciones críticas requieren confirmación
- **Validación**: Entrada de datos validada en tiempo real
- **Backup automático**: Respaldos locales automáticos

## 📝 **Notas Técnicas**

### **Unidades de Medida**
- **Peso de pollos**: Se almacena en gramos, se muestra en kg
- **Alimento**: Se almacena en kg, se calcula en bultos (40kg)
- **Consumo**: Se calcula en gramos por ave por día

### **Cálculos Automáticos**
- **Stock de alimento**: Disminuye automáticamente según consumo diario
- **Consumo de pollos**: Se calcula según tabla por día de vida
- **Fecha de parto**: Se calcula automáticamente (+150 días desde monta)
- **Salario neto**: Se calcula automáticamente (salario - préstamos)

### **Etapas de Alimentación**
- **Pollos de Engorde**:
  - Preinicio: Días 2-11
  - Inicio: Días 12-21
  - Engorde: Días 22-34
  - Finalizador: Días 35-42
- **Cerdos**:
  - Inicio
  - Levante
  - Engorde

## 🆕 **Versión Actual**

Esta versión incluye:
- ✅ Módulo completo de Porcicultura
- ✅ Módulo completo de Control Ovino/Caprino
- ✅ Módulo completo de Avicultura (Engorde y Ponedoras)
- ✅ Sistema financiero para lotes
- ✅ Control automático de stock y alimentación
- ✅ Sistema de vacunación completo
- ✅ Gráficos y estadísticas avanzadas
- ✅ Gestión unificada de alimento

---

**Desarrollado con Flutter** - Una solución completa para la gestión moderna de fincas ganaderas. 🚀
