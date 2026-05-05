# elasticsearch/mappings/

Ce dossier contient les définitions de mapping des index Elasticsearch.

## Fichiers

| Fichier | Index | Feature |
|---|---|---|
| `movies_raw_mapping.json` | `movies_raw` | F2 - ingestion-raw |
| `movies_clean_mapping.json` | `movies_clean` | F4 - mapping-quality |

## Principes

- `movies_raw` : mapping **minimal** (dynamic = true), ingestion brute sans contrainte
- `movies_clean` : mapping **explicite** avec types stricts + analyzer personnalisé

## Analyzers personnalisés (movies_clean)

```json
"overview_analyzer" : tokenizer standard + lowercase + stop + porter_stem
"title_analyzer"    : tokenizer standard + lowercase + asciifolding
```
