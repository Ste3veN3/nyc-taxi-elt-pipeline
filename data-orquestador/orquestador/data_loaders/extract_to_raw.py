if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader

import pyarrow.parquet as pq
import requests
import tempfile
import gc
from os import path

from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.postgres import Postgres


@data_loader
def carga_ny_taxi_a_raw(*args, **kwargs):
    """
    Carga NY Taxi Yellow por MES y por CHUNK (row groups)
    en un solo bloque, sin yield, sin data_exporter.

    - Elimina la tabla RAW si existe
    - La recrea con el esquema correcto
    - Evita errores de tipos (ej. passenger_count = 1.0)
    - No depende de triggers externos
    """

    # ==============================
    # 🔧 CONFIGURACIÓN
    # ==============================
    YEAR = 2025
    MESES = range(1, 13)        # 1–12  (usa range(1,4) para pruebas)
    SCHEMA = "raw"
    TABLE = "ny_taxi_trips"

    BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"
    config_path = path.join(get_repo_path(), "io_config.yaml")

    with Postgres.with_config(ConfigFileLoader(config_path, "default")) as loader:

        # ==============================
        # 🧨 DROP TABLE UNA SOLA VEZ
        # ==============================
        print("=" * 80)
        print(f"🧨 Eliminando tabla {SCHEMA}.{TABLE} si existe...")
        loader.execute(f"DROP TABLE IF EXISTS {SCHEMA}.{TABLE};")
        print("✅ Tabla eliminada")

        # ==============================
        # 🔁 LOOP POR MES
        # ==============================
        for month in MESES:
            print("=" * 80)
            print(f"📅 PROCESANDO {YEAR}-{month:02d}")

            url = f"{BASE_URL}/yellow_tripdata_{YEAR}-{month:02d}.parquet"
            print(f"⬇️ Descargando {url}")

            # ------------------------------
            # Descargar parquet a disco
            # ------------------------------
            with requests.get(url, stream=True) as r:
                r.raise_for_status()
                with tempfile.NamedTemporaryFile(delete=False) as tmp:
                    for chunk in r.iter_content(chunk_size=1024 * 1024):
                        tmp.write(chunk)
                    parquet_path = tmp.name

            pq_file = pq.ParquetFile(parquet_path)
            total_groups = pq_file.num_row_groups
            print(f"📦 Row groups del mes: {total_groups}")

            total_rows_month = 0

            # ==============================
            # 🔂 LOOP POR CHUNK
            # ==============================
            for rg in range(total_groups):
                print(f"➡️ Chunk {rg + 1}/{total_groups}")

                df = pq_file.read_row_group(rg).to_pandas()
                rows = len(df)
                total_rows_month += rows

                # ==============================
                # ✅ FIX DE TIPOS (CRÍTICO)
                # evita error: smallint <- "1.0"
                # ==============================
                for col in ["passenger_count", "RatecodeID", "payment_type"]:
                    if col in df.columns:
                        df[col] = df[col].astype("float64")

                print(f"📦 Insertando {rows:,} filas en {SCHEMA}.{TABLE}")

                loader.export(
                    df,
                    schema_name=SCHEMA,
                    table_name=TABLE,
                    if_exists="append",
                    index=False,
                )

                del df
                gc.collect()

                print("✅ Chunk insertado")

            print(f"✅ TOTAL MES {YEAR}-{month:02d}: {total_rows_month:,} filas")

    print("\n🎉 CARGA COMPLETA FINALIZADA PARA TODOS LOS MESES")