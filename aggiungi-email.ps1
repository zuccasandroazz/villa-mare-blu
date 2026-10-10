$ErrorActionPreference = "Stop"

# Backup
$backup = "index.backup-prima-email-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
Copy-Item index.html $backup -Force
Write-Host "OK: backup -> $backup" -ForegroundColor Green

$c = Get-Content index.html -Raw -Encoding UTF8
$mod = 0

# ============================================================
# 1. CSS per il link email nel blocco contatti
# ============================================================
$newCss = @'
  .cta-email{display:inline-flex;align-items:center;gap:12px;margin-top:20px;padding:14px 26px;background:rgba(255,255,255,.06);border:1.5px solid rgba(255,255,255,.2);border-radius:50px;text-decoration:none;transition:all .35s;backdrop-filter:blur(10px);color:var(--white)}
  .cta-email:hover{background:rgba(255,255,255,.14);transform:translateY(-2px);box-shadow:0 14px 34px rgba(0,0,0,.25)}
  .cta-email svg{width:20px;height:20px;color:var(--gold);flex-shrink:0}
  .cta-email span{font-size:1rem;font-weight:500;letter-spacing:.4px}
  @media (max-width:560px){.cta-email{padding:12px 20px}.cta-email span{font-size:.92rem}}
'@

if (-not $c.Contains('.cta-email')) {
    $c = $c.Replace("</style>", "$newCss`n</style>")
    Write-Host "OK: CSS email aggiunto" -ForegroundColor Green
    $mod++
}

# ============================================================
# 2. Aggiungi email nella sezione contatti (dopo il pulsante telefono)
# ============================================================
$emailBlock = @'
<a href="mailto:mandriol@tiscali.it" class="cta-email">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        <span>mandriol@tiscali.it</span>
      </a>
'@

# Trova il pulsante telefono nella sezione CTA e aggiungi l'email subito dopo
if ($c -match '(?s)(<a href="tel:\+393287434911" class="cta-phone">[\s\S]*?</a>)(\s*<div class="cta-prices">)') {
    $c = $c -replace '(?s)(<a href="tel:\+393287434911" class="cta-phone">[\s\S]*?</a>)(\s*<div class="cta-prices">)', "`$1`n      $emailBlock`n`n      `$2"
    Write-Host "OK: email aggiunta nella sezione contatti" -ForegroundColor Green
    $mod++
} else {
    Write-Host "ATTENZIONE: pulsante telefono sezione CTA non trovato" -ForegroundColor Yellow
}

# ============================================================
# 3. Aggiorna il footer - sostituisci la mail esistente
# ============================================================
$c = $c -replace '<a href="mailto:info@casamandriola\.it">[^<]*</a>', '<a href="mailto:mandriol@tiscali.it">mandriol@tiscali.it</a>'
$c = $c -replace '<a href="mailto:info@mandriola\.it">[^<]*</a>', '<a href="mailto:mandriol@tiscali.it">mandriol@tiscali.it</a>'

# Se nel footer non c'è nessuna mail, la aggiungiamo
if (-not $c.Contains('mailto:mandriol@tiscali.it')) {
    $c = $c -replace '(<li><a href="tel:\+393287434911" class="footer-phone">\+39 328 743 4911</a></li>)', "`$1`n        <li><a href=`"mailto:mandriol@tiscali.it`">mandriol@tiscali.it</a></li>"
    Write-Host "OK: email aggiunta nel footer" -ForegroundColor Green
    $mod++
} else {
    Write-Host "OK: email aggiornata nel footer" -ForegroundColor Green
    $mod++
}

# ============================================================
# 4. Aggiungi meta tag per email
# ============================================================
if (-not $c.Contains('mailto:mandriol@tiscali.it')) {
    # se ancora non c'è, cerchiamo un punto dove inserirla (contatti footer)
    $c = $c.Replace('<li>Mandriola - San Vero Milis (OR)</li>', '<li><a href="mailto:mandriol@tiscali.it">mandriol@tiscali.it</a></li>' + "`n        " + '<li>Mandriola - San Vero Milis (OR)</li>')
}

# ============================================================
# 5. Aggiorna Schema.org (email)
# ============================================================
$c = $c -replace '"email":"[^"]*"', '"email":"mandriol@tiscali.it"'

# Se non c'è campo email nello schema, aggiungilo dopo telephone
if (-not $c.Contains('"email"')) {
    $c = $c -replace '("telephone":"\+39-328-743-4911")', '$1,"email":"mandriol@tiscali.it"'
    Write-Host "OK: email aggiunta allo schema" -ForegroundColor Green
    $mod++
}

# ============================================================
# 6. Testo "chiama o scrivi"
# ============================================================
$c = $c -replace 'Chiamaci per verificare la disponibilita[^<]*\.', 'Chiamaci o scrivici per verificare la disponibilita, ricevere un preventivo personalizzato e concordare ogni dettaglio del tuo soggiorno.'

# ============================================================
# SALVA
# ============================================================
Set-Content -Path index.html -Value $c -Encoding UTF8 -NoNewline
$size = (Get-Item index.html).Length
Write-Host "`nOK: index.html salvato ($([math]::Round($size/1024,1)) KB)" -ForegroundColor Green
Write-Host "Modifiche: $mod" -ForegroundColor Cyan

# ============================================================
# VERIFICA
# ============================================================
$c2 = Get-Content index.html -Raw -Encoding UTF8
$occorrenze = ([regex]::Matches($c2, 'mandriol@tiscali\.it')).Count
Write-Host "`nOccorrenze email nel file: $occorrenze" -ForegroundColor Cyan
if ($occorrenze -ge 3) {
    Write-Host "OK: email presente in almeno 3 punti (contatti + footer + schema)" -ForegroundColor Green
} else {
    Write-Host "ATTENZIONE: email presente solo $occorrenze volte" -ForegroundColor Yellow
}

# ============================================================
# DEPLOY
# ============================================================
Write-Host "`n===== Deploy =====" -ForegroundColor Cyan
git add .
git commit -m "Aggiunta email di contatto mandriol@tiscali.it"
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