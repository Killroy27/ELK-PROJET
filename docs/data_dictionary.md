# Dictionnaire de Données — Movies Dataset

## 1. Description du Dataset Source
- **Nom du fichier** : `movies_dataset.csv`
- **Taille** : 10 000 lignes (dont 1 ligne d'en-tête et 1 ligne vide).
- **Nombre de variables (colonnes)** : 8

## 2. Dictionnaire (movies_raw vs movies_clean)

| Colonne Source | Type Brut | Champ Cible (movies_clean) | Type Cible | Description |
|---|---|---|---|---|
| `index` | String | `movie_id` | Integer | Identifiant unique séquentiel du film. |
| `title` | String | `title` | Text + Keyword | Titre officiel du film. |
| `original_language` | String | `original_language` | Keyword | Code langue sur 2 lettres (ex: `en`, `fr`, `ja`). |
| `release_date` | String | `release_date` | Date | Date de sortie originale (convertie de `dd-MM-yyyy` vers ISO 8601). |
| `popularity` | String | `popularity` | Float | Score de popularité (métrique interne type TMDB). |
| `vote_average` | String | `vote_average` | Float | Note moyenne des utilisateurs (sur 10). |
| `vote_count` | String | `vote_count` | Integer | Nombre total de votes ayant constitué la note. |
| `overview` | String | `overview` | Text | Résumé ou synopsis du film. |

## 3. Variables Dérivées et Calculées (Enrichissement)

Ces champs n'existent pas dans le fichier source et sont créés dynamiquement par le pipeline `02_movies_clean.conf`.

| Nouveau Champ | Type | Règles de calcul | Utilité |
|---|---|---|---|
| `release_year` | Integer | Extraction de l'année depuis `release_date`. | Filtres rapides sur les décennies/années. |
| `has_overview` | Boolean | `true` si `overview` n'est pas vide. | Facilite le filtrage des films incomplets. |
| `has_release_date`| Boolean | `true` si `release_date` n'est pas vide. | Idem. |
| `is_rating_reliable`| Boolean | `true` si `vote_count` >= 100. | Exclure les notes peu représentatives. |
| `is_future_release`| Boolean | `true` si `release_date` > date actuelle. | Masquer les films pas encore sortis. |
| `quality_tags` | Keyword (Array) | Accumulation des tags d'anomalies (`missing_overview`, `low_vote_count`...). | Analyse de la qualité de la donnée. |
| `ingested_at` | Date | Horodatage de l'exécution Logstash (`@timestamp`). | Suivi des mises à jour. |
