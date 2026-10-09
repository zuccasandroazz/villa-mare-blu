# ============================================================
#  VILLA MARE BLU - Correggi simboli in didascalie e mappa
# ============================================================
$ErrorActionPreference = "Stop"

Copy-Item index.html "index.backup-prima-simboli.html" -Force
Write-Host "OK: backup creato" -ForegroundColor Green

$content = Get-Content index.html -Raw

# ---------- 1. PULISCI emoji corrotti nel map-overlay ----------
# Rimuovi ogni emoji "sporca" sostituendola con testo pulito
$content = $content.Replace('<strong>📍 Mandriola</strong>', '<strong>Mandriola</strong>')
$content = $content.Replace('<strong>📌 Mandriola</strong>', '<strong>Mandriola</strong>')
$content = $content.Replace('<strong>?? Mandriola</strong>', '<strong>Mandriola</strong>')
$content = $content.Replace('🗺️ Apri in Google Maps', 'Apri in Google Maps')
$content = $content.Replace('🗺 Apri in Google Maps', 'Apri in Google Maps')
$content = $content.Replace('?? Apri in Google Maps', 'Apri in Google Maps')
$content = $content.Replace('🧭 Indicazioni stradali', 'Indicazioni stradali')
$content = $content.Replace('?? Indicazioni stradali', 'Indicazioni stradali')

# In caso di emoji residui (qualunque "?" doppio), pulizia generale nell'overlay
$content = $content -replace '(?<=<strong>)[^<]*?\?\?+\s*', ''
$content = $content -replace '(?<=class="map-btn[^"]*">)\s*\?\?+\s*', ''

# ---------- 2. AGGIUNGI icone SVG pulite (invece degli emoji) ----------
$svgPin = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:6px"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>'
$svgMap = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:6px"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>'
$svgNav = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:6px"><polygon points="3 11 22 2 13 21 11 13 3 11"/></svg>'

# Aggiungi l'icona pin al titolo Mandriola (se non già presente)
if ($content -notmatch 'class="map-address".*?<svg') {
    $content = $content.Replace(
        '<strong>Mandriola</strong>',
        "<strong>$svgPin Mandriola</strong>"
    )
    Write-Host "OK: icona pin SVG aggiunta a Mandriola" -ForegroundColor Green
}

# Aggiungi icone SVG ai pulsanti mappa
if ($content -notmatch 'map-btn[^>]*>\s*<svg') {
    $content = $content.Replace(
        'class="map-btn">Apri in Google Maps',
        "class=`"map-btn`">$svgMap Apri in Google Maps"
    )
    $content = $content.Replace(
        'class="map-btn map-btn-primary">Indicazioni stradali',
        "class=`"map-btn map-btn-primary`">$svgNav Indicazioni stradali"
    )
    Write-Host "OK: icone SVG aggiunte ai pulsanti" -ForegroundColor Green
}

# ---------- 3. PULISCI emoji corrotti nelle DIDASCALIE galleria ----------
# In caso di "??" residui nelle caption
$content = $content -replace '(?<=gallery-caption">)\s*\?\?+\s*', ''
$content = $content -replace '(?<=gallery-caption">)([^<]*?)\?\?+', '$1'

# ---------- 4. Verifica ----------
Write-Host "`nControllo emoji residui..." -ForegroundColor Yellow
$residui = [regex]::Matches($content, '\?\?+').Count
if ($residui -eq 0) {
    Write-Host "OK: nessun emoji corrotto residuo" -ForegroundColor Green
} else {
    Write-Host "ATTENZIONE: $residui emoji corrotti ancora presenti" -ForegroundColor Yellow
    Write-Host "Controlla manualmente index.html alla ricerca di '??'" -ForegroundColor Yellow
}

# ---------- 5. Salva ----------
Set-Content -Path index.html -Value $content -Encoding UTF8 -NoNewline
Write-Host "`nHTML salvato" -ForegroundColor Green

# ---------- 6. Deploy ----------
Write-Host "`n===== Deploy su Vercel =====" -ForegroundColor Cyan
git add .
git commit -m "Corretti simboli didascalie e mappa Mandriola"
git push
vercel --prod --yes

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "FATTO! Ricarica il sito tra 20-30 secondi con Ctrl+F5:" -ForegroundColor Green
Write-Host "https://villa-mare-blu.vercel.app" -ForegroundColor White
Write-Host "==================================================`n" -ForegroundColor Cyan