FROM python:3.11-slim

WORKDIR /app

# Copie des dépendances
COPY requirements.txt .

# Installation
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source
COPY main.py .

# Exposition du port
EXPOSE 8000

# Démarrage de l'API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
