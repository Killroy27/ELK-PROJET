# ================================================================
# scripts/stop.ps1 — Arrête la stack ELK proprement
# Usage : .\scripts\stop.ps1
# ================================================================

Write-Host "=== Arret de la stack ELK ===" -ForegroundColor Cyan
docker compose down
Write-Host "[OK] Stack arretee." -ForegroundColor Green
Write-Host "Note : les donnees Elasticsearch sont preservees dans le volume 'elasticsearch_data'." -ForegroundColor Yellow
Write-Host "Pour supprimer egalement les donnees : docker compose down -v  (destructif)" -ForegroundColor Red
