/* scamsung-debloat v5 — progressive enhancement only.
   Content is fully readable without JS. html.motion is added only after a
   double-rAF proves frames pump; every animation hangs off it, and a failsafe
   drops the class again if reveals never fire. */
(function () {
    "use strict";

    var doc = document.documentElement;
    var reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var canObserve = "IntersectionObserver" in window;
    var motionOK = !reduced && "requestAnimationFrame" in window && canObserve;
    var motionReady = false;

    /* ---------- motion gate ---------- */
    if (motionOK) {
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                motionReady = true;
                doc.classList.add("motion");
                observeRises();
            });
        });
    }

    /* ---------- entrance reveals ---------- */
    function observeRises() {
        var rises = document.querySelectorAll("[data-rise]");
        if (!rises.length) return;

        var reveal = function (el) { el.classList.add("up"); };
        var ro = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (!e.isIntersecting) return;
                reveal(e.target);
                ro.unobserve(e.target);
            });
        }, { threshold: 0.12, rootMargin: "0px 0px -6% 0px" });

        Array.prototype.forEach.call(rises, function (el) { ro.observe(el); });

        /* failsafe: if the observer never delivers, show everything */
        setTimeout(function () {
            if (!document.querySelector("[data-rise].up")) {
                doc.classList.remove("motion");
            }
        }, 2200);
    }

    /* ---------- sticky header shadow ---------- */
    var head = document.querySelector(".site-head");
    if (head) {
        var ticking = false;
        var sync = function () {
            head.classList.toggle("stuck", window.scrollY > 8);
            ticking = false;
        };
        sync();
        window.addEventListener("scroll", function () {
            if (ticking) return;
            ticking = true;
            requestAnimationFrame(sync);
        }, { passive: true });
    }

    /* ---------- interactive demo terminal ---------- */
    var demo = document.getElementById("demo");
    if (!demo) return;

    var card = demo.querySelector(".demo-card") || demo;
    var out = card.querySelector(".term-out");
    var cmdEl = card.querySelector("[data-cmd]");
    var chips = Array.prototype.slice.call(card.querySelectorAll(".t-chip"));
    var replayBtn = card.querySelector(".replay");
    var tpl = {};

    chips.forEach(function (chip) {
        var t = document.getElementById("tpl-" + chip.dataset.preset);
        if (t) tpl[chip.dataset.preset] = t.innerHTML;
    });

    function setPreset(name) {
        chips.forEach(function (c) {
            var on = c.dataset.preset === name;
            c.classList.toggle("on", on);
            c.setAttribute("aria-pressed", on ? "true" : "false");
        });
        if (cmdEl) cmdEl.dataset.cmd = "./scamsung-debloat apply " + name;
        if (out && tpl[name]) out.innerHTML = tpl[name];
    }

    var timers = [];
    function later(fn, ms) { timers.push(setTimeout(fn, ms)); }
    function clearTimers() { timers.forEach(clearTimeout); timers = []; }

    function run(animated) {
        clearTimers();
        if (!out) return;
        var lines = Array.prototype.slice.call(out.children);
        var full = cmdEl ? cmdEl.dataset.cmd : "";

        if (!animated) {
            lines.forEach(function (l) { l.style.display = ""; });
            if (cmdEl) cmdEl.textContent = full;
            return;
        }

        lines.forEach(function (l) { l.style.display = "none"; });
        if (cmdEl) cmdEl.textContent = "";

        var t = 260;
        if (cmdEl) {
            for (var i = 0; i < full.length; i++) {
                (function (ch, k) {
                    later(function () { cmdEl.textContent += ch; }, t + k * 26);
                })(full.charAt(i), i);
            }
            t += full.length * 26 + 300;
        }
        lines.forEach(function (line) {
            var kind = line.dataset.speed || "line";
            var d = kind === "fast" ? 32 : kind === "slow" ? 230 : 80;
            later(function () { line.style.display = ""; }, t);
            t += d;
        });
    }

    var played = false;

    function autoplay() {
        if (played) return;
        played = true;
        run(motionReady);
    }

    if (!motionOK) {
        /* no motion: static output, but make sure the command reads right */
        if (cmdEl) cmdEl.textContent = cmdEl.dataset.cmd;
    } else {
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (!e.isIntersecting) return;
                autoplay();
                io.disconnect();
            });
        }, { threshold: 0.2 });
        io.observe(card);
    }

    chips.forEach(function (chip) {
        chip.addEventListener("click", function () {
            setPreset(chip.dataset.preset);
            played = true;
            run(motionReady);
        });
    });

    if (replayBtn) {
        replayBtn.addEventListener("click", function () {
            if (!played) {
                played = true;
                run(motionReady);
                return;
            }
            run(motionReady);
        });
    }
})();
