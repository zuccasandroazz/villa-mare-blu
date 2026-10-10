$ErrorActionPreference = "Stop"

# Backup
$backup = "index.backup-prima-nome-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
Copy-Item index.html $backup -Force
Write-Host "OK: backup -> $backup" -ForegroundColor Green

$c = Get-Content index.html -Raw -Encoding UTF8
$modifiche = 0

# --- 1. HERO H1: "La tua casa al mare<br>a <em>Mandriola</em>" ---
$oldHero = 'La tua casa al mare<br>a <em>Mandriola</em>'
$newHero = 'Casa <em>Minicapo</em><br>Mandriola'
if ($c.Contains($oldHero)) {
    $c = $c.Replace($oldHero, $newHero)
    Write-Host "OK: titolo hero aggiornato" -ForegroundColor Green
    $modifiche++
} else {
    Write-Host "ATTENZIONE: titolo hero non trovato esatto, provo variante..." -ForegroundColor Yellow
    $c = $c -replace 'La tua casa al mare\s*<br>\s*a\s*<em>Mandriola</em>', $newHero
}

# --- 2. ALTRE OCCORRENZE DI "La tua casa al mare" (varianti) ---
$c = $c -replace 'La tua casa al mare', 'Casa Minicapo'

# --- 3. FOOTER + LOGO ---
# Logo attuale: "Casa<span>Mandriola</span>" → mantieni coerente
if ($c.Contains('<div class="logo">Casa<span>Mandriola</span></div>')) {
    $c = $c.Replace('<div class="logo">Casa<span>Mandriola</span></div>', '<div class="logo">Casa<span>Minicapo</span></div>')
    Write-Host "OK: logo aggiornato in Casa Minicapo" -ForegroundColor Green
    $modifiche++
}

# Footer brand
if ($c.Contains('<h4>Casa<span>Mandriola</span></h4>')) {
    $c = $c.Replace('<h4>Casa<span>Mandriola</span></h4>', '<h4>Casa<span>Minicapo</span> Mandriola</h4>')
    Write-Host "OK: footer brand aggiornato" -ForegroundColor Green
    $modifiche++
}

# --- 4. META TITLE ---
if ($c.Contains('<title>Casa Vacanze Mandriola - Sinis, Sardegna</title>')) {
    $c = $c.Replace('<title>Casa Vacanze Mandriola - Sinis, Sardegna</title>', '<title>Casa Minicapo Mandriola - Sinis, Sardegna</title>')
    Write-Host "OK: title meta aggiornato" -ForegroundColor Green
    $modifiche++
}

# --- 5. META DESCRIPTION + OG TITLE ---
$c = $c -replace 'content="Casa Vacanze Mandriola[^"]*"', 'content="Casa Minicapo Mandriola - Appartamenti sul mare nel Sinis, Sardegna"'
$c = $c -replace 'content="Casa Vacanze Mandriola[^"]*"', 'content="Casa Minicapo Mandriola - Sinis, Sardegna"'

# --- 6. AUTHOR + SCHEMA ---
$c = $c -replace 'content="Casa Mandriola"', 'content="Casa Minicapo Mandriola"'
$c = $c -replace '"name":"Casa Mandriola"', '"name":"Casa Minicapo Mandriola"'
$c = $c -replace 'Casa Mandriola - Appartamenti', 'Casa Minicapo Mandriola - Appartamenti'

# --- 7. FOOTER BOTTOM ---
$c = $c -replace '2025 Casa Mandriola', '2025 Casa Minicapo Mandriola'

# --- Salva ---
Set-Content -Path index.html -Value $c -Encoding UTF8 -NoNewline
$size = (Get-Item index.html).Length
Write-Host "`nOK: index.html salvato ($([math]::Round($size/1024,1)) KB)" -ForegroundColor Green
Write-Host "Totale modifiche: $modifiche principali + sostituzioni globali" -ForegroundColor Cyan

# --- Deploy ---
Write-Host "`n===== Deploy =====" -ForegroundColor Cyan
git add .
git commit -m "Cambio dicitura: Casa Minicapo Mandriola"
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