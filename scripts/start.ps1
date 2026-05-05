# ================================================================
# scripts/start.ps1 — Lance la stack ELK
# Usage : .\scripts\start.ps1
# ================================================================
# ⚠️  CE SCRIPT LANCE DES CONTENEURS DOCKER
# ⚠️  Valider avec l'équipe avant exécution
# ================================================================

Write-Host "=== Demarrage de la stack ELK ===" -ForegroundColor Cyan

# Vérifier que Docker est disponible
try {
    docker info | Out-Null
} catch {
    Write-Host "[KO] Docker n'est pas accessible. Veuillez demarrer Docker Desktop." -ForegroundColor Red
    exit 1
}

# Lancer la stack
Write-Host "-> docker compose up -d ..." -ForegroundColor Yellow
docker compose up -d

Write-Host "`n-> Attente de 30 secondes avant health check..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Health check automatique
.\scripts\health_check.ps1
