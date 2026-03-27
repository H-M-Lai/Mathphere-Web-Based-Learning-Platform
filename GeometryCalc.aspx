<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="GeometryCalc.aspx.cs" Inherits="MathSphere.GeometryCalc" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Geometry Calculator
</asp:Content>

<asp:Content ID="HeadBlock" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    input[type=number]::-webkit-inner-spin-button,
    input[type=number]::-webkit-outer-spin-button { -webkit-appearance:none; }
    input[type=number] { -moz-appearance:textfield; }

    .calc-input { transition: border-color .2s, box-shadow .2s; }
    .calc-input:focus { outline:none; border-color:#2563eb; box-shadow:0 0 0 3px rgba(37,99,235,.12); }

    /* Answer panel */
    .answer-panel {
        background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
        border-radius: 1.25rem;
        padding: 1.25rem 1.5rem;
        display: none;
        position: relative;
        overflow: hidden;
    }
    .answer-panel::before {
        content: '';
        position: absolute;
        top: -20px; right: -20px;
        width: 80px; height: 80px;
        background: rgba(249,208,6,0.15);
        border-radius: 50%;
    }
    .answer-panel.show { display: block; }

    @keyframes answerIn {
        from { opacity:0; transform:translateY(8px) scale(.97); }
        to   { opacity:1; transform:translateY(0)   scale(1); }
    }
    .answer-panel.show { animation: answerIn .25s cubic-bezier(.34,1.2,.64,1) forwards; }

    .answer-label {
        font-size: 10px;
        font-weight: 900;
        letter-spacing: .18em;
        text-transform: uppercase;
        color: rgba(249,208,6,0.8);
        margin-bottom: .35rem;
    }
    .answer-value {
        font-size: 2rem;
        font-weight: 900;
        color: #ffffff;
        line-height: 1.1;
        font-family: 'Courier New', monospace;
    }
    .answer-unit {
        font-size: .875rem;
        font-weight: 700;
        color: rgba(255,255,255,0.55);
        margin-left: .35rem;
    }
    .answer-formula {
        font-size: .75rem;
        font-weight: 600;
        color: rgba(255,255,255,0.45);
        margin-top: .4rem;
        font-family: 'Courier New', monospace;
    }
    /* Multi-row answer (circle has 3 values) */
    .answer-row {
        display: flex;
        align-items: baseline;
        gap: .5rem;
        padding: .3rem 0;
        border-bottom: 1px solid rgba(255,255,255,.08);
    }
    .answer-row:last-child { border-bottom: none; }
    .answer-row-label {
        font-size: .7rem;
        font-weight: 800;
        color: rgba(249,208,6,.7);
        text-transform: uppercase;
        letter-spacing: .12em;
        min-width: 6.5rem;
    }
    .answer-row-val {
        font-size: 1.1rem;
        font-weight: 900;
        color: #fff;
        font-family: 'Courier New', monospace;
    }
    .answer-row-unit {
        font-size: .7rem;
        font-weight: 600;
        color: rgba(255,255,255,.4);
    }

    /* Error state */
    .answer-error {
        background: linear-gradient(135deg, #dc2626 0%, #ef4444 100%);
    }
    .answer-error .answer-label { color: rgba(255,255,255,.7); }

    .tool-card { transition: transform .25s, box-shadow .25s; }
    .tool-card:hover { transform:translateY(-4px); box-shadow:0 28px 64px rgba(0,0,0,.09); }
</style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">
    <%-- Page Header --%>
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-yellow-200 bg-primary/15 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-math-dark-blue">
                    <span class="material-symbols-outlined text-sm fill-icon">calculate</span>
                    Math playground
                </div>
                <h1 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Geometry Calculator</h1>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Triangles, circles, and the Pythagorean theorem - solved instantly with clear visual feedback.</p>
            </div>
            <a href="GraphTool.aspx"
               class="inline-flex items-center gap-2 px-5 py-3 rounded-2xl bg-white border border-gray-200 text-gray-600 font-black text-sm uppercase tracking-widest self-start md:self-auto hover:border-math-green/50 hover:text-math-green transition-all shadow-sm">
                <span class="material-symbols-outlined text-base fill-icon">show_chart</span>
                Graph Explorer
            </a>
        </div>
    </section>

    <%-- Three Calculator Cards --%>
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">

        <%-- Triangle Area --%>
        <div class="surface-card p-7 tool-card flex flex-col">
            <div class="flex items-start justify-between mb-5">
                <div class="w-14 h-14 rounded-2xl bg-math-blue/10 border border-math-blue/15 flex items-center justify-center">
                    <span class="material-symbols-outlined text-math-blue text-3xl fill-icon">change_history</span>
                </div>
                <code class="text-[11px] px-2.5 py-1.5 rounded-xl bg-math-blue/10 border border-math-blue/15 text-math-blue font-bold">½ × b × h</code>
            </div>
            <h2 class="text-xl font-black text-math-dark-blue mb-5">Triangle Area</h2>

            <div class="space-y-4 flex-1">
                <div>
                    <label class="block text-[11px] font-black uppercase tracking-[0.18em] text-gray-400 mb-1.5">Base</label>
                    <div class="relative">
                        <input id="triBase" type="number" step="any" min="0" placeholder="e.g. 10"
                               class="calc-input w-full px-4 py-3 rounded-xl border-2 border-gray-200 bg-white font-bold text-math-dark-blue placeholder-gray-300 text-base" />
                        <span class="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-300 uppercase">units</span>
                    </div>
                </div>
                <div>
                    <label class="block text-[11px] font-black uppercase tracking-[0.18em] text-gray-400 mb-1.5">Height</label>
                    <div class="relative">
                        <input id="triHeight" type="number" step="any" min="0" placeholder="e.g. 6"
                               class="calc-input w-full px-4 py-3 rounded-xl border-2 border-gray-200 bg-white font-bold text-math-dark-blue placeholder-gray-300 text-base" />
                        <span class="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-300 uppercase">units</span>
                    </div>
                </div>
            </div>

            <div class="flex gap-2 mt-5 mb-4">
                <%-- type="button" prevents form postback --%>
                <button type="button" onclick="calcTriangle()"
                        class="flex-1 py-3 rounded-xl bg-math-blue text-white font-black text-sm uppercase tracking-widest shadow-lg shadow-math-blue/20 hover:bg-math-dark-blue transition-all active:scale-[.98]">
                    Calculate
                </button>
                <button type="button" onclick="resetCard('triBase','triHeight','triAnswer')" title="Reset"
                        class="px-4 py-3 rounded-xl bg-gray-100 border-2 border-gray-200 text-gray-400 hover:bg-gray-200 transition-all">
                    <span class="material-symbols-outlined text-base">refresh</span>
                </button>
            </div>

            <%-- Answer Display --%>
            <div id="triAnswer" class="answer-panel">
                <p class="answer-label">Answer</p>
                <div class="flex items-baseline gap-1">
                    <span class="answer-value" id="triAnswerVal">—</span>
                    <span class="answer-unit" id="triAnswerUnit">units²</span>
                </div>
                <p class="answer-formula" id="triAnswerFormula"></p>
            </div>
        </div>

        <%-- Circle Calculator --%>
        <div class="surface-card p-7 tool-card flex flex-col">
            <div class="flex items-start justify-between mb-5">
                <div class="w-14 h-14 rounded-2xl bg-math-green/10 border border-math-green/15 flex items-center justify-center">
                    <span class="material-symbols-outlined text-math-green text-3xl fill-icon">radio_button_unchecked</span>
                </div>
                <code class="text-[11px] px-2.5 py-1.5 rounded-xl bg-math-green/10 border border-math-green/15 text-math-green font-bold">pr², 2pr</code>
            </div>
            <h2 class="text-xl font-black text-math-dark-blue mb-5">Circle</h2>

            <div class="space-y-4 flex-1">
                <div>
                    <label class="block text-[11px] font-black uppercase tracking-[0.18em] text-gray-400 mb-1.5">Radius (r)</label>
                    <div class="relative">
                        <input id="cirR" type="number" step="any" min="0" placeholder="e.g. 5"
                               class="calc-input w-full px-4 py-3 rounded-xl border-2 border-gray-200 bg-white font-bold text-math-dark-blue placeholder-gray-300 text-base" />
                        <span class="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-300 uppercase">units</span>
                    </div>
                </div>
                <div class="h-[60px]"></div>
            </div>

            <div class="flex gap-2 mt-5 mb-4">
                <%-- type="button" prevents form postback --%>
                <button type="button" onclick="calcCircle()"
                        class="flex-1 py-3 rounded-xl bg-math-green text-white font-black text-sm uppercase tracking-widest shadow-lg shadow-math-green/20 hover:bg-green-600 transition-all active:scale-[.98]">
                    Calculate
                </button>
                <button type="button" onclick="resetCard('cirR',null,'cirAnswer')" title="Reset"
                        class="px-4 py-3 rounded-xl bg-gray-100 border-2 border-gray-200 text-gray-400 hover:bg-gray-200 transition-all">
                    <span class="material-symbols-outlined text-base">refresh</span>
                </button>
            </div>

            <%-- Answer Display — multi-row for circle --%>
            <div id="cirAnswer" class="answer-panel">
                <p class="answer-label">Answer</p>
                <div id="cirAnswerRows"></div>
            </div>
        </div>

        <%-- Pythagorean Theorem --%>
        <div class="surface-card p-7 tool-card flex flex-col">
            <div class="flex items-start justify-between mb-5">
                <div class="w-14 h-14 rounded-2xl bg-primary/25 border border-primary/40 flex items-center justify-center">
                    <span class="material-symbols-outlined text-math-dark-blue text-3xl fill-icon">square_foot</span>
                </div>
                <code class="text-[11px] px-2.5 py-1.5 rounded-xl bg-primary/20 border border-primary/30 text-math-dark-blue font-bold">a² + b² = c²</code>
            </div>
            <h2 class="text-xl font-black text-math-dark-blue mb-2">Pythagorean Theorem</h2>
            <p class="text-xs font-semibold text-gray-400 mb-5">Set <strong class="text-math-dark-blue">one</strong> value to 0 to solve for it.</p>

            <div class="grid grid-cols-3 gap-3 flex-1">
                <div>
                    <label class="block text-[11px] font-black uppercase tracking-[0.15em] text-gray-400 mb-1.5 text-center">a</label>
                    <input id="pyA" type="number" step="any" min="0" value="0"
                           class="calc-input w-full px-2 py-3 rounded-xl border-2 border-gray-200 bg-white font-bold text-math-dark-blue text-base text-center" />
                </div>
                <div>
                    <label class="block text-[11px] font-black uppercase tracking-[0.15em] text-gray-400 mb-1.5 text-center">b</label>
                    <input id="pyB" type="number" step="any" min="0" value="0"
                           class="calc-input w-full px-2 py-3 rounded-xl border-2 border-gray-200 bg-white font-bold text-math-dark-blue text-base text-center" />
                </div>
                <div>
                    <label class="block text-[11px] font-black uppercase tracking-[0.15em] text-math-blue mb-1.5 text-center">c (hyp)</label>
                    <input id="pyC" type="number" step="any" min="0" value="0"
                           class="calc-input w-full px-2 py-3 rounded-xl border-2 border-math-blue/25 bg-math-blue/5 font-bold text-math-dark-blue text-base text-center" />
                </div>
            </div>

            <div class="flex gap-2 mt-5 mb-4">
                <%-- type="button" prevents form postback --%>
                <button type="button" onclick="calcPythagorean()"
                        class="flex-1 py-3 rounded-xl bg-math-dark-blue text-primary font-black text-sm uppercase tracking-widest shadow-lg shadow-math-dark-blue/20 hover:bg-math-blue hover:text-white transition-all active:scale-[.98]">
                    Find Missing
                </button>
                <button type="button" onclick="resetPythagorean()" title="Reset"
                        class="px-4 py-3 rounded-xl bg-gray-100 border-2 border-gray-200 text-gray-400 hover:bg-gray-200 transition-all">
                    <span class="material-symbols-outlined text-base">refresh</span>
                </button>
            </div>

            <%-- Answer Display --%>
            <div id="pyAnswer" class="answer-panel">
                <p class="answer-label">Answer</p>
                <div class="flex items-baseline gap-1">
                    <span class="answer-value" id="pyAnswerVal">—</span>
                    <span class="answer-unit">units</span>
                </div>
                <p class="answer-formula" id="pyAnswerFormula"></p>
            </div>
        </div>

    </div>

    <%-- Formula Reference --%>
    <div class="surface-card p-6">
        <div class="flex items-center gap-2 mb-4">
            <span class="material-symbols-outlined text-math-blue text-xl fill-icon">menu_book</span>
            <h3 class="text-sm font-black uppercase tracking-widest text-math-dark-blue">Formula Reference</h3>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="p-3.5 rounded-2xl bg-math-blue/5 border border-math-blue/10">
                <p class="text-[10px] font-black text-math-blue uppercase tracking-widest mb-1.5">Triangle Area</p>
                <code class="font-bold text-math-dark-blue text-sm">A = ½ × b × h</code>
            </div>
            <div class="p-3.5 rounded-2xl bg-math-green/5 border border-math-green/10">
                <p class="text-[10px] font-black text-math-green uppercase tracking-widest mb-1.5">Circle Area</p>
                <code class="font-bold text-math-dark-blue text-sm">A = p × r²</code>
            </div>
            <div class="p-3.5 rounded-2xl bg-math-green/5 border border-math-green/10">
                <p class="text-[10px] font-black text-math-green uppercase tracking-widest mb-1.5">Circumference</p>
                <code class="font-bold text-math-dark-blue text-sm">C = 2 × p × r</code>
            </div>
            <div class="p-3.5 rounded-2xl bg-primary/10 border border-primary/20">
                <p class="text-[10px] font-black text-math-dark-blue uppercase tracking-widest mb-1.5">Pythagorean</p>
                <code class="font-bold text-math-dark-blue text-sm">a² + b² = c²</code>
            </div>
        </div>
    </div>

    <script>
        (function () {
            'use strict';

            /* Get raw number from input — returns NaN if blank/invalid */
            function getNum(id) {
                var v = document.getElementById(id).value.trim();
                if (v === '') return NaN;
                var n = parseFloat(v);
                return isNaN(n) ? NaN : n;
            }

            /* Format number: up to 4 dp, strip trailing zeros */
            function fmt(x) {
                return String(parseFloat(x.toFixed(4)));
            }

            /* Show the answer panel */
            function showAnswer(panelId, html, isError) {
                var el = document.getElementById(panelId);
                el.classList.remove('show', 'answer-error');
                void el.offsetWidth;
                el.innerHTML = html;
                if (isError) el.classList.add('answer-error');
                el.classList.add('show');
            }

            function showError(panelId, msg) {
                showAnswer(panelId,
                    '<p class="answer-label">Error</p>' +
                    '<p style="color:#fff;font-weight:900;font-size:.9rem;">&#9888; ' + msg + '</p>',
                    true);
            }

            function showResult(panelId, label, value, unit, formula) {
                showAnswer(panelId,
                    '<p class="answer-label">' + label + '</p>' +
                    '<div style="display:flex;align-items:baseline;gap:.4rem;">' +
                    '<span class="answer-value">' + value + '</span>' +
                    '<span class="answer-unit">' + unit + '</span>' +
                    '</div>' +
                    '<p class="answer-formula">' + formula + '</p>');
            }

            /* -- Triangle -- */
            window.calcTriangle = function () {
                var b = getNum('triBase');
                var h = getNum('triHeight');
                if (isNaN(b) || isNaN(h)) { showError('triAnswer', 'Enter both Base and Height.'); return; }
                if (b <= 0 || h <= 0) { showError('triAnswer', 'Both values must be greater than 0.'); return; }
                var area = 0.5 * b * h;
                showResult('triAnswer', 'Area', fmt(area), 'units&#178;',
                    '&#189; &times; ' + fmt(b) + ' &times; ' + fmt(h) + ' = ' + fmt(area));
            };

            window.resetCard = function (id1, id2, panelId) {
                if (id1) document.getElementById(id1).value = '';
                if (id2) document.getElementById(id2).value = '';
                document.getElementById(panelId).classList.remove('show');
            };

            /* -- Circle -- */
            window.calcCircle = function () {
                var r = getNum('cirR');
                if (isNaN(r)) { showError('cirAnswer', 'Enter a Radius value.'); return; }
                if (r <= 0) { showError('cirAnswer', 'Radius must be greater than 0.'); return; }
                var d = 2 * r;
                var circ = 2 * Math.PI * r;
                var area = Math.PI * r * r;
                function row(lbl, v, u) {
                    return '<div class="answer-row">' +
                        '<span class="answer-row-label">' + lbl + '</span>' +
                        '<span class="answer-row-val">' + fmt(v) + '</span>' +
                        '<span class="answer-row-unit">' + u + '</span>' +
                        '</div>';
                }
                showAnswer('cirAnswer',
                    '<p class="answer-label">Results</p>' +
                    row('Diameter', d, 'units') +
                    row('Circumference', circ, 'units') +
                    row('Area', area, 'units&#178;'));
            };

            /* -- Pythagorean --
               Leave the unknown field BLANK or type 0. Exactly one must be blank/zero. */
            window.calcPythagorean = function () {
                var vA = document.getElementById('pyA').value.trim();
                var vB = document.getElementById('pyB').value.trim();
                var vC = document.getElementById('pyC').value.trim();

                var aBlank = (vA === '' || vA === '0');
                var bBlank = (vB === '' || vB === '0');
                var cBlank = (vC === '' || vC === '0');
                var blanks = (aBlank ? 1 : 0) + (bBlank ? 1 : 0) + (cBlank ? 1 : 0);

                if (blanks === 0) { showError('pyAnswer', 'Leave one field blank or 0 to solve for it.'); return; }
                if (blanks > 1) { showError('pyAnswer', 'Fill in two sides and leave one blank or 0.'); return; }

                var A = parseFloat(vA);
                var B = parseFloat(vB);
                var C = parseFloat(vC);
                var result, label, formula;

                if (cBlank) {
                    if (isNaN(A) || A <= 0 || isNaN(B) || B <= 0) { showError('pyAnswer', 'a and b must be positive numbers.'); return; }
                    result = Math.sqrt(A * A + B * B);
                    label = 'Hypotenuse c';
                    formula = '&#8730;(' + fmt(A) + '&#178; + ' + fmt(B) + '&#178;) = ' + fmt(result);
                    document.getElementById('pyC').value = fmt(result);
                } else if (aBlank) {
                    if (isNaN(B) || B <= 0 || isNaN(C) || C <= 0) { showError('pyAnswer', 'b and c must be positive numbers.'); return; }
                    if (C <= B) { showError('pyAnswer', 'Hypotenuse c must be larger than b.'); return; }
                    result = Math.sqrt(C * C - B * B);
                    label = 'Side a';
                    formula = '&#8730;(' + fmt(C) + '&#178; &minus; ' + fmt(B) + '&#178;) = ' + fmt(result);
                    document.getElementById('pyA').value = fmt(result);
                } else {
                    if (isNaN(A) || A <= 0 || isNaN(C) || C <= 0) { showError('pyAnswer', 'a and c must be positive numbers.'); return; }
                    if (C <= A) { showError('pyAnswer', 'Hypotenuse c must be larger than a.'); return; }
                    result = Math.sqrt(C * C - A * A);
                    label = 'Side b';
                    formula = '&#8730;(' + fmt(C) + '&#178; &minus; ' + fmt(A) + '&#178;) = ' + fmt(result);
                    document.getElementById('pyB').value = fmt(result);
                }

                showResult('pyAnswer', label, fmt(result), 'units', formula);
            };

            window.resetPythagorean = function () {
                ['pyA', 'pyB', 'pyC'].forEach(function (id) {
                    document.getElementById(id).value = '';
                });
                document.getElementById('pyAnswer').classList.remove('show');
            };

            /* -- Enter key shortcut -- */
            document.addEventListener('keydown', function (e) {
                if (e.key !== 'Enter') return;
                var id = document.activeElement && document.activeElement.id;
                if (id === 'triBase' || id === 'triHeight') window.calcTriangle();
                else if (id === 'cirR') window.calcCircle();
                else if (id === 'pyA' || id === 'pyB' || id === 'pyC') window.calcPythagorean();
            });

        })();
    </script>

</asp:Content>

