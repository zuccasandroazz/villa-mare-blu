$ErrorActionPreference = "Stop"
Copy-Item index.html "index.backup-prima-foto-org.html" -Force

# Crea cartelle
New-Item -ItemType Directory -Path "images\piano-terra" -Force | Out-Null
New-Item -ItemType Directory -Path "images\primo-piano" -Force | Out-Null
New-Item -ItemType Directory -Path "images\paesaggio" -Force | Out-Null

# Mappa: [sorgente, destinazione, didascalia]
$foto = @(
    # --- PIANO TERRA ---
    @("salotto sala pranzo.avif",                    "piano-terra\soggiorno.avif",       "Soggiorno con zona pranzo"),
    @("sala pranzo.avif",                            "piano-terra\pranzo.avif",          "Zona pranzo"),
    @("sala pranzo diversa vista.avif",              "piano-terra\pranzo-2.avif",        "Zona pranzo - altra vista"),
    @("angolo cottura.avif",                         "piano-terra\cottura.avif",         "Angolo cottura"),
    @("camera letto uno.jpg",                        "piano-terra\camera-1.jpg",         "Camera matrimoniale"),
    @("camera letto uno altra vista.jpg",            "piano-terra\camera-1-altra.jpg",   "Camera matrimoniale - altra vista"),
    @("camera letto uno diversa vista.avif",         "piano-terra\camera-1-vista.avif",  "Camera matrimoniale - vista"),
    @("camera letto uno altra diversa vista.avif",   "piano-terra\camera-1-dettaglio.avif","Camera matrimoniale - dettaglio"),
    @("bagno completo.avif",                         "piano-terra\bagno.avif",           "Bagno completo con doccia"),
    @("balcone.avif",                                "piano-terra\balcone.avif",         "Balcone privato"),
    @("particolari sulle pareti.avif",               "piano-terra\pareti.avif",          "Particolari decorativi"),
    # --- PRIMO PIANO ---
    @("camera letto due.avif",                       "primo-piano\camera-2.avif",        "Camera da letto 2"),
    @("camera letto tre.jpg",                        "primo-piano\camera-3.jpg",         "Camera da letto 3"),
    # --- PAESAGGIO ---
    @("piccola spiaggia a 100mt dalla casa.avif",    "paesaggio\spiaggia.avif",          "La spiaggia di Mandriola a 100 metri"),
    @("particolare sulla pulitissima e cristallina acqua.jpg", "paesaggio\acqua.avif",    "Acqua cristallina"),
    @("particolare sulla sabbia delle coste limitrofe.avif",   "paesaggio\sabbia.avif",   "Le spiagge del Sinis"),
    @("veduta sul mare limpido e cristallino.avif",  "paesaggio\mare.avif",              "Il mare del Sinis"),
    @("veduta dei mari dalle coste vicine.avif",     "paesaggio\coste.avif",             "Veduta dalle coste vicine"),
    @("strapiombi sul mare.avif",                    "paesaggio\strapiombi.avif",        "Strapiombi sul mare"),
    @("torretta limitrofa all'abitato.jpg",          "paesaggio\torretta.jpg",           "Torretta limitrofa"),
    @("veduta dall'acqua della casa.avif",           "paesaggio\veduta-acqua.avif",      "La casa vista dal mare"),
    @("vista dal mare dell'abitazione.avif",         "paesaggio\veduta-mare.avif",       "Vista dal mare"),
    @("vista aerea centro abitato.avif",             "paesaggio\aerea.avif",             "Vista aerea di Mandriola"),
    @("vista dall'alto ubicazione abitazione.avif",  "paesaggio\ubicazione.avif",        "Ubicazione della casa"),
    @("cancelletto esterno.avif",                    "paesaggio\cancelletto.avif",       "Ingresso esterno"),
    @("locale nei pressi, mandriola.avif",           "paesaggio\mandriola.avif",         "Mandriola"),
    @("mari limitrofi della costa.avif",             "paesaggio\mari.avif",              "Mari limitrofi")
)

# Copia
$ok=0; $miss=0
foreach ($f in $foto) {
    $src = "images\$($f[0])"
    $dst = "images\$($f[1])"
    if (Test-Path -LiteralPath $src) {
        Copy-Item -LiteralPath $src -Destination $dst -Force
        $ok++
    } else {
        Write-Host "  MANCA: $($f[0])" -ForegroundColor Yellow
        $miss++
    }
}
Write-Host "`nOK: $ok copiate, $miss mancanti" -ForegroundColor Green

# Copia hero (usa il mare limpido)
if (Test-Path -LiteralPath "images\veduta sul mare limpido e cristallino.avif") {
    Copy-Item -LiteralPath "images\veduta sul mare limpido e cristallino.avif" -Destination "images\piano-terra\hero.avif" -Force
    Copy-Item -LiteralPath "images\veduta sul mare limpido e cristallino.avif" -Destination "images\hero.avif" -Force
}

# ============================================================
# AGGIORNA GALLERIE NELL'HTML
# ============================================================
$content = Get-Content index.html -Raw -Encoding UTF8

# --- Galleria PIANO TERRA ---
$ptItems = @'
<div class="gallery-item wide tall" style="background-image:url('images/piano-terra/soggiorno.avif')"><span class="gallery-caption">Soggiorno con zona pranzo</span></div>
      <div class="gallery-item" style="background-image:url('images/piano-terra/camera-1.jpg')"><span class="gallery-caption">Camera matrimoniale</span></div>
      <div class="gallery-item" style="background-image:url('images/piano-terra/cottura.avif')"><span class="gallery-caption">Angolo cottura</span></div>
      <div class="gallery-item" style="background-image:url('images/piano-terra/pranzo.avif')"><span class="gallery-caption">Zona pranzo</span></div>
      <div class="gallery-item wide" style="background-image:url('images/piano-terra/balcone.avif')"><span class="gallery-caption">Balcone privato</span></div>
      <div class="gallery-item" style="background-image:url('images/piano-terra/bagno.avif')"><span class="gallery-caption">Bagno completo</span></div>
      <div class="gallery-item" style="background-image:url('images/piano-terra/pareti.avif')"><span class="gallery-caption">Particolari decorativi</span></div>
      <div class="gallery-item" style="background-image:url('images/piano-terra/camera-1-altra.jpg')"><span class="gallery-caption">Camera - altra vista</span></div>
'@

$content = $content -replace '(?s)(<section class="gallery" id="gallery-piano-terra">.*?<div class="gallery-grid">).*?(</div>\s*</div>\s*</section>)', "`$1`n$ptItems`n    `$2"

# --- Galleria PRIMO PIANO ---
$ppItems = @'
<div class="gallery-item wide tall" style="background-image:url('images/primo-piano/camera-2.avif')"><span class="gallery-caption">Camera da letto 2</span></div>
      <div class="gallery-item" style="background-image:url('images/primo-piano/camera-3.jpg')"><span class="gallery-caption">Camera da letto 3</span></div>
      <div class="gallery-item gallery-empty">Salotto<br><small>Foto in arrivo</small></div>
      <div class="gallery-item gallery-empty">Cucina<br><small>Foto in arrivo</small></div>
      <div class="gallery-item wide gallery-empty">Terrazza panoramica<br><small>Foto in arrivo</small></div>
      <div class="gallery-item gallery-empty">Bagno<br><small>Foto in arrivo</small></div>
      <div class="gallery-item gallery-empty">Dettagli<br><small>Foto in arrivo</small></div>
'@

$content = $content -replace '(?s)(<section class="gallery alt" id="primo-piano">.*?<div class="gallery-grid">).*?(</div>\s*</div>\s*</section>)', "`$1`n$ppItems`n    `$2"

Set-Content -Path index.html -Value $content -Encoding UTF8 -NoNewline
Write-Host "OK: gallerie aggiornate nell'HTML" -ForegroundColor Green

# ============================================================
# DEPLOY
# ============================================================
git add .
git commit -m "Organizzate foto per piano terra, primo piano e paesaggio con didascalie"
git push
vercel --prod --yes

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "FATTO! Ricarica tra 30 secondi:" -ForegroundColor Green
Write-Host "https://villa-mare-blu.vercel.app" -ForegroundColor White
Write-Host "==================================================`n" -ForegroundColor Cyan