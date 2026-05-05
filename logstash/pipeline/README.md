# logstash/pipeline/

Ce dossier contient les pipelines Logstash d'ingestion.

## Fichiers (à créer dans les features correspondantes)

| Fichier | Feature | Description |
|---|---|---|
| `01_movies_raw.conf` | F2 - ingestion-raw | Lecture CSV → index `movies_raw` |
| `02_movies_clean.conf` | F3 - cleaning-normalisation | Nettoyage + typage → index `movies_clean` |

## Montage Docker

```yaml
volumes:
  - ./logstash/pipeline:/usr/share/logstash/pipeline:ro
```

## Points d'attention

- Ignorer la **ligne 1 vide** du CSV (`skip_empty_rows => true` ou filtre `drop`)
- Convertir `release_date` de `DD-MM-YYYY` vers ISO 8601
- Convertir `popularity`, `vote_average` en float
- Convertir `vote_count` en integer
- Tagger les films sans note (`vote_average = 0`) → `unrated`
- Tagger les films sans overview → `no_overview`
