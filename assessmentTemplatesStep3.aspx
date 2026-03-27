<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="assessmentTemplatesStep3.aspx.cs" Inherits="MathSphere.assessmentTemplateStep3" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere � Review &amp; Save
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/assessmentTemplates.css" rel="stylesheet" type="text/css" />
    <style>
        .wizard-layout {
            display: grid;
            grid-template-columns: 280px minmax(0, 1fr) 320px;
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
        .custom-scrollbar { overflow: visible; }
        @media (max-width: 1200px) {
            .wizard-layout { grid-template-columns: 1fr; }
            .wizard-left, .wizard-right { position: static; min-height: auto; }
        }
        .mission-summary-card {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
        }
        .toggle-switch {
            position:relative; display:inline-flex;
            width:44px; height:24px;
            border-radius:9999px; border:none; cursor:pointer;
            transition:background .2s;
        }
        .toggle-off     { background:#e5e7eb; }
        .toggle-on-blue { background:#2563eb; }
        .toggle-dot {
            position:absolute; top:3px;
            width:18px; height:18px;
            background:white; border-radius:50%;
            box-shadow:0 1px 3px rgba(0,0,0,.2);
            transition:left .2s;
        }
        .toggle-dot-left  { left:3px; }
        .toggle-dot-right { left:23px; }
        .pass-threshold-slider { -webkit-appearance:none; appearance:none; width:100%; height:6px; border-radius:9999px; background:#e5e7eb; outline:none; }
        .pass-threshold-slider::-webkit-slider-thumb { -webkit-appearance:none; width:18px; height:18px; border-radius:50%; background:#84cc16; cursor:pointer; border:3px solid white; box-shadow:0 0 0 2px #84cc16; }
        .confetti-piece { position:absolute; width:10px; height:10px; border-radius:2px; opacity:.6; }
        .math-grid-modal {
            background-image: linear-gradient(rgba(37,99,235,.08) 1px, transparent 1px),
                              linear-gradient(90deg, rgba(37,99,235,.08) 1px, transparent 1px);
            background-size:24px 24px;
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hfShuffleOn"     runat="server" Value="0" />
    <asp:HiddenField ID="hfRequirePassOn" runat="server" Value="0" />
    <asp:HiddenField ID="hfPassScore"     runat="server" Value="60" />
    <asp:HiddenField ID="hfTimeLimit"     runat="server" Value="60" />
    <asp:HiddenField ID="hfTemplateName"  runat="server" Value="" />

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
                <button type="button" onclick="window.location.href='<%= ResolveModuleBuilderUrl() %>'"
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

        <%-- LEFT SIDEBAR --%>
        <aside class="wizard-left">
            <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-6">WIZARD STEPS</h3>
            <div class="space-y-4 flex-1">
                <div class="flex items-center gap-4 p-3 opacity-40">
                    <div class="size-10 bg-white rounded-xl shadow-sm flex items-center justify-center text-gray-400 border border-gray-100">
                        <span class="material-symbols-outlined">settings</span>
                    </div>
                    <div>
                        <p class="text-xs font-black text-gray-500">Step 1</p>
                        <p class="text-[11px] text-gray-400 font-bold uppercase">Basic Settings</p>
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
                <div class="flex items-center gap-4 p-3 bg-math-green/10 border-2 border-math-green/20 rounded-2xl">
                    <div class="size-10 bg-white rounded-xl shadow-sm flex items-center justify-center text-math-green border border-math-green/20">
                        <span class="material-symbols-outlined fill-icon">task_alt</span>
                    </div>
                    <div>
                        <p class="text-xs font-black text-math-green">Step 3</p>
                        <p class="text-[11px] text-math-dark-blue font-bold uppercase">Review &amp; Save</p>
                    </div>
                </div>
            </div>
            <div class="mt-auto p-5 bg-math-dark-blue rounded-2xl relative overflow-hidden">
                <div class="absolute -right-4 -bottom-4 size-24 bg-white/5 rounded-full"></div>
                <h4 class="text-white font-black italic text-lg mb-2 relative z-10">Almost there!</h4>
                <p class="text-blue-100 text-xs font-medium leading-relaxed relative z-10">
                    Review your points allocation before publishing to ensure it matches your curriculum goals.
                </p>
            </div>
        </aside>

        <%-- CENTRE MAIN --%>
        <main class="wizard-centre flex flex-col">
            <div class="px-10 pt-8 pb-4 flex-shrink-0">
                <p class="text-[10px] font-black text-math-green uppercase tracking-[0.2em] mb-2">Review & Publish</p>
                <h2 class="text-3xl font-black text-math-dark-blue">
                    <asp:Literal ID="litStepMode" runat="server" Text="Step 3: Review &amp; Save" />
                </h2>
            </div>

            <div class="flex-1 overflow-y-auto px-10 pb-4 custom-scrollbar space-y-8">

                <%-- Mission Summary Card --%>
                <div class="mission-summary-card p-10 rounded-3xl shadow-xl border-4 border-white relative overflow-hidden">
                    <div class="absolute -top-10 -right-10 size-48 bg-white/10 rounded-full"></div>
                    <div class="absolute top-20 -left-10 size-32 bg-white/5 rounded-full"></div>
                    <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-8">
                        <div class="space-y-3">
                            <span class="text-[10px] font-black text-white/60 uppercase tracking-widest">Assessment Name</span>
                            <h3 class="text-4xl font-black text-white tracking-tight">
                                <asp:Label ID="lblAssessmentName" runat="server" Text=""></asp:Label>
                            </h3>
                            <div class="flex gap-3 pt-1 flex-wrap">
                                <span class="flex items-center gap-1.5 px-3 py-1 bg-white/10 rounded-full text-[11px] font-bold text-white border border-white/20">
                                    <span class="material-symbols-outlined text-sm">schedule</span>
                                    <asp:Label ID="lblTimeDisplay" runat="server" Text="60 Min"></asp:Label>
                                </span>
                                <asp:Panel ID="pnlShuffleBadge" runat="server" Visible="false">
                                    <span class="flex items-center gap-1.5 px-3 py-1 bg-white/10 rounded-full text-[11px] font-bold text-white border border-white/20">
                                        <span class="material-symbols-outlined text-sm">shuffle</span> Shuffled
                                    </span>
                                </asp:Panel>
                            </div>
                        </div>
                        <div class="flex gap-4">
                            <div class="bg-white/10 backdrop-blur-md rounded-2xl p-6 border border-white/20 flex flex-col items-center min-w-[110px]">
                                <span class="text-[10px] font-black text-white/70 uppercase mb-1">Questions</span>
                                <span class="text-3xl font-black text-primary">
                                    <asp:Label ID="lblTotalQuestions" runat="server" Text="0"></asp:Label>
                                </span>
                            </div>
                            <div class="bg-white/10 backdrop-blur-md rounded-2xl p-6 border border-white/20 flex flex-col items-center min-w-[110px]">
                                <span class="text-[10px] font-black text-white/70 uppercase mb-1">Points</span>
                                <span class="text-3xl font-black text-primary">
                                    <asp:Label ID="lblTotalPoints" runat="server" Text="0"></asp:Label>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Question Preview --%>
                <div class="space-y-3">
                    <div class="flex items-center justify-between px-1">
                        <h3 class="text-xs font-black text-math-dark-blue uppercase tracking-widest">Question Preview</h3>
                        <span class="text-[10px] font-bold text-gray-400 uppercase">ORDER: AS DEFINED</span>
                    </div>
                    <asp:Repeater ID="rptReviewQuestions" runat="server" OnItemDataBound="rptReviewQuestions_ItemDataBound">
                        <ItemTemplate>
                            <div class="flex items-center gap-5 p-5 bg-white border-2 border-gray-100 rounded-2xl shadow-sm hover:border-math-blue/30 transition-all">
                                <span class="size-10 flex items-center justify-center bg-gray-50 text-math-dark-blue font-black rounded-xl border-2 border-gray-100 text-sm flex-shrink-0"><%# Eval("OrderNum") %></span>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-bold text-math-dark-blue line-clamp-1"><%# System.Web.HttpUtility.HtmlEncode(Eval("questionText").ToString()) %></p>
                                </div>
                                <div class="flex items-center gap-5 flex-shrink-0">
                                    <asp:Literal ID="litDiffBadge" runat="server"></asp:Literal>
                                    <span class="text-xs font-black text-math-dark-blue w-16 text-right"><%# Eval("points") %> PTS</span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlMoreQsRow" runat="server" Visible="false">
                        <div class="flex items-center gap-5 p-5 bg-white border-2 border-gray-100 rounded-2xl opacity-50">
                            <span class="size-10 flex items-center justify-center bg-gray-50 text-gray-400 font-black rounded-xl border-2 border-gray-100 text-sm flex-shrink-0">...</span>
                            <p class="text-xs font-bold text-gray-400 uppercase tracking-widest flex-1 text-center">
                                <asp:Literal ID="litMoreQsLabel" runat="server"></asp:Literal>
                            </p>
                        </div>
                    </asp:Panel>
                </div>

            </div>

            <%-- Bottom action bar --%>
            <div class="px-10 py-5 flex justify-between items-center gap-4 border-t-2 border-gray-100 bg-white/80 backdrop-blur-sm flex-shrink-0">
                <asp:Button ID="btnPreviousStep" runat="server" Text="Previous Step"
                    CausesValidation="false"
                    CssClass="flex items-center gap-3 px-8 py-4 bg-white border-2 border-gray-200
                              text-math-dark-blue font-black text-sm rounded-2xl shadow-sm
                              hover:bg-gray-50 transition-colors uppercase tracking-widest cursor-pointer" />
                <asp:Button ID="btnPublish" runat="server" Text="Publish Assessment"
                    OnClick="btnPublish_Click"
                    CssClass="px-12 py-4 bg-primary text-math-dark-blue font-black text-base rounded-2xl
                              shadow-2xl shadow-primary/30 hover:scale-[1.02] active:scale-[0.98]
                              transition-transform uppercase tracking-widest cursor-pointer border-none" />
            </div>
        </main>

        <%-- RIGHT PANEL --%>
        <aside class="wizard-right">
            <div class="p-6 border-b border-gray-100 flex-shrink-0">
                <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-5">TEMPLATE SETTINGS</h3>
                <div class="flex flex-col gap-2">
                    <label class="text-[10px] font-black text-math-blue uppercase tracking-widest">TEMPLATE TITLE / ASSESSMENT NAME</label>
                    <input type="text" id="txtTemplateName"
                           class="w-full px-5 py-4 bg-gray-50 border-2 border-transparent rounded-xl
                                  text-math-dark-blue text-sm font-bold focus:border-math-blue
                                  focus:outline-none transition-colors"
                           placeholder="Enter assessment name..."
                           oninput="syncTitle(this.value)" />
                    <p class="text-[10px] text-gray-400 font-medium">Editing this also updates the assessment name above.</p>
                </div>
            </div>

            <div class="p-6 flex flex-col gap-5 flex-1">
                <label class="text-[10px] font-black text-math-blue uppercase tracking-widest flex items-center gap-2">
                    <span class="size-1.5 rounded-full bg-primary"></span>ADAPTIVE RULES
                </label>

                <div class="flex items-center justify-between p-4 bg-gray-50 rounded-2xl border border-gray-100">
                    <span class="text-sm font-bold text-gray-600">Shuffle Questions</span>
                    <button type="button" id="btnShuffleToggle"
                            onclick="toggleAdaptive(this,'blue','<%= hfShuffleOn.ClientID %>')"
                            class="toggle-switch toggle-off" aria-pressed="false">
                        <span class="toggle-dot toggle-dot-left"></span>
                    </button>
                </div>

                <div class="flex flex-col gap-4 p-4 bg-gray-50/80 rounded-2xl border-2 border-math-green/20">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-black text-math-dark-blue uppercase tracking-widest">Pass Threshold</span>
                        <div class="px-3 py-1 bg-primary text-math-dark-blue rounded-full text-xs font-black" id="thresholdLabel">60%</div>
                    </div>
                    <input type="range" class="pass-threshold-slider" min="0" max="100" value="60" id="sliderPassScore"
                        oninput="document.getElementById('thresholdLabel').innerText = this.value + '%';
                                 document.getElementById('<%= hfPassScore.ClientID %>').value = this.value;" />
                    <p class="text-[11px] text-math-green font-bold">Students must reach this score to unlock the next mission.</p>
                </div>

                <div class="flex items-center justify-between p-4 bg-gray-50 rounded-2xl border border-gray-100">
                    <span class="text-sm font-bold text-gray-600">Time Limit</span>
                    <div class="flex items-center gap-2">
                        <input type="number" id="inputTimeLimit" value="60" min="0"
                               class="w-14 bg-white border-2 border-gray-200 text-xs font-black text-center
                                      py-2 px-1 rounded-lg text-math-dark-blue"
                               oninput="document.getElementById('<%= hfTimeLimit.ClientID %>').value = this.value" />
                        <span class="text-[10px] font-black text-gray-400">MIN</span>
                    </div>
                </div>
            </div>

        </aside>

    </div>

    <%-- Success Modal --%>
    <asp:Panel ID="pnlSuccessModal" runat="server" Visible="false">
        <div class="fixed inset-0 bg-black/50 backdrop-blur-md z-[100] flex items-center justify-center p-4">
            <div class="relative w-full max-w-[560px] bg-white rounded-[2rem] shadow-2xl overflow-hidden">
                <div class="absolute inset-0 pointer-events-none overflow-hidden">
                    <div class="confetti-piece bg-math-blue  top-8  left-8   rotate-12"></div>
                    <div class="confetti-piece bg-primary    top-14 right-12 -rotate-45"></div>
                    <div class="confetti-piece bg-math-green bottom-24 left-14 rotate-6"></div>
                    <div class="confetti-piece bg-primary    bottom-16 right-16 rotate-12"></div>
                    <div class="confetti-piece bg-math-blue  top-1/2 left-6  rotate-45"></div>
                    <div class="absolute w-3 h-3 border-2 border-primary rounded-full top-28 left-1/4"></div>
                    <div class="absolute w-4 h-4 border-2 border-math-blue rounded-full bottom-20 right-1/4"></div>
                </div>
                <div class="relative w-full overflow-hidden bg-gray-50 border-b-2 border-gray-100" style="aspect-ratio:16/7">
                    <div class="absolute inset-0 math-grid-modal"></div>
                    <div class="relative z-10 h-full flex items-center justify-center">
                        <span class="material-symbols-outlined text-[6rem] text-math-blue drop-shadow-xl" style="font-variation-settings:'FILL' 1">rocket_launch</span>
                    </div>
                    <span class="material-symbols-outlined absolute top-5 left-6  text-math-blue/30 text-5xl">calculate</span>
                    <span class="material-symbols-outlined absolute top-8 right-6 text-math-green/30 text-4xl">functions</span>
                    <span class="material-symbols-outlined absolute bottom-5 left-14 text-primary/30 text-5xl">square_foot</span>
                </div>
                <div class="p-8 flex flex-col items-center text-center">
                    <h2 class="text-4xl font-black text-math-blue tracking-tight mb-3">Assessment Published</h2>
                    <p class="text-gray-500 font-medium mb-8 max-w-sm">Your assessment is now live and ready for students.</p>
                    <div class="flex flex-col sm:flex-row gap-4 w-full justify-center mb-6">
                        <button type="button" onclick="window.location.href='courselistDashboard.aspx'"
                            class="flex items-center justify-center gap-2 min-w-[190px] h-14 px-8
                                   bg-primary text-math-dark-blue text-sm font-black uppercase
                                   tracking-wider rounded-2xl shadow-lg hover:scale-105 transition-transform">
                            <span class="material-symbols-outlined fill-icon">school</span>Go to Classroom
                        </button>
                        <asp:HyperLink ID="lnkCreateAnother" runat="server"
                            CssClass="flex items-center justify-center gap-2 min-w-[190px] h-14 px-8
                                      bg-white border-2 border-math-blue text-math-blue text-sm font-black
                                      uppercase tracking-wider rounded-2xl hover:bg-math-blue/5 transition-colors">
                            <span class="material-symbols-outlined fill-icon">add_circle</span>Create Another
                        </asp:HyperLink>
                    </div>
                    <p class="text-gray-400 text-xs font-bold flex items-center gap-1">
                        <span class="material-symbols-outlined text-sm text-math-green">verified</span>
                        Published to:
                        <asp:Label ID="lblCourseName" runat="server" Text="this course"
                            CssClass="text-math-dark-blue ml-1"></asp:Label>
                    </p>
                </div>
            </div>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        function toggleAdaptive(btn, color, hfId) {
            var dot = btn.querySelector('.toggle-dot');
            var on  = btn.getAttribute('aria-pressed') === 'true';
            var hf  = document.getElementById(hfId);
            if (on) {
                btn.setAttribute('aria-pressed', 'false');
                btn.className = 'toggle-switch toggle-off';
                dot.className = 'toggle-dot toggle-dot-left';
                if (hf) hf.value = '0';
            } else {
                btn.setAttribute('aria-pressed', 'true');
                btn.className = 'toggle-switch toggle-on-' + color;
                dot.className = 'toggle-dot toggle-dot-right';
                if (hf) hf.value = '1';
            }
        }

        function syncTitle(val) {
            var hf  = document.getElementById('<%= hfTemplateName.ClientID %>');
            var lbl = document.getElementById('<%= lblAssessmentName.ClientID %>');
            if (hf)  hf.value      = val;
            if (lbl) lbl.innerText = val || 'Assessment Name';
        }

        document.addEventListener('DOMContentLoaded', function () {
            var hfName = document.getElementById('<%= hfTemplateName.ClientID %>');
            var inp    = document.getElementById('txtTemplateName');
            if (hfName && inp) inp.value = hfName.value;

            var psHf     = document.getElementById('<%= hfPassScore.ClientID %>');
            var psSlider = document.getElementById('sliderPassScore');
            var psLabel  = document.getElementById('thresholdLabel');
            if (psHf && psSlider && psHf.value) {
                psSlider.value = psHf.value;
                if (psLabel) psLabel.innerText = psHf.value + '%';
            }

            var tlHf    = document.getElementById('<%= hfTimeLimit.ClientID %>');
            var tlInput = document.getElementById('inputTimeLimit');
            if (tlHf && tlInput && tlHf.value) tlInput.value = tlHf.value;

            var shuffleHf  = document.getElementById('<%= hfShuffleOn.ClientID %>');
            var shuffleBtn = document.getElementById('btnShuffleToggle');
            if (shuffleHf && shuffleBtn && shuffleHf.value === '1') {
                shuffleBtn.setAttribute('aria-pressed', 'true');
                shuffleBtn.className = 'toggle-switch toggle-on-blue';
                var dot = shuffleBtn.querySelector('.toggle-dot');
                if (dot) dot.className = 'toggle-dot toggle-dot-right';
            }
        });
    </script>
</asp:Content>


