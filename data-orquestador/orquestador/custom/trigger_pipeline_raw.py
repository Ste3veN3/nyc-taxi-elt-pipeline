if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom

from mage_ai.orchestration.triggers.api import trigger_pipeline
from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.postgres import Postgres
from os import path


@custom
def trigger_start_year(*args, **kwargs):

    pipeline_ingestion = 'raw_ingestion_pipeline'

    config_path = path.join(get_repo_path(), 'io_config.yaml')

    with Postgres.with_config(ConfigFileLoader(config_path, 'default')) as loader:

        cur = loader.conn.cursor()

        cur.execute("TRUNCATE TABLE raw.ny_taxi_trips;")
        cur.execute("TRUNCATE TABLE raw.control_mes;")

        loader.conn.commit()
        cur.close()

    print("✔ RAW y control_mes vaciados")

    run = trigger_pipeline(
        pipeline_uuid=pipeline_ingestion,
        variables={
            'month': 1,
            'year': 2025
        }
    )

    print(f"🚀 Mes 01 enviado con run_id={run.id}")