# ================================================================
# scripts/health_check.ps1 — Movies ELK Platform
# Vérifie que les services ELK répondent correctement (Windows)
# Usage : .\scripts\health_check.ps1
# ================================================================

param(
    [string]$EsUrl = "http://localhost:9200",
    [string]$KbUrl = "http://localhost:5601"
)

function Write-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "  [KO] $msg" -ForegroundColor Red }
function Write-Warn($msg) { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Write-Sep()      { Write-Host ("=" * 50) -ForegroundColor Cyan }

Write-Sep
Write-Host "  Movies ELK Platform — Health Check" -ForegroundColor Cyan
Write-Sep

$allOk = $true

# ── 1. Elasticsearch cluster health ───────────────────────────
Write-Host "`n[1/4] Elasticsearch — cluster health" -ForegroundColor Yellow
try {
    $es = Invoke-RestMethod -Uri "$EsUrl/_cluster/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    if ($es.status -in @("green", "yellow")) {
        Write-Ok "Elasticsearch UP — status=$($es.status), noeuds=$($es.number_of_nodes)"
    } else {
        Write-Fail "Elasticsearch status inattendu : $($es.status)"
        $allOk = $false
    }
} catch {
    Write-Fail "Elasticsearch inaccessible sur $EsUrl"
    $allOk = $false
}

# ── 2. Index existants ────────────────────────────────────────
Write-Host "`n[2/4] Elasticsearch — index existants" -ForegroundColor Yellow
try {
    $indices = Invoke-RestMethod -Uri "$EsUrl/_cat/indices?h=index,docs.count,store.size&s=index&format=json" -Method GET -TimeoutSec 5 -ErrorAction Stop
    if ($indices.Count -eq 0) {
        Write-Warn "Aucun index present (normal avant ingestion)"
    } else {
        foreach ($idx in $indices) {
            Write-Host "  -> $($idx.index.PadRight(20)) docs=$($idx.'docs.count'.PadLeft(8))  size=$($idx.'store.size')" -ForegroundColor Gray
        }
    }
} catch {
    Write-Warn "Impossible de lister les index"
}

# ── 3. Index movies_raw et movies_clean ───────────────────────
Write-Host "`n[3/4] Index movies_raw et movies_clean" -ForegroundColor Yellow
foreach ($index in @("movies_raw", "movies_clean")) {
    try {
        $count = Invoke-RestMethod -Uri "$EsUrl/$index/_count" -Method GET -TimeoutSec 5 -ErrorAction Stop
        Write-Ok "$index — $($count.count) documents"
    } catch {
        Write-Warn "$index — inexistant ou vide (normal avant ingestion)"
    }
}

# ── 4. Kibana status ──────────────────────────────────────────
Write-Host "`n[4/4] Kibana — status" -ForegroundColor Yellow
try {
    $kb = Invoke-RestMethod -Uri "$KbUrl/api/status" -Method GET -TimeoutSec 10 -ErrorAction Stop
    $level = $kb.status.overall.level
    if ($level -eq "available") {
        Write-Ok "Kibana UP — level=$level"
    } else {
        Write-Warn "Kibana repond mais level=$level (demarrage en cours ?)"
    }
} catch {
    Write-Fail "Kibana inaccessible sur $KbUrl"
    $allOk = $false
}

# ── Résultat final ────────────────────────────────────────────
Write-Sep
if ($allOk) {
    Write-Host "  OK Stack ELK operationnelle" -ForegroundColor Green
} else {
    Write-Host "  KO Des services sont inaccessibles" -ForegroundColor Red
    Write-Host "  -> Verifier avec : docker compose logs" -ForegroundColor Red
}
Write-Sep
