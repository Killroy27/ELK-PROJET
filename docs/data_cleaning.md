# Documentation du nettoyage — movies_clean

> Règles implémentées dans le pipeline `02_movies_clean.conf` (Feature F3).

---

## 1. Règles de nettoyage et d'enrichissement

### R1 — Ignorer la ligne vide et l'en-tête du CSV

| Avant | Après |
|---|---|
| Lignes contenant `index` vide ou `"index"` lues par Logstash | Ignorées avec `drop {}` |

### R2 — Formatage de texte (Trim & Lowercase)

| Champ | Traitement Logstash |
|---|---|
| `title` | Suppression des espaces avant/après (`strip`) |
| `overview` | Suppression des espaces avant/après (`strip`) |
| `original_language` | Mise en minuscules (`lowercase`) |

### R3 — Typage numérique fort

| Champ | Type cible ES | Traitement Logstash |
|---|---|---|
| `movie_id` (ancien `index`) | `integer` | `convert => { "movie_id" => "integer" }` |
| `popularity` | `float` | `convert => { "popularity" => "float" }` |
| `vote_average` | `float` | `convert => { "vote_average" => "float" }` |
| `vote_count` | `integer` | `convert => { "vote_count" => "integer" }` |

### R4 — Enrichissement Booléen et Tableau `quality_tags`

Nous ne supprimons **aucune** donnée défectueuse (sauf l'en-tête CSV). Les lignes incomplètes sont conservées mais taguées dans le champ tableau `quality_tags` pour filtrage ultérieur.

| Champ Booléen | Condition | Tag ajouté dans `quality_tags` si faux/invalide |
|---|---|---|
| `has_overview` | `true` si `overview` n'est pas vide | `missing_overview` |
| `has_release_date` | `true` si `release_date` n'est pas vide | `missing_release_date` |
| `is_rating_reliable` | `true` si `vote_count` >= 100 | `low_vote_count` |
| `is_future_release` | `true` si date de sortie > Date du jour | `future_release` |

### R5 — Conversion de la date et extraction d'année

| Avant | Après |
|---|---|
| `release_date`: String `"31-05-2023"` | `release_date`: Date ISO `"2023-05-31T00:00:00.000Z"` |
| — | `release_year`: Integer `2023` |

**Logstash** :
```conf
date { match => ["release_date", "dd-MM-yyyy"] target => "release_date" }
# Suivi d'un script Ruby pour extraire l'année et tester la "future release"
```

---

## 2. Mesure d'impact avant/après (movies_raw vs movies_clean)

| Métrique | `movies_raw` (Brut) | `movies_clean` (Nettoyé) | Impact métier |
|---|---|---|---|
| Total documents | 10 006 | ~10 000 | Filtre des lignes vides/en-têtes |
| Qualité des dates | String libre | Type `date` ES | Permet les histogrammes Kibana |
| Gestion des erreurs | Aucune visibilité | Tableau `quality_tags` | Possibilité d'exclure les `low_vote_count` dans Kibana |
| Types numériques | String | Float/Integer | Permet les filtres `range` et aggs `avg` |
