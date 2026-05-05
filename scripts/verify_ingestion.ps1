# verify_ingestion.ps1 — Vérifie le count et un échantillon des index
# Usage : .\scripts\verify_ingestion.ps1

Write-Host "=== Vérification de l'ingestion ===" -ForegroundColor Cyan

foreach ($index in @("movies_raw", "movies_clean")) {
    try {
        $count = Invoke-RestMethod -Uri "http://localhost:9200/$index/_count" -Method GET
        Write-Host "[$index] count = $($count.count)" -ForegroundColor Green

        $sample = Invoke-RestMethod -Uri "http://localhost:9200/$index/_search?size=1&pretty" -Method GET
        $hit = $sample.hits.hits[0]._source
        Write-Host "  Exemple : title='$($hit.title)' | lang='$($hit.original_language)' | date='$($hit.release_date)'" -ForegroundColor Yellow
    } catch {
        Write-Host "[$index] Inaccessible ou inexistant" -ForegroundColor Red
    }
}

Write-Host "=====================================" -ForegroundColor Cyan
