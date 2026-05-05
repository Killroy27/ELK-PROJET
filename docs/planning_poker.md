# Planning Poker — Estimations

> Les estimations sont réalisées en points d'effort (Suite de Fibonacci : 1, 2, 3, 5, 8, 13).

| Feature | Description | Estimation (Points) | Complexité / Risque |
|---|---|---|---|
| **F1** | Infrastructure (Docker Compose) | 5 | Risques liés aux volumes et au réseau Docker sous Windows/WSL2. |
| **F2** | Ingestion Raw (Logstash 01) | 3 | Parsing simple du CSV, gestion de l'en-tête. |
| **F3** | Nettoyage & Enrichissement (Logstash 02) | 8 | Fort : Beaucoup de règles de gestion (Ruby), filtres conditionnels et conversions de types stricts. |
| **F4** | Mapping Elasticsearch | 3 | Définition des analyzers et types adéquats. |
| **F5** | 12 Requêtes (DSL) | 5 | Recherche textuelle fine, agrégations et combinaisons booléennes métier. |
| **F6** | Dashboard Kibana | 5 | Création graphique, choix des bonnes visualisations pour le storytelling. |
| **F7** | Documentation globale | 3 | Rédaction transverse de tous les documents markdown exigés. |
| **F8** | Moteur de recherche (FastAPI) | 8 | Développement d'une API de A à Z (routing, parse JSON, connexion ES dynamique). |

**Total estimé** : 40 points d'effort.
