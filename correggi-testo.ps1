$ErrorActionPreference = "Stop"
Copy-Item index.html "index.backup-prima-pulizia.html" -Force
$content = Get-Content index.html -Raw -Encoding UTF8

# Accenti italiani
$content = $content -replace "\be'\b", "è"
$content = $content -replace "\bpiu'", "più"
$content = $content -replace "\bperche'", "perché"
$content = $content -replace "\bcosi'", "così"
$content = $content -replace "\bpuo'", "può"
$content = $content -replace "\bgia'", "già"
$content = $content -replace "\bcitta'", "città"
$content = $content -replace "\blocalita'", "località"
$content = $content -replace "\bpossibilita'", "possibilità"
$content = $content -replace "\bqualita'", "qualità"
$content = $content -replace "\bvelocita'", "velocità"
$content = $content -replace "\battivita'", "attività"

# Apostrofi tipografici
$content = $content.Replace([char]0x2019, "'")
$content = $content.Replace([char]0x2018, "'")

# Emoji corrotti
$content = $content -replace '\?\?+', ''

# Spazi doppi nel testo visibile
$content = $content -replace '(?<=>)\s{2,}(?=<)', ' '

# Fix specifici
$content = $content -replace '\b100mt\b', '100 metri'
$content = $content -replace 'SanVeroMilis', 'San Vero Milis'
$content = $content -replace '\bTharos\b', 'Tharros'
$content = $content -replace '\bIsArutas\b', 'Is Arutas'
$content = $content -replace "S''Archittu", "S'Archittu"

Set-Content -Path index.html -Value $content -Encoding UTF8 -NoNewline
Write-Host "`nOK: pulizia completata" -ForegroundColor Green

# Report finale
$c = Get-Content index.html -Raw -Encoding UTF8
$residui = ([regex]::Matches($c, '\?\?+')).Count
Write-Host "Emoji corrotti residui: $residui" -ForegroundColor $(if ($residui -eq 0) {"Green"} else {"Yellow"})

# Deploy
git add .
git commit -m "Pulizia errori tipografici e simboli"
git push
vercel --prod --yes
Write-Host "`nFATTO! Ricarica tra 30 secondi: https://villa-mare-blu.vercel.app" -ForegroundColor Cyan