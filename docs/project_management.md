# Gestion de Projet & Organisation

## 1. Méthodologie

Le projet suit une méthode Agile allégée avec utilisation du workflow **Gitflow** pour assurer la stabilité du livrable final.

## 2. Architecture des Branches (Gitflow)

- `main` : Branche de production. Le code y est toujours stable, testé et déployable.
- `dev` : Branche d'intégration globale.
- `feature/*` : Branches de travail isolées par tâche.

### Historique des Features développées

| Feature ID | Nom de la branche | Responsabilité | Statut |
|---|---|---|---|
| F1 | `feature/infrastructure` | Déploiement Docker, configuration ELK. | Terminé |
| F2 | `feature/ingestion-raw` | Logstash pipeline `01` pour index `movies_raw`. | Terminé |
| F3 | `feature/cleaning` | Logstash pipeline `02` (nettoyage & règles de gestion). | Terminé |
| F4 | `feature/elasticsearch-mapping` | Création mapping `movies_clean`. | Terminé |
| F5 | `feature/queries` | Rédaction des 12 requêtes (DSL). | Terminé |
| F6 | `feature/dashboard` | Création du Dashboard Kibana. | Terminé |
| F7 | `feature/documentation` | Rédaction des docs obligatoires. | Terminé |
| F8 | `feature/search-api` | Développement de l'API FastAPI. | Terminé |

## 3. Convention de nommage
Les commits respectent la norme *Conventional Commits* pour une meilleure lisibilité de l'historique :
- `feat:` pour une nouvelle fonctionnalité (ex: *feat: ajout de l'api fastapi*).
- `fix:` pour une correction de bug ou d'anomalie de pipeline.
- `docs:` pour la mise à jour documentaire.
- `refactor:` pour une réécriture de code ou l'optimisation des requêtes.
