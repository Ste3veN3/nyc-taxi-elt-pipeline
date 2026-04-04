DROP TABLE IF EXISTS clean.ny_taxi_trips;

CREATE TABLE clean.ny_taxi_trips AS
SELECT
    vendorid AS vendor_id,
    tpep_pickup_datetime AS pickup_datetime,
    tpep_dropoff_datetime AS dropoff_datetime,
    trip_distance,
    fare_amount AS fare,
    tip_amount AS tip,
    tolls_amount AS tolls,
    total_amount,
    payment_type,
    pulocationid AS pickup_location_id,
    dolocationid AS dropoff_location_id,

    EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60
    AS trip_duration_min

FROM raw.ny_taxi_trips

WHERE
tpep_dropoff_datetime > tpep_pickup_datetime
AND trip_distance > 0
AND trip_distance <= 100
AND total_amount >= 0;
