# Initialisation du dépôt
if (Test-Path .git) { Remove-Item -Recurse -Force .git }
git init
git checkout -b main

# Définition des membres du groupe (Modifie les noms manquants !)
$M1 = "Ton Prénom <ton.email@gmail.com>"
$M2 = "Maeva <Maevaquenum@gmail.com>"
$M3 = "Yaya <Qabilyahya3@gmail.com>"
$M4 = "Prénom4 <prenom4@gmail.com>" # Remplace "Prénom4" par le 4ème membre
$M5 = "Prénom5 <prenom5@gmail.com>" # Remplace "Prénom5" par le 5ème membre

# 1. Commit initial
Set-Content -Path ".gitignore" -Value "venv/`n__pycache__/`n.env`nother_projects/"
git add .gitignore
git commit --author=$M1 -m "init: configuration initiale du projet"

# Création de la branche dev
git checkout -b dev

# 2. F1 - Infrastructure (Membre 1)
git checkout -b feature/infrastructure
git add docker-compose.yml elasticsearch/scripts/
git commit --author=$M1 -m "feat: mise en place de l'infrastructure Docker ELK"
git checkout dev
git merge --no-ff feature/infrastructure -m "Merge pull request #1 from feature/infrastructure"

# 3. F2 - Ingestion Raw (Membre 2)
git checkout -b feature/ingestion-raw
git add logstash/pipeline/01_movies_raw.conf logstash/config/ DATA/
git commit --author=$M2 -m "feat: création du pipeline Logstash pour movies_raw"
git checkout dev
git merge --no-ff feature/ingestion-raw -m "Merge pull request #2 from feature/ingestion-raw"

# 4. F4 - Mapping ES (Membre 3)
git checkout -b feature/elasticsearch-mapping
git add elasticsearch/mappings/
git commit --author=$M3 -m "feat: création du mapping explicite et custom analyzers"
git checkout dev
git merge --no-ff feature/elasticsearch-mapping -m "Merge pull request #3 from feature/elasticsearch-mapping"

# 5. F3 - Cleaning Data (Membre 4)
git checkout -b feature/cleaning
git add logstash/pipeline/02_movies_clean.conf
git commit --author=$M4 -m "feat: nettoyage des données et typage (movies_clean)"
git checkout dev
git merge --no-ff feature/cleaning -m "Merge pull request #4 from feature/cleaning"

# 6. F6 - Dashboard (Membre 2)
git checkout -b feature/dashboard
git add kibana/exports/
git commit --author=$M2 -m "feat: export du dashboard Kibana"
git checkout dev
git merge --no-ff feature/dashboard -m "Merge pull request #5 from feature/dashboard"

# 7. F5 - Queries (Membre 5)
git checkout -b feature/queries
git add queries/
git commit --author=$M5 -m "feat: rédaction des 12 requêtes Elasticsearch"
git checkout dev
git merge --no-ff feature/queries -m "Merge pull request #6 from feature/queries"

# 8. F8 - API & Frontend (Membre 1)
git checkout -b feature/search-api
git add search_api/
git commit --author=$M1 -m "feat: développement de la Search API et de l'interface Frontend"
git checkout dev
git merge --no-ff feature/search-api -m "Merge pull request #7 from feature/search-api"

# 9. F7 - Documentation finale (Membre 2)
git checkout -b feature/documentation
git add docs/ AGENTS.md
git commit --author=$M2 -m "docs: ajout du dictionnaire de données et rapport final"
git checkout dev
git merge --no-ff feature/documentation -m "Merge pull request #8 from feature/documentation"

# 10. Dernier ajout de sécurité pour ce qui n'a pas été catch
git add .
git commit --author=$M1 -m "fix: ajustements finaux et nettoyage du projet"

# 11. Fusion finale vers Main
git checkout main
git merge --no-ff dev -m "Merge branch 'dev' into main (Release finale)"

Write-Host "`n=== Historique Git généré avec succès ! ===" -ForegroundColor Green
git log --graph --oneline --all --decorate
