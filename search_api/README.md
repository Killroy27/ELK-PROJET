# search_api/

Mini moteur de recherche connecté à Elasticsearch — Feature F8.

## Technologie

Interface HTML/CSS/JS (vanilla) — aucune dépendance externe requise.

## Fichiers (à créer dans feature/search-engine)

| Fichier | Description |
|---|---|
| `index.html` | Interface utilisateur du moteur de recherche |
| `app.js` | Logique : requêtes ES via `fetch()` + rendu résultats |
| `style.css` | Styles de l'interface |

## Fonctionnalités prévues

- Barre de recherche full-text (champs `title` + `overview`)
- Filtre par langue (`original_language`) — dropdown
- Filtre par année de sortie (`release_year`)
- Affichage des résultats : titre, langue, année, note, popularité, extrait overview
- Pagination simple

## Lancement

```bash
# Ouvrir directement dans le navigateur (aucun serveur requis)
start search_api/index.html
```

## Exigences minimales (barème)

- Recherche full-text sur au moins un champ textuel (`title` ou `overview`)
- Au moins un filtre exact (`original_language`, `release_year`…)
- Démonstration dans `docs/demo_script.md`
