# ============================================================
#  VILLA MARE BLU - Pulizia errori tipografici e simboli
# ============================================================
$ErrorActionPreference = "Stop"

# ---------- Backup ----------
$backupName = "index.backup-prima-pulizia-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
Copy-Item index.html $backupName -Force
Write-Host "OK: backup -> $backupName" -ForegroundColor Green

$content = Get-Content index.html -Raw -Encoding UTF8

Write-Host "`n===== SCANSIONE ERRORI =====" -ForegroundColor Cyan

# ---------- 1. Conta problemi iniziali ----------
$report = @{}

# Emoji corrotti
$report["Emoji corrotti (?? o ??)"] = ([regex]::Matches($content, '\?\?+')).Count

# Accenti sbagliati (e' al posto di è)
$report["e' invece di è"] = ([regex]::Matches($content, "\be'\b")).Count
$report["piu' invece di più"] = ([regex]::Matches($content, "\bpiu'")).Count
$report["perche' invece di perché"] = ([regex]::Matches($content, "\bperche'")).Count
$report["cosi' invece di così"] = ([regex]::Matches($content, "\bcosi'")).Count
$report["puo' invece di può"] = ([regex]::Matches($content, "\bpuo'")).Count
$report["gia' invece di già"] = ([regex]::Matches($content, "\bgia'")).Count
$report["citta' invece di città"] = ([regex]::Matches($content, "\bcitta'")).Count
$report["localita' invece di località"] = ([regex]::Matches($content, "\blocalita'")).Count
$report["possibilita' invece di possibilità"] = ([regex]::Matches($content, "\bpossibilita'")).Count
$report["qualita' invece di qualità"] = ([regex]::Matches($content, "\bqualita'")).Count
$report["velocita' invece di velocità"] = ([regex]::Matches($content, "\bvelocita'")).Count
$report["attivita' invece di attività"] = ([regex]::Matches($content, "\battivita'")).Count

# Apostrofi tipografici strani
$report["Apostrofi tipografici (')"] = ([regex]::Matches($content, "'")).Count
$report["Virgolette tipografiche ("")"] = ([regex]::Matches($content, '"')).Count

# Spazi doppi
$report["Spazi doppi"] = ([regex]::Matches($content, '  ')).Count

# Spazi prima di punteggiatura
$report["Spazio prima di . , ; : ! ?"] = ([regex]::Matches($content, ' [.,;:!?]')).Count

# "?" isolati nel testo visibile (potrebbe essere emoji mancante)
$report["Punti interrogativi isolati"] = ([regex]::Matches($content, '>\s*\?\s*<')).Count

# Mostra report
foreach ($key in $report.Keys) {
    $val = $report[$key]
    $color = if ($val -eq 0) { "Green" } else { "Yellow" }
    Write-Host ("  {0,-40} : {1}" -f $key, $val) -ForegroundColor $color
}

# ---------- 2. APPLICA CORREZIONI ----------
Write-Host "`n===== CORREZIONI APPLICATE =====" -ForegroundColor Cyan
$fixes = 0

# Funzione helper
function Fix-Text {
    param($pattern, $replacement, $label)
    $script:content = $script:content -replace $pattern, $replacement
    $script:fixes++
}

# Accenti italiani
Fix-Text "\be'\b"           "è"          "e' -> è"
Fix-Text "\bpiu'"           "più"        "piu' -> più"
Fix-Text "\bperche'"        "perché"     "perche' -> perché"
Fix-Text "\bcosi'"          "così"       "cosi' -> così"
Fix-Text "\bpuo'"           "può"        "puo' -> può"
Fix-Text "\bgia'"           "già"        "gia' -> già"
Fix-Text "\bcitta'"         "città"      "citta' -> città"
Fix-Text "\blocalita'"      "località"   "localita' -> località"
Fix-Text "\bpossibilita'"   "possibilità" "possibilita' -> possibilità"
Fix-Text "\bqualita'"       "qualità"    "qualita' -> qualità"
Fix-Text "\bvelocita'"      "velocità"   "velocita' -> velocità"
Fix-Text "\battivita'"      "attività"   "attivita' -> attività"
Fix-Text "\bpercio'"        "perciò"     "percio' -> perciò"
Fix-Text "\bPero\b"         "Però"       "Pero -> Però"
Fix-Text "\bpero\b"         "però"       "pero -> però"

# Apostrofi tipografici -> apostrofo dritto (standard web)
$content = $content.Replace([char]0x2019, "'")   # ' -> '
$content = $content.Replace([char]0x2018, "'")   # ' -> '
$content = $content.Replace([char]0x201C, '"')   # " -> "
$content = $content.Replace([char]0x201D, '"')   # " -> "
Write-Host "  Apostrofi/virgolette tipografiche normalizzate" -ForegroundColor Green

# Pulisci emoji corrotti residui
$content = $content -replace '\?\?+', ''
Write-Host "  Emoji corrotti rimossi" -ForegroundColor Green

# Spazi doppi (solo nel testo visibile, non nel CSS/JS)
# Nota: nel CSS gli spazi doppi non fanno danno, quindi li lasciamo
$content = $content -replace '(?<=>)\s{2,}(?=<)', ' '
$content = $content -replace '(?<=>)\s+(?=[^\s<])', ''

Write-Host "  Correzioni applicate: $fixes" -ForegroundColor Green

# ---------- 3. FIX specifici per contenuto noto ----------
# Sistema "100 metri" (spesso ha "100mt" o "100 m" incoerenti)
$content = $content -replace '\b100mt\b', '100 metri'
$content = $content -replace '\b100 m\b', '100 metri'

# Sistema "San Vero Milis" (spesso scritto "SanVeroMilis")
$content = $content -replace 'SanVeroMilis', 'San Vero Milis'
$content = $content -replace 'San  Vero', 'San Vero'

# Sistema "S'Archittu" con apostrofo corretto
$content = $content -replace "S'Archittu", "S'Archittu"
$content = $content -replace "S''Archittu", "S'Archittu"

# Sistema "Is Arutas" (nome corretto)
$content = $content -replace '\bIsArutas\b', 'Is Arutas'

# Sistema "Nuraghe S'Uraki"
$content = $content -replace "Nuraghe S'Uraki", "Nuraghe S'Uraki"

# Sistema "Tharros" (doppia r)
$content = $content -replace '\bTharos\b', 'Tharros'

Write-Host "  Correzioni specifiche Sardegna/Sinis applicate" -ForegroundColor Green

# ---------- 4. Salva ----------
Set-Content -Path index.html -Value $content -Encoding UTF8 -NoNewline
Write-Host "`nHTML salvato con successo" -ForegroundColor Green

# ---------- 5. Ri-scansione per confermare ----------
Write-Host "`n===== VERIFICA POST-CORREZIONE =====" -ForegroundColor Cyan
$content2 = Get-Content index.html -Raw -Encoding UTF8

$residui = @{
    "Emoji corrotti residui" = ([regex]::Matches($content2, '\?\?+')).Count
    "e' residui" = ([regex]::Matches($content2, "\be'\b")).Count
    "piu' residui" = ([regex]::Matches($content2, "\bpiu'")).Count
    "Spazi doppi in testo" = ([regex]::Matches($content2, '>\s{2,}<')).Count
    "Apostrofi tipografici" = ([regex]::Matches($content2, '[' + [char]0x2019 + [char]0x2018 + ']')).Count
}

$pulito = $true
foreach ($k in $residui.Keys) {
    $v = $residui[$k]
    if ($v -eq 0) {
        Write-Host "  OK  $k : 0" -ForegroundColor Green
    } else {
        Write-Host "  !!  $k : $v" -ForegroundColor Yellow
        $pulito = $false
    }
}

if ($pulito) {
    Write-Host "`nSITO PULITO!" -ForegroundColor Green
} else {
    Write-Host "`nAlcuni residui rimasti - controlla il report sopra" -ForegroundColor Yellow
}

# ---------- 6. Deploy ----------
Write-Host "`n===== Deploy su Vercel =====" -ForegroundColor Cyan
git add .
git commit -m "Pulizia errori tipografici e simboli"
git push
vercel --prod --yes

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "FATTO! Ricarica il sito tra 20-30 secondi con Ctrl+F5:" -ForegroundColor Green
Write-Host "https://villa-mare-blu.vercel.app" -ForegroundColor White
Write-Host "==================================================`n" -ForegroundColor Cyan