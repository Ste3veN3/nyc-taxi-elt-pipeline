if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader

import requests
from io import BytesIO
import pyarrow.parquet as pq


@data_loader
def excract_info_to_raw(*args, **kwargs):
    print("LOADER INICIADO 🚀")

    month = kwargs.get('month')
    year = kwargs.get('year', 2025)

    # ✅ Protección para ejecuciones de UI / preview
    if month is None:
        print("ℹ Loader ejecutado sin 'month'.")
        return {
            "parquet_url": None,
            "month": None,
            "year": None
        }

    month_str = f"{month:02d}"
    url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{year}-{month_str}.parquet"

    print(f"📌 Verificando disponibilidad: {url}")

    # ✅ Solo validamos que exista
    response = requests.head(url, timeout=30)
    response.raise_for_status()

    print("✅ Parquet disponible.")

    # ✅ DEVOLVEMOS SOLO REFERENCIA (NO DATA)
    return {
        "parquet_url": url,
        "month": month,
        "year": year
    }