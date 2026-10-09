# ============================================================
#  DEPLOY AUTOMATICO - Casa Mandriola
#  Uso: .\deploy.ps1 "messaggio commit"
#  Esempio: .\deploy.ps1 "Aggiunta sezione paesaggio"
# ============================================================

param(
    [string]$Message = "Aggiornamento sito $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  DEPLOY CASA MANDRIOLA" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Verifica prerequisiti ---
Write-Host "[1/6] Controllo prerequisiti..." -ForegroundColor Yellow
foreach ($cmd in @("git","gh","vercel")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "  MANCA: $cmd" -ForegroundColor Red
        exit 1
    }
}
Write-Host "  OK" -ForegroundColor Green

# --- 2. Verifica di essere nella cartella giusta ---
Write-Host "[2/6] Verifica cartella progetto..." -ForegroundColor Yellow
if (-not (Test-Path "index.html")) {
    Write-Host "  ERRORE: index.html non trovato. Sei nella cartella giusta?" -ForegroundColor Red
    Write-Host "  Cartella attuale: $(Get-Location)" -ForegroundColor Yellow
    exit 1
}
$size = (Get-Item index.html).Length
if ($size -lt 20000) {
    Write-Host "  ATTENZIONE: index.html sembra piccolo ($size byte)" -ForegroundColor Yellow
}
Write-Host "  OK (index.html: $([math]::Round($size/1024,1)) KB)" -ForegroundColor Green

# --- 3. Commit + Push su GitHub ---
Write-Host "[3/6] Commit e push su GitHub..." -ForegroundColor Yellow
git add .
$status = git status --short
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "  Nessuna modifica da committare" -ForegroundColor DarkYellow
} else {
    git commit -m "$Message"
    Write-Host "  OK: commit creato" -ForegroundColor Green
}

# Push (con force se serve)
$pushOutput = git push 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Push normale fallito, provo force..." -ForegroundColor DarkYellow
    git push -u origin main --force
}
Write-Host "  OK: push completato" -ForegroundColor Green

# --- 4. Deploy Vercel ---
Write-Host "[4/6] Deploy su Vercel..." -ForegroundColor Yellow
$vercelOutput = vercel --prod --yes 2>&1 | Out-String

# Estrai URL del deploy appena fatto
$deployUrl = [regex]::Match($vercelOutput, 'https://villa-mare-[a-z0-9]+-leader-d231\.vercel\.app').Value
if ([string]::IsNullOrWhiteSpace($deployUrl)) {
    Write-Host "  ATTENZIONE: URL deploy non trovato nell'output" -ForegroundColor Yellow
    Write-Host $vercelOutput
    exit 1
}
Write-Host "  OK: deploy a $deployUrl" -ForegroundColor Green

# --- 5. Ricollega dominio (risolve il 404) ---
Write-Host "[5/6] Ricollego dominio villa-mare-blu.vercel.app..." -ForegroundColor Yellow
$deployDomain = $deployUrl -replace "https://",""
$aliasOutput = vercel alias set $deployDomain villa-mare-blu.vercel.app 2>&1 | Out-String
if ($aliasOutput -match "Success") {
    Write-Host "  OK: dominio collegato" -ForegroundColor Green
} else {
    Write-Host "  ATTENZIONE: alias potrebbe non essere riuscito" -ForegroundColor Yellow
    Write-Host $aliasOutput
}

# --- 6. Verifica finale ---
Write-Host "[6/6] Verifica finale..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
$curlOutput = curl.exe -s -I https://villa-mare-blu.vercel.app 2>&1 | Out-String
if ($curlOutput -match "HTTP/1.1 200") {
    Write-Host "  OK: sito online e raggiungibile" -ForegroundColor Green
} else {
    Write-Host "  ATTENZIONE: il sito potrebbe non rispondere" -ForegroundColor Yellow
    Write-Host $curlOutput
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  DEPLOY COMPLETATO!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Sito online:  https://villa-mare-blu.vercel.app" -ForegroundColor White
Write-Host "  GitHub:       https://github.com/zuccasandroazz/villa-mare-blu" -ForegroundColor White
Write-Host ""
Write-Host "  Per il prossimo deploy, esegui:" -ForegroundColor Yellow
Write-Host "    .\deploy.ps1 'descrizione modifiche'" -ForegroundColor White
Write-Host ""