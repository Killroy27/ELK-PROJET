# Runbook technique — Movies ELK Platform

> Guide opérationnel pour lancer, vérifier et relancer le projet sur une machine vierge.  
> À compléter dans la feature/documentation (F7)

---

## Prérequis

- Docker Desktop installé et démarré
- Git installé
- PowerShell 5+ (Windows) ou Bash (Linux/Mac)
- Ports libres : 9200, 5601

---

## 1. Premier lancement (machine vierge)

```powershell
# 1. Cloner le repo
git clone <url-repo>
cd movies-elk-platform

# 2. Configurer l'environnement
# Vérifier le fichier .env (ports, mot de passe)
notepad .env

# 3. Lancer la stack
# ⚠️ VALIDATION REQUISE avant cette commande
docker compose up -d

# 4. Attendre ~30 secondes puis vérifier la santé
.\scripts\health_check.ps1

# 5. Vérifier les index après ingestion Logstash (~1 min)
.\scripts\verify_ingestion.ps1
```

---

## 2. Vérifications Elasticsearch

```powershell
# Santé du cluster
curl http://localhost:9200/_cluster/health?pretty

# Lister les index
curl http://localhost:9200/_cat/indices?v

# Compter les documents
curl http://localhost:9200/movies_raw/_count
curl http://localhost:9200/movies_clean/_count

# Voir un échantillon de 5 documents (movies_raw)
curl.exe -X GET "http://localhost:9200/movies_raw/_search?pretty" -H "Content-Type: application/json" -d "{ \"size\": 5 }"

# Voir le mapping
curl http://localhost:9200/movies_clean/_mapping?pretty
```

---

## 3. Arrêter la stack

```powershell
docker compose down
```

---

## 4. Recréer les index (⚠️ destructif — validation requise)

```powershell
# ATTENTION : supprime toutes les données
# Commande à ne pas exécuter sans validation explicite
.\scripts\delete_indexes.ps1
```

---

## 5. Importer le dashboard Kibana

```
1. Ouvrir http://localhost:5601
2. Stack Management → Saved Objects → Import
3. Sélectionner kibana/exports/dashboard.ndjson
4. Confirmer l'import
5. Aller dans Analytics → Dashboard → Movies Dashboard
```

---

## 6. Lancer et tester le moteur de recherche (FastAPI)

```powershell
# Aller dans le dossier de l'API
cd search_api

# Créer un environnement virtuel et installer les dépendances
python -m venv venv
.\venv\Scripts\Activate.ps1   # (Sous Windows)
# source venv/bin/activate    # (Sous Linux/Mac)
pip install -r requirements.txt

# Lancer le serveur localement (port 8000)
uvicorn main:app --reload
```

### Tester l'API (depuis un autre terminal)

```powershell
# 1. Vérifier la santé de l'API et la connexion ES
curl.exe -s http://localhost:8000/health

# 2. Faire une recherche textuelle simple
curl.exe -s "http://localhost:8000/search?q=Batman"

# 3. Recherche avec filtres multiples
curl.exe -s "http://localhost:8000/search?q=Batman&language=en&year_from=2000&min_vote_count=1000"
```

> **Note** : L'API est également testable via son interface Swagger interactive générée automatiquement : [http://localhost:8000/docs](http://localhost:8000/docs).

---

## 7. Troubleshooting courant

| Problème | Solution |
|---|---|
| ES ne démarre pas | Vérifier `vm.max_map_count` (Linux) ou mémoire Docker |
| `movies_raw` vide | Vérifier le chemin de montage `./DATA:/data:ro` |
| Erreur de date Logstash | Vérifier le format `dd-MM-yyyy` dans le pipeline |
| Kibana timeout | Attendre 60s après `docker compose up` |
