# elasticsearch/scripts/

Ce dossier contient les scripts shell/PowerShell pour créer et gérer les index Elasticsearch.

## Fichiers (à créer dans les features correspondantes)

| Fichier | Description | Feature |
|---|---|---|
| `create_index_raw.ps1` | Crée l'index `movies_raw` via l'API ES | F2 |
| `create_index_clean.ps1` | Crée l'index `movies_clean` avec mapping explicite | F4 |
| `delete_indexes.ps1` | Supprime les deux index (⚠️ destructif) | F2/F4 |
| `verify_ingestion.ps1` | `_count` + échantillon des deux index | F2 |

## Usage type

```powershell
# Créer l'index movies_clean avec le mapping
Invoke-RestMethod -Uri "http://localhost:9200/movies_clean" `
  -Method PUT `
  -ContentType "application/json" `
  -InFile "..\mappings\movies_clean_mapping.json"
```

> ⚠️ Les scripts destructifs (`delete_indexes.ps1`) doivent être validés avant exécution.
