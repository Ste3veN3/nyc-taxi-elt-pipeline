if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.postgres import Postgres
from os import path
import gc


@data_exporter
def export_to_raw(df, **kwargs):
    print(f"📦 Exportando {len(df):,} filas")

    config_path = path.join(get_repo_path(), "io_config.yaml")

    with Postgres.with_config(ConfigFileLoader(config_path, "default")) as loader:
        loader.export(
            df,
            schema_name="raw",
            table_name="ny_taxi_trips",
            if_exists="append",
            index=False,
        )

    del df
    gc.collect()
    print("✅ Chunk insertado")
