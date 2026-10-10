$ErrorActionPreference = "Stop"

# Backup
$backup = "index.backup-prima-ospiti-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
Copy-Item index.html $backup -Force
Write-Host "OK: backup -> $backup" -ForegroundColor Green

$c = Get-Content index.html -Raw -Encoding UTF8
$mod = 0

# ============================================================
# PIANO TERRA: da 3 a 4 ospiti
# ============================================================

# 1. Card appartamenti - Piano Terra
if ($c -match '(?s)(<h3>Piano Terra</h3>\s*<p class="apartment-subtitle">)Fino a 3 ospiti(</p>)') {
    $c = $c -replace '(?s)(<h3>Piano Terra</h3>\s*<p class="apartment-subtitle">)Fino a 3 ospiti(</p>)', '${1}Fino a 4 ospiti${2}'
    Write-Host "OK: card Piano Terra -> 4 ospiti" -ForegroundColor Green
    $mod++
}

# 2. About stats - Piano Terra
if ($c -match '(?s)(id="piano-terra">[\s\S]{0,3000}?<div class="stat-number">)3(</div><div class="stat-label">Ospiti</div>)') {
    $c = $c -replace '(?s)(id="piano-terra">[\s\S]{0,3000}?<div class="stat-number">)3(</div><div class="stat-label">Ospiti</div>)', '${1}4${2}'
    Write-Host "OK: about stats Piano Terra -> 4" -ForegroundColor Green
    $mod++
}

# 3. CTA prezzi - Piano Terra (il testo dice solo "Piano Terra", non ha "fino a X ospiti")
# Lascia invariato

# 4. Select form (se esiste ancora)
$c = $c -replace '(Piano Terra[^\n]*?)fino a 3 ospiti', '${1}fino a 4 ospiti'

# 5. Schema.org - number of guests (se presente)
$c = $c -replace 'occupancy.*?3', 'occupancy": 4'

# ============================================================
# PRIMO PIANO: rimane a 5 (già corretto) - solo verifica
# ============================================================

# Verifica che Primo Piano dica "Fino a 5 ospiti"
if ($c -match '(<h3>Primo Piano</h3>\s*<p class="apartment-subtitle">)Fino a 5 ospiti(</p>)') {
    Write-Host "OK: card Primo Piano già corretta (5 ospiti)" -ForegroundColor Green
} else {
    Write-Host "ATTENZIONE: card Primo Piano non trovata" -ForegroundColor Yellow
}

# ============================================================
# AGGIORNA ALTRE DICITURE
# ============================================================

# Hero e sottotitoli
$c = $c -replace '\(fino a 3 ospiti\)', '(fino a 4 ospiti)'

# Se c'è "fino a 3" in generale
$c = $c -replace 'fino a 3 ospiti', 'fino a 4 ospiti'

# ============================================================
# AGGIORNA SEZIONE CONTATTI - Card prezzi
# ============================================================

# Nella sezione contatti, le card dicono "Piano Terra", "Primo Piano", "Casa Intera"
# senza specificare ospiti. Aggiungiamo "max 4" e "max 5" per chiarezza.
$c = $c -replace '(<div class="name">)Piano Terra(</div>\s*<div class="price">da 60)', '${1}Piano Terra · max 4${2}'
$c = $c -replace '(<div class="name">)Primo Piano(</div>\s*<div class="price">da 60)', '${1}Primo Piano · max 5${2}'
$c = $c -replace '(<div class="name">)Casa Intera(</div>\s*<div class="price">da 120)', '${1}Casa Intera · max 9${2}'

Write-Host "OK: card prezzi contatti aggiornate" -ForegroundColor Green

# ============================================================
# FAQ - se menziona numeri ospiti
# ============================================================

# Aggiorna eventuali riferimenti in FAQ
$c = $c -replace '3 ospiti', '4 ospiti'

# ============================================================
# SALVA
# ============================================================

Set-Content -Path index.html -Value $c -Encoding UTF8 -NoNewline
$size = (Get-Item index.html).Length
Write-Host "`nOK: index.html salvato ($([math]::Round($size/1024,1)) KB)" -ForegroundColor Green
Write-Host "Modifiche principali: $mod" -ForegroundColor Cyan

# ============================================================
# DEPLOY
# ============================================================

Write-Host "`n===== Deploy =====" -ForegroundColor Cyan
git add .
git commit -m "Aggiornato numero massimo ospiti: Piano Terra max 4, Primo Piano max 5"
git push
vercel --prod --yes

Write-Host "`nAggiorno dominio..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$out = vercel ls --prod | Out-String
$url = ([regex]::Match($out, 'https://villa-mare-[a-z0-9]+-leader-d231\.vercel\.app')).Value
if ($url) {
    vercel alias set ($url -replace 'https://','') villa-mare-blu.vercel.app
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "FATTO! Ricarica tra 30 secondi:" -ForegroundColor Green
Write-Host "https://villa-mare-blu.vercel.app" -ForegroundColor White
Write-Host "==================================================`n" -ForegroundColor Cyan