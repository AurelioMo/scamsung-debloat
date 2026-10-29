/* scamsung-debloat — progressive enhancement only.
   Every animation degrades to fully-visible content without JS
   and when prefers-reduced-motion is set. */
(function () {
    "use strict";

    var reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    /* Only animate when the compositor actually pumps frames: double rAF is
       the proof. If it never fires (blocked JS, dead compositor), every
       animation-dependent style stays off and content is fully visible. */
    var motionOK = !reduced && "requestAnimationFrame" in window;
    if (motionOK) {
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                document.documentElement.classList.add("motion");
            });
        });
    }

    /* ---------- reveal on scroll ---------- */
    var revealEls = document.querySelectorAll("[data-reveal]");
    if (revealEls.length) {
        if (reduced || !("IntersectionObserver" in window)) {
            revealEls.forEach(function (el) { el.classList.add("revealed"); });
        } else {
            var ro = new IntersectionObserver(function (entries) {
                entries.forEach(function (e) {
                    if (e.isIntersecting) {
                        e.target.classList.add("revealed");
                        ro.unobserve(e.target);
                    }
                });
            }, { threshold: 0.12, rootMargin: "0px 0px -6% 0px" });
            revealEls.forEach(function (el) { ro.observe(el); });
        }
    }

    /* ---------- run-steps: light up sequentially ---------- */
    var steps = document.querySelectorAll(".steps .step");
    if (steps.length && !reduced && "IntersectionObserver" in window) {
        var so = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (e.isIntersecting) e.target.classList.add("active");
            });
        }, { threshold: 0.6 });
        steps.forEach(function (s) { so.observe(s); });
    } else {
        steps.forEach(function (s) { s.classList.add("active"); });
    }

    /* ---------- preset connector: draw the nesting line ---------- */
    var connector = document.querySelector(".connector path");
    if (connector) {
        var len = connector.getTotalLength();
        connector.style.strokeDasharray = len;
        connector.style.strokeDashoffset = reduced ? 0 : len;
        if (!reduced && "IntersectionObserver" in window) {
            var co = new IntersectionObserver(function (entries) {
                entries.forEach(function (e) {
                    if (e.isIntersecting) {
                        connector.classList.add("drawn");
                        co.disconnect();
                    }
                });
            }, { threshold: 0.4 });
            co.observe(connector.closest(".connector"));
        } else {
            connector.classList.add("drawn");
        }
    }

    /* ---------- phosphor glow follows the pointer on card shells ---------- */
    if (window.matchMedia("(pointer: fine)").matches) {
        document.querySelectorAll(".shell").forEach(function (shell) {
            shell.addEventListener("pointermove", function (ev) {
                var r = shell.getBoundingClientRect();
                shell.style.setProperty("--mx", (ev.clientX - r.left) + "px");
                shell.style.setProperty("--my", (ev.clientY - r.top) + "px");
            });
        });
    }

    /* ---------- interactive demo terminal ---------- */
    var demo = document.getElementById("demo");
    if (!demo) return;

    var out = demo.querySelector(".term-out");
    var cmdEl = demo.querySelector("[data-cmd]");
    var chips = Array.prototype.slice.call(demo.querySelectorAll(".t-chip"));
    var replayBtn = demo.querySelector(".replay");
    var tpl = {};
    chips.forEach(function (chip) {
        var t = document.getElementById("tpl-" + chip.dataset.preset);
        if (t) tpl[chip.dataset.preset] = t.innerHTML;
    });

    var typed = demo.querySelector(".term-bar .dots"); // noop guard, keeps bar stable

    function setPreset(name) {
        chips.forEach(function (c) {
            c.classList.toggle("on", c.dataset.preset === name);
            c.setAttribute("aria-pressed", c.dataset.preset === name ? "true" : "false");
        });
        if (cmdEl) cmdEl.dataset.cmd = "./scamsung-debloat apply " + name;
        out.innerHTML = tpl[name];
    }

    /* preset sessions kept out of .term-out so re-renders can't destroy them */

    var timers = [];
    function later(fn, ms) { timers.push(setTimeout(fn, ms)); }
    function clearTimers() { timers.forEach(clearTimeout); timers = []; }

    function run(animated) {
        clearTimers();
        var lines = Array.prototype.slice.call(out.children);
        if (!animated) {
            lines.forEach(function (l) { l.style.display = ""; });
            if (cmdEl) cmdEl.textContent = cmdEl.dataset.cmd;
            return;
        }
        /* hide everything, then bring the session to life */
        lines.forEach(function (l) { l.style.display = "none"; });
        if (cmdEl) cmdEl.textContent = "";

        var t = 350; /* after CRT power-on */
        if (cmdEl) {
            var full = cmdEl.dataset.cmd;
            for (var i = 0; i < full.length; i++) {
                (function (ch, k) {
                    later(function () { cmdEl.textContent += ch; }, t + k * 38);
                })(full.charAt(i), i);
            }
            t += full.length * 38 + 420;
        }
        lines.forEach(function (line) {
            var kind = line.dataset.speed || "line";
            var d = kind === "fast" ? 45 : kind === "slow" ? 360 : 120;
            later(function () { line.style.display = ""; }, t);
            t += d;
        });
    }

    /* auto-play once when the terminal scrolls into view */
    var played = false;
    function autoplay() {
        if (played) return;
        played = true;
        run(motionOK);
    }
    if (reduced || !("IntersectionObserver" in window)) {
        run(false);
    } else {
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) { if (e.isIntersecting) { autoplay(); io.disconnect(); } });
        }, { threshold: 0.35 });
        io.observe(demo);
        /* static content stays visible until the animation starts */
    }

    chips.forEach(function (chip) {
        chip.addEventListener("click", function () {
            setPreset(chip.dataset.preset);
            played = true;
            run(motionOK);
        });
    });
    if (replayBtn) {
        replayBtn.addEventListener("click", function () { run(motionOK); });
    }
})();
