# scripts/

Scripts utilitaires pour gérer le projet localement.

## Fichiers

| Fichier | Description | À valider avant exec |
|---|---|---|
| `start.ps1` | Lance `docker compose up -d` | Non |
| `stop.ps1` | Arrête la stack proprement | Non |
| `health_check.ps1` | Vérifie Elasticsearch et Kibana | Non |
| `verify_ingestion.ps1` | `_count` + échantillon des index | Non |
| `delete_indexes.ps1` | ⚠️ Supprime les index ES | **Oui** |

> ⚠️ Toute commande destructive doit être validée par l'équipe avant exécution.
