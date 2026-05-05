# DATA/

Ce dossier contient le dataset source utilisé par Logstash.

## Contenu

| Fichier | Description | Taille |
|---|---|---|
| `movies_dataset.csv` | Dataset de 10 000 films | ~3.3 MB |

## Structure du CSV

```
"index","title","original_language","release_date","popularity","vote_average","vote_count","overview"
```

> ⚠️ **Note** : La ligne 1 du fichier est vide — le pipeline Logstash doit l'ignorer.

## Colonnes disponibles

| Colonne | Type brut | Remarques |
|---|---|---|
| `index` | string (int) | Séquentiel 0–9999 |
| `title` | string | Doublons possibles (films homonymes) |
| `original_language` | string | Code ISO 2 lettres |
| `release_date` | string `DD-MM-YYYY` | 18 valeurs manquantes |
| `popularity` | string (float) | 0.0 à 3368.6 |
| `vote_average` | string (float) | 295 valeurs à 0.0 (films non notés) |
| `vote_count` | string (int) | Corrélé à `vote_average` |
| `overview` | string | 95 valeurs vides |

## Colonnes ABSENTES (ne pas inventer)

`genres`, `budget`, `revenue`, `runtime`, `credits`, `keywords`, `tagline`, `status`

## Montage Docker

Ce dossier est monté en **lecture seule** dans le conteneur Logstash :
```yaml
volumes:
  - ./DATA:/data:ro
```
