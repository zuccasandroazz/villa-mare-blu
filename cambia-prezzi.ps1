$ErrorActionPreference = "Stop"

# Backup
$backup = "index.backup-prima-prezzi-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
Copy-Item index.html $backup -Force
Write-Host "OK: backup -> $backup" -ForegroundColor Green

$c = Get-Content index.html -Raw -Encoding UTF8

# ============================================================
# 1. CARD APPARTAMENTI - aggiorna prezzi
# ============================================================

# Piano Terra - prezzo
$c = $c -replace '(<h3>Piano Terra</h3>[\s\S]{0,600}?<p class="apartment-price">)da 60 &euro; <small>/ notte</small>(</p>)', '${1}da 60 &euro; <small>a notte</small>${2}'
$c = $c -replace '(<h3>Piano Terra</h3>[\s\S]{0,600}?<p class="apartment-note">)[^<]*(</p>)', '${1}Prezzo minimo 60 euro a notte. Il costo finale viene concordato telefonicamente in base a stagione, durata e servizi extra.${2}'

# Primo Piano - prezzo
$c = $c -replace '(<h3>Primo Piano</h3>[\s\S]{0,600}?<p class="apartment-price">)da 60 &euro; <small>/ notte</small>(</p>)', '${1}da 60 &euro; <small>a notte</small>${2}'
$c = $c -replace '(<h3>Primo Piano</h3>[\s\S]{0,600}?<p class="apartment-note">)[^<]*(</p>)', '${1}Prezzo minimo 60 euro a notte. Il costo finale viene concordato telefonicamente in base a stagione, durata e servizi extra.${2}'

# ============================================================
# 2. SEZIONE CONTATTI - Card prezzi
# ============================================================

# Sostituisci le card prezzo con versione "da 60 € a notte"
# Piano Terra card
$c = $c -replace '(<div class="cta-price-card">\s*<div class="name">Piano Terra[^<]*</div>\s*<div class="price">)da 60 &euro;<small>/notte</small>(</div>)', '${1}da 60 &euro;<small>/notte</small>${2}'
$c = $c -replace '(<div class="name">Piano Terra[^<]*</div>\s*<div class="price">)da [0-9]+ &euro;<small>[^<]*</small>(</div>)', '${1}da 60 &euro;<small>/notte</small>${2}'

# Primo Piano card
$c = $c -replace '(<div class="cta-price-card">\s*<div class="name">Primo Piano[^<]*</div>\s*<div class="price">)da [0-9]+ &euro;<small>[^<]*</small>(</div>)', '${1}da 60 &euro;<small>/notte</small>${2}'

# ============================================================
# 3. SEZIONE CONTATTI - Testo introduttivo
# ============================================================

# Sostituisci il paragrafo "I prezzi indicati sono minimi..."
$vecchioTesto = 'I prezzi indicati sono minimi di partenza e variano in base a stagione, durata del soggiorno, numero di ospiti e servizi extra. Ogni variazione viene concordata telefonicamente in fase di prenotazione. Pulizia finale, biancheria e tassa di soggiorno da definire al telefono.'
$nuovoTesto = 'Il prezzo di partenza e di <strong>60 euro a notte</strong> per appartamento. Il costo finale viene sempre concordato telefonicamente in base a stagione (bassa o alta), durata del soggiorno, numero di ospiti e servizi extra richiesti (pulizia finale, biancheria, tassa di soggiorno).'

if ($c.Contains($vecchioTesto)) {
    $c = $c.Replace($vecchioTesto, $nuovoTesto)
    Write-Host "OK: testo prezzi aggiornato (match esatto)" -ForegroundColor Green
} else {
    # Regex piu flessibile
    $c = $c -replace 'I prezzi indicati sono minimi[^<]*', $nuovoTesto
    Write-Host "OK: testo prezzi aggiornato (regex)" -ForegroundColor Yellow
}

# ============================================================
# 4. SOTTOTITOLO SEZIONE CONTATTI
# ============================================================

$c = $c -replace 'Chiamaci per verificare la disponibilita[^<]*\.', 'Chiamaci per verificare la disponibilita, ricevere un preventivo personalizzato e concordare ogni dettaglio del tuo soggiorno.'

# ============================================================
# 5. APARTMENT NODE - Unifica in un testo chiaro
# ============================================================

# Rimuovi le note duplicati se ci sono piu versioni
$c = $c -replace '<p class="apartment-note">[^<]*Prezzo minimo indicativo[^<]*</p>', '<p class="apartment-note">Prezzo minimo 60 euro a notte. Il costo finale viene concordato telefonicamente in base a stagione, durata e servizi extra.</p>'

# ============================================================
# 6. META DESCRIPTION + SCHEMA
# ============================================================

$c = $c -replace 'priceRange":"[^"]*"', 'priceRange":"da 60 EUR per notte"'

# ============================================================
# SALVA
# ============================================================
Set-Content -Path index.html -Value $c -Encoding UTF8 -NoNewline
$size = (Get-Item index.html).Length
Write-Host "`nOK: index.html salvato ($([math]::Round($size/1024,1)) KB)" -ForegroundColor Green

# ============================================================
# VERIFICA - Cerca prezzi vecchi residui
# ============================================================
Write-Host "`nVerifica prezzi residui..." -ForegroundColor Yellow
$c2 = Get-Content index.html -Raw -Encoding UTF8
$trovati = [regex]::Matches($c2, 'da (60|120|120|180|240|290|190|150|100) &euro;')
if ($trovati.Count -gt 0) {
    Write-Host "Trovati $($trovati.Count) riferimenti a prezzi:" -ForegroundColor Cyan
    foreach ($t in $trovati) {
        Write-Host "  - $($t.Value)" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "Nessun prezzo vecchio trovato" -ForegroundColor Green
}

# ============================================================
# DEPLOY
# ============================================================
Write-Host "`n===== Deploy =====" -ForegroundColor Cyan
git add .
git commit -m "Prezzi: da 60 euro a notte, da concordare telefonicamente"
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