# kibana/exports/

Ce dossier contient les exports du dashboard Kibana au format `.ndjson`.

## Fichiers

| Fichier | Description | Feature |
|---|---|---|
| `dashboard.ndjson` | Export complet dashboard + visualisations | F6 - kibana-dashboard |

## Importer dans Kibana

```
Kibana → Stack Management → Saved Objects → Import → dashboard.ndjson
```

## Visualisations prévues (6 à 8)

| # | Type | Titre |
|---|---|---|
| V1 | Metric | Nombre total de films |
| V2 | Donut | Répartition par langue |
| V3 | Bar chart | Films par année de sortie |
| V4 | Bar chart horizontal | Top 10 popularité |
| V5 | Histogram | Distribution des notes (`vote_average`) |
| V6 | Bar chart | Films par tier de popularité |
| V7 | Metric | % films avec overview |
| V8 | Data table | Top films notés |

> Ce fichier sera généré via l'export Kibana dans la feature F6.
