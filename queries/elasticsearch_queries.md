# Requêtes Elasticsearch — Movies ELK Platform

> Ce document liste 12 requêtes d'analyse et de vérification sur l'index `movies_clean`.  
> Il contient **5 requêtes booléennes** complexes, des requêtes métier et des requêtes de vérification de qualité.

---

## Requêtes simples et Textuelles

### Q01 — Recherche Full-Text sur le titre (`match`)
**Objectif** : Trouver tous les films contenant "Spider-Man" dans leur titre.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "match": {
      "title": "Spider-Man"
    }
  },
  "size": 5
}
```
**Résultat attendu** : Retourne les films dont le titre analysé correspond à "spider", "man". L'analyzer `movie_text_analyzer` permet de matcher sans se soucier de la casse ou de la ponctuation.

### Q02 — Recherche Full-Text sur l'overview (`match_phrase`)
**Objectif** : Trouver les films dont le synopsis contient l'expression exacte "friendly neighborhood".
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "match_phrase": {
      "overview": "friendly neighborhood"
    }
  }
}
```
**Résultat attendu** : Retourne une poignée de films (principalement Spider-Man) dont l'overview contient ces mots dans cet ordre exact.

### Q03 — Requête de Qualité Data : Films sans synopsis (`term`)
**Objectif** : Isoler les films qui n'ont pas de description (`has_overview = false`).
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "term": {
      "has_overview": false
    }
  },
  "size": 10
}
```
**Interprétation** : Permet à l'équipe data d'identifier les ~95 films sans overview pour d'éventuelles corrections manuelles ou exclusions.

### Q04 — Requête Métier : Films très bien notés (`range`)
**Objectif** : Lister les films ayant une note moyenne supérieure ou égale à 8.5.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "range": {
      "vote_average": {
        "gte": 8.5
      }
    }
  },
  "sort": [
    { "vote_average": "desc" }
  ]
}
```
**Résultat attendu** : Liste des meilleurs films du dataset, triés par la note décroissante.

---

## Agrégations

### Q05 — Agrégation : Répartition par langue (`terms`)
**Objectif** : Connaître les langues originales les plus représentées dans le dataset.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "size": 0,
  "aggs": {
    "languages": {
      "terms": {
        "field": "original_language",
        "size": 10
      }
    }
  }
}
```
**Interprétation** : Retourne un top 10 des langues. L'anglais (`en`) sera majoritaire à ~71%, suivi du japonais (`ja`) et coréen (`ko`).

### Q06 — Agrégation : Volume de films par décennie (`histogram`)
**Objectif** : Observer l'évolution du volume de films produits par décennie.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "size": 0,
  "aggs": {
    "films_par_decennie": {
      "histogram": {
        "field": "release_year",
        "interval": 10
      }
    }
  }
}
```
**Interprétation** : Montre que la majorité des films du dataset sont récents (années 2000 à 2020).

### Q07 — Agrégation : Statistiques de popularité (`stats`)
**Objectif** : Obtenir la moyenne, le min et le max de popularité sur tout le dataset.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "size": 0,
  "aggs": {
    "popularity_stats": {
      "stats": {
        "field": "popularity"
      }
    }
  }
}
```
**Interprétation** : Donne une vue globale de la distribution du champ `popularity`, avec un maximum autour de 3368.

---

## Requêtes Booléennes Complexes (5 requêtes)

### Q08 — Bool [must + filter] : Top films d'animation récents
**Objectif** : Trouver les films japonais (`ja`), sortis depuis 2020, avec des notes fiables (plus de 100 votes) et une note > 8.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "bool": {
      "must": [
        { "term": { "original_language": "ja" } }
      ],
      "filter": [
        { "range": { "release_year": { "gte": 2020 } } },
        { "range": { "vote_average": { "gte": 8.0 } } },
        { "term": { "is_rating_reliable": true } }
      ]
    }
  }
}
```
**Interprétation** : Très utile pour un système de recommandation pointu. Le `filter` est utilisé pour de meilleures performances (mise en cache).

### Q09 — Bool [should] : Films francophones ou hispanophones
**Objectif** : Retourner les films dont la langue originale est le français OU l'espagnol, triés par popularité.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "bool": {
      "should": [
        { "term": { "original_language": "fr" } },
        { "term": { "original_language": "es" } }
      ],
      "minimum_should_match": 1
    }
  },
  "sort": [
    { "popularity": "desc" }
  ]
}
```
**Résultat attendu** : Une sélection de films internationaux, montrant comment combiner des choix multiples (équivalent d'un IN SQL).

### Q10 — Bool [must_not] : Films sortis sans être "future release"
**Objectif** : Exclure du catalogue tous les films dont la date est dans le futur (tag `future_release`), pour n'afficher que les films réellement visionnables.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "bool": {
      "must": [
        { "match_all": {} }
      ],
      "must_not": [
        { "term": { "quality_tags": "future_release" } },
        { "term": { "has_release_date": false } }
      ]
    }
  }
}
```
**Interprétation** : Requête de nettoyage applicatif type. Elle s'appuie sur les tags qualité injectés par Logstash pour nettoyer les vues utilisateurs.

### Q11 — Bool [must + must_not + filter] : Faux positifs de popularité
**Objectif** : Trouver les films qui ont une très forte popularité (> 1000) MAIS qui ne sont pas fiables niveau vote (`vote_count < 100`).
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "bool": {
      "must": [
        { "range": { "popularity": { "gte": 1000 } } }
      ],
      "must_not": [
        { "term": { "is_rating_reliable": true } }
      ]
    }
  }
}
```
**Interprétation** : Permet de détecter des anomalies métier : un film très populaire mais avec presque aucun vote (souvent des films tout juste annoncés ou des erreurs de dataset).

### Q12 — Bool [complex / multi_match] : Moteur de Recherche "Batman"
**Objectif** : Recherche textuelle de "Batman" sur le titre (poids fort) ET l'overview (poids normal), uniquement sur des films fiables sortis avant 2015.
**Commande JSON** :
```json
GET movies_clean/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "Batman",
            "fields": ["title^3", "overview"]
          }
        }
      ],
      "filter": [
        { "term": { "is_rating_reliable": true } },
        { "range": { "release_year": { "lt": 2015 } } }
      ]
    }
  }
}
```
**Interprétation** : C'est le cœur du moteur de recherche. Le `^3` donne 3 fois plus de poids si "Batman" est dans le titre plutôt que juste dans l'overview. Le score de pertinence ES fera le reste.
