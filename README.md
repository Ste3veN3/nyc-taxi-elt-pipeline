# NYC Taxi ELT Pipeline (2025)

Proyecto desarrollado para la materia **Fundamentos de Ciencia de Datos** de la **Universidad San Francisco de Quito**.

Este proyecto implementa una arquitectura para la ingesta, almacenamiento, transformación y modelado de datos históricos de viajes de taxi de Nueva York en el año 2025.

La solución utiliza **Docker Compose** para desplegar un entorno reproducible con **Mage AI** como orquestador, **PostgreSQL** como data warehouse y **pgAdmin** como herramienta de inspección.

---

# Objetivo del proyecto

Construir un pipeline de ingeniería de datos completamente reproducible que permita:

* ingerir datos históricos de taxis de Nueva York
* almacenar los datos crudos en una capa **raw**
* transformar los datos a una capa **clean**
* implementar un **modelo dimensional**
* automatizar pipelines mediante triggers
* permitir validación mediante pgAdmin

El proyecto sigue una arquitectura **ETL (Extract-Transform-Load)**.

---

# Fuente de datos

Dataset público de viajes de taxi de Nueva York.

Fuente:

https://d37ci6vzurychx.cloudfront.net/trip-data/

Formato de los archivos:

Parquet

Ejemplo de archivo:

yellow_tripdata_2025-01.parquet

El pipeline permite ingerir la información del año 2025

---

# Arquitectura del sistema

La arquitectura del proyecto está compuesta por los siguientes componentes:

* fuente de datos NY Taxi
* Mage (orquestación de pipelines)
* PostgreSQL (data warehouse)
* pgAdmin (inspección y validación)

Flujo de datos:

```
NY Taxi Dataset
(parquet files 2025)
        ↓
 Mage
 raw_ingestion_pipeline
        ↓
 PostgreSQL
 schema: raw
 (raw.ny_taxi_trips)
        ↓
 Mage
 clean_pipeline
        ↓
 PostgreSQL
 schema: clean
 ├ dim_vendor
 ├ dim_payment_type
 ├ dim_pickup_location
 ├ dim_dropoff_location
 └ fact_trips
        ↓
 pgAdmin
 (analysis & validation)
```

El diagrama de arquitectura se encuentra en:

```
docs/architecture_diagram.png
```

---

# Tecnologías utilizadas

* Docker
* Docker Compose
* Python
* SQL
* Mage AI
* PostgreSQL
* pgAdmin
* Pandas

---

# Estructura del proyecto

```
pset-2-sq/
│
├── docker-compose.yml
├── DockerFile
├── README.md
├── requirimients.txt
├── notebooks/
    └── EDA.ipynb
    └── ingest-data.py
├── data-orquestador/
    └── mage_data
    └── orquestador
├── docs/
│   └── architecture_diagram.png
    └── modelo_dimensional.docx
    └── evidencias_visuales.docx
```

---

# Cómo levantar el entorno

Primero asegúrese de tener instalado:

* Docker
* Docker Compose

Luego ejecute el siguiente comando desde la raíz del proyecto:

```
docker compose up --build
```

Esto iniciará automáticamente los siguientes servicios:

* PostgreSQL
* Mage
* pgAdmin

Los contenedores estarán conectados dentro de la misma red Docker.

---

# Acceso a los servicios

## Mage

URL:

```
http://localhost:6789
```

Aquí se pueden visualizar y ejecutar los pipelines del proyecto.

---

## pgAdmin

URL:

```
http://localhost:9000
```

pgAdmin permite explorar las tablas dentro de PostgreSQL y validar los resultados del pipeline.

---

# Pipelines de datos

El proyecto implementa dos pipelines separados en Mage.

## 1. Raw Ingestion Pipeline

Nombre del pipeline:

```
raw_ingestion_pipeline
```

Responsabilidades:

* descargar datos del dataset NY Taxi
* leer archivos Parquet
* cargar datos en PostgreSQL
* crear el schema **raw** si no existe

Tabla resultante:

```
raw.ny_taxi_trips
```

Características:

* ingesta de múltiples años
* reejecución idempotente
* mínima transformación de datos

---

## 2. Clean Transformation Pipeline

Nombre del pipeline:

```
clean_pipeline
```

Responsabilidades:

* leer datos desde `raw.ny_taxi_trips`
* limpiar datos inconsistentes
* estandarizar columnas
* validar tipos de datos
* construir el modelo dimensional

Resultados almacenados en el schema:

```
clean
```

---

# Triggers y automatización

Los pipelines utilizan triggers configurados en Mage.

Triggers implementados:

```
trigger_pipeline_raw
```

Este trigger ejecuta la ingesta de datos crudos.


Posteriormente se ejecuta el pipeline de transformación denominado: 

```
Ejecucion Clean Pipeline
```

que depende de los datos cargados en la capa raw.

Esto permite automatizar el flujo completo de datos.

---

# Acceder a pgAdmin
Correo: bryanste3ven@gmail.com
Contraseña: root

# Secrets y configuración

Las credenciales de conexión a PostgreSQL no están hardcodeadas.

Se utilizan **Mage Secrets** para almacenar información sensible.

Configuración utilizada:

```
POSTGRES_DBNAME
POSTGRES_USER
POSTGRES_PASSWORD
POSTGRES_HOST
POSTGRES_PORT
POSTGRES_CONNECT_TIMEOUT
```

Ejemplo de configuración en Mage:

```
POSTGRES_DBNAME: {{ mage_secret_var('pg_db') }}
POSTGRES_USER: {{ mage_secret_var('pg_user') }}
POSTGRES_PASSWORD: {{ mage_secret_var('pg_password') }}
POSTGRES_HOST: {{ mage_secret_var('pg_host') }}
POSTGRES_PORT: {{ mage_secret_var('pg_port') }}
```

Esto permite mantener el proyecto seguro y reproducible.

---

# Modelo dimensional

La capa **clean** implementa un modelo dimensional tipo **Star Schema**.

## Tabla de hechos

```
fact_trips
```

Granularidad:

Un registro representa **un viaje individual de taxi**.

Métricas incluidas:

* trip_distance
* fare
* tip
* tolls
* total_amount
* trip_duration

---

## Dimensiones

### dim_vendor

Información sobre el proveedor del taxi.

---

### dim_payment_type

Tipo de pago utilizado en el viaje.

---

### dim_pickup_location

Ubicación donde inicia el viaje.

---

### dim_dropoff_location

Ubicación donde termina el viaje.

---

# Relaciones del modelo

```
fact_trips
│
├── vendor_key → dim_vendor
├── payment_type_key → dim_payment_type
├── pickup_location_key → dim_pickup_location
└── dropoff_location_key → dim_dropoff_location
```

---

# Validación de resultados en PostgreSQL

Para validar los resultados del pipeline se pueden ejecutar consultas en pgAdmin.

Ejemplo:

Contar registros en raw:

```sql
SELECT COUNT(*) FROM raw.ny_taxi_trips;
```

Ver datos en clean:

```sql
SELECT * FROM clean.fact_trips LIMIT 10;
```

Consultar dimensiones:

```sql
SELECT * FROM clean.dim_vendor;
```

---

# Validaciones aplicadas en la capa clean

Durante el pipeline de transformación se aplican validaciones como:

* manejo de valores nulos
* estandarización de nombres de columnas
* tipificación de fechas y valores numéricos
* eliminación de registros inválidos
* validación de coherencia entre pickup y dropoff
* filtrado de distancias o montos negativos

Esto garantiza que los datos de la capa clean sean adecuados para análisis.

---

# Evidencia visual

El proyecto incluye capturas en el repositorio que muestran:

* contenedores corriendo en Docker
* pipelines visibles en Mage
* triggers configurados
* tablas en schema raw
* tablas en schema clean
* consultas ejecutadas en pgAdmin

---

# Conclusión

Este proyecto demuestra la construcción de una arquitectura moderna de ingeniería de datos utilizando herramientas open source.

La solución implementa buenas prácticas como:

* separación entre capas raw y clean
* pipelines independientes
* modelo dimensional
* orquestación con Mage
* manejo seguro de credenciales
* entorno reproducible con Docker Compose

---
