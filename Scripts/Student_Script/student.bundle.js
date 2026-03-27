/* =========================================================
   MathSphere - Student Bundle
   - WebForms + UpdatePanel safe
   - Works on pages that DO NOT have search/filter/module cards
   ========================================================= */

(function (w, d) {
    "use strict";

    /* -----------------------------
       Core Utilities (MS namespace)
    ----------------------------- */
    const MS = (w.MS = w.MS || {});

    MS.getElByAspNetId = function (endsWithId) {
        if (!endsWithId) return null;
        return d.querySelector('[id$="' + endsWithId + '"]');
    };

    MS.onReady = function (fn) {
        if (typeof fn !== "function") return;
        if (d.readyState === "loading") d.addEventListener("DOMContentLoaded", fn);
        else fn();
    };

    MS.onEndRequest = function (fn) {
        if (typeof fn !== "function") return;
        if (w.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                fn();
            });
        }
    };

    MS.debounce = function (fn, wait) {
        let t = null;
        return function () {
            const ctx = this;
            const args = arguments;
            clearTimeout(t);
            t = setTimeout(function () {
                fn.apply(ctx, args);
            }, wait || 300);
        };
    };

    /* -----------------------------
       Filters: loading overlay
    ----------------------------- */
    MS.showFilterLoading = function () {
        const overlay = d.getElementById("filterLoading");
        const bar = d.getElementById("filterBar");

        if (overlay) {
            overlay.classList.remove("hidden");
            overlay.classList.add("flex");
        }
        if (bar) {
            bar.classList.add("pointer-events-none", "opacity-90");
        }
    };

    /* -----------------------------
       Nav Indicator (sliding underline)
    ----------------------------- */
    function initNavIndicator() {
        const nav = d.getElementById("mainNav");
        const indicator = d.getElementById("navIndicator");
        if (!nav || !indicator) return;

        const links = Array.from(nav.querySelectorAll(".nav-link"));

        const currentKey = (w.location.pathname.split("/").pop() || "")
            .toLowerCase()
            .replace(".aspx", "");

        links.forEach((a) => a.classList.remove("active"));
        const activeLink = links.find(
            (a) => ((a.dataset.match || "").toLowerCase() === currentKey)
        );
        if (activeLink) activeLink.classList.add("active");

        function moveTo(el, animate) {
            const navRect = nav.getBoundingClientRect();
            const elRect = el.getBoundingClientRect();

            if (!animate) indicator.classList.add("!transition-none");
            indicator.style.left = elRect.left - navRect.left + "px";
            indicator.style.width = elRect.width + "px";

            if (!animate) {
                requestAnimationFrame(() =>
                    indicator.classList.remove("!transition-none")
                );
            }
        }

        function setFromActive(animate) {
            const active = nav.querySelector(".nav-link.active");
            if (active) moveTo(active, animate);
            else indicator.style.width = "0px";
        }

        w.addEventListener("load", function () {
            setFromActive(false);
            setTimeout(() => setFromActive(false), 50);
        });

        links.forEach((link) => {
            link.addEventListener("mouseenter", () => moveTo(link, true));
            link.addEventListener("focus", () => moveTo(link, true));
        });

        nav.addEventListener("mouseleave", () => setFromActive(true));
        w.addEventListener("resize", () => setFromActive(false));
    }

    /* -----------------------------
       Browse modules: stagger animation
       - looks for .module-card
       - toggles .module-slide-in
    ----------------------------- */
    function animateModules() {
        const cards = d.querySelectorAll(".module-card");
        if (!cards || cards.length === 0) return;

        cards.forEach((card, i) => {
            card.classList.remove("module-slide-in");
            card.style.animationDelay = i * 45 + "ms";
            void card.offsetWidth;
            card.classList.add("module-slide-in");
        });
    }

    /* -----------------------------
       Search: clear button + debounce postback
       - txtSearch (ASP TextBox endswith)
       - btnClearSearch (plain HTML id)
    ----------------------------- */
    function toggleClearBtn(input) {
        const btn = d.getElementById("btnClearSearch");
        if (!btn || !input) return;

        const hasValue = input.value && input.value.trim().length > 0;
        btn.classList.toggle("opacity-0", !hasValue);
        btn.classList.toggle("pointer-events-none", !hasValue);
    }

    // Expose for inline onclick usage if you already have it
    w.clearSearch = function (aspTextBoxId) {
        const input = MS.getElByAspNetId(aspTextBoxId);
        const btn = d.getElementById("btnClearSearch");
        if (!input) return;

        input.value = "";
        input.focus();

        if (btn) {
            btn.classList.add("opacity-0");
            btn.classList.add("pointer-events-none");
        }

        input.dispatchEvent(new Event("input", { bubbles: true }));
    };

    function wireClearButton() {
        const input = MS.getElByAspNetId("txtSearch");
        const btn = d.getElementById("btnClearSearch");
        if (!input || !btn) return;

        // initial state
        toggleClearBtn(input);

        // update on input
        input.addEventListener("input", function () {
            toggleClearBtn(input);
        });
    }

    function wireDebouncedSearch() {
        const input = MS.getElByAspNetId("txtSearch");
        if (!input) return;

        const path = (w.location.pathname || "").toLowerCase();
        const isBrowseModule = path.indexOf("browsemodule.aspx") >= 0;
        const isLocalOnly = input.getAttribute("data-search-mode") === "local";
        if (isBrowseModule || isLocalOnly) return;

        const handler = MS.debounce(function () {
            if (typeof w.__doPostBack === "function") {
                if (MS.showFilterLoading) MS.showFilterLoading();
                w.__doPostBack(input.name, "");
            }
        }, 350);

        input.addEventListener("input", handler);
    }

    function initSearchUX() {
        wireClearButton();
        wireDebouncedSearch();
    }

    /* -----------------------------
       Avatar preview + cancel (StudentProfile)
       - Preview ONLY profile avatar
       - Enable Save/Cancel buttons when file selected
    ----------------------------- */
    function initAvatarPreview() {
        const fu = MS.getElByAspNetId("fuAvatar");
        const img = MS.getElByAspNetId("imgMainAvatar");
        const hfOriginal = MS.getElByAspNetId("hfAvatarOriginal");
        const btnSave = MS.getElByAspNetId("btnChangeAvatar");
        const btnCancel = MS.getElByAspNetId("btnCancelAvatar");
        const hint = MS.getElByAspNetId("lblAvatarHint");

        if (!fu || !img || !hfOriginal || !btnSave || !btnCancel) return;

        if (fu.dataset.msWired === "1") return;
        fu.dataset.msWired = "1";

        function setButtonsEnabled(enabled) {
            if (enabled) {
                btnSave.classList.remove("opacity-50", "pointer-events-none");
                btnCancel.classList.remove("opacity-50", "pointer-events-none");
                if (hint) hint.classList.remove("hidden");
            } else {
                btnSave.classList.add("opacity-50", "pointer-events-none");
                btnCancel.classList.add("opacity-50", "pointer-events-none");
                if (hint) hint.classList.add("hidden");
            }
        }

        // Always start disabled
        setButtonsEnabled(false);

        fu.addEventListener("change", function () {
            if (!fu.files || fu.files.length === 0) {
                setButtonsEnabled(false);
                return;
            }

            const file = fu.files[0];

            const okTypes = ["image/png", "image/jpeg", "image/jpg"];
            if (okTypes.indexOf(file.type) === -1) {
                alert("Only PNG / JPG / JPEG files are allowed.");
                fu.value = "";
                setButtonsEnabled(false);
                return;
            }

            if (file.size > 2 * 1024 * 1024) {
                alert("Image too large (max 2MB).");
                fu.value = "";
                setButtonsEnabled(false);
                return;
            }

            const reader = new FileReader();
            reader.onload = function (e) {
                img.src = e.target.result;      // preview ONLY profile
                setButtonsEnabled(true);
            };
            reader.readAsDataURL(file);
        });

        MS.cancelAvatarPreview = function () {
            const original = hfOriginal.value || "";
            if (original) img.src = original;  // revert to saved or default

            fu.value = "";                     // clear selection, so save won't upload
            setButtonsEnabled(false);
            return false;                      // prevent postback
        };
    }

    /* -----------------------------
       Init
    ----------------------------- */
    MS.onReady(initNavIndicator);
    MS.onReady(animateModules);
    MS.onReady(initSearchUX);
    MS.onReady(initAvatarPreview);

    // UpdatePanel re-init
    MS.onEndRequest(animateModules);
    MS.onEndRequest(initSearchUX);
    MS.onEndRequest(initAvatarPreview);
})(window, document);
