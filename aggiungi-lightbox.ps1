$ErrorActionPreference = "Stop"

# Backup
$backup = "index.backup-prima-lightbox-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
Copy-Item index.html $backup -Force
Write-Host "OK: backup -> $backup" -ForegroundColor Green

$c = Get-Content index.html -Raw -Encoding UTF8

# ============================================================
# 1. CSS LIGHTBOX
# ============================================================
$lightboxCss = @'
  /* LIGHTBOX */
  .lightbox{position:fixed;inset:0;z-index:9999;background:rgba(8,41,58,.96);backdrop-filter:blur(12px);display:flex;align-items:center;justify-content:center;opacity:0;visibility:hidden;transition:opacity .4s cubic-bezier(.4,0,.2,1),visibility .4s;padding:20px}
  .lightbox.active{opacity:1;visibility:visible}
  .lightbox-img{max-width:95vw;max-height:88vh;object-fit:contain;border-radius:12px;box-shadow:0 30px 80px rgba(0,0,0,.6);transform:scale(.85);transition:transform .4s cubic-bezier(.4,0,.2,1);background:#0a2e3d}
  .lightbox.active .lightbox-img{transform:scale(1)}
  .lightbox-close{position:absolute;top:20px;right:20px;width:52px;height:52px;border-radius:50%;background:rgba(255,255,255,.15);border:1.5px solid rgba(255,255,255,.3);color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .3s;backdrop-filter:blur(10px);z-index:2}
  .lightbox-close:hover{background:var(--coral);border-color:var(--coral);transform:rotate(90deg)}
  .lightbox-close svg{width:24px;height:24px}
  .lightbox-caption{position:absolute;bottom:30px;left:50%;transform:translateX(-50%);color:#fff;font-size:1rem;font-weight:500;letter-spacing:.4px;padding:12px 26px;background:rgba(255,255,255,.1);border-radius:50px;backdrop-filter:blur(10px);border:1px solid rgba(255,255,255,.15);max-width:85vw;text-align:center;opacity:0;transition:opacity .3s .1s}
  .lightbox.active .lightbox-caption{opacity:1}
  .lightbox-caption:empty{display:none}
  .lightbox-nav{position:absolute;top:50%;transform:translateY(-50%);width:56px;height:56px;border-radius:50%;background:rgba(255,255,255,.15);border:1.5px solid rgba(255,255,255,.3);color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .3s;backdrop-filter:blur(10px);z-index:2}
  .lightbox-nav:hover{background:var(--coral);border-color:var(--coral);transform:translateY(-50%) scale(1.08)}
  .lightbox-nav svg{width:26px;height:26px}
  .lightbox-prev{left:24px}
  .lightbox-next{right:24px}
  .lightbox-nav.hidden{opacity:0;pointer-events:none}

  /* Rendi cliccabili le immagini delle gallerie */
  .gallery-item,.landscape-item,.about-thumbs > div,.about-img{cursor:zoom-in}

  @media (max-width:640px){
    .lightbox{padding:10px}
    .lightbox-img{max-width:100vw;max-height:80vh;border-radius:8px}
    .lightbox-close{top:12px;right:12px;width:44px;height:44px}
    .lightbox-nav{width:44px;height:44px}
    .lightbox-prev{left:10px}
    .lightbox-next{right:10px}
    .lightbox-caption{bottom:16px;font-size:.85rem;padding:10px 20px}
  }
'@

if (-not $c.Contains('.lightbox{')) {
    $c = $c.Replace("</style>", "$lightboxCss`n</style>")
    Write-Host "OK: CSS lightbox aggiunto" -ForegroundColor Green
} else {
    Write-Host "INFO: CSS lightbox gia presente" -ForegroundColor Yellow
}

# ============================================================
# 2. HTML LIGHTBOX (prima di </body>)
# ============================================================
$lightboxHtml = @'
<div class="lightbox" id="lightbox" role="dialog" aria-modal="true" aria-hidden="true">
  <button class="lightbox-close" id="lightboxClose" aria-label="Chiudi">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
  </button>
  <button class="lightbox-nav lightbox-prev hidden" id="lightboxPrev" aria-label="Precedente">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
  </button>
  <img class="lightbox-img" id="lightboxImg" src="" alt="">
  <button class="lightbox-nav lightbox-next hidden" id="lightboxNext" aria-label="Successiva">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
  </button>
  <div class="lightbox-caption" id="lightboxCaption"></div>
</div>
'@

if (-not $c.Contains('id="lightbox"')) {
    $c = $c.Replace("</body>", "$lightboxHtml`n</body>")
    Write-Host "OK: HTML lightbox aggiunto" -ForegroundColor Green
} else {
    Write-Host "INFO: HTML lightbox gia presente" -ForegroundColor Yellow
}

# ============================================================
# 3. JS LIGHTBOX
# ============================================================
$lightboxJs = @'

// ==========================================
// LIGHTBOX - click/tap su foto per ingrandire
// ==========================================
(function(){
  var lb = document.getElementById('lightbox');
  if (!lb) return;

  var img = document.getElementById('lightboxImg');
  var cap = document.getElementById('lightboxCaption');
  var close = document.getElementById('lightboxClose');
  var prev = document.getElementById('lightboxPrev');
  var next = document.getElementById('lightboxNext');

  var currentGallery = [];
  var currentIndex = 0;

  // Funzione: estrae URL immagine da un elemento con background-image
  function getBgUrl(el){
    var bg = el.style.backgroundImage || window.getComputedStyle(el).backgroundImage;
    var m = bg.match(/url\(["']?([^"')]+)["']?\)/);
    return m ? m[1] : null;
  }

  // Funzione: caption dell'elemento
  function getCaption(el){
    var c = el.querySelector('.gallery-caption, .landscape-caption');
    return c ? c.textContent.trim() : '';
  }

  // Apri lightbox
  function open(src, caption, gallery, index){
    img.src = src;
    img.alt = caption || '';
    cap.textContent = caption || '';
    currentGallery = gallery || [];
    currentIndex = index || 0;

    // Nascondi frecce se c'è solo una foto
    if (currentGallery.length > 1) {
      prev.classList.remove('hidden');
      next.classList.remove('hidden');
    } else {
      prev.classList.add('hidden');
      next.classList.add('hidden');
    }

    lb.classList.add('active');
    lb.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  }

  // Chiudi lightbox
  function closeLb(){
    lb.classList.remove('active');
    lb.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
    setTimeout(function(){ img.src = ''; }, 300);
  }

  // Naviga
  function navigate(dir){
    if (currentGallery.length < 2) return;
    currentIndex = (currentIndex + dir + currentGallery.length) % currentGallery.length;
    var item = currentGallery[currentIndex];
    img.src = item.src;
    img.alt = item.caption || '';
    cap.textContent = item.caption || '';
  }

  // Raccogli TUTTI gli elementi cliccabili per galleria
  function initGallery(selector){
    var items = document.querySelectorAll(selector);
    var gallery = [];
    items.forEach(function(el){
      var src = getBgUrl(el);
      if (src) {
        gallery.push({ el: el, src: src, caption: getCaption(el) });
      }
    });

    gallery.forEach(function(item, idx){
      item.el.addEventListener('click', function(e){
        e.preventDefault();
        open(item.src, item.caption, gallery, idx);
      });
      // Supporto touch esplicito
      item.el.addEventListener('touchend', function(e){
        e.preventDefault();
        open(item.src, item.caption, gallery, idx);
      });
    });
  }

  // Inizializza tutte le gallerie del sito
  initGallery('.gallery-item');
  initGallery('.landscape-item');
  initGallery('.about-thumbs > div');

  // Eventi chiusura
  close.addEventListener('click', closeLb);
  lb.addEventListener('click', function(e){
    if (e.target === lb) closeLb();
  });

  // Navigazione frecce
  prev.addEventListener('click', function(e){ e.stopPropagation(); navigate(-1); });
  next.addEventListener('click', function(e){ e.stopPropagation(); navigate(1); });

  // Tastiera
  document.addEventListener('keydown', function(e){
    if (!lb.classList.contains('active')) return;
    if (e.key === 'Escape') closeLb();
    if (e.key === 'ArrowLeft') navigate(-1);
    if (e.key === 'ArrowRight') navigate(1);
  });

  // Swipe su mobile
  var touchStartX = 0;
  var touchEndX = 0;
  lb.addEventListener('touchstart', function(e){ touchStartX = e.changedTouches[0].screenX; }, {passive:true});
  lb.addEventListener('touchend', function(e){
    touchEndX = e.changedTouches[0].screenX;
    var diff = touchStartX - touchEndX;
    if (Math.abs(diff) > 60) {
      if (diff > 0) navigate(1);
      else navigate(-1);
    }
  }, {passive:true});
})();
'@

# Inserisci lo script JS prima di </script>
if (-not $c.Contains('LIGHTBOX - click/tap')) {
    $c = $c.Replace("</script>", "$lightboxJs`n</script>")
    Write-Host "OK: JS lightbox aggiunto" -ForegroundColor Green
} else {
    Write-Host "INFO: JS lightbox gia presente" -ForegroundColor Yellow
}

# ============================================================
# SALVA
# ============================================================
Set-Content -Path index.html -Value $c -Encoding UTF8 -NoNewline
$size = (Get-Item index.html).Length
Write-Host "`nOK: index.html salvato ($([math]::Round($size/1024,1)) KB)" -ForegroundColor Green

# ============================================================
# DEPLOY
# ============================================================
Write-Host "`n===== Deploy =====" -ForegroundColor Cyan
git add .
git commit -m "Aggiunto lightbox: click/tap sulle foto per ingrandirle"
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