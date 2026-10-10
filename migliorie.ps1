$ErrorActionPreference = "Stop"
Copy-Item index.html "index.backup-prima-migliorie.html" -Force
Write-Host "OK: backup creato" -ForegroundColor Green

$c = Get-Content index.html -Raw -Encoding UTF8

# --- CSS NUOVO ---
$newCss = @'
  .landscape{background:var(--cream)}
  .landscape-grid{display:grid;grid-template-columns:repeat(4,1fr);grid-auto-rows:220px;gap:14px}
  .landscape-item{border-radius:16px;background-size:cover;background-position:center;position:relative;overflow:hidden;transition:transform .5s cubic-bezier(.4,0,.2,1);cursor:pointer}
  .landscape-item::after{content:'';position:absolute;inset:0;background:linear-gradient(to top,rgba(8,41,58,.8),transparent 55%);opacity:0;transition:opacity .45s;z-index:1}
  .landscape-item:hover{transform:scale(1.03)}
  .landscape-item:hover::after{opacity:1}
  .landscape-item.wide{grid-column:span 2}
  .landscape-item.tall{grid-row:span 2}
  .landscape-caption{position:absolute;bottom:18px;left:20px;right:20px;color:#fff;font-size:.9rem;font-weight:500;letter-spacing:.4px;opacity:0;transform:translateY(10px);transition:opacity .4s,transform .4s;z-index:2;text-shadow:0 2px 10px rgba(0,0,0,.7);pointer-events:none}
  .landscape-item:hover .landscape-caption{opacity:1;transform:translateY(0)}
  .faq{background:var(--sand)}
  .faq-list{max-width:820px;margin:0 auto}
  .faq-item{background:var(--white);border-radius:14px;margin-bottom:14px;overflow:hidden;box-shadow:var(--shadow-sm);transition:box-shadow .3s}
  .faq-item:hover{box-shadow:var(--shadow-md)}
  .faq-question{padding:22px 28px;cursor:pointer;display:flex;justify-content:space-between;align-items:center;gap:16px;font-size:1.05rem;font-weight:600;color:var(--sea-deep);transition:color .3s;user-select:none}
  .faq-question:hover{color:var(--coral)}
  .faq-question svg{width:20px;height:20px;color:var(--coral);flex-shrink:0;transition:transform .35s cubic-bezier(.4,0,.2,1)}
  .faq-item.open .faq-question svg{transform:rotate(180deg)}
  .faq-answer{max-height:0;overflow:hidden;transition:max-height .45s cubic-bezier(.4,0,.2,1),padding .35s}
  .faq-item.open .faq-answer{max-height:320px;padding:0 28px 24px}
  .faq-answer p{color:#4a4a4a;font-size:.96rem;line-height:1.75}
  .floating-whatsapp{position:fixed;bottom:28px;left:200px;z-index:99;width:52px;height:52px;border-radius:50%;background:#25d366;color:#fff;text-decoration:none;display:flex;align-items:center;justify-content:center;box-shadow:0 14px 40px rgba(37,211,102,.45);transition:all .35s cubic-bezier(.4,0,.2,1)}
  .floating-whatsapp:hover{transform:translateY(-4px) scale(1.06);box-shadow:0 20px 50px rgba(37,211,102,.6)}
  .floating-whatsapp svg{width:26px;height:26px}
  @media (max-width:960px){
    .landscape-grid{grid-template-columns:repeat(2,1fr);grid-auto-rows:170px}
    .landscape-item.wide{grid-column:span 2}
    .landscape-item.tall{grid-row:span 1}
    .floating-whatsapp{bottom:20px;left:96px;width:48px;height:48px}
  }
  @media (max-width:560px){
    .landscape-grid{grid-auto-rows:150px;gap:10px}
    .floating-whatsapp{left:84px;width:44px;height:44px}
    .floating-whatsapp svg{width:22px;height:22px}
  }
'@
$c = $c.Replace("</style>", "$newCss`n</style>")

# --- SEZIONE PAESAGGIO ---
$landscapeSection = @'

<section class="landscape" id="dintorni">
  <div class="container">
    <div class="section-head reveal">
      <span class="section-label">Il territorio</span>
      <h2 class="section-title">Il Sinis e i suoi tesori</h2>
      <p class="section-subtitle">Spiagge da sogno, siti archeologici e panorami mozzafiato. Mandriola e' il punto di partenza ideale per esplorare una delle coste piu belle della Sardegna.</p>
    </div>
    <div class="landscape-grid reveal">
      <div class="landscape-item wide tall" style="background-image:url('images/paesaggio/mare.avif')"><span class="landscape-caption">Il mare cristallino del Sinis</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/spiaggia.avif')"><span class="landscape-caption">La spiaggia di Mandriola a 100 metri</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/acqua.avif')"><span class="landscape-caption">Acqua trasparente</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/aerea.avif')"><span class="landscape-caption">Vista aerea di Mandriola</span></div>
      <div class="landscape-item wide" style="background-image:url('images/paesaggio/coste.avif')"><span class="landscape-caption">Le coste del Sinis</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/torretta.jpg')"><span class="landscape-caption">Torretta spagnola</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/strapiombi.avif')"><span class="landscape-caption">Strapiombi sul mare</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/mari.avif')"><span class="landscape-caption">Mari limitrofi</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/mandriola.avif')"><span class="landscape-caption">Mandriola</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/ubicazione.avif')"><span class="landscape-caption">Ubicazione della casa</span></div>
      <div class="landscape-item wide" style="background-image:url('images/paesaggio/veduta-mare.avif')"><span class="landscape-caption">Veduta dal mare</span></div>
      <div class="landscape-item" style="background-image:url('images/paesaggio/cancelletto.avif')"><span class="landscape-caption">Ingresso esterno</span></div>
    </div>
  </div>
</section>
'@
$c = $c -replace '(<section class="location" id="posizione">)', "$landscapeSection`n`$1"

# --- SEZIONE FAQ ---
$faqSection = @'

<section class="faq" id="faq">
  <div class="container">
    <div class="section-head reveal">
      <span class="section-label">Domande frequenti</span>
      <h2 class="section-title">Le risposte alle domande piu comuni</h2>
      <p class="section-subtitle">Se non trovi quello che cerchi, chiamaci al +39 328 743 4911.</p>
    </div>
    <div class="faq-list reveal">
      <div class="faq-item"><div class="faq-question">Qual e' il periodo migliore per soggiornare?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg></div><div class="faq-answer"><p>Da maggio a ottobre. Giugno e settembre offrono il miglior equilibrio tra clima mite, mare caldo e prezzi piu accessibili. Luglio e agosto sono i mesi piu richiesti.</p></div></div>
      <div class="faq-item"><div class="faq-question">Posso portare il mio cane?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg></div><div class="faq-answer"><p>Certo! Amiamo gli animali e i tuoi amici a quattro zampe sono i benvenuti. Ti chiediamo solo di segnalarcelo in fase di prenotazione telefonica.</p></div></div>
      <div class="faq-item"><div class="faq-question">C'e' il parcheggio?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg></div><div class="faq-answer"><p>Si, e' possibile parcheggiare nelle vicinanze della casa. Nella zona di Mandriola il parcheggio e' libero e generalmente non ci sono problemi di spazio, anche in alta stagione.</p></div></div>
      <div class="faq-item"><div class="faq-question">Cosa devo portare per il soggiorno?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg></div><div class="faq-answer"><p>Gli appartamenti sono forniti di tutto il necessario: cucina attrezzata, stoviglie, elettrodomestici, aria condizionata e Wi-Fi. La biancheria puo' essere fornita a richiesta.</p></div></div>
      <div class="faq-item"><div class="faq-question">Quanto dista il mare?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg></div><div class="faq-answer"><p>La spiaggia di Mandriola e' a soli 100 metri dalla casa: si raggiunge a piedi in 2 minuti. Le altre spiagge del Sinis sono a 15-25 minuti di auto.</p></div></div>
      <div class="faq-item"><div class="faq-question">Come funziona la prenotazione?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg></div><div class="faq-answer"><p>Ci contatti telefonicamente al +39 328 743 4911: verifichiamo insieme la disponibilita, concordiamo il periodo e tutti i dettagli. Il prezzo finale viene definito in base a stagione, durata e servizi extra.</p></div></div>
    </div>
  </div>
</section>
'@
$c = $c -replace '(<section class="cta" id="contatti">)', "$faqSection`n`$1"

# --- PULSANTE WHATSAPP ---
$waButton = @'
<a href="https://wa.me/393287434911?text=Ciao%2C%20vorrei%20informazioni%20sulla%20casa%20vacanze%20a%20Mandriola" target="_blank" rel="noopener" class="floating-whatsapp" aria-label="WhatsApp"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg></a>
'@
$c = $c -replace '(<a href="tel:\+393287434911" class="floating-phone"[^>]*>[\s\S]*?</a>)', "`$1`n$waButton"

# --- JS FAQ ---
$faqScript = @'

document.querySelectorAll('.faq-question').forEach(function(q){
  q.addEventListener('click',function(){
    var item = q.parentElement;
    var wasOpen = item.classList.contains('open');
    document.querySelectorAll('.faq-item').forEach(function(i){i.classList.remove('open')});
    if(!wasOpen){item.classList.add('open')}
  })
});
'@
$c = $c -replace '(</script>)', "$faqScript`n`$1"

Set-Content -Path index.html -Value $c -Encoding UTF8 -NoNewline
Write-Host "OK: index.html aggiornato ($([math]::Round((Get-Item index.html).Length/1024,1)) KB)" -ForegroundColor Green

# --- DEPLOY ---
git add .
git commit -m "Aggiunte sezione Paesaggio, FAQ e pulsante WhatsApp"
git push
vercel --prod --yes

Start-Sleep -Seconds 5
$out = vercel ls --prod | Out-String
$url = ([regex]::Match($out, 'https://villa-mare-[a-z0-9]+-leader-d231\.vercel\.app')).Value
if ($url) {
    Write-Host "Aggiorno dominio..." -ForegroundColor Yellow
    vercel alias set ($url -replace 'https://','') villa-mare-blu.vercel.app
}
Write-Host "FATTO!" -ForegroundColor Green