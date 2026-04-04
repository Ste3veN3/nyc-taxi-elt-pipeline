SELECT '🚀 INICIANDO CREACIÓN DEL MODELO DIMENSIONAL' AS status;


-- =====================================
-- DIM_VENDOR
-- =====================================
SELECT '📦 Creando dim_vendor...' AS status;

DROP TABLE IF EXISTS clean.dim_vendor;

CREATE TABLE clean.dim_vendor AS
SELECT
    ROW_NUMBER() OVER() AS vendor_key,
    vendor_id
FROM (
    SELECT DISTINCT vendor_id
    FROM clean.ny_taxi_trips
) t;

SELECT 
    '✅ dim_vendor creada' AS tabla,
    COUNT(*) AS total_registros
FROM clean.dim_vendor;



-- =====================================
-- DIM_PAYMENT_TYPE
-- =====================================
SELECT '📦 Creando dim_payment_type...' AS status;

DROP TABLE IF EXISTS clean.dim_payment_type;

CREATE TABLE clean.dim_payment_type AS
SELECT
    ROW_NUMBER() OVER() AS payment_type_key,
    payment_type
FROM (
    SELECT DISTINCT payment_type
    FROM clean.ny_taxi_trips
) t;

SELECT 
    '✅ dim_payment_type creada' AS tabla,
    COUNT(*) AS total_registros
FROM clean.dim_payment_type;



-- =====================================
-- DIM_PICKUP_LOCATION
-- =====================================
SELECT '📦 Creando dim_pickup_location...' AS status;

DROP TABLE IF EXISTS clean.dim_pickup_location;

CREATE TABLE clean.dim_pickup_location AS
SELECT
    ROW_NUMBER() OVER() AS pickup_location_key,
    pickup_location_id
FROM (
    SELECT DISTINCT pickup_location_id
    FROM clean.ny_taxi_trips
) t;

SELECT 
    '✅ dim_pickup_location creada' AS tabla,
    COUNT(*) AS total_registros
FROM clean.dim_pickup_location;



-- =====================================
-- DIM_DROPOFF_LOCATION
-- =====================================
SELECT '📦 Creando dim_dropoff_location...' AS status;

DROP TABLE IF EXISTS clean.dim_dropoff_location;

CREATE TABLE clean.dim_dropoff_location AS
SELECT
    ROW_NUMBER() OVER() AS dropoff_location_key,
    dropoff_location_id
FROM (
    SELECT DISTINCT dropoff_location_id
    FROM clean.ny_taxi_trips
) t;

SELECT 
    '✅ dim_dropoff_location creada' AS tabla,
    COUNT(*) AS total_registros
FROM clean.dim_dropoff_location;



-- =====================================
-- FACT TABLE
-- =====================================
SELECT '📊 Creando fact_trips...' AS status;

DROP TABLE IF EXISTS clean.fact_trips;

CREATE TABLE clean.fact_trips AS
SELECT

    v.vendor_key,
    p.payment_type_key,
    pl.pickup_location_key,
    dl.dropoff_location_key,

    trip_distance,
    fare,
    tip,
    tolls,
    total_amount,
    trip_duration_min,

    1 AS trip_count

FROM clean.ny_taxi_trips t

LEFT JOIN clean.dim_vendor v
ON t.vendor_id = v.vendor_id

LEFT JOIN clean.dim_payment_type p
ON t.payment_type = p.payment_type

LEFT JOIN clean.dim_pickup_location pl
ON t.pickup_location_id = pl.pickup_location_id

LEFT JOIN clean.dim_dropoff_location dl
ON t.dropoff_location_id = dl.dropoff_location_id;


SELECT 
    '🎉 fact_trips creada' AS tabla,
    COUNT(*) AS total_registros
FROM clean.fact_trips;


SELECT '🏁 MODELO DIMENSIONAL CREADO CORRECTAMENTE' AS status;
