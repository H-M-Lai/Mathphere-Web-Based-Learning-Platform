<%@ Page Title="Assessment Templates"
    Language="C#"
    MasterPageFile="~/Teacher.master"
    AutoEventWireup="true"
    CodeBehind="assessmentTemplates.aspx.cs"
    Inherits="MathSphere.assessmentTemplates" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/assessmentTemplates.css") %>" rel="stylesheet" type="text/css" />
    <style>
        .wizard-layout {
            display: grid;
            grid-template-columns: 280px minmax(0, 1fr);
            gap: 1.5rem;
            align-items: start;
        }
        .wizard-left, .wizard-right {
            position: sticky;
            top: 110px;
            align-self: start;
            background: rgba(255,255,255,0.96);
            border: 1px solid rgba(255,255,255,0.78);
            box-shadow: 0 18px 40px rgba(15,23,42,0.07);
            border-radius: 2rem;
            padding: 1.5rem;
            min-height: 640px;
        }
        .wizard-centre { min-width: 0; }
        .tab-active-yellow { background: rgba(255,255,255,0.98); border-color: #f9d006; box-shadow: 0 14px 32px rgba(15,23,42,0.08); }
        .tab-inactive { background: rgba(255,255,255,0.82); border-color: rgba(226,232,240,0.85); transition: all 0.2s ease; }
        .tab-inactive:hover { background: rgba(255,255,255,0.96); transform: translateY(-1px); box-shadow: 0 10px 24px rgba(15,23,42,0.05); }
        .toggle-switch { width: 50px; height: 28px; border-radius: 9999px; position: relative; transition: background-color 0.2s ease, box-shadow 0.2s ease; display: inline-flex; align-items: center; padding: 0; overflow: hidden; box-shadow: inset 0 1px 2px rgba(15,23,42,0.08); }
        .toggle-off { background: #e5e7eb; }
        .toggle-on-lime { background: #84cc16; box-shadow: inset 0 1px 2px rgba(255,255,255,0.16); }
        .toggle-dot { position: absolute; top: 3px; left: 4px; width: 20px; height: 20px; display: block; background: white; border-radius: 9999px; box-shadow: 0 2px 8px rgba(15,23,42,0.14); transition: left 0.2s ease; }
        .toggle-dot-left { left: 4px; }
        .toggle-dot-right { left: 26px; }
        .custom-scrollbar { overflow: visible; }
        .donut-chart circle { transition: stroke-dasharray 0.25s ease, stroke-dashoffset 0.25s ease; }
        @media (max-width: 1200px) {
            .wizard-layout { grid-template-columns: 1fr; }
            .wizard-left, .wizard-right { position: static; min-height: auto; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hdnCourseId"          runat="server" />
    <asp:HiddenField ID="hdnAssessmentId"       runat="server" />
    <asp:HiddenField ID="hdnCreatedBy"          runat="server" />
    <asp:HiddenField ID="hdnTimeLimitMinutes"   runat="server" Value="60" />
    <asp:HiddenField ID="hdnIsPublished"        runat="server" Value="false" />
    <asp:HiddenField ID="hdnEasyCount"          runat="server" Value="8" />
    <asp:HiddenField ID="hdnMediumCount"        runat="server" Value="8" />
    <asp:HiddenField ID="hdnHardCount"          runat="server" Value="4" />
    <asp:HiddenField ID="hdnShuffleQuestions"   runat="server" Value="true" />
    <asp:HiddenField ID="hdnRequireQuizPass"    runat="server" Value="false" />

    <div class="mb-8 rounded-[2.25rem] border border-white/80 bg-white/85 shadow-[0_18px_40px_rgba(15,23,42,0.06)] backdrop-blur-sm">
        <div class="max-w-7xl mx-auto px-6 py-4">
            <div class="flex flex-wrap gap-4 md:gap-8 justify-center md:justify-start">
                <button type="button" onclick="window.location.href='courselistDashboard.aspx'"
                    class="flex items-center gap-3 px-6 py-3.5 rounded-[1.5rem] border tab-inactive group border-math-blue/20">
                    <div class="size-10 rounded-xl bg-math-blue/10 flex items-center justify-center group-hover:scale-110 transition-transform">
                        <span class="material-symbols-outlined text-math-blue fill-icon">layers</span>
                    </div>
                    <span class="font-black text-sm uppercase tracking-widest">Courses</span>
                </button>
                <button type="button" onclick="goToModuleBuilderFromStep1()"
                    class="flex items-center gap-3 px-6 py-3.5 rounded-[1.5rem] border tab-inactive group border-math-green/20">
                    <div class="size-10 rounded-xl bg-math-green/10 flex items-center justify-center group-hover:scale-110 transition-transform">
                        <span class="material-symbols-outlined text-math-green fill-icon">grid_view</span>
                    </div>
                    <span class="font-black text-sm uppercase tracking-widest">Module Builder</span>
                </button>
                <button type="button"
                    class="flex items-center gap-3 px-6 py-3.5 rounded-[1.5rem] border tab-active-yellow group">
                    <div class="size-10 rounded-xl bg-primary/10 flex items-center justify-center group-hover:scale-110 transition-transform">
                        <span class="material-symbols-outlined text-primary fill-icon">assignment</span>
                    </div>
                    <span class="font-black text-sm uppercase tracking-widest">Assessment Templates</span>
                </button>
            </div>
        </div>
    </div>

    <div class="wizard-layout">

        <aside class="wizard-left">
            <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-6">Wizard Steps</h3>
            <div class="space-y-4 flex-1">
                <div class="flex items-center gap-4 p-3 bg-math-blue/5 border-2 border-math-blue/20 rounded-2xl">
                    <div class="size-10 bg-white rounded-xl shadow-sm flex items-center justify-center text-math-blue border border-math-blue/10">
                        <span class="material-symbols-outlined fill-icon">settings</span>
                    </div>
                    <div>
                        <p class="text-xs font-black text-math-dark-blue">Step 1</p>
                        <p class="text-[11px] text-math-blue font-bold uppercase">Basic Settings</p>
                    </div>
                </div>
                <div class="flex items-center gap-4 p-3 opacity-40">
                    <div class="size-10 bg-white rounded-xl shadow-sm flex items-center justify-center text-gray-400 border border-gray-100">
                        <span class="material-symbols-outlined">quiz</span>
                    </div>
                    <div>
                        <p class="text-xs font-black text-gray-500">Step 2</p>
                        <p class="text-[11px] text-gray-400 font-bold uppercase">Define Questions</p>
                    </div>
                </div>
                <div class="flex items-center gap-4 p-3 opacity-40">
                    <div class="size-10 bg-white rounded-xl shadow-sm flex items-center justify-center text-gray-400 border border-gray-100">
                        <span class="material-symbols-outlined">task_alt</span>
                    </div>
                    <div>
                        <p class="text-xs font-black text-gray-500">Step 3</p>
                        <p class="text-[11px] text-gray-400 font-bold uppercase">Review &amp; Save</p>
                    </div>
                </div>
            </div>
            <div class="mt-8 p-5 bg-math-dark-blue rounded-2xl relative overflow-hidden">
                <div class="absolute -right-4 -bottom-4 size-24 bg-white/5 rounded-full"></div>
                <h4 class="text-white font-black italic text-lg mb-2 relative z-10">Pro Tip!</h4>
                <p class="text-blue-100 text-xs font-medium leading-relaxed relative z-10">
                    Keep your hard-question percentage below 30% to maintain student engagement.
                </p>
            </div>
        </aside>

        <main class="wizard-centre custom-scrollbar">
            <div class="max-w-4xl mx-auto">
                <p class="text-[10px] font-black text-math-green uppercase tracking-[0.2em] mb-2">Assessment Setup</p>
                <div class="flex justify-between items-center mb-8">
                    <h2 class="text-3xl font-black text-math-dark-blue">Step 1: Basic Settings</h2>
                </div>

                <div class="bg-white rounded-[2rem] border-2 border-math-green/30 p-10 shadow-xl shadow-math-dark-blue/5 relative overflow-hidden">
                    <div class="absolute -top-10 -left-10 size-40 bg-math-green/5 rounded-full pointer-events-none"></div>

                    <div class="space-y-10 relative z-10">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                            <div class="flex flex-col gap-2">
                                <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest ml-1">Template Name</label>
                                <asp:TextBox ID="txtTemplateName" runat="server"
                                    CssClass="w-full px-5 py-4 bg-gray-50 border-2 border-transparent rounded-xl text-math-dark-blue font-bold placeholder:text-gray-300 transition-colors"
                                    placeholder="e.g. Final Semester Prep - Calculus"
                                    oninput="syncTitleFromMain(this.value)"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-2">
                                <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest ml-1">Target Module</label>
                                <asp:DropDownList ID="ddlTargetModule" runat="server"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlTargetModule_SelectedIndexChanged"
                                    CssClass="w-full px-5 py-4 bg-gray-50 border-2 border-transparent rounded-xl text-math-dark-blue font-bold appearance-none cursor-pointer">
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="bg-gray-50 rounded-2xl p-8 border-2 border-dashed border-gray-200">
                            <div class="flex items-center gap-2 mb-8">
                                <span class="material-symbols-outlined text-primary fill-icon">pie_chart</span>
                                <h3 class="text-xs font-black text-math-dark-blue uppercase tracking-widest">Question Composition</h3>
                            </div>

                            <div class="flex flex-col md:flex-row items-center justify-between gap-12">
                                <div class="relative size-44 flex-shrink-0">
                                    <asp:Literal ID="litDonutChart" runat="server"></asp:Literal>
                                    <div class="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                                        <span class="text-3xl font-black text-math-dark-blue leading-none" id="totalLabel">20</span>
                                        <span class="text-[9px] font-black text-gray-400 uppercase">Items</span>
                                    </div>
                                </div>

                                <div class="flex-1 w-full space-y-6">
                                    <div class="flex items-center justify-between gap-4">
                                        <div class="flex items-center gap-3 w-24 flex-shrink-0">
                                            <div class="size-3 rounded-full bg-math-green"></div>
                                            <span class="text-xs font-black text-math-dark-blue">Easy</span>
                                        </div>
                                        <div class="flex items-center gap-3 flex-1">
                                            <input type="number" id="txtEasyCount" value="8" min="0"
                                                oninput="syncCount(this,'<%= hdnEasyCount.ClientID %>'); updateComposition()"
                                                class="w-16 px-3 py-2 bg-white border-2 border-gray-200 rounded-xl text-math-dark-blue font-black text-center text-sm" />
                                            <span class="text-[10px] font-bold text-gray-400">Items</span>
                                        </div>
                                        <span id="lblEasyPct" class="px-3 py-1 bg-math-green/10 text-math-green text-[10px] font-black rounded-full min-w-[48px] text-center">40%</span>
                                    </div>

                                    <div class="flex items-center justify-between gap-4">
                                        <div class="flex items-center gap-3 w-24 flex-shrink-0">
                                            <div class="size-3 rounded-full bg-math-blue"></div>
                                            <span class="text-xs font-black text-math-dark-blue">Medium</span>
                                        </div>
                                        <div class="flex items-center gap-3 flex-1">
                                            <input type="number" id="txtMediumCount" value="8" min="0"
                                                oninput="syncCount(this,'<%= hdnMediumCount.ClientID %>'); updateComposition()"
                                                class="w-16 px-3 py-2 bg-white border-2 border-gray-200 rounded-xl text-math-dark-blue font-black text-center text-sm" />
                                            <span class="text-[10px] font-bold text-gray-400">Items</span>
                                        </div>
                                        <span id="lblMediumPct" class="px-3 py-1 bg-math-blue/10 text-math-blue text-[10px] font-black rounded-full min-w-[48px] text-center">40%</span>
                                    </div>

                                    <div class="flex items-center justify-between gap-4">
                                        <div class="flex items-center gap-3 w-24 flex-shrink-0">
                                            <div class="size-3 rounded-full bg-primary"></div>
                                            <span class="text-xs font-black text-math-dark-blue">Hard</span>
                                        </div>
                                        <div class="flex items-center gap-3 flex-1">
                                            <input type="number" id="txtHardCount" value="4" min="0"
                                                oninput="syncCount(this,'<%= hdnHardCount.ClientID %>'); updateComposition()"
                                                class="w-16 px-3 py-2 bg-white border-2 border-gray-200 rounded-xl text-math-dark-blue font-black text-center text-sm" />
                                            <span class="text-[10px] font-bold text-gray-400">Items</span>
                                        </div>
                                        <span id="lblHardPct" class="px-3 py-1 bg-primary/10 text-primary text-[10px] font-black rounded-full min-w-[48px] text-center">20%</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="flex justify-end pt-2">
                            <asp:Button ID="btnSaveConfig" runat="server"
                                Text="Next: Define Questions"
                                OnClick="btnSaveConfig_Click"
                                OnClientClick="syncBeforeSubmit();"
                                UseSubmitBehavior="true"
                                CssClass="flex items-center gap-3 rounded-2xl bg-primary px-10 py-5 text-sm font-black uppercase tracking-[0.18em] text-math-dark-blue shadow-[0_14px_28px_rgba(249,208,6,0.24)] transition-all hover:-translate-y-0.5" />
                        </div>
                    </div>
                </div>
            </div>
        </main>

    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        function goToModuleBuilderFromStep1() {
            var ddl = document.getElementById('<%= ddlTargetModule.ClientID %>');
            var courseHdn = document.getElementById('<%= hdnCourseId.ClientID %>');
            var moduleId = ddl ? ddl.value : '';
            var courseId = courseHdn ? courseHdn.value : '';

            if (moduleId) {
                window.location.href = 'moduleBuilder.aspx?id=' + encodeURIComponent(moduleId) +
                    '&courseId=' + encodeURIComponent(courseId || '');
            } else {
                window.location.href = 'fullModuleView.aspx?courseId=' + encodeURIComponent(courseId || '');
            }
        }

        function syncCount(inputEl, hiddenId) {
            var hdn = document.getElementById(hiddenId);
            if (hdn) hdn.value = parseInt(inputEl.value, 10) || 0;
        }

        function syncTitleFromMain(val) {
            var rp = document.getElementById('rightPanelTitle');
            if (rp) rp.value = val;
        }

        function syncTitleFromRight(val) {
            var mainTxt = document.getElementById('<%= txtTemplateName.ClientID %>');
            if (mainTxt) mainTxt.value = val;
        }

        // FIX BUG-04: sync right panel title FIRST, then counts, then time
        function syncBeforeSubmit() {
            var rp = document.getElementById('rightPanelTitle');
            var mainTxt = document.getElementById('<%= txtTemplateName.ClientID %>');
            if (rp && mainTxt && rp.value.trim() !== '') {
                mainTxt.value = rp.value;
            }

            syncCount(document.getElementById('txtEasyCount'),   '<%= hdnEasyCount.ClientID %>');
            syncCount(document.getElementById('txtMediumCount'), '<%= hdnMediumCount.ClientID %>');
            syncCount(document.getElementById('txtHardCount'),   '<%= hdnHardCount.ClientID %>');

            var timeInput  = document.getElementById('txtTimeLimit');
            var timeHidden = document.getElementById('<%= hdnTimeLimitMinutes.ClientID %>');
            if (timeInput && timeHidden) {
                timeHidden.value = parseInt(timeInput.value, 10) || 60;
            }
        }

        function setCompositionValues(easy, med, hard) {
            var easyBox = document.getElementById('txtEasyCount');
            var medBox  = document.getElementById('txtMediumCount');
            var hardBox = document.getElementById('txtHardCount');
            if (easyBox) easyBox.value = easy;
            if (medBox)  medBox.value  = med;
            if (hardBox) hardBox.value = hard;
            syncCount(easyBox, '<%= hdnEasyCount.ClientID %>');
            syncCount(medBox,  '<%= hdnMediumCount.ClientID %>');
            syncCount(hardBox, '<%= hdnHardCount.ClientID %>');
            updateComposition();
        }

        function setToggleState(buttonId, hiddenId, isOn, color) {
            var btn    = document.getElementById(buttonId);
            var hidden = document.getElementById(hiddenId);
            if (!btn || !hidden) return;
            var dot = btn.querySelector('.toggle-dot');
            hidden.value = isOn ? 'true' : 'false';
            btn.setAttribute('aria-pressed', isOn ? 'true' : 'false');
            if (isOn) {
                btn.className = 'toggle-switch toggle-on-' + color;
                if (dot) dot.className = 'toggle-dot toggle-dot-right';
            } else {
                btn.className = 'toggle-switch toggle-off';
                if (dot) dot.className = 'toggle-dot toggle-dot-left';
            }
        }

        function toggleRule(btn, color, hiddenId) {
            var dot    = btn.querySelector('.toggle-dot');
            var hidden = document.getElementById(hiddenId);
            var on     = btn.getAttribute('aria-pressed') === 'true';
            if (on) {
                btn.setAttribute('aria-pressed', 'false');
                btn.className = 'toggle-switch toggle-off';
                if (dot)    dot.className = 'toggle-dot toggle-dot-left';
                if (hidden) hidden.value  = 'false';
            } else {
                btn.setAttribute('aria-pressed', 'true');
                btn.className = 'toggle-switch toggle-on-' + color;
                if (dot)    dot.className = 'toggle-dot toggle-dot-right';
                if (hidden) hidden.value  = 'true';
            }
        }

        window.addEventListener('DOMContentLoaded', function () {
            syncCount(document.getElementById('txtEasyCount'),   '<%= hdnEasyCount.ClientID %>');
            syncCount(document.getElementById('txtMediumCount'), '<%= hdnMediumCount.ClientID %>');
            syncCount(document.getElementById('txtHardCount'),   '<%= hdnHardCount.ClientID %>');
            updateComposition();

            var mainTxt = document.getElementById('<%= txtTemplateName.ClientID %>');
            var rp      = document.getElementById('rightPanelTitle');
            if (mainTxt && rp) rp.value = mainTxt.value || '';

            var timeInput  = document.getElementById('txtTimeLimit');
            var timeHidden = document.getElementById('<%= hdnTimeLimitMinutes.ClientID %>');
            if (timeInput && timeHidden && timeHidden.value) {
                timeInput.value = timeHidden.value;
            }

            // Restore shuffle toggle state from hidden field
            var shuffleHdn = document.getElementById('<%= hdnShuffleQuestions.ClientID %>');
            var shuffleBtn = document.getElementById('btnShuffleToggle');
            if (shuffleHdn && shuffleBtn) {
                setToggleState('btnShuffleToggle', '<%= hdnShuffleQuestions.ClientID %>',
                    shuffleHdn.value === 'true', 'lime');
            }
        });

        function updateComposition() {
            var easy = parseInt(document.getElementById('txtEasyCount').value, 10) || 0;
            var med = parseInt(document.getElementById('txtMediumCount').value, 10) || 0;
            var hard = parseInt(document.getElementById('txtHardCount').value, 10) || 0;
            var total = easy + med + hard;

            document.getElementById('totalLabel').innerText = total;

            var ep = total > 0 ? Math.round(easy / total * 100) : 0;
            var mp = total > 0 ? Math.round(med / total * 100) : 0;
            var hp = total > 0 ? Math.round(hard / total * 100) : 0;

            document.getElementById('lblEasyPct').innerText = ep + '%';
            document.getElementById('lblMediumPct').innerText = mp + '%';
            document.getElementById('lblHardPct').innerText = hp + '%';

            var C = 2 * Math.PI * 40;
            var ea = ep / 100 * C;
            var ma = mp / 100 * C;
            var ha = hp / 100 * C;
            var c = document.querySelectorAll('.donut-circle');

            if (c.length === 3) {
                c[0].setAttribute('stroke-dasharray', ea.toFixed(1) + ' ' + C.toFixed(1));
                c[0].setAttribute('stroke-dashoffset', '0');
                c[1].setAttribute('stroke-dasharray', ma.toFixed(1) + ' ' + C.toFixed(1));
                c[1].setAttribute('stroke-dashoffset', (-ea).toFixed(1));
                c[2].setAttribute('stroke-dasharray', ha.toFixed(1) + ' ' + C.toFixed(1));
                c[2].setAttribute('stroke-dashoffset', (-(ea + ma)).toFixed(1));
            }
        }
    </script>
</asp:Content>




