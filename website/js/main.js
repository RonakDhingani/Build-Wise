/* =========================================================================
   Build Wise — premium site interactions (vanilla JS, no dependencies)
   Nav · header state · FAQ · scroll reveal · hero parallax ·
   interactive carousel (auto / drag / dots / keyboard) · contact form · year
   Performance: transforms/opacity only, IntersectionObserver, rAF-throttled.
   ========================================================================= */
(function () {
  'use strict';

  var SUPPORT_EMAIL = 'support@buildwise.app';
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---- Mobile navigation ------------------------------------------------ */
  function initNav() {
    var toggle = document.querySelector('.nav__toggle');
    var links = document.getElementById('nav-links');
    if (!toggle || !links) return;
    toggle.addEventListener('click', function () {
      var open = links.classList.toggle('open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    links.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') {
        links.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
      }
    });
  }

  /* ---- Header shadow on scroll ------------------------------------------ */
  function initHeader() {
    var header = document.getElementById('site-header');
    if (!header) return;
    var ticking = false;
    function update() { header.classList.toggle('scrolled', window.scrollY > 8); ticking = false; }
    window.addEventListener('scroll', function () {
      if (!ticking) { window.requestAnimationFrame(update); ticking = true; }
    }, { passive: true });
    update();
  }

  /* ---- FAQ accordion ---------------------------------------------------- */
  function initFaq() {
    var items = document.querySelectorAll('.faq__item');
    items.forEach(function (item) {
      var q = item.querySelector('.faq__q');
      var a = item.querySelector('.faq__a');
      if (!q || !a) return;
      q.addEventListener('click', function () {
        var isOpen = item.classList.contains('open');
        items.forEach(function (o) {
          o.classList.remove('open');
          var oa = o.querySelector('.faq__a'); var oq = o.querySelector('.faq__q');
          if (oa) oa.style.maxHeight = null;
          if (oq) oq.setAttribute('aria-expanded', 'false');
        });
        if (!isOpen) {
          item.classList.add('open');
          a.style.maxHeight = a.scrollHeight + 'px';
          q.setAttribute('aria-expanded', 'true');
        }
      });
    });
  }

  /* ---- Scroll reveal (staggered) ---------------------------------------- */
  function initReveal() {
    var els = document.querySelectorAll('.reveal');
    if (reduceMotion || !('IntersectionObserver' in window) || !els.length) {
      els.forEach(function (el) { el.classList.add('in'); });
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) { entry.target.classList.add('in'); io.unobserve(entry.target); }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });
    els.forEach(function (el) { io.observe(el); });
  }

  /* ---- Hero parallax (mouse + scroll) ----------------------------------- */
  function initParallax() {
    if (reduceMotion) return;
    var hero = document.querySelector('.hero');
    var preview = document.getElementById('hero-preview');
    if (!hero || !preview) return;
    var mx = 0, my = 0, sy = 0, raf = null;

    function apply() {
      preview.style.transform =
        'translate3d(' + mx + 'px,' + (my + sy) + 'px,0)';
      raf = null;
    }
    function schedule() { if (!raf) raf = window.requestAnimationFrame(apply); }

    hero.addEventListener('mousemove', function (e) {
      var r = hero.getBoundingClientRect();
      mx = ((e.clientX - r.left) / r.width - 0.5) * 18;
      my = ((e.clientY - r.top) / r.height - 0.5) * 14;
      schedule();
    });
    hero.addEventListener('mouseleave', function () { mx = 0; my = 0; schedule(); });
    window.addEventListener('scroll', function () {
      if (window.scrollY < window.innerHeight) { sy = window.scrollY * 0.06; schedule(); }
    }, { passive: true });
  }

  /* ---- Interactive carousel --------------------------------------------- */
  function initCarousel() {
    var root = document.getElementById('carousel');
    var stage = document.getElementById('carousel-stage');
    if (!root || !stage) return;

    var slides = Array.prototype.slice.call(stage.querySelectorAll('.carousel__slide'));
    var n = slides.length;
    if (!n) return;

    var caption = document.getElementById('carousel-caption');
    var dotsWrap = document.getElementById('carousel-dots');
    var prevBtn = document.getElementById('carousel-prev');
    var nextBtn = document.getElementById('carousel-next');
    var current = 0;
    var autoTimer = null;
    var AUTO_MS = 4500;

    // Build dots
    var dots = [];
    if (dotsWrap) {
      slides.forEach(function (_, i) {
        var b = document.createElement('button');
        b.type = 'button';
        b.setAttribute('aria-label', 'Go to screenshot ' + (i + 1));
        b.addEventListener('click', function () { go(i); restartAuto(); });
        dotsWrap.appendChild(b);
        dots.push(b);
      });
    }

    function render() {
      slides.forEach(function (slide, i) {
        // shortest circular distance
        var rel = i - current;
        if (rel > n / 2) rel -= n;
        if (rel < -n / 2) rel += n;
        var abs = Math.abs(rel);
        var x = rel * 64;                 // % offset from centre
        var scale = abs === 0 ? 1 : abs === 1 ? 0.82 : 0.66;
        var opacity = abs === 0 ? 1 : abs === 1 ? 0.55 : 0;
        var blur = abs === 0 ? 0 : abs === 1 ? 2 : 4;
        var z = 10 - abs;
        slide.style.transform = 'translateX(calc(-50% + ' + x + '%)) scale(' + scale + ')';
        slide.style.opacity = opacity;
        slide.style.filter = blur ? 'blur(' + blur + 'px)' : 'none';
        slide.style.zIndex = z;
        slide.style.pointerEvents = abs === 0 ? 'auto' : 'none';
        slide.setAttribute('aria-hidden', abs === 0 ? 'false' : 'true');
      });
      dots.forEach(function (d, i) { d.classList.toggle('active', i === current); });
      updateCaption();
    }

    function updateCaption() {
      if (!caption) return;
      var s = slides[current];
      var h = caption.querySelector('h3'); var p = caption.querySelector('p');
      caption.style.opacity = 0;
      window.setTimeout(function () {
        if (h) h.innerHTML = s.getAttribute('data-title') || '';
        if (p) p.textContent = s.getAttribute('data-desc') || '';
        caption.style.opacity = 1;
      }, 160);
    }

    function go(i) { current = (i % n + n) % n; render(); }
    function next() { go(current + 1); }
    function prev() { go(current - 1); }

    function startAuto() { if (reduceMotion) return; stopAuto(); autoTimer = window.setInterval(next, AUTO_MS); }
    function stopAuto() { if (autoTimer) { window.clearInterval(autoTimer); autoTimer = null; } }
    function restartAuto() { stopAuto(); startAuto(); }

    if (nextBtn) nextBtn.addEventListener('click', function () { next(); restartAuto(); });
    if (prevBtn) prevBtn.addEventListener('click', function () { prev(); restartAuto(); });

    // Pause on hover
    root.addEventListener('mouseenter', stopAuto);
    root.addEventListener('mouseleave', startAuto);

    // Keyboard (when carousel is in viewport / focused)
    root.setAttribute('tabindex', '0');
    root.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowRight') { next(); restartAuto(); }
      else if (e.key === 'ArrowLeft') { prev(); restartAuto(); }
    });

    // Drag / swipe (pointer events)
    var dragging = false, startX = 0, dx = 0;
    stage.addEventListener('pointerdown', function (e) {
      dragging = true; startX = e.clientX; dx = 0; stopAuto();
      stage.setPointerCapture && stage.setPointerCapture(e.pointerId);
    });
    stage.addEventListener('pointermove', function (e) { if (dragging) dx = e.clientX - startX; });
    function endDrag() {
      if (!dragging) return;
      dragging = false;
      if (Math.abs(dx) > 45) { dx < 0 ? next() : prev(); }
      restartAuto();
    }
    stage.addEventListener('pointerup', endDrag);
    stage.addEventListener('pointercancel', endDrag);
    stage.addEventListener('pointerleave', endDrag);

    // Only auto-play while the carousel is on screen
    if ('IntersectionObserver' in window) {
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) { en.isIntersecting ? startAuto() : stopAuto(); });
      }, { threshold: 0.25 });
      io.observe(root);
    } else { startAuto(); }

    render();
  }

  /* ---- Contact form -> mailto ------------------------------------------- */
  function initForm() {
    var form = document.getElementById('contact-form');
    if (!form) return;
    var status = document.getElementById('form-status');
    function setStatus(msg, kind) { if (status) { status.textContent = msg; status.className = 'form__status ' + kind; } }

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var name = (form.name.value || '').trim();
      var email = (form.email.value || '').trim();
      var subject = (form.subject.value || '').trim();
      var message = (form.message.value || '').trim();
      if (!name || !email || !message) { setStatus('Please fill in your name, email, and message.', 'err'); return; }
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { setStatus('Please enter a valid email address.', 'err'); return; }
      var body = 'Name: ' + name + '\nEmail: ' + email + '\n\n' + message;
      window.location.href = 'mailto:' + SUPPORT_EMAIL +
        '?subject=' + encodeURIComponent(subject || 'Build Wise enquiry') +
        '&body=' + encodeURIComponent(body);
      setStatus('Opening your email app…', 'ok');
      form.reset();
    });
  }

  /* ---- Footer year ------------------------------------------------------ */
  function initYear() {
    document.querySelectorAll('[data-year]').forEach(function (el) { el.textContent = new Date().getFullYear(); });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initNav();
    initHeader();
    initFaq();
    initReveal();
    initParallax();
    initCarousel();
    initForm();
    initYear();
  });
})();
