<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="GraphTool.aspx.cs" Inherits="MathSphere.GraphTool" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Graph Explorer
</asp:Content>

<asp:Content ID="HeadBlock" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    #graphCanvas {
        cursor: crosshair;
        border-radius: 1.25rem;
        width: 100%;
        max-width: 680px;
        display: block;
    }
    input[type=range] {
        -webkit-appearance: none;
        width: 100%;
        height: 6px;
        border-radius: 99px;
        background: #e5e7eb;
        outline: none;
        cursor: pointer;
        transition: background .2s;
    }
    input[type=range]::-webkit-slider-thumb {
        -webkit-appearance: none;
        width: 18px; height: 18px;
        border-radius: 50%;
        background: #1e3a8a;
        border: 3px solid #f9d006;
        cursor: pointer;
        transition: transform .15s;
    }
    input[type=range]::-webkit-slider-thumb:hover { transform: scale(1.2); }
    input[type=range]::-moz-range-thumb {
        width: 18px; height: 18px;
        border-radius: 50%;
        background: #1e3a8a;
        border: 3px solid #f9d006;
        cursor: pointer;
    }
    .coeff-val {
        font-variant-numeric: tabular-nums;
        min-width: 3.2rem;
        text-align: right;
    }
    @keyframes fadeUp {
        from { opacity:0; transform:translateY(8px); }
        to   { opacity:1; transform:translateY(0); }
    }
    .fade-up { animation: fadeUp .3s ease forwards; }
</style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">
    <%-- Page Header --%>
    <section class="relative mb-8 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-yellow-200 bg-primary/15 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-math-dark-blue">
                    <span class="material-symbols-outlined text-sm fill-icon">show_chart</span>
                    Math playground
                </div>
                <h1 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Graph Explorer</h1>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Visualise linear and quadratic functions, inspect coordinates live, and explore how coefficients change the graph.</p>
            </div>
            <a href="GeometryCalc.aspx"
               class="inline-flex items-center gap-2 px-5 py-3 rounded-2xl bg-white border border-gray-200 text-gray-600 font-black text-sm uppercase tracking-widest self-start md:self-auto hover:border-math-blue/40 hover:text-math-blue transition-all shadow-sm">
                <span class="material-symbols-outlined text-base fill-icon">calculate</span>
                Geometry Calculator
            </a>
        </div>
    </section>

    <div class="grid grid-cols-1 xl:grid-cols-[1fr_320px] gap-6">

        <%-- Graph Canvas Panel --%>
        <div class="surface-card p-6 flex flex-col gap-4">

            <%-- Toolbar: Mode + Export --%>
            <div class="flex items-center justify-between gap-4 flex-wrap">
                <div class="flex gap-2">
                    <button type="button" id="btnLinear" onclick="setMode('linear')"
                            class="mode-btn px-4 py-2 rounded-xl font-black text-xs uppercase tracking-widest
                                   border-2 transition-all">
                        Linear
                    </button>
                    <button type="button" id="btnQuadratic" onclick="setMode('quadratic')"
                            class="mode-btn px-4 py-2 rounded-xl font-black text-xs uppercase tracking-widest
                                   border-2 transition-all">
                        Quadratic
                    </button>
                </div>

                <div class="flex gap-2">
                    <button type="button" onclick="resetGraph()"
                            class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-gray-100 border-2
                                   border-gray-200 text-gray-500 font-black text-xs uppercase tracking-widest
                                   hover:bg-gray-200 transition-all">
                        <span class="material-symbols-outlined text-sm">refresh</span>
                        Reset
                    </button>
                    <button type="button" onclick="exportPng()"
                            class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-math-dark-blue
                                   text-primary font-black text-xs uppercase tracking-widest
                                   hover:bg-math-blue transition-all shadow-md">
                        <span class="material-symbols-outlined text-sm fill-icon">download</span>
                        Export PNG
                    </button>
                </div>
            </div>

            <%-- Canvas --%>
            <div class="relative flex justify-center">
                <canvas id="graphCanvas" width="680" height="440"
                        class="border border-gray-200 bg-white shadow-inner"></canvas>
            </div>

            <%-- Hover readout --%>
            <div class="flex items-center gap-3 px-4 py-2.5 rounded-2xl bg-gray-50 border border-gray-200">
                <span class="material-symbols-outlined text-math-blue text-sm fill-icon">my_location</span>
                <span id="hoverReadout" class="text-sm font-bold text-gray-500 font-mono">
                    Hover over the graph to read coordinates
                </span>
            </div>

            <%-- Equation display --%>
            <div class="flex items-center gap-3 px-4 py-3 rounded-2xl bg-math-blue/5 border border-math-blue/15">
                <span class="material-symbols-outlined text-math-blue fill-icon">function</span>
                <span id="eqDisplay"
                      class="font-black text-math-dark-blue text-base tracking-wide fade-up"
                      style="font-family:'Courier New',monospace">
                    y = x²
                </span>
            </div>
        </div>

        <%-- Controls Sidebar --%>
        <div class="surface-card p-6 space-y-6">

            <div>
                <p class="text-[11px] font-black uppercase tracking-[0.22em] text-gray-400 mb-4">
                    Coefficients
                </p>

                <%-- a --%>
                <div class="mb-5">
                    <div class="flex items-center justify-between mb-2">
                        <label class="font-black text-sm text-math-dark-blue">
                            a <span id="aLabel" class="text-gray-400 font-semibold text-xs">(leading)</span>
                        </label>
                        <span id="aVal" class="coeff-val font-black text-math-blue text-sm">1.0</span>
                    </div>
                    <input type="range" id="sliderA" min="-5" max="5" step="0.1" value="1"
                           oninput="updateGraph()" />
                    <div class="flex justify-between text-[10px] text-gray-400 font-semibold mt-1">
                        <span>-5</span><span>0</span><span>+5</span>
                    </div>
                </div>

                <%-- b --%>
                <div class="mb-5">
                    <div class="flex items-center justify-between mb-2">
                        <label class="font-black text-sm text-math-dark-blue">
                            b <span id="bLabel" class="text-gray-400 font-semibold text-xs">(linear)</span>
                        </label>
                        <span id="bVal" class="coeff-val font-black text-math-blue text-sm">0.0</span>
                    </div>
                    <input type="range" id="sliderB" min="-10" max="10" step="0.1" value="0"
                           oninput="updateGraph()" />
                    <div class="flex justify-between text-[10px] text-gray-400 font-semibold mt-1">
                        <span>-10</span><span>0</span><span>+10</span>
                    </div>
                </div>

                <%-- c (quadratic only) --%>
                <div id="cRow" class="mb-5">
                    <div class="flex items-center justify-between mb-2">
                        <label class="font-black text-sm text-math-dark-blue">
                            c <span class="text-gray-400 font-semibold text-xs">(constant)</span>
                        </label>
                        <span id="cVal" class="coeff-val font-black text-math-blue text-sm">0.0</span>
                    </div>
                    <input type="range" id="sliderC" min="-10" max="10" step="0.1" value="0"
                           oninput="updateGraph()" />
                    <div class="flex justify-between text-[10px] text-gray-400 font-semibold mt-1">
                        <span>-10</span><span>0</span><span>+10</span>
                    </div>
                </div>
            </div>

            <%-- Zoom --%>
            <div>
                <p class="text-[11px] font-black uppercase tracking-[0.22em] text-gray-400 mb-3">Zoom</p>
                <div class="flex gap-2">
                    <button type="button" onclick="zoom(1.2)"
                            class="flex-1 py-2 rounded-xl bg-white border-2 border-gray-200 font-black text-sm
                                   text-math-dark-blue hover:border-math-blue/40 hover:bg-math-blue/5 transition-all">
                        <span class="material-symbols-outlined text-base align-middle">zoom_in</span> In
                    </button>
                    <button type="button" onclick="zoom(0.83)"
                            class="flex-1 py-2 rounded-xl bg-white border-2 border-gray-200 font-black text-sm
                                   text-math-dark-blue hover:border-math-blue/40 hover:bg-math-blue/5 transition-all">
                        <span class="material-symbols-outlined text-base align-middle">zoom_out</span> Out
                    </button>
                </div>
                <p class="text-[10px] font-semibold text-gray-400 mt-2 text-center">
                    or scroll on the graph
                </p>
            </div>

            <%-- Key facts (dynamic) --%>
            <div>
                <p class="text-[11px] font-black uppercase tracking-[0.22em] text-gray-400 mb-3">Key Facts</p>
                <div id="keyFacts" class="space-y-2 text-sm"></div>
            </div>
        </div>

    </div>

    <script>
        (function () {
            'use strict';

            var canvas = document.getElementById('graphCanvas');
            var ctx = canvas.getContext('2d');
            var ppu = 40;
            var mode = 'quadratic';

            function setMode(m) {
                mode = m;
                document.getElementById('cRow').style.display = (m === 'quadratic') ? '' : 'none';
                document.getElementById('aLabel').textContent = m === 'linear' ? '(slope)' : '(leading)';
                document.getElementById('bLabel').textContent = m === 'linear' ? '(intercept)' : '(linear)';
                updateModeButtons();
                draw();
            }
            window.setMode = setMode;

            function updateModeButtons() {
                var linBtn = document.getElementById('btnLinear');
                var quadBtn = document.getElementById('btnQuadratic');
                var active = 'bg-math-dark-blue text-primary border-math-dark-blue shadow-md';
                var inactive = 'bg-white text-gray-500 border-gray-200 hover:border-math-blue/40 hover:text-math-blue';
                linBtn.className = 'mode-btn px-4 py-2 rounded-xl font-black text-xs uppercase tracking-widest border-2 transition-all ' + (mode === 'linear' ? active : inactive);
                quadBtn.className = 'mode-btn px-4 py-2 rounded-xl font-black text-xs uppercase tracking-widest border-2 transition-all ' + (mode === 'quadratic' ? active : inactive);
            }

            function A() { return parseFloat(document.getElementById('sliderA').value); }
            function B() { return parseFloat(document.getElementById('sliderB').value); }
            function C() { return parseFloat(document.getElementById('sliderC').value); }
            function f(x) {
                return mode === 'linear' ? A() * x + B() : A() * x * x + B() * x + C();
            }

            function toScreen(x, y) { return { sx: canvas.width / 2 + x * ppu, sy: canvas.height / 2 - y * ppu }; }
            function toMath(px, py) { return { x: (px - canvas.width / 2) / ppu, y: (canvas.height / 2 - py) / ppu }; }

            function draw() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                drawGrid();
                drawCurve();
                updateUI();
            }

            function drawGrid() {
                ctx.save();
                var step = ppu;
                ctx.strokeStyle = '#f0f0f0'; ctx.lineWidth = 1;
                for (var x = canvas.width / 2 % step; x <= canvas.width; x += step) {
                    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke();
                }
                for (var y = canvas.height / 2 % step; y <= canvas.height; y += step) {
                    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke();
                }
                ctx.strokeStyle = '#d1d5db'; ctx.lineWidth = 1.5;
                ctx.beginPath(); ctx.moveTo(canvas.width / 2, 0); ctx.lineTo(canvas.width / 2, canvas.height); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(0, canvas.height / 2); ctx.lineTo(canvas.width, canvas.height / 2); ctx.stroke();
                ctx.fillStyle = '#9ca3af'; ctx.font = 'bold 10px Space Grotesk, sans-serif';
                var range = Math.ceil((canvas.width / 2) / ppu);
                for (var i = -range; i <= range; i++) {
                    if (i === 0) continue;
                    var sx = canvas.width / 2 + i * ppu, sy = canvas.height / 2;
                    ctx.beginPath(); ctx.moveTo(sx, sy - 3); ctx.lineTo(sx, sy + 3); ctx.stroke();
                    ctx.fillText(i, sx - 4, sy + 14);
                }
                for (var j = -(Math.ceil((canvas.height / 2) / ppu)); j <= Math.ceil((canvas.height / 2) / ppu); j++) {
                    if (j === 0) continue;
                    var sx2 = canvas.width / 2, sy2 = canvas.height / 2 - j * ppu;
                    ctx.beginPath(); ctx.moveTo(sx2 - 3, sy2); ctx.lineTo(sx2 + 3, sy2); ctx.stroke();
                    ctx.fillText(j, sx2 + 6, sy2 + 4);
                }
                ctx.restore();
            }

            function drawCurve() {
                ctx.save();
                ctx.strokeStyle = '#2563eb'; ctx.lineWidth = 2.5; ctx.lineJoin = 'round';
                ctx.shadowColor = 'rgba(37,99,235,.18)'; ctx.shadowBlur = 6;
                ctx.beginPath();
                var first = true, prevY = null;
                for (var px = 0; px <= canvas.width; px++) {
                    var mx = toMath(px, 0).x;
                    var y = f(mx);
                    var s = toScreen(mx, y);
                    if (Math.abs(s.sy) > canvas.height * 3) { first = true; prevY = null; continue; }
                    if (prevY !== null && Math.abs(s.sy - prevY) > canvas.height * 2) { first = true; }
                    if (first) { ctx.moveTo(s.sx, s.sy); first = false; }
                    else { ctx.lineTo(s.sx, s.sy); }
                    prevY = s.sy;
                }
                ctx.stroke();
                var yInt = toScreen(0, f(0));
                if (yInt.sy >= 0 && yInt.sy <= canvas.height) {
                    ctx.beginPath();
                    ctx.arc(yInt.sx, yInt.sy, 5, 0, Math.PI * 2);
                    ctx.fillStyle = '#f9d006'; ctx.strokeStyle = '#1e3a8a'; ctx.lineWidth = 2;
                    ctx.fill(); ctx.stroke();
                }
                ctx.restore();
            }

            function updateUI() {
                var a = A(), b = B(), c = C();
                var eq = '';
                function coeff(v, varStr, first) {
                    if (v === 0) return '';
                    var abs = Math.abs(v), s = '';
                    if (!first) s = v < 0 ? ' - ' : ' + ';
                    else s = v < 0 ? '-' : '';
                    return s + (abs === 1 ? '' : abs.toFixed(1)) + varStr;
                }
                if (mode === 'linear') {
                    eq = 'y = ';
                    var pa = coeff(a, 'x', true), pb = coeff(b, '', false);
                    eq += (pa || '') + (pb || '');
                    if (!pa && !pb) eq += '0';
                } else {
                    eq = 'y = ';
                    var qa = coeff(a, 'x²', true), qb = coeff(b, 'x', !qa), qc = coeff(c, '', !qa && !qb);
                    eq += (qa || '') + (qb || '') + (qc || '');
                    if (!qa && !qb && !qc) eq += '0';
                }
                document.getElementById('eqDisplay').textContent = eq;
                document.getElementById('aVal').textContent = a.toFixed(1);
                document.getElementById('bVal').textContent = b.toFixed(1);
                document.getElementById('cVal').textContent = c.toFixed(1);

                var facts = '';
                var yI = f(0);
                facts += '<div class="flex justify-between px-3 py-2 rounded-xl bg-gray-50 border border-gray-100"><span class="text-gray-500">y-intercept</span><span class="font-black text-math-dark-blue">' + yI.toFixed(3) + '</span></div>';
                if (mode === 'linear') {
                    if (a !== 0) {
                        facts += '<div class="flex justify-between px-3 py-2 rounded-xl bg-gray-50 border border-gray-100"><span class="text-gray-500">x-intercept</span><span class="font-black text-math-dark-blue">' + (-b / a).toFixed(3) + '</span></div>';
                    }
                    facts += '<div class="flex justify-between px-3 py-2 rounded-xl bg-gray-50 border border-gray-100"><span class="text-gray-500">Slope</span><span class="font-black text-math-dark-blue">' + a.toFixed(3) + '</span></div>';
                } else if (a !== 0) {
                    var vx = -b / (2 * a), vy = f(vx);
                    facts += '<div class="flex justify-between px-3 py-2 rounded-xl bg-gray-50 border border-gray-100"><span class="text-gray-500">Vertex</span><span class="font-black text-math-dark-blue">(' + vx.toFixed(2) + ', ' + vy.toFixed(2) + ')</span></div>';
                    var disc = b * b - 4 * a * c;
                    facts += '<div class="flex justify-between px-3 py-2 rounded-xl bg-gray-50 border border-gray-100"><span class="text-gray-500">Roots</span><span class="font-black text-math-dark-blue">' + (disc > 0 ? '2 roots' : disc === 0 ? '1 root' : 'No real roots') + '</span></div>';
                }
                document.getElementById('keyFacts').innerHTML = facts;
            }

            window.updateGraph = function () { draw(); };
            window.zoom = function (factor) { ppu = Math.max(10, Math.min(120, ppu * factor)); draw(); };
            window.resetGraph = function () {
                document.getElementById('sliderA').value = 1;
                document.getElementById('sliderB').value = 0;
                document.getElementById('sliderC').value = 0;
                ppu = 40;
                setMode('quadratic');
            };

            window.exportPng = function () {
                var off = document.createElement('canvas');
                off.width = canvas.width; off.height = canvas.height;
                var octx = off.getContext('2d');
                octx.fillStyle = '#ffffff';
                octx.fillRect(0, 0, off.width, off.height);
                var saved = ctx; ctx = octx;
                drawGrid(); drawCurve();
                ctx = saved;
                octx.fillStyle = 'rgba(30,58,138,0.35)';
                octx.font = 'bold 11px Space Grotesk,sans-serif';
                octx.textAlign = 'right';
                octx.fillText('MathSphere — Graph Explorer', off.width - 10, off.height - 10);
                var eq = document.getElementById('eqDisplay').textContent;
                octx.fillStyle = 'rgba(30,58,138,0.55)';
                octx.font = 'bold 14px Courier New, monospace';
                octx.textAlign = 'left';
                octx.fillText(eq, 12, 22);
                var link = document.createElement('a');
                link.download = 'mathsphere-graph.png';
                link.href = off.toDataURL('image/png');
                link.click();
            };

            canvas.addEventListener('mousemove', function (e) {
                var rect = canvas.getBoundingClientRect();
                var px = (e.clientX - rect.left) * (canvas.width / rect.width);
                var py = (e.clientY - rect.top) * (canvas.height / rect.height);
                var m = toMath(px, py);
                document.getElementById('hoverReadout').textContent =
                    'x = ' + m.x.toFixed(2) + '    y (cursor) = ' + m.y.toFixed(2) + '    f(x) = ' + f(m.x).toFixed(3);
            });
            canvas.addEventListener('mouseleave', function () {
                document.getElementById('hoverReadout').textContent = 'Hover over the graph to read coordinates';
            });
            canvas.addEventListener('wheel', function (e) {
                e.preventDefault();
                window.zoom(e.deltaY < 0 ? 1.1 : 0.9);
            }, { passive: false });

            setMode('quadratic');

        })();
    </script>

</asp:Content>

