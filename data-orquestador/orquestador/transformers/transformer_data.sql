DROP TABLE IF EXISTS clean.ny_taxi_trips;

CREATE TABLE clean.ny_taxi_trips AS
SELECT DISTINCT

    -- ===============================
    -- ESTANDARIZACIÓN DE NOMBRES
    -- ===============================
    vendorid AS vendor_id,
    pulocationid AS pickup_location_id,
    dolocationid AS dropoff_location_id,
    payment_type,

    -- ===============================
    -- TIPIFICACIÓN
    -- ===============================
    CAST(tpep_pickup_datetime AS timestamp)  AS pickup_datetime,
    CAST(tpep_dropoff_datetime AS timestamp) AS dropoff_datetime,

    CAST(trip_distance AS numeric)  AS trip_distance,
    CAST(fare_amount AS numeric)    AS fare,
    CAST(tip_amount AS numeric)     AS tip,
    CAST(tolls_amount AS numeric)   AS tolls,
    CAST(total_amount AS numeric)   AS total_amount,

    -- ===============================
    -- MÉTRICA DERIVADA
    -- ===============================
    EXTRACT(EPOCH FROM (
        tpep_dropoff_datetime - tpep_pickup_datetime
    )) / 60 AS trip_duration_min

FROM raw.ny_taxi_trips

WHERE

-- ===============================
-- VALIDACIÓN DE NULOS
-- ===============================
tpep_pickup_datetime IS NOT NULL
AND tpep_dropoff_datetime IS NOT NULL
AND trip_distance IS NOT NULL
AND total_amount IS NOT NULL

-- ===============================
-- CONSISTENCIA DE FECHAS
-- ===============================
AND tpep_dropoff_datetime > tpep_pickup_datetime

-- ===============================
-- VALIDACIÓN DE DURACIÓN
-- ===============================
AND EXTRACT(EPOCH FROM (
    tpep_dropoff_datetime - tpep_pickup_datetime
)) / 60 BETWEEN 1 AND 180

-- ===============================
-- VALIDACIÓN DE DISTANCIA
-- ===============================
AND trip_distance > 0
AND trip_distance <= 100

-- ===============================
-- VALIDACIÓN DE MONTOS
-- ===============================
AND total_amount >= 0
AND total_amount >= (fare_amount + tip_amount + tolls_amount);