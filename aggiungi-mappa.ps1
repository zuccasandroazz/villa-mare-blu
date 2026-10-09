# ============================================================
#  VILLA MARE BLU - Aggiungi mappa GPS (Mandriola/Sinis)
# ============================================================
$ErrorActionPreference = "Stop"

# Backup
Copy-Item index.html "index.backup-prima-mappa.html" -Force
Write-Host "OK: backup creato" -ForegroundColor Green

$content = Get-Content index.html -Raw

# ---------- 1. Sostituisci la mappa SVG con iframe OpenStreetMap ----------
$oldMapPattern = '<div class="location-map">[\s\S]*?</div>'

$newMap = @'
<div class="location-map">
        <iframe
          width="100%"
          height="100%"
          frameborder="0"
          style="border:0;border-radius:20px;"
          src="https://www.openstreetmap.org/export/embed.html?bbox=8.37694%2C40.0238%2C8.41694%2C40.0438&layer=mapnik&marker=40.0338%2C8.39694"
          allowfullscreen>
        </iframe>
        <div class="map-overlay">
          <div class="map-address">
            <strong>📍 Mandriola</strong>
            <span>Marina di San Vero Milis · Sinis, Sardegna</span>
          </div>
          <div class="map-actions">
            <a href="https://www.google.com/maps?q=40.0338,8.39694" target="_blank" rel="noopener" class="map-btn">
              🗺️ Apri in Google Maps
            </a>
            <a href="https://www.google.com/maps/dir/?api=1&destination=40.0338,8.39694" target="_blank" rel="noopener" class="map-btn map-btn-primary">
              🧭 Indicazioni stradali
            </a>
          </div>
        </div>
      </div>
'@

if ($content -match $oldMapPattern) {
    $content = $content -replace $oldMapPattern, $newMap
    Write-Host "OK: mappa SVG sostituita con mappa interattiva" -ForegroundColor Green
} else {
    Write-Host "ATTENZIONE: mappa SVG non trovata, cerco varianti..." -ForegroundColor Yellow
    $content = $content -replace '<svg viewBox="0 0 400 400"[\s\S]*?</svg>', $newMap
}

# ---------- 2. Aggiungi CSS per l'overlay mappa ----------
$cssMap = @'
  .location-map{position:relative;overflow:hidden}
  .location-map iframe{display:block;width:100%;height:100%;min-height:480px}
  .map-overlay{position:absolute;bottom:0;left:0;right:0;padding:20px;background:linear-gradient(to top,rgba(10,46,61,.95),rgba(10,46,61,.7) 70%,transparent);display:flex;justify-content:space-between;align-items:flex-end;gap:16px;flex-wrap:wrap;border-radius:0 0 20px 20px}
  .map-address{color:#fff}
  .map-address strong{display:block;font-size:1.05rem;margin-bottom:4px}
  .map-address span{font-size:.85rem;opacity:.8}
  .map-actions{display:flex;gap:10px;flex-wrap:wrap}
  .map-btn{display:inline-block;padding:10px 18px;background:rgba(255,255,255,.15);color:#fff;text-decoration:none;border-radius:50px;font-size:.85rem;font-weight:500;border:1px solid rgba(255,255,255,.3);transition:all .25s;backdrop-filter:blur(8px)}
  .map-btn:hover{background:rgba(255,255,255,.25);transform:translateY(-2px)}
  .map-btn-primary{background:#e76f51;border-color:#e76f51}
  .map-btn-primary:hover{background:#d65f41}
  @media (max-width:768px){
    .location-map iframe{min-height:320px}
    .map-overlay{flex-direction:column;align-items:flex-start;padding:16px}
    .map-actions{width:100%}
    .map-btn{flex:1;text-align:center;justify-content:center}
  }
'@

if (-not $content.Contains(".map-overlay")) {
    $content = $content.Replace("</style>", "$cssMap`n</style>")
    Write-Host "OK: CSS mappa aggiunto" -ForegroundColor Green
} else {
    Write-Host "INFO: CSS mappa gia presente" -ForegroundColor Yellow
}

# ---------- 3. Aggiorna la lista luoghi con coordinate ----------
$content = $content.Replace(
    '<strong>Spiaggia di Mandriola</strong><span>100 metri a piedi</span>',
    '<strong>Spiaggia di Mandriola</strong><span>100 metri a piedi - 40.0321N 8.3955E</span>'
)
$content = $content.Replace(
    '<strong>Spiagge del Sinis</strong><span>Is Arutas, Mari Ermi, S''Archittu a pochi minuti</span>',
    '<strong>Spiagge del Sinis</strong><span>Is Arutas, Mari Ermi, S''Archittu - 15-25 min in auto</span>'
)
$content = $content.Replace(
    '<strong>Siti archeologici</strong><span>Tharros, Cornus, area archeologica di San Vero Milis</span>',
    '<strong>Siti archeologici</strong><span>Tharros (40.0567N 8.4167E), Cornus, Nuraghe S''Uraki</span>'
)
$content = $content.Replace(
    '<strong>Oristano</strong><span>15 km · circa 20 minuti in auto</span>',
    '<strong>Oristano</strong><span>15 km - circa 20 minuti - 39.9037N 8.5913E</span>'
)
$content = $content.Replace(
    '<strong>Aeroporto di Cagliari</strong><span>110 km · circa 1h 30 in auto</span>',
    '<strong>Aeroporto di Cagliari</strong><span>110 km - circa 1h 30 - 39.2515N 9.0543E</span>'
)

# ---------- 4. Aggiorna la sezione location con sottotitolo GPS ----------
$content = $content.Replace(
    '<p class="section-subtitle">Mandriola, Marina di San Vero Milis — sulla costa occidentale della Sardegna.</p>',
    '<p class="section-subtitle">Mandriola, Marina di San Vero Milis - sulla costa occidentale della Sardegna. Coordinate GPS: <strong>40.0338N, 8.39694E</strong></p>'
)

# ---------- Salva ----------
Set-Content -Path index.html -Value $content -Encoding UTF8 -NoNewline
Write-Host "`nHTML aggiornato con mappa GPS" -ForegroundColor Green

# ---------- Deploy ----------
Write-Host "`n===== Deploy su Vercel =====" -ForegroundColor Cyan
git add .
git commit -m "Aggiunta mappa GPS interattiva Mandriola"
git push
vercel --prod --yes

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "FATTO! Ricarica il sito tra 20-30 secondi con Ctrl+F5:" -ForegroundColor Green
Write-Host "https://villa-mare-blu.vercel.app" -ForegroundColor White
Write-Host "==================================================`n" -ForegroundColor Cyan