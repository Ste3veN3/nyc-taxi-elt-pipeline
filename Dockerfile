# Capa 1: imagen base
FROM python:3.10-slim

# Capa 2
# Configurar la carpeta (directorio) de trabajo
WORKDIR /app

# Instalar las librerias
COPY requirements.txt .
RUN pip install -r requirements.txt

#Copiar el python al directorio
COPY ingest-data.py /app/

CMD ["python", "ingest-data.py"]