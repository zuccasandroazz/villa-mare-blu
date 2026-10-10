$ErrorActionPreference = "Stop"

# Backup
$backup = "index.backup-prima-solo-appartamenti-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
Copy-Item index.html $backup -Force
Write-Host "OK: backup -> $backup" -ForegroundColor Green

$c = Get-Content index.html -Raw -Encoding UTF8

# ============================================================
# 1. RIMUOVI CARD "CASA INTERA" DALLA SEZIONE APPARTAMENTI
# ============================================================
$cardCasaIntera = @'
<div class="apartment-card reveal reveal-d3">
        <div class="apartment-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18M5 21V7l7-4 7 4v14M9 9h.01M15 9h.01M9 13h.01M15 13h.01M9 17h.01M15 17h.01"/></svg></div>
        <h3>Casa Intera</h3>
        <p class="apartment-subtitle">Fino a 9 ospiti</p>
        <ul class="apartment-features">
          <li>Entrambi gli appartamenti</li>
          <li>Ideale per gruppi e famiglie</li>
          <li>Massima privacy e spazio</li>
          <li>Due bagni completi</li>
          <li>Due cucine attrezzate</li>
          <li>Prezzo dedicato su richiesta</li>
        </ul>
        <p class="apartment-price">da 120 &euro; <small>/ notte</small></p>
        <p class="apartment-note">Prezzo minimo indicativo. Preventivo personalizzato al telefono.</p>
        <a href="#contatti" class="btn">Richiedi preventivo</a>
      </div>
'@

# Prova a rimuoverlo con match esatto
if ($c.Contains($cardCasaIntera)) {
    $c = $c.Replace($cardCasaIntera, '')
    Write-Host "OK: card Casa Intera rimossa (match esatto)" -ForegroundColor Green
} else {
    # Prova regex piu flessibile
    $c = $c -replace '(?s)<div class="apartment-card reveal reveal-d3">\s*<div class="apartment-icon">[\s\S]*?<h3>Casa Intera</h3>[\s\S]*?</div>\s*</div>', ''
    Write-Host "OK: card Casa Intera rimossa (regex)" -ForegroundColor Yellow
}

# ============================================================
# 2. AGGIORNA IL TITOLO DELLA SEZIONE (tre modi -> due)
# ============================================================
$c = $c.Replace(
    '<h2 class="section-title">Due appartamenti,<br>tre modi di soggiornare</h2>',
    '<h2 class="section-title">Due appartamenti,<br>due modi di soggiornare</h2>'
)
$c = $c.Replace(
    '<p class="section-subtitle">Scegli la soluzione piu adatta alle tue esigenze: puoi affittare solo il piano terra, solo il primo piano, oppure l''intera casa per gruppi piu numerosi.</p>',
    '<p class="section-subtitle">Scegli la soluzione piu adatta alle tue esigenze: appartamento al piano terra o appartamento al primo piano, entrambi completamente indipendenti e con ingresso autonomo.</p>'
)

# Varianti se il match esatto non funziona
$c = $c -replace 'tre modi di soggiornare', 'due modi di soggiornare'
$c = $c -replace 'oppure l''intera casa per gruppi piu numerosi', 'entrambi completamente indipendenti'
$c = $c -replace 'oppure l''intera casa', ''

# ============================================================
# 3. RIMUOVI CARD PREZZO "CASA INTERA" DALLA SEZIONE CONTATTI
# ============================================================
$c = $c -replace '(?s)<div class="cta-price-card">\s*<div class="name">Casa Intera[^<]*</div>\s*<div class="price">[^<]*<small>[^<]*</small></div>\s*</div>', ''

# Varianti
$c = $c -replace '<div class="name">Casa Intera[^<]*</div>', ''

# ============================================================
# 4. RIMUOVI SEZIONE "Casa Intera" IN ALTRI PUNTI (se presente)
# ============================================================
$c = $c -replace '(?s)<div class="apartment-card[^"]*featured[^"]*">[\s\S]{0,500}?Casa Intera[\s\S]{0,500}?</div>', ''

# ============================================================
# 5. AGGIORNA CSS DELLA GRIGLIA A 2 COLONNE
# ============================================================
# Sostituisci la griglia auto-fit (che si adatta da sola) con 2 colonne fisse che si centrano bene
$oldGrid = '.apartment-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:28px}'
$newGrid = '.apartment-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:28px;max-width:820px;margin:0 auto}'
if ($c.Contains($oldGrid)) {
    $c = $c.Replace($oldGrid, $newGrid)
    Write-Host "OK: griglia appartamenti -> 2 colonne centrate" -ForegroundColor Green
} else {
    $c = $c -replace '\.apartment-grid\{[^}]*\}', $newGrid
    Write-Host "OK: griglia appartamenti aggiornata (regex)" -ForegroundColor Yellow
}

# Media query per mobile - 1 colonna
$mobileFix = @'
  @media (max-width:768px){
    .apartment-grid{grid-template-columns:1fr;max-width:100%}
  }
'@
# Inserisci dentro la media query esistente (o aggiungi come nuovo blocco prima di </style>)
$c = $c.Replace("</style>", "$mobileFix`n</style>")

# ============================================================
# 6. AGGIORNA TESTI RIFERITI A "CASA INTERA" O "GRUPPI"
# ============================================================
$c = $c -replace 'Ideale per gruppi e famiglie', 'Ideale per famiglie'
$c = $c -replace 'per gruppi piu numerosi', 'per ogni esigenza'
$c = $c -replace 'l''intera casa', 'un appartamento indipendente'
$c = $c -replace 'Entrambi gli appartamenti', 'Appartamento indipendente'

# ============================================================
# 7. AGGIORNA FAQ (se cita "casa intera" o "gruppi")
# ============================================================
$c = $c -replace 'Possiamo affittare entrambi gli appartamenti\?', 'Gli appartamenti sono indipendenti?'
$c = $c -replace 'entrambi gli appartamenti', 'un appartamento'

# ============================================================
# 8. AGGIORNA META DESCRIPTION E SEO
# ============================================================
$c = $c -replace 'Due appartamenti al piano terra e primo piano, affittabili separatamente o interamente\.', 'Due appartamenti indipendenti al piano terra e primo piano a Mandriola, nel Sinis.'
$c = $c -replace 'affittabili separatamente o come casa intera', 'completamente indipendenti con ingresso autonomo'

# ============================================================
# 9. AGGIORNA LA SEZIONE CONTATTI - SOTTOTITOLO
# ============================================================
$c = $c -replace 'I prezzi indicati sono minimi di partenza[^.]*\.', 'I prezzi indicati sono minimi di partenza per appartamento.'

# ============================================================
# SALVA
# ============================================================
Set-Content -Path index.html -Value $c -Encoding UTF8 -NoNewline
$size = (Get-Item index.html).Length
Write-Host "`nOK: index.html salvato ($([math]::Round($size/1024,1)) KB)" -ForegroundColor Green

# ============================================================
# VERIFICA
# ============================================================
$c2 = Get-Content index.html -Raw -Encoding UTF8
if ($c2 -match 'Casa Intera') {
    Write-Host "ATTENZIONE: esiste ancora un riferimento a 'Casa Intera'" -ForegroundColor Yellow
    # Elenca dove appare
    $righe = ($c2 -split "`n") | Select-String 'Casa Intera'
    foreach ($r in $righe) {
        Write-Host "  riga: $($r.Line.Trim())" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "OK: nessun riferimento a 'Casa Intera'" -ForegroundColor Green
}

# ============================================================
# DEPLOY
# ============================================================
Write-Host "`n===== Deploy =====" -ForegroundColor Cyan
git add .
git commit -m "Rimossa formula casa intera - solo appartamenti separati"
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