# Script de Démonstration (Soutenance)

> Ce document sert de fil conducteur pour la présentation finale du projet (15-20 minutes).

## 1. Introduction (2 min)
- **Accroche** : "Transformer un fichier CSV brut de 10 000 films en un moteur de recherche performant et analysable."
- **Présentation de la stack** : Elasticsearch, Logstash, Kibana (v8.13.0) + FastAPI pour l'API de recherche.

## 2. Infrastructure et Ingestion (3 min)
- Montrer rapidement le `docker-compose.yml` (montage `/data:ro` en lecture seule, isolation du réseau).
- Exécuter la commande `curl localhost:9200` pour prouver que le cluster est sain.
- Montrer le pipeline `01_movies_raw.conf` et expliquer l'isolation via le champ `type => "raw"`.

## 3. Nettoyage et Qualité des Données (4 min)
- Se connecter à Kibana > Dev Tools.
- Montrer le mapping de `movies_clean` (notamment le `movie_text_analyzer`).
- Zoom sur le pipeline `02_movies_clean.conf` : Explication du concept de `quality_tags`.
  *Argumentaire* : "Au lieu de supprimer les données imparfaites, on les conserve mais on les tague (ex: `missing_overview`, `low_vote_count`) pour filtrage ultérieur. C'est la meilleure approche Big Data."

## 4. Requêtes et Moteur de Recherche ES (4 min)
*Dans Kibana Dev Tools :*
- Exécuter **Q01** : Recherche textuelle simple "Spider-Man".
- Exécuter **Q11** : Détection d'anomalies booléenne (popularité énorme mais moins de 100 votes).
- Exécuter **Q12** : Le mini moteur multi-critères : "Batman", `title` pondéré à `^3`, avec filtres sur les années et la fiabilité des votes.

## 5. Dashboard Analytique Kibana (4 min)
- Afficher le Dashboard "Movies Dashboard".
- Montrer les KPIs (Total films, Note Moyenne).
- Démontrer l'interactivité : cliquer sur une décennie dans l'histogramme ou sur la langue `ja` dans le Pie Chart pour que tout le Dashboard se mette à jour instantanément.

## 6. L'API de Recherche FastAPI (3 min)
- Ouvrir le Swagger UI dans le navigateur (`http://localhost:8000/docs`).
- Démontrer le fonctionnement en temps réel en faisant une requête `/search` (ex: `q="Avengers"`, `language="en"`, `min_vote_count=5000`).
- Montrer le JSON de retour propre (avec pagination intégrée et l'overview tronquée) prêt à être consommé par une équipe Frontend.
- Conclure sur les limites (manque des genres) et les pistes d'évolution (API externe TMDB).
