<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="assessmentTemplateStep2.aspx.cs" Inherits="MathSphere.assessmentTemplateStep2" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere - Define Questions
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/assessmentTemplates.css" rel="stylesheet" type="text/css" />
        <style>
        .wizard-layout {
            display: grid;
            grid-template-columns: 250px minmax(0, 1fr) 280px;
            gap: 1.25rem;
            align-items: start;
        }
        .wizard-left, .wizard-right {
            position: sticky;
            top: 110px;
            align-self: start;
            background: rgba(255,255,255,0.96);
            box-shadow: 0 18px 40px rgba(15,23,42,0.07);
            border: 1px solid rgba(255,255,255,0.78);
            border-radius: 2rem;
            padding: 1.25rem;
            min-height: 0;
        }
        .wizard-centre {
            min-width: 0;
            background: rgba(255,255,255,0.94);
            border: 1px solid rgba(255,255,255,0.82);
            border-radius: 2rem;
            box-shadow: 0 18px 40px rgba(15,23,42,0.06);
            overflow: hidden;
        }
        .wizard-centre-inner {
            display: grid;
            grid-template-rows: auto minmax(0, 1fr) auto;
            min-height: 680px;
        }
        .question-builder-grid {
            display: grid;
            grid-template-columns: minmax(300px, 0.9fr) minmax(420px, 1.15fr);
            gap: 1.25rem;
            min-height: 0;
        }
        .pool-panel,
        .selected-panel {
            display: flex;
            flex-direction: column;
            min-height: 0;
            background: #fff;
            border-radius: 1.75rem;
            overflow: hidden;
            box-shadow: 0 10px 24px rgba(15,23,42,0.04);
        }
        .pool-panel {
            border: 2px solid rgba(226,232,240,0.9);
        }
        .selected-panel {
            border: 2px dashed rgba(132,204,22,0.4);
        }
        .custom-scrollbar { overflow-y: auto; min-height: 0; }
        .quota-bar      { height:6px; border-radius:9999px; overflow:hidden; background:#e5e7eb; }
        .quota-bar-fill { height:100%; border-radius:9999px; transition:width .3s ease; }
        .quota-bar-fill.easy   { background:#84cc16; }
        .quota-bar-fill.medium { background:#2563eb; }
        .quota-bar-fill.hard   { background:#f9d006; }
        .quota-exceeded .quota-bar-fill { background:#ef4444 !important; }
        .tab-active-yellow { background: white; border-color: #f9d006; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        .tab-inactive { background: rgba(255,255,255,0.7); transition: all 0.2s ease; }
        .tab-inactive:hover { background: white; transform: translateY(-1px); }
        .step-chip {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.45rem 0.85rem;
            border-radius: 9999px;
            background: rgba(132,204,22,0.12);
            color: #65a30d;
            font-size: 10px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.18em;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .animate-spin { animation: spin 1s linear infinite; }
        @media (max-width: 1400px) {
            .wizard-layout { grid-template-columns: 230px minmax(0, 1fr) 250px; }
            .question-builder-grid { grid-template-columns: minmax(280px, 0.92fr) minmax(360px, 1.08fr); }
        }
        @media (max-width: 1200px) {
            .wizard-layout { grid-template-columns: 1fr; }
            .wizard-left, .wizard-right { position: static; min-height: auto; }
            .wizard-centre-inner { min-height: auto; }
            .question-builder-grid { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Core state hidden fields --%>
    <asp:HiddenField ID="hdnAssessmentId"          runat="server" />
    <asp:HiddenField ID="hdnCourseId"              runat="server" />
    <asp:HiddenField ID="hdnSelectedQuestionsJson" runat="server" />
    <asp:HiddenField ID="hdnQuestionsJson"         runat="server" />
    <asp:HiddenField ID="hdnQuotaEasy"             runat="server" Value="0" />
    <asp:HiddenField ID="hdnQuotaMedium"           runat="server" Value="0" />
    <asp:HiddenField ID="hdnQuotaHard"             runat="server" Value="0" />`r`n    <asp:HiddenField ID="hdnTemplateTitle"          runat="server" />

    <%-- Tab Nav --%>
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

        <%-- ── LEFT SIDEBAR ─────────────────────────────────────────────── --%>
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
                <div class="flex items-center gap-4 p-3 bg-math-blue/5 border-2 border-math-blue/20 rounded-2xl">
                    <div class="size-10 bg-white rounded-xl shadow-sm flex items-center justify-center text-math-blue border border-math-blue/10">
                        <span class="material-symbols-outlined fill-icon">quiz</span>
                    </div>
                    <div>
                        <p class="text-xs font-black text-math-dark-blue">Step 2</p>
                        <p class="text-[11px] text-math-blue font-bold uppercase">Define Questions</p>
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

            <%-- Quota tracker --%>
            <div class="mt-6 p-4 bg-gray-50 rounded-2xl border border-gray-100 space-y-4">
                <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Selection Quotas</p>
                <div>
                    <div class="flex justify-between text-[10px] font-bold mb-1">
                        <span class="text-math-green">Easy</span>
                        <span id="quotaEasyLabel" class="text-math-dark-blue">0 / 0</span>
                    </div>
                    <div class="quota-bar" id="quotaEasyBar">
                        <div class="quota-bar-fill easy" id="quotaEasyFill" style="width:0%"></div>
                    </div>
                </div>
                <div>
                    <div class="flex justify-between text-[10px] font-bold mb-1">
                        <span class="text-math-blue">Medium</span>
                        <span id="quotaMediumLabel" class="text-math-dark-blue">0 / 0</span>
                    </div>
                    <div class="quota-bar" id="quotaMediumBar">
                        <div class="quota-bar-fill medium" id="quotaMediumFill" style="width:0%"></div>
                    </div>
                </div>
                <div>
                    <div class="flex justify-between text-[10px] font-bold mb-1">
                        <span class="text-primary">Hard</span>
                        <span id="quotaHardLabel" class="text-math-dark-blue">0 / 0</span>
                    </div>
                    <div class="quota-bar" id="quotaHardBar">
                        <div class="quota-bar-fill hard" id="quotaHardFill" style="width:0%"></div>
                    </div>
                </div>
                <p class="text-[9px] text-gray-400 font-medium leading-relaxed">
                    Quotas are set in Step 1. You cannot exceed the limit for each difficulty tier.
                </p>
            </div>

            <div class="mt-4 p-5 bg-math-dark-blue rounded-2xl relative overflow-hidden">
                <div class="absolute -right-4 -bottom-4 size-24 bg-white/5 rounded-full"></div>
                <h4 class="text-white font-black italic text-lg mb-2 relative z-10">Pro Tip!</h4>
                <p class="text-blue-100 text-xs font-medium leading-relaxed relative z-10">
                    Mix difficulty levels to keep students engaged throughout the assessment!
                </p>
            </div>
        </aside>

        <%-- ── CENTRE MAIN ───────────────────────────────────────────────── --%>
        <main class="wizard-centre"><div class="wizard-centre-inner">
            <div class="px-8 pt-8 pb-5 flex-shrink-0 lg:px-10">
                <div class="step-chip mb-3"><span class="material-symbols-outlined fill-icon" style="font-size:14px">quiz</span> Question Builder</div>
                <h2 class="text-3xl font-black text-math-dark-blue">Step 2: Define Questions</h2>
            </div>

            <div class="question-builder-grid flex-1 min-h-0 px-8 pb-4 lg:px-10">

                <%-- ── Question Pool Panel ──────────────────────────────── --%>
                <div class="pool-panel">

                    <%-- Pool Header --%>
                    <div class="p-5 border-b-2 border-gray-100 bg-gray-50/50 flex-shrink-0">
                        <div class="flex items-center justify-between mb-3">
                            <h3 class="text-xs font-black text-math-dark-blue uppercase tracking-widest flex items-center gap-2">
                                <span class="material-symbols-outlined text-math-blue text-sm fill-icon">database</span>
                                Question Pool
                            </h3>
                            <%-- AI Generate button --%>
                            <button type="button" onclick="openAiPanel()"
                                class="flex items-center gap-2 px-4 py-2 bg-math-dark-blue text-white rounded-xl
                                       text-[10px] font-black uppercase tracking-wider hover:bg-math-blue transition-all">
                                <span class="material-symbols-outlined fill-icon text-primary text-sm">auto_awesome</span>
                                AI Generate
                                <span id="btnAiBadge" class="px-1.5 py-0.5 bg-primary text-math-dark-blue rounded-full text-[9px] font-black">0 Qs</span>
                            </button>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="text-[10px] font-bold text-gray-400 uppercase">Filter:</span>
                            <asp:DropDownList ID="ddlFilter" runat="server"
                                CssClass="text-[10px] font-black text-math-dark-blue border-none bg-transparent p-0 pr-6 cursor-pointer">
                                <asp:ListItem Text="ALL TOPICS" Value="all"/>
                                <asp:ListItem Text="CALCULUS"   Value="calculus"/>
                                <asp:ListItem Text="ALGEBRA"    Value="algebra"/>
                                <asp:ListItem Text="GEOMETRY"   Value="geometry"/>
                                <asp:ListItem Text="STATISTICS" Value="statistics"/>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <%-- END Pool Header --%>

                    <%-- Pool List --%>
                    <div class="flex-1 overflow-y-auto p-5 space-y-3 custom-scrollbar">
                        <asp:Repeater ID="rptQuestionPool" runat="server" OnItemDataBound="rptQuestionPool_ItemDataBound">
                            <ItemTemplate>
                                <div class="p-4 bg-white border-2 border-gray-100 rounded-2xl hover:border-math-blue hover:shadow-md transition-all cursor-pointer group pool-question"
                                     data-qid='<%# Eval("QuestionID") %>'
                                     data-difficulty='<%# Eval("Difficulty") %>'
                                     data-text='<%# System.Web.HttpUtility.HtmlAttributeEncode(Eval("QuestionText").ToString()) %>'
                                     data-points='<%# Eval("Points") %>'
                                     data-options='<asp:Literal ID="litOptionsJson" runat="server"></asp:Literal>'
                                     onclick="addToSelected(this)">
                                    <div class="flex items-center justify-between mb-2">
                                        <asp:Literal ID="litDiffBadge" runat="server"></asp:Literal>
                                        <div class="flex items-center gap-1.5">
                                            <span class="pool-selected-badge hidden items-center gap-1 px-2 py-0.5 bg-math-green/15 text-math-green text-[9px] font-black rounded-full">
                                                <span class="material-symbols-outlined" style="font-size:10px">check_circle</span> Added
                                            </span>
                                            <span class="pool-add-icon material-symbols-outlined text-gray-300 group-hover:text-math-blue transition-colors text-sm">add_circle</span>
                                        </div>
                                    </div>
                                    <p class="text-sm font-bold text-math-dark-blue line-clamp-2"><%# System.Web.HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %></p>
                                    <p class="text-[10px] font-bold text-gray-400 mt-1.5"><%# Eval("Points") %> pts (from question bank)</p>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <%-- END Pool List --%>

                </div>
                <%-- END Question Pool Panel --%>

                <%-- ── Selected Questions Panel ────────────────────────── --%>
                <div class="selected-panel">
                    <%-- Header --%>
                    <div class="p-5 border-b-2 border-gray-100 flex items-center justify-between bg-math-green/5 flex-shrink-0">
                        <h3 class="text-xs font-black text-math-dark-blue uppercase tracking-widest flex items-center gap-2">
                            <span class="material-symbols-outlined text-math-green text-sm fill-icon">checklist</span>
                            Selected Questions (<span id="selectedCount">0</span>)
                        </h3>
                        <span class="text-[10px] font-black text-gray-400 uppercase">
                            Total: <span id="totalPoints" class="text-math-dark-blue">0</span> pts
                        </span>
                    </div>

                    <%-- Card list — all cards live here, pagination hides/shows them --%>
                    <div class="flex-1 overflow-y-auto p-5 space-y-4 custom-scrollbar" id="selectedContainer">
                        <div class="border-2 border-dashed border-gray-200 rounded-3xl p-8 flex flex-col items-center justify-center text-gray-300" id="dropZone">
                            <span class="material-symbols-outlined text-4xl mb-2 opacity-40">add_circle</span>
                            <p class="text-xs font-black uppercase tracking-widest">Click questions to add here</p>
                        </div>
                    </div>

                    <%-- Pagination bar — hidden until > PAGE_SIZE questions --%>
                    <div id="selectedPager" class="hidden px-5 py-3 border-t-2 border-gray-100 bg-gray-50/60 flex items-center justify-between flex-shrink-0">
                        <button type="button" id="pagerPrev" onclick="changePage(-1)"
                            class="flex items-center gap-1.5 px-4 py-2 bg-white border-2 border-gray-200
                                   text-math-dark-blue font-black text-[10px] rounded-xl hover:bg-gray-50
                                   transition-all uppercase tracking-widest">
                            <span class="material-symbols-outlined text-sm">chevron_left</span> Prev
                        </button>
                        <span id="pagerLabel" class="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            Page 1 of 1
                        </span>
                        <button type="button" id="pagerNext" onclick="changePage(1)"
                            class="flex items-center gap-1.5 px-4 py-2 bg-white border-2 border-gray-200
                                   text-math-dark-blue font-black text-[10px] rounded-xl hover:bg-gray-50
                                   transition-all uppercase tracking-widest">
                            Next <span class="material-symbols-outlined text-sm">chevron_right</span>
                        </button>
                    </div>
                </div>
                <%-- END Selected Questions Panel --%>

            </div>

            <%-- Bottom action bar --%>
            <div class="px-8 py-5 flex justify-between flex-shrink-0 border-t-2 border-gray-100 bg-white/80 backdrop-blur-sm lg:px-10">
                <button type="button" onclick="goBack()"
                    class="flex items-center gap-3 px-8 py-4 bg-white border-2 border-gray-200
                           text-math-dark-blue font-black text-sm rounded-2xl hover:bg-gray-50
                           transition-colors uppercase tracking-widest">
                    <span class="material-symbols-outlined text-lg">arrow_back</span> Previous
                </button>
                <asp:Button ID="btnSaveQuestions" runat="server"
                    Text="Next: Review &amp; Save"
                    OnClick="btnSaveQuestions_Click"
                    OnClientClick="return serializeAndValidate()"
                    CssClass="flex items-center gap-3 rounded-2xl bg-primary px-10 py-4 text-sm font-black uppercase tracking-[0.18em] text-math-dark-blue shadow-[0_14px_28px_rgba(249,208,6,0.24)] transition-all hover:-translate-y-0.5 cursor-pointer border-none" />
            </div>
        </main>
        <%-- END CENTRE MAIN --%>

        <%-- ── RIGHT SIDEBAR ─────────────────────────────────────────────── --%>
        <aside class="wizard-right">
            <div class="p-6 border-b border-gray-100 flex-shrink-0">
                <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-5">TEMPLATE SETTINGS</h3>
                <div class="flex flex-col gap-2">
                    <label class="text-[10px] font-black text-math-blue uppercase tracking-widest">TEMPLATE TITLE</label>
                    <p id="rightPanelTitleDisplay"
                       class="w-full px-5 py-4 bg-gray-50 border-2 border-transparent rounded-xl
                              text-math-dark-blue text-sm font-bold"></p>
                    <p class="text-[10px] text-gray-400 font-medium">Title is set in Step 1 and can be changed in Step 3.</p>
                </div>
            </div>
            <div class="p-6 flex flex-col gap-5 flex-1">
                <label class="text-[10px] font-black text-math-blue uppercase tracking-widest flex items-center gap-2">
                    <span class="size-1.5 rounded-full bg-math-blue"></span>COMPOSITION SUMMARY
                </label>
                <div class="space-y-3 p-4 bg-gray-50 rounded-2xl border border-gray-100 text-xs font-bold text-gray-600">
                    <div class="flex justify-between">
                        <span class="text-math-green">Easy quota</span>
                        <span id="summaryEasy" class="text-math-dark-blue">0 questions</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-math-blue">Medium quota</span>
                        <span id="summaryMedium" class="text-math-dark-blue">0 questions</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-primary">Hard quota</span>
                        <span id="summaryHard" class="text-math-dark-blue">0 questions</span>
                    </div>
                </div>
                <p class="text-[10px] text-gray-400 font-medium leading-relaxed">
                    Go back to Step 1 to change the question composition.
                </p>
            </div>
        </aside>

    </div>
    <%-- END wizard-layout --%>

    <%-- ═══════════════════════════════════════════════════════════
         AI QUESTION GENERATOR MODAL
         ═══════════════════════════════════════════════════════════ --%>
    <div id="aiModal" class="fixed inset-0 z-[200] hidden items-center justify-center p-4">
        <%-- Backdrop --%>
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" onclick="closeAiPanel()"></div>

        <%-- Modal card --%>
        <div class="relative w-full max-w-2xl bg-white rounded-[2rem] shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">

            <%-- Modal Header --%>
            <div class="bg-gradient-to-br from-math-dark-blue to-math-blue p-6 flex items-center justify-between flex-shrink-0">
                <div class="flex items-center gap-3">
                    <div class="size-10 rounded-2xl bg-primary flex items-center justify-center">
                        <span class="material-symbols-outlined fill-icon text-math-dark-blue text-xl">auto_awesome</span>
                    </div>
                    <div>
                        <div class="text-[10px] font-black text-white/60 uppercase tracking-widest">Powered by Gemini AI</div>
                        <h3 class="text-lg font-black text-white">Generate Questions</h3>
                    </div>
                </div>
                <button type="button" onclick="closeAiPanel()"
                    class="size-9 rounded-xl bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all text-white">
                    <span class="material-symbols-outlined text-lg">close</span>
                </button>
            </div>

            <%-- Modal Body --%>
            <div class="flex-1 overflow-y-auto p-6 space-y-5">

                <%-- Topic --%>
                <div class="space-y-2">
                    <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Topic / Concept</label>
                    <input type="text" id="aiTopic"
                        placeholder="e.g. Quadratic Equations, Pythagoras Theorem..."
                        class="w-full px-5 py-4 bg-gray-50 border-2 border-transparent rounded-xl
                               text-math-dark-blue font-bold placeholder:text-gray-300
                               focus:border-math-blue focus:outline-none transition-colors" />
                </div>

                <%-- Question Type --%>
                <div class="space-y-2">
                    <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Question Type</label>
                    <select id="aiType"
                        class="w-full px-4 py-3 bg-gray-50 border-2 border-transparent rounded-xl
                               text-math-dark-blue font-bold text-sm focus:border-math-blue focus:outline-none">
                        <option value="mcq">Multiple Choice (MCQ)</option>
                        <option value="true_false">True / False</option>
                    </select>
                </div>

                <%-- Difficulty tier picker — one at a time --%>
                <div class="space-y-2">
                    <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Difficulty Tier</label>
                    <div class="grid grid-cols-3 gap-3" id="aiTierPicker">
                        <button type="button" data-tier="Easy"
                            onclick="selectAiTier('Easy')"
                            class="ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2
                                   border-math-green/30 bg-math-green/5 hover:bg-math-green/15
                                   transition-all group cursor-pointer">
                            <span class="text-[9px] font-black text-math-green uppercase tracking-wider mb-1">Easy</span>
                            <span id="aiTierCountEasy" class="text-2xl font-black text-math-dark-blue">0</span>
                            <span class="text-[9px] text-gray-400 font-bold">questions</span>
                        </button>
                        <button type="button" data-tier="Medium"
                            onclick="selectAiTier('Medium')"
                            class="ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2
                                   border-math-blue/30 bg-math-blue/5 hover:bg-math-blue/15
                                   transition-all group cursor-pointer">
                            <span class="text-[9px] font-black text-math-blue uppercase tracking-wider mb-1">Medium</span>
                            <span id="aiTierCountMedium" class="text-2xl font-black text-math-dark-blue">0</span>
                            <span class="text-[9px] text-gray-400 font-bold">questions</span>
                        </button>
                        <button type="button" data-tier="Hard"
                            onclick="selectAiTier('Hard')"
                            class="ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2
                                   border-primary/30 bg-primary/5 hover:bg-primary/15
                                   transition-all group cursor-pointer">
                            <span class="text-[9px] font-black text-primary uppercase tracking-wider mb-1">Hard</span>
                            <span id="aiTierCountHard" class="text-2xl font-black text-math-dark-blue">0</span>
                            <span class="text-[9px] text-gray-400 font-bold">questions</span>
                        </button>
                    </div>
                    <p class="text-[9px] text-gray-400 font-medium">
                        Click a tier to select it. Count is set from your Step 1 quotas.
                        Tiers with quota 0 are disabled.
                    </p>
                </div>

                <%-- Generate button --%>
                <button type="button" id="btnAiGenerate" onclick="generateAiQuestions()"
                    class="w-full py-4 bg-math-dark-blue text-white font-black text-sm uppercase tracking-widest
                           rounded-2xl hover:bg-math-blue transition-all flex items-center justify-center gap-3">
                    <span class="material-symbols-outlined fill-icon">auto_awesome</span>
                    <span id="btnAiGenerateLabel">Select a Tier Above</span>
                </button>

                <%-- Loading spinner --%>
                <div id="aiLoading" class="hidden flex-col items-center gap-4 py-6">
                    <div class="relative size-16">
                        <div class="absolute inset-0 rounded-full border-4 border-math-blue/20"></div>
                        <div class="absolute inset-0 rounded-full border-4 border-t-math-blue animate-spin"></div>
                        <span class="material-symbols-outlined absolute inset-0 flex items-center justify-center text-math-blue fill-icon text-2xl">auto_awesome</span>
                    </div>
                    <p class="text-sm font-bold text-gray-500" id="aiLoadingText">Generating questions with AI...</p>
                </div>

                <%-- Error --%>
                <div id="aiError" class="hidden rounded-2xl border border-red-200 bg-red-50 px-4 py-3">
                    <div class="flex items-center gap-3">
                        <span class="material-symbols-outlined text-red-500">error</span>
                        <span id="aiErrorText" class="text-red-700 font-semibold text-sm"></span>
                    </div>
                </div>

                <%-- Results --%>
                <div id="aiResults" class="hidden space-y-3">
                    <div class="flex items-center justify-between px-1">
                        <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest" id="aiResultsLabel">
                            Generated Questions - click to add
                        </h4>
                        <button type="button" onclick="addAllAiQuestions()"
                            class="flex items-center gap-1 px-4 py-2 bg-math-green text-white rounded-xl
                                   text-[10px] font-black uppercase tracking-wider hover:bg-math-green/80 transition-all">
                            <span class="material-symbols-outlined text-sm">playlist_add</span>Add All
                        </button>
                    </div>
                    <div id="aiQuestionsList" class="space-y-3 max-h-[360px] overflow-y-auto pr-1"></div>
                </div>

            </div>
            <%-- END Modal Body --%>
        </div>
        <%-- END Modal card --%>
    </div>
    <%-- END AI Modal --%>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        // ── State ─────────────────────────────────────────────────────────
        var selectedQuestions = [];
        var aiGeneratedQuestions = [];
        var QUOTA = { Easy: 0, Medium: 0, Hard: 0 };
        var hasQuota = false;

        // ── Navigation ────────────────────────────────────────────────────
        function goBack() {
            var aid = document.getElementById('<%= hdnAssessmentId.ClientID %>').value;
            var cid = document.getElementById('<%= hdnCourseId.ClientID %>').value;
            var qe = document.getElementById('<%= hdnQuotaEasy.ClientID %>').value || 0;
            var qm = document.getElementById('<%= hdnQuotaMedium.ClientID %>').value || 0;
            var qh = document.getElementById('<%= hdnQuotaHard.ClientID %>').value || 0;
            window.location.href =
                'assessmentTemplates.aspx?assessmentId=' + aid +
                '&courseId=' + cid +
                '&easy=' + qe + '&medium=' + qm + '&hard=' + qh;
        }

        // ── Escape helpers ────────────────────────────────────────────────
        function esc(s) {
            return String(s)
                .replace(/&/g, '&amp;').replace(/"/g, '&quot;')
                .replace(/</g, '&lt;').replace(/>/g, '&gt;');
        }
        function htmlEsc(s) { return esc(s || ''); }

        // ── Build options HTML (shared by pool cards & selected cards) ────
        function buildOptionsHtml(opts) {
            if (!opts || opts.length === 0)
                return '<p class="text-[10px] text-gray-400 italic mt-2">No options stored for this question.</p>';
            var rows = '';
            opts.forEach(function (opt) {
                var isCorrect = opt.isCorrect;
                var label = esc(opt.optionLabel || '');
                var badgeCls = isCorrect
                    ? 'size-6 flex items-center justify-center rounded-lg bg-math-green text-white text-[10px] font-black flex-shrink-0'
                    : 'size-6 flex items-center justify-center rounded-lg bg-gray-100 text-math-dark-blue text-[10px] font-black flex-shrink-0';
                var rowCls = isCorrect
                    ? 'flex items-center gap-2 px-3 py-2 bg-math-green/5 border border-math-green/20 rounded-xl'
                    : 'flex items-center gap-2 px-3 py-2 bg-gray-50 border border-gray-100 rounded-xl';
                var tick = isCorrect
                    ? '<span class="material-symbols-outlined text-math-green ml-auto" style="font-size:14px">check_circle</span>'
                    : '';
                rows += '<div class="' + rowCls + '">'
                    + '<span class="' + badgeCls + '">' + label + '</span>'
                    + '<span class="text-xs font-bold text-math-dark-blue flex-1 opt-display" data-raw-opt="' + htmlEsc(opt.optionText || '') + '"></span>'
                    + tick + '</div>';
            });
            return '<div class="mt-3 space-y-1.5 border-t border-gray-100 pt-3">'
                + '<p class="text-[9px] font-black text-gray-400 uppercase tracking-wider mb-2">'
                + 'Answer Options <span class="text-math-green">(&#x2714; = correct)</span></p>'
                + rows + '</div>';
        }

        // ── Build selected-question card HTML ─────────────────────────────
        function buildCard(num, qid, diff, text, pts, opts) {
            var cls = diff === 'Easy' ? 'bg-math-green/10 text-math-green'
                : diff === 'Medium' ? 'bg-math-blue/10 text-math-blue'
                    : 'bg-primary/10 text-primary';
            return '<div class="bg-white border-2 border-math-green/20 rounded-2xl p-5 shadow-sm selected-question"'
                + ' data-qid="' + esc(qid) + '" data-difficulty="' + esc(diff) + '" data-points="' + pts + '">'
                + '<div class="flex justify-between items-start mb-3">'
                + '<div class="flex gap-2 items-center">'
                + '<span class="size-6 bg-math-dark-blue text-white text-[10px] font-black rounded-lg flex items-center justify-center q-number">' + num + '</span>'
                + '<span class="px-2 py-0.5 ' + cls + ' text-[9px] font-black rounded-lg uppercase">' + diff + '</span>'
                + '</div>'
                + '<div class="flex items-center gap-2">'
                + '<span class="points-display px-3 py-1.5 bg-gray-50 border-2 border-gray-100 text-math-dark-blue text-xs font-black rounded-lg">' + pts + '</span>'
                + '<span class="text-[9px] font-black text-gray-400">pts</span>'
                + '<button type="button" onclick="removeQuestion(this)" class="text-gray-300 hover:text-red-400 transition-colors ml-1">'
                + '<span class="material-symbols-outlined text-base">delete</span></button>'
                + '</div></div>'
                + '<p class="text-sm font-bold text-math-dark-blue q-text mb-1" data-raw-text="' + htmlEsc(text) + '"></p>'
                + buildOptionsHtml(opts || [])
                + '</div>';
        }

        // ── Apply text content safely (avoids XSS via innerHTML) ──────────
        function applyCardText(container) {
            container.querySelectorAll('.q-text[data-raw-text]').forEach(function (el) {
                el.textContent = el.getAttribute('data-raw-text');
                el.removeAttribute('data-raw-text');
            });
            container.querySelectorAll('.opt-display[data-raw-opt]').forEach(function (el) {
                el.textContent = el.getAttribute('data-raw-opt');
                el.removeAttribute('data-raw-opt');
            });
        }

        // ── Quota ─────────────────────────────────────────────────────────
        function loadQuota() {
            var qe = parseInt(document.getElementById('<%= hdnQuotaEasy.ClientID %>').value, 10) || 0;
            var qm = parseInt(document.getElementById('<%= hdnQuotaMedium.ClientID %>').value, 10) || 0;
            var qh = parseInt(document.getElementById('<%= hdnQuotaHard.ClientID %>').value,   10) || 0;
            QUOTA    = { Easy: qe, Medium: qm, Hard: qh };
            hasQuota = (qe + qm + qh) > 0;
            document.getElementById('summaryEasy').textContent   = qe + ' questions';
            document.getElementById('summaryMedium').textContent = qm + ' questions';
            document.getElementById('summaryHard').textContent   = qh + ' questions';
            // Update AI badge
            var badge = document.getElementById('btnAiBadge');
            if (badge) badge.textContent = (qe + qm + qh) + ' Qs';
        }

        function countSelected(diff) {
            var n = 0;
            document.querySelectorAll('.selected-question[data-difficulty="' + diff + '"]')
                    .forEach(function() { n++; });
            return n;
        }

        function updateQuotaBars() {
            ['Easy','Medium','Hard'].forEach(function(diff) {
                var used  = countSelected(diff);
                var quota = QUOTA[diff];
                var label = document.getElementById('quota' + diff + 'Label');
                var bar   = document.getElementById('quota' + diff + 'Bar');
                var fill  = document.getElementById('quota' + diff + 'Fill');
                if (label) label.textContent = used + ' / ' + quota;
                if (fill)  fill.style.width  = quota > 0 ? Math.min(used / quota * 100, 100) + '%' : '0%';
                if (bar) {
                    if (quota > 0 && used > quota) bar.classList.add('quota-exceeded');
                    else bar.classList.remove('quota-exceeded');
                }
            });
        }

        // ── Page init ─────────────────────────────────────────────────────
        window.addEventListener('DOMContentLoaded', function () {
            loadQuota();
            var poolEmpty = document.getElementById('poolEmptyState');
            if (poolEmpty) poolEmpty.classList.toggle('hidden', document.querySelectorAll('.pool-question').length > 0);

            var titleDisplay = document.getElementById('rightPanelTitleDisplay');
            var templateTitle = document.getElementById('<%= hdnTemplateTitle.ClientID %>').value || '';
            if (titleDisplay) titleDisplay.textContent = templateTitle || 'Untitled Assessment';

            var raw = document.getElementById('<%= hdnSelectedQuestionsJson.ClientID %>').value;
            if (raw && raw !== '[]' && raw !== '') {
                var items;
                try { items = JSON.parse(raw); } catch(e) { items = []; }
                var container = document.getElementById('selectedContainer');
                var dropZone  = document.getElementById('dropZone');
                var num = 1;
                items.forEach(function(q) {
                    var diff = q.difficulty || diffFromPoints(q.points);
                    container.insertAdjacentHTML('beforeend',
                        buildCard(num, q.questionId, diff, q.questionText, q.points, q.options || []));
                    applyCardText(container);
                    selectedQuestions.push(q.questionId);
                    num++;
                    var poolCard = document.querySelector('.pool-question[data-qid="' + q.questionId + '"]');
                    if (poolCard) {
                        var badge   = poolCard.querySelector('.pool-selected-badge');
                        var addIcon = poolCard.querySelector('.pool-add-icon');
                        if (badge)   badge.classList.replace('hidden','flex');
                        if (addIcon) addIcon.classList.add('hidden');
                        poolCard.dataset.selected = 'true';
                    }
                });
                container.appendChild(dropZone);
                updateCounts();
                updateQuotaBars();
                currentPage = 1;
                renderPage();
            }
        });

        function diffFromPoints(pts) {
            return pts <= 5 ? 'Easy' : pts <= 10 ? 'Medium' : 'Hard';
        }

        // ── Pool interactions ─────────────────────────────────────────────
        function addToSelected(el) {
            var qid = el.dataset.qid;
            if (el.dataset.selected === 'true') return;
            var diff = el.dataset.difficulty;
            if (hasQuota && QUOTA[diff] !== undefined) {
                var used = countSelected(diff);
                if (used >= QUOTA[diff]) {
                    alert('You have reached the maximum for ' + diff + ' questions (' + QUOTA[diff] + ').');
                    return;
                }
            }
            selectedQuestions.push(qid);
            var text = el.dataset.text || '';
            var pts  = parseInt(el.dataset.points) || 5;
            var opts = [];
            try { if (el.dataset.options) opts = JSON.parse(el.dataset.options); } catch(e) {}
            var container = document.getElementById('selectedContainer');
            var dropZone  = document.getElementById('dropZone');
            var num = document.querySelectorAll('.selected-question').length + 1;
            container.insertAdjacentHTML('beforeend', buildCard(num, qid, diff, text, pts, opts));
            applyCardText(container);
            container.appendChild(dropZone);
            // Jump to last page so the new card is visible
            var newTotal = document.querySelectorAll('.selected-question').length;
            currentPage  = Math.ceil(newTotal / PAGE_SIZE);
            updateCounts();
            updateQuotaBars();
            var badge   = el.querySelector('.pool-selected-badge');
            var addIcon = el.querySelector('.pool-add-icon');
            if (badge)   badge.classList.replace('hidden','flex');
            if (addIcon) addIcon.classList.add('hidden');
            el.dataset.selected = 'true';
        }

        function removeQuestion(btn) {
            var card = btn.closest('.selected-question');
            var qid  = card.dataset.qid;
            selectedQuestions = selectedQuestions.filter(function(id) { return id !== qid; });
            card.remove();

            // If removing the last card on a page, step back one page
            var remaining  = document.querySelectorAll('.selected-question').length;
            var totalPages = Math.max(1, Math.ceil(remaining / PAGE_SIZE));
            if (currentPage > totalPages) currentPage = totalPages;

            renumberQuestions();
            updateCounts();
            updateQuotaBars();
            if (!qid.startsWith('AI_')) {
                var poolCard = document.querySelector('.pool-question[data-qid="' + qid + '"]');
                if (poolCard) {
                    var badge   = poolCard.querySelector('.pool-selected-badge');
                    var addIcon = poolCard.querySelector('.pool-add-icon');
                    if (badge)   badge.classList.replace('flex','hidden');
                    if (addIcon) addIcon.classList.remove('hidden');
                    poolCard.dataset.selected = 'false';
                }
            }
        }

        // ── Pagination ────────────────────────────────────────────────────
        var PAGE_SIZE    = 4;   // cards visible per page
        var currentPage  = 1;

        function renumberQuestions() {
            // Always renumber ALL cards (DOM order), regardless of visibility
            document.querySelectorAll('.selected-question').forEach(function(c, i) {
                var n = c.querySelector('.q-number');
                if (n) n.innerText = i + 1;
            });
        }

        function updateCounts() {
            var cards = document.querySelectorAll('.selected-question');
            var dropZone = document.getElementById('dropZone');
            document.getElementById('selectedCount').innerText = cards.length;
            var t = 0;
            cards.forEach(function(c) { t += parseInt(c.dataset.points) || 0; });
            document.getElementById('totalPoints').innerText = t;
            if (dropZone) dropZone.style.display = cards.length === 0 ? '' : 'none';
            renderPage();
        }

        function renderPage() {
            var cards = Array.from(document.querySelectorAll('.selected-question'));
            var total = cards.length;
            var totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
            var dropZone = document.getElementById('dropZone');

            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;

            var start = (currentPage - 1) * PAGE_SIZE;
            var end = start + PAGE_SIZE;

            cards.forEach(function(c, i) {
                c.style.display = (i >= start && i < end) ? '' : 'none';
            });

            if (dropZone) {
                dropZone.style.display = total === 0 ? '' : 'none';
            }

            var pager = document.getElementById('selectedPager');
            if (total > PAGE_SIZE) {
                pager.classList.remove('hidden');
                document.getElementById('pagerLabel').textContent = 'Page ' + currentPage + ' of ' + totalPages;
                document.getElementById('pagerPrev').disabled = (currentPage === 1);
                document.getElementById('pagerNext').disabled = (currentPage === totalPages);
                document.getElementById('pagerPrev').style.opacity = (currentPage === 1) ? '0.35' : '1';
                document.getElementById('pagerNext').style.opacity = (currentPage === totalPages) ? '0.35' : '1';
            } else {
                pager.classList.add('hidden');
            }
        }

        function changePage(delta) {
            var cards = document.querySelectorAll('.selected-question');
            var totalPages = Math.max(1, Math.ceil(cards.length / PAGE_SIZE));
            currentPage = Math.min(Math.max(currentPage + delta, 1), totalPages);
            renderPage();
            var container = document.getElementById('selectedContainer');
            if (container) container.scrollTop = 0;
        }

        // ── Serialize before submit ───────────────────────────────────────
        function serializeAndValidate() {
            var cards = document.querySelectorAll('.selected-question');
            if (cards.length === 0) { alert('Please add at least one question.'); return false; }

            var questions = [];
            cards.forEach(function(card) {
                var qid = card.dataset.qid || '';

                if (qid.startsWith('AI_')) {
                    var parts = qid.split('_');
                    var idx   = parseInt(parts[parts.length - 1]);
                    var q     = aiGeneratedQuestions[idx];
                    if (q) {
                        questions.push({
                            questionId:   '',
                            isAiGenerated: true,
                            questionText: q.question,
                            answer:       q.answer,
                            difficulty:   card.dataset.difficulty,
                            points:       parseInt(card.dataset.points) || 5,
                            aiOptions:    q.options || null,
                            questionType: card.dataset.qtype || 'mcq'
                        });
                    }
                } else {
                    questions.push({ questionId: qid, isAiGenerated: false });
                }
            });

            document.getElementById('<%= hdnQuestionsJson.ClientID %>').value = JSON.stringify(questions);
            return true;
        }

        // ═══════════════════════════════════════════════════════════
        //  AI QUESTION GENERATOR — single-tier-at-a-time flow
        // ═══════════════════════════════════════════════════════════

        var aiSelectedTier = null; // 'Easy' | 'Medium' | 'Hard'

        // Tier button colours
        var TIER_SELECTED_CLS = {
            Easy:   'ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2 border-math-green bg-math-green/20 ring-2 ring-math-green/40 transition-all cursor-pointer scale-[1.04]',
            Medium: 'ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2 border-math-blue  bg-math-blue/20  ring-2 ring-math-blue/40  transition-all cursor-pointer scale-[1.04]',
            Hard:   'ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2 border-primary     bg-primary/20    ring-2 ring-primary/40    transition-all cursor-pointer scale-[1.04]'
        };
        var TIER_DEFAULT_CLS = {
            Easy:   'ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2 border-math-green/30 bg-math-green/5  hover:bg-math-green/15 transition-all cursor-pointer',
            Medium: 'ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2 border-math-blue/30  bg-math-blue/5   hover:bg-math-blue/15  transition-all cursor-pointer',
            Hard:   'ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2 border-primary/30    bg-primary/5     hover:bg-primary/15    transition-all cursor-pointer'
        };
        var TIER_DISABLED_CLS = 'ai-tier-btn flex flex-col items-center p-4 rounded-2xl border-2 border-gray-200 bg-gray-50 opacity-40 cursor-not-allowed transition-all';

        function openAiPanel() {
            var modal = document.getElementById('aiModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            resetAiPanel();
        }

        function closeAiPanel() {
            var modal = document.getElementById('aiModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }

        function resetAiPanel() {
            aiSelectedTier = null;
            aiGeneratedQuestions = [];
            document.getElementById('aiResults').classList.add('hidden');
            document.getElementById('aiError').classList.add('hidden');
            document.getElementById('aiLoading').classList.add('hidden');
            document.getElementById('aiLoading').classList.remove('flex');
            document.getElementById('aiQuestionsList').innerHTML = '';

            var qe = parseInt(document.getElementById('<%= hdnQuotaEasy.ClientID %>').value,   10) || 0;
            var qm = parseInt(document.getElementById('<%= hdnQuotaMedium.ClientID %>').value, 10) || 0;
            var qh = parseInt(document.getElementById('<%= hdnQuotaHard.ClientID %>').value,   10) || 0;

            // Populate counts and enable/disable buttons
            var counts = { Easy: qe, Medium: qm, Hard: qh };
            ['Easy','Medium','Hard'].forEach(function(d) {
                document.getElementById('aiTierCount' + d).textContent = counts[d];
                var btn = document.querySelector('[data-tier="' + d + '"]');
                if (!btn) return;
                if (counts[d] <= 0) {
                    btn.className = TIER_DISABLED_CLS;
                    btn.disabled  = true;
                } else {
                    btn.className = TIER_DEFAULT_CLS[d];
                    btn.disabled  = false;
                }
            });

            // Reset generate button
            var lbl = document.getElementById('btnAiGenerateLabel');
            if (lbl) lbl.textContent = 'Select a Tier Above';
            document.getElementById('btnAiGenerate').disabled = true;
            document.getElementById('btnAiGenerate').classList.add('opacity-50');
        }

        function selectAiTier(tier) {
            var qe = parseInt(document.getElementById('<%= hdnQuotaEasy.ClientID %>').value,   10) || 0;
            var qm = parseInt(document.getElementById('<%= hdnQuotaMedium.ClientID %>').value, 10) || 0;
            var qh = parseInt(document.getElementById('<%= hdnQuotaHard.ClientID %>').value,   10) || 0;
            var counts = { Easy: qe, Medium: qm, Hard: qh };
            if (counts[tier] <= 0) return; // disabled

            aiSelectedTier = tier;

            // Update button visuals
            ['Easy','Medium','Hard'].forEach(function(d) {
                var btn = document.querySelector('[data-tier="' + d + '"]');
                if (!btn || counts[d] <= 0) return;
                btn.className = (d === tier) ? TIER_SELECTED_CLS[d] : TIER_DEFAULT_CLS[d];
            });

            // Enable generate button
            var lbl = document.getElementById('btnAiGenerateLabel');
            if (lbl) lbl.textContent = 'Generate ' + counts[tier] + ' ' + tier + ' Questions';
            document.getElementById('btnAiGenerate').disabled = false;
            document.getElementById('btnAiGenerate').classList.remove('opacity-50');

            // Clear previous results when tier changes
            document.getElementById('aiResults').classList.add('hidden');
            document.getElementById('aiError').classList.add('hidden');
            document.getElementById('aiQuestionsList').innerHTML = '';
            aiGeneratedQuestions = [];
        }

        // ── Single-tier generate ──────────────────────────────────────────
        async function generateAiQuestions() {
            if (!aiSelectedTier) { alert('Please select a difficulty tier first.'); return; }

            var topic = document.getElementById('aiTopic').value.trim();
            var type  = document.getElementById('aiType').value;
            if (!topic) { alert('Please enter a topic / concept first.'); return; }

            var counts = {
                Easy:   parseInt(document.getElementById('<%= hdnQuotaEasy.ClientID %>').value,   10) || 0,
                Medium: parseInt(document.getElementById('<%= hdnQuotaMedium.ClientID %>').value, 10) || 0,
                Hard:   parseInt(document.getElementById('<%= hdnQuotaHard.ClientID %>').value, 10) || 0
            };
            var count = counts[aiSelectedTier];
            if (count <= 0) { alert('Quota for ' + aiSelectedTier + ' is 0. Go back to Step 1 to set it.'); return; }

            // Show loading
            document.getElementById('aiResults').classList.add('hidden');
            document.getElementById('aiError').classList.add('hidden');
            document.getElementById('aiLoading').classList.remove('hidden');
            document.getElementById('aiLoading').classList.add('flex');
            document.getElementById('aiLoadingText').textContent =
                'Generating ' + count + ' ' + aiSelectedTier + ' questions...';
            document.getElementById('btnAiGenerate').disabled = true;
            aiGeneratedQuestions = [];

            try {
                var res = await fetch('AiQuestionGenerator.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        topic: topic,
                        type: type,
                        level: aiSelectedTier,
                        count: count
                    })
                });

                var data = await res.json();

                document.getElementById('aiLoading').classList.add('hidden');
                document.getElementById('aiLoading').classList.remove('flex');
                document.getElementById('btnAiGenerate').disabled = false;

                if (data.ok && data.questions && data.questions.length > 0) {
                    data.questions.forEach(function (q) { q._level = aiSelectedTier; });
                    aiGeneratedQuestions = data.questions;
                    renderAiQuestions(aiGeneratedQuestions, type);
                } else {
                    var errMsg = data.error || 'No questions returned. Please retry.';
                    document.getElementById('aiErrorText').textContent = errMsg;
                    document.getElementById('aiError').classList.remove('hidden');
                }
            } catch (err) {
                document.getElementById('aiLoading').classList.add('hidden');
                document.getElementById('aiLoading').classList.remove('flex');
                document.getElementById('btnAiGenerate').disabled = false;
                document.getElementById('aiErrorText').textContent =
                    'Network error - please check your connection and retry. (' + err.message + ')';
                document.getElementById('aiError').classList.remove('hidden');
            }
        }

                function renderAiQuestions(questions, type) {
            var list = document.getElementById('aiQuestionsList');
            list.innerHTML = '';

            questions.forEach(function (q, i) {
                var level = q._level || 'Medium';
                var pts = level === 'Easy' ? 5 : level === 'Medium' ? 10 : 15;

                var optionsHtml = '';
                if (type === 'mcq' && q.options) {
                    optionsHtml = '<div class="mt-3 space-y-1.5 border-t border-gray-100 pt-3">';
                    ['A', 'B', 'C', 'D'].forEach(function (label) {
                        var text = q.options[label] || '';
                        var isCorrect = (q.answer === label);
                        var cls = isCorrect
                            ? 'flex items-center gap-2 px-3 py-2 bg-math-green/5 border border-math-green/20 rounded-xl'
                            : 'flex items-center gap-2 px-3 py-2 bg-gray-50 border border-gray-100 rounded-xl';
                        var badgeCls = isCorrect
                            ? 'size-6 flex items-center justify-center rounded-lg bg-math-green text-white text-[10px] font-black flex-shrink-0'
                            : 'size-6 flex items-center justify-center rounded-lg bg-gray-100 text-math-dark-blue text-[10px] font-black flex-shrink-0';
                        var tick = isCorrect
                            ? '<span class="material-symbols-outlined text-math-green ml-auto" style="font-size:14px">check_circle</span>'
                            : '';
                        optionsHtml += '<div class="' + cls + '">'
                            + '<span class="' + badgeCls + '">' + label + '</span>'
                            + '<span class="text-xs font-bold text-math-dark-blue flex-1">' + htmlEsc(text) + '</span>'
                            + tick + '</div>';
                    });
                    optionsHtml += '</div>';
                } else if (type === 'true_false') {
                    var tfTrue = (q.answer === 'True') ? 'bg-math-green/5 border-math-green/20 text-math-green' : 'bg-gray-50 border-gray-100 text-gray-500';
                    var tfFalse = (q.answer === 'False') ? 'bg-math-green/5 border-math-green/20 text-math-green' : 'bg-gray-50 border-gray-100 text-gray-500';
                    optionsHtml = '<div class="mt-3 flex gap-3 border-t border-gray-100 pt-3">'
                        + '<span class="flex-1 text-center py-2 border rounded-xl text-xs font-black ' + tfTrue + '">True</span>'
                        + '<span class="flex-1 text-center py-2 border rounded-xl text-xs font-black ' + tfFalse + '">False</span>'
                        + '</div>';
                }

                var diffCls = level === 'Easy' ? 'bg-math-green/10 text-math-green'
                    : level === 'Medium' ? 'bg-math-blue/10 text-math-blue'
                    : 'bg-primary/10 text-primary';

                var explanationHtml = q.explanation
                    ? '<p class="mt-3 text-[10px] text-gray-400 font-medium italic border-t border-gray-100 pt-3">Hint: ' + htmlEsc(q.explanation) + '</p>'
                    : '';

                var card = document.createElement('div');
                card.className = 'p-4 bg-white border-2 border-gray-100 rounded-2xl hover:border-math-blue hover:shadow-md transition-all cursor-pointer group ai-gen-card';
                card.dataset.index = i;
                card.dataset.added = 'false';
                card.innerHTML =
                    '<div class="flex items-start justify-between mb-2">'
                    + '<span class="px-2 py-0.5 ' + diffCls + ' text-[9px] font-black rounded-lg uppercase">' + level + '</span>'
                    + '<div class="flex items-center gap-2">'
                    + '<span class="ai-add-badge hidden items-center gap-1 px-2 py-0.5 bg-math-green/15 text-math-green text-[9px] font-black rounded-full">'
                    + '<span class="material-symbols-outlined" style="font-size:10px">check_circle</span> Added</span>'
                    + '<span class="ai-add-icon material-symbols-outlined text-gray-300 group-hover:text-math-blue transition-colors text-sm">add_circle</span>'
                    + '</div></div>'
                    + '<p class="text-sm font-bold text-math-dark-blue">' + htmlEsc(q.question) + '</p>'
                    + optionsHtml
                    + explanationHtml
                    + '<p class="mt-3 text-[10px] font-black text-gray-400 uppercase tracking-widest">'
                    + pts + ' suggested points</p>';

                card.addEventListener('click', function () {
                    addAiQuestionToSelected(this, i, type, level, pts);
                });

                list.appendChild(card);
            });

            document.getElementById('aiResults').classList.remove('hidden');
        }

        function addAiQuestionToSelected(card, index, type, level, pts) {
            if (card.dataset.added === 'true') return;
            var q = aiGeneratedQuestions[index];
            if (!q) return;

            if (hasQuota && QUOTA[level] !== undefined) {
                var used = countSelected(level);
                if (used >= QUOTA[level]) {
                    alert('You have reached the maximum for ' + level + ' questions (' + QUOTA[level] + ').');
                    return;
                }
            }

            var tempQid = 'AI_' + Date.now() + '_' + index;
            var opts = [];
            if (type === 'mcq' && q.options) {
                ['A', 'B', 'C', 'D'].forEach(function (label) {
                    opts.push({ optionLabel: label, optionText: q.options[label] || '', isCorrect: (q.answer === label) });
                });
            } else if (type === 'true_false') {
                opts.push({ optionLabel: 'A', optionText: 'True', isCorrect: q.answer === 'True' });
                opts.push({ optionLabel: 'B', optionText: 'False', isCorrect: q.answer === 'False' });
            }

            var container = document.getElementById('selectedContainer');
            var dropZone = document.getElementById('dropZone');
            var num = document.querySelectorAll('.selected-question').length + 1;

            container.insertAdjacentHTML('beforeend', buildCard(num, tempQid, level, q.question, pts, opts));
            applyCardText(container);
            // stamp question type so serializeAndValidate can read it
            var newCard = container.querySelector('[data-qid="' + tempQid + '"]');
            if (newCard) newCard.dataset.qtype = type;
            container.appendChild(dropZone);

            selectedQuestions.push(tempQid);
            // Jump to last page so new card is visible
            var newTotal = document.querySelectorAll('.selected-question').length;
            currentPage = Math.ceil(newTotal / PAGE_SIZE);
            updateCounts();
            updateQuotaBars();

            card.dataset.added = 'true';
            var badge = card.querySelector('.ai-add-badge');
            var addIcon = card.querySelector('.ai-add-icon');
            if (badge) badge.classList.replace('hidden', 'flex');
            if (addIcon) addIcon.classList.add('hidden');
        }

        function addAllAiQuestions() {
            var type = document.getElementById('aiType').value;
            document.querySelectorAll('.ai-gen-card').forEach(function (card) {
                if (card.dataset.added !== 'true') {
                    var idx = parseInt(card.dataset.index);
                    var q = aiGeneratedQuestions[idx];
                    var level = q ? (q._level || 'Medium') : 'Medium';
                    var pts = level === 'Easy' ? 5 : level === 'Medium' ? 10 : 15;
                    addAiQuestionToSelected(card, idx, type, level, pts);
                }
            });
        }

    </script>
</asp:Content>










