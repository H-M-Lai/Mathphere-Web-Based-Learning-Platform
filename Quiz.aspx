<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="Quiz.aspx.cs" Inherits="MathSphere.Quiz" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Quiz
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

<style>
    /* -- Option card states -- */
    .opt-card       { cursor:pointer; transition:all .2s ease; }
    .opt-card:hover { transform:translateY(-2px); }
    .opt-card.selected {
        border-color:#2563eb !important;
        background:#eff6ff !important;
        box-shadow:0 0 0 3px rgba(37,99,235,.15);
    }
    .opt-card.correct { border-color:#84cc16 !important; background:#f0fdf4 !important; }
    .opt-card.wrong   { border-color:#ef4444 !important; background:#fef2f2 !important; opacity:.75; }

    #quizProgressBar { transition:width .4s cubic-bezier(.4,0,.2,1); }

    @keyframes slideIn {
        from { opacity:0; transform:translateX(28px); }
        to   { opacity:1; transform:translateX(0); }
    }
    .question-slide { animation:slideIn .3s ease forwards; }

    @keyframes scoreRing {
        from { stroke-dashoffset:283; }
        to   { stroke-dashoffset:var(--offset); }
    }
    #scoreArc { animation:scoreRing 1.2s cubic-bezier(.4,0,.2,1) .4s forwards; }

    @keyframes cardIn {
        from { opacity: 0; transform: translateY(20px) scale(.98); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }
    .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }

    @keyframes confettiPop {
        0%   { transform:translate(var(--tx),var(--ty)) scale(0) rotate(0deg); opacity:1; }
        60%  { opacity:1; }
        100% { transform:translate(calc(var(--tx)*3),calc(var(--ty)*3 - 60px)) scale(1) rotate(720deg); opacity:0; }
    }
    .confetti-dot {
        position:absolute; border-radius:50%; width:8px; height:8px;
        animation:confettiPop .9s ease forwards;
    }
</style>

<div class="page-enter space-y-8">
    <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-3 max-w-3xl">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">quiz</span>
                Knowledge check
            </div>
            <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Module Quiz</h2>
            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Answer each question, track your score as you go, and finish with a clear review of what to revisit next.</p>
        </div>
    </section>

<%-- ERROR STATE --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100
                shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-10 text-center max-w-lg mx-auto">
        <div class="size-16 rounded-3xl bg-red-100 flex items-center justify-center mx-auto mb-5">
            <span class="material-symbols-outlined text-red-400 text-3xl fill-icon">error</span>
        </div>
        <h2 class="text-2xl font-black text-math-dark-blue mb-2">Quiz Not Found</h2>
        <p class="text-gray-400 font-semibold mb-6"><asp:Literal ID="litError" runat="server" /></p>
        <a href="StudentDashboard.aspx"
           class="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-blue text-white
                  font-black text-sm uppercase tracking-widest hover:bg-math-dark-blue transition-all">
            <span class="material-symbols-outlined text-base fill-icon">home</span> Back to Dashboard
        </a>
    </div>
</asp:Panel>

<%-- QUIZ PANEL --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">

    <%-- Header --%>
    <div class="mb-8">
        <div class="flex items-start justify-between gap-6">
            <div>
                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Quiz</p>
                <h1 class="text-3xl md:text-4xl font-black tracking-tight text-math-dark-blue mt-1">
                    <asp:Literal ID="litQuizTitle" runat="server" />
                </h1>
            </div>
            <div class="hidden md:flex size-14 rounded-2xl bg-math-blue/10 border border-math-blue/10
                        items-center justify-center shadow-sm shrink-0">
                <span class="material-symbols-outlined text-math-blue fill-icon text-3xl">quiz</span>
            </div>
        </div>

        <%-- Progress bar --%>
        <div class="mt-6 space-y-2">
            <div class="flex justify-between text-xs font-black uppercase tracking-widest text-gray-400">
                <span>Question <span id="qCurrent">1</span> of <asp:Literal ID="litTotal" runat="server" /></span>
                <span id="qScore" class="text-math-blue">0 pts earned</span>
            </div>
            <div class="h-2.5 w-full bg-gray-100 rounded-full overflow-hidden border border-gray-200">
                <div id="quizProgressBar" class="h-full bg-math-blue rounded-full" style="width:0%"></div>
            </div>
        </div>
    </div>

    <%-- Hidden server-wired state fields --%>
    <asp:HiddenField ID="litTotalHidden" runat="server" />
    <asp:HiddenField ID="litQuizId"      runat="server" />
    <asp:HiddenField ID="litModuleId"    runat="server" />

    <%-- Hidden fields posted by JS on finish --%>
    <input type="hidden" name="hdnSubmitAnswers" id="hdnSubmitAnswers" />
    <input type="hidden" name="hdnEarnedPts"     id="hdnEarnedPts" />
    <input type="hidden" name="hdnFinish"        id="hdnFinish" value="0" />

    <%-- Questions --%>
    <div id="questionContainer">
        <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
            <ItemTemplate>
                <div class="question-card bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100
                            shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-8 hidden"
                     data-qindex='<%# Container.ItemIndex %>'
                     data-qid='<%# Eval("QuestionID") %>'
                     data-points='<%# Eval("Points") %>'>

                    <%-- Question header --%>
                    <div class="flex items-start gap-4 mb-8">
                        <div class="shrink-0 size-10 rounded-2xl bg-math-dark-blue flex items-center justify-center">
                            <span class="text-white font-black text-sm"><%# Container.ItemIndex + 1 %></span>
                        </div>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 mb-2">
                                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400">MCQ</span>
                                <span class="text-[10px] font-black uppercase tracking-widest text-primary
                                             bg-primary/10 px-2 py-0.5 rounded-full">
                                    <%# Eval("Points") %> pt<%# Convert.ToInt32(Eval("Points")) != 1 ? "s" : "" %>
                                </span>
                            </div>
                            <p class="text-lg md:text-xl font-black text-math-dark-blue leading-snug">
                                <%# Eval("QuestionText") %>
                            </p>
                            <%-- Hint --%>
                            <asp:Panel runat="server"
                                       Visible='<%# !string.IsNullOrEmpty(Eval("Hint")?.ToString()) %>'>
                                <div class="mt-3 flex items-start gap-2 p-3 rounded-xl bg-primary/5 border border-primary/15">
                                    <span class="material-symbols-outlined text-primary text-base shrink-0 mt-0.5">lightbulb</span>
                                    <p class="text-sm font-semibold text-gray-500 italic"><%# Eval("Hint") %></p>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>

                    <%-- Options --%>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <asp:Repeater ID="rptOptions" runat="server">
                            <ItemTemplate>
                                <div class="opt-card group flex items-center gap-4 p-4 rounded-2xl
                                            border-2 border-gray-100 bg-white/60"
                                     data-option-id='<%# Eval("OptionID") %>'
                                     data-correct='<%# Eval("IsCorrect").ToString().ToLower() %>'
                                     data-label='<%# Eval("OptionLabel") %>'>
                                    <div class="shrink-0 size-9 rounded-xl border-2 border-gray-200 bg-white
                                                flex items-center justify-center font-black text-sm text-gray-400
                                                group-hover:border-math-blue group-hover:text-math-blue
                                                transition-colors opt-label-box">
                                        <%# Eval("OptionLabel") %>
                                    </div>
                                    <span class="font-semibold text-gray-700 text-sm leading-snug flex-1">
                                        <%# Eval("OptionText") %>
                                    </span>
                                    <span class="material-symbols-outlined text-math-green fill-icon text-lg hidden opt-check">check_circle</span>
                                    <span class="material-symbols-outlined text-red-400 fill-icon text-lg hidden opt-x">cancel</span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <%-- Feedback area --%>
                    <div class="feedback-area mt-6 hidden">
                        <div class="feedback-correct hidden items-center gap-3 p-4 rounded-2xl
                                    bg-math-green/10 border border-math-green/20">
                            <span class="material-symbols-outlined text-math-green fill-icon text-2xl">check_circle</span>
                            <div>
                                <p class="font-black text-math-green text-sm uppercase tracking-wider">Correct!</p>
                                <p class="text-xs font-semibold text-gray-500 mt-0.5 feedback-pts"></p>
                            </div>
                        </div>
                        <div class="feedback-wrong hidden items-center gap-3 p-4 rounded-2xl
                                    bg-red-50 border border-red-200">
                            <span class="material-symbols-outlined text-red-400 fill-icon text-2xl">cancel</span>
                            <div>
                                <p class="font-black text-red-400 text-sm uppercase tracking-wider">Incorrect</p>
                                <p class="text-xs font-semibold text-gray-500 mt-0.5 feedback-answer"></p>
                            </div>
                        </div>
                    </div>

                    <%-- Navigation row --%>
                    <div class="mt-6 flex items-center justify-between gap-3">
                        <button type="button" class="btn-prev hidden inline-flex items-center gap-2
                                px-5 py-2.5 rounded-2xl bg-gray-100 text-gray-600 font-black text-sm
                                uppercase tracking-widest hover:bg-gray-200 transition-all">
                            <span class="material-symbols-outlined text-base">arrow_back</span> Back
                        </button>
                        <div class="flex gap-3 ml-auto">
                            <button type="button" class="btn-submit inline-flex items-center gap-2
                                    px-6 py-3 rounded-2xl bg-math-blue text-white font-black text-sm
                                    uppercase tracking-widest shadow-lg shadow-math-blue/20
                                    hover:bg-math-dark-blue transition-all" disabled>
                                <span class="material-symbols-outlined text-base fill-icon">check</span>
                                Submit Answer
                            </button>
                            <button type="button" class="btn-next hidden inline-flex items-center gap-2
                                    px-6 py-3 rounded-2xl bg-math-blue text-white font-black text-sm
                                    uppercase tracking-widest shadow-lg shadow-math-blue/20
                                    hover:bg-math-dark-blue transition-all">
                                Next <span class="material-symbols-outlined text-base">arrow_forward</span>
                            </button>
                            <button type="button" class="btn-finish hidden inline-flex items-center gap-2
                                    px-6 py-3 rounded-2xl bg-math-green text-white font-black text-sm
                                    uppercase tracking-widest shadow-lg shadow-math-green/20
                                    hover:bg-green-600 transition-all">
                                <span class="material-symbols-outlined text-base fill-icon">emoji_events</span>
                                Finish Quiz
                            </button>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

</asp:Panel>

<%-- RESULTS PANEL --%>
<asp:Panel ID="pnlResults" runat="server" Visible="false">
    <div class="bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100
                shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-10 text-center max-w-2xl mx-auto">

        <%-- Score ring --%>
        <div class="relative inline-flex items-center justify-center mb-8 size-40">
            <svg class="size-40 -rotate-90" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="45" fill="none" stroke="#e5e7eb" stroke-width="8"/>
                <circle id="scoreArc" cx="50" cy="50" r="45" fill="none"
                        stroke="#2563eb" stroke-width="8" stroke-linecap="round"
                        stroke-dasharray="283" stroke-dashoffset="283"
                        style="--offset:<asp:Literal ID="litScoreOffset" runat="server" />"/>
            </svg>
            <div class="absolute inset-0 flex flex-col items-center justify-center">
                <span class="text-4xl font-black text-math-dark-blue">
                    <asp:Literal ID="litScorePct" runat="server" />%
                </span>
                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400">Score</span>
            </div>
            <div id="confettiZone" class="absolute inset-0 pointer-events-none overflow-visible"></div>
        </div>

        <asp:Panel ID="pnlPass" runat="server" Visible="false">
            <h2 class="text-3xl font-black text-math-dark-blue mb-1">Great Work!</h2>
            <p class="text-gray-500 font-semibold mb-2">You passed the quiz!</p>
        </asp:Panel>
        <asp:Panel ID="pnlFail" runat="server" Visible="false">
            <h2 class="text-3xl font-black text-math-dark-blue mb-1">Keep Practising!</h2>
            <p class="text-gray-500 font-semibold mb-2">Review the material and try again.</p>
        </asp:Panel>

        <%-- Score breakdown --%>
        <div class="flex justify-center gap-4 my-8 flex-wrap">
            <div class="flex flex-col items-center px-6 py-4 bg-math-blue/5 rounded-2xl border border-math-blue/10">
                <span class="text-3xl font-black text-math-blue"><asp:Literal ID="litScoreNum" runat="server" /></span>
                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400 mt-1">Points Earned</span>
            </div>
            <div class="flex flex-col items-center px-6 py-4 bg-gray-50 rounded-2xl border border-gray-100">
                <span class="text-3xl font-black text-math-dark-blue"><asp:Literal ID="litMaxScore" runat="server" /></span>
                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400 mt-1">Total Points</span>
            </div>
            <div class="flex flex-col items-center px-6 py-4 bg-math-green/5 rounded-2xl border border-math-green/10">
                <span class="text-3xl font-black text-math-green">
                    <asp:Literal ID="litCorrectCount" runat="server" />/<asp:Literal ID="litTotalCount" runat="server" />
                </span>
                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400 mt-1">Correct</span>
            </div>
        </div>

        <%-- XP notice --%>
        <asp:Panel ID="pnlXpAwarded" runat="server" Visible="false">
            <div class="flex items-center justify-center gap-2 mb-6 p-3 rounded-2xl bg-primary/10 border border-primary/20">
                <span class="material-symbols-outlined text-primary fill-icon">stars</span>
                <span class="text-sm font-black text-math-dark-blue">
                    +<asp:Literal ID="litXpAwarded" runat="server" /> XP earned!
                    <asp:Literal ID="litXpNote" runat="server" />
                </span>
            </div>
        </asp:Panel>

        <%-- Question Review --%>
        <asp:Panel ID="pnlQuizReview" runat="server" Visible="false">
            <div class="mt-8 text-left space-y-4">
                <div class="flex items-center gap-2 mb-5">
                    <span class="material-symbols-outlined text-math-blue fill-icon">rate_review</span>
                    <h3 class="text-sm font-black text-math-dark-blue uppercase tracking-widest">Answer Review</h3>
                </div>
                <asp:Repeater ID="rptReview" runat="server" OnItemDataBound="rptReview_ItemDataBound">
                    <ItemTemplate>
                        <div class='<%# (bool)Eval("IsCorrect")
                            ? "p-5 rounded-2xl border-2 border-math-green/30 bg-math-green/5"
                            : "p-5 rounded-2xl border-2 border-red-200 bg-red-50/50" %>'>

                            <%-- Question header --%>
                            <div class="flex items-start gap-3 mb-4">
                                <div class='<%# (bool)Eval("IsCorrect")
                                    ? "shrink-0 size-8 rounded-xl bg-math-green/20 flex items-center justify-center"
                                    : "shrink-0 size-8 rounded-xl bg-red-100 flex items-center justify-center" %>'>
                                    <span class='<%# (bool)Eval("IsCorrect")
                                        ? "material-symbols-outlined text-math-green fill-icon text-base"
                                        : "material-symbols-outlined text-red-400 fill-icon text-base" %>'>
                                        <%# (bool)Eval("IsCorrect") ? "check_circle" : "cancel" %>
                                    </span>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span class="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                                            Q<%# Eval("QuestionNumber") %>
                                        </span>
                                        <span class='<%# (bool)Eval("IsCorrect")
                                            ? "text-[10px] font-black text-math-green bg-math-green/10 px-2 py-0.5 rounded-full uppercase"
                                            : "text-[10px] font-black text-red-400 bg-red-100 px-2 py-0.5 rounded-full uppercase" %>'>
                                            <%# (bool)Eval("IsCorrect") ? "Correct" : "Wrong" %>
                                        </span>
                                        <span class="text-[10px] font-black text-primary bg-primary/10 px-2 py-0.5 rounded-full">
                                            <%# Eval("Points") %> pt<%# Convert.ToInt32(Eval("Points")) != 1 ? "s" : "" %>
                                        </span>
                                    </div>
                                    <p class="text-sm font-bold text-math-dark-blue leading-snug">
                                        <%# Eval("QuestionText") %>
                                    </p>
                                </div>
                            </div>

                            <%-- Options --%>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-2 pl-11">
                                <asp:Repeater ID="rptReviewOptions" runat="server">
                                    <ItemTemplate>
                                        <div class='<%# (bool)Eval("IsCorrect")
                                            ? "flex items-center gap-2 p-3 rounded-xl border-2 border-math-green/40 bg-math-green/10"
                                            : (bool)Eval("WasSelected")
                                                ? "flex items-center gap-2 p-3 rounded-xl border-2 border-red-300 bg-red-100/60"
                                                : "flex items-center gap-2 p-3 rounded-xl border border-gray-100 bg-white/60" %>'>
                                            <div class='<%# (bool)Eval("IsCorrect")
                                                ? "shrink-0 size-7 rounded-lg border-2 border-math-green bg-math-green/20 flex items-center justify-center font-black text-xs text-math-green"
                                                : (bool)Eval("WasSelected")
                                                    ? "shrink-0 size-7 rounded-lg border-2 border-red-300 bg-red-100 flex items-center justify-center font-black text-xs text-red-400"
                                                    : "shrink-0 size-7 rounded-lg border border-gray-200 bg-white flex items-center justify-center font-black text-xs text-gray-400" %>'>
                                                <%# Eval("OptionLabel") %>
                                            </div>
                                            <span class='<%# (bool)Eval("IsCorrect")
                                                ? "text-xs font-bold text-math-green flex-1"
                                                : (bool)Eval("WasSelected")
                                                    ? "text-xs font-bold text-red-500 flex-1"
                                                    : "text-xs font-semibold text-gray-500 flex-1" %>'>
                                                <%# Eval("OptionText") %>
                                            </span>
                                            <asp:Panel runat="server" Visible='<%# (bool)Eval("IsCorrect") %>'>
                                                <span class="material-symbols-outlined text-math-green fill-icon text-base">check_circle</span>
                                            </asp:Panel>
                                            <asp:Panel runat="server" Visible='<%# (bool)Eval("WasSelected") && !(bool)Eval("IsCorrect") %>'>
                                                <span class="material-symbols-outlined text-red-400 fill-icon text-base">cancel</span>
                                            </asp:Panel>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <%-- Hint --%>
                            <asp:Panel runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("Hint")?.ToString()) %>'>
                                <div class="mt-3 pl-11 flex items-start gap-2 p-3 rounded-xl bg-primary/5 border border-primary/15">
                                    <span class="material-symbols-outlined text-primary text-base shrink-0">lightbulb</span>
                                    <p class="text-xs font-semibold text-gray-500 italic"><%# Eval("Hint") %></p>
                                </div>
                            </asp:Panel>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <%-- Actions --%>
        <div class="flex flex-col sm:flex-row gap-4 justify-center mt-2">
            <asp:HyperLink ID="lnkRetry" runat="server"
               CssClass="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-2xl
                         bg-gray-100 text-gray-700 font-black text-sm uppercase tracking-widest
                         hover:bg-gray-200 transition-all">
                <span class="material-symbols-outlined text-base fill-icon">replay</span> Retry Quiz
            </asp:HyperLink>
            <asp:HyperLink ID="lnkBackToModule" runat="server"
               CssClass="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-2xl
                         bg-math-blue text-white font-black text-sm uppercase tracking-widest
                         shadow-lg shadow-math-blue/20 hover:bg-math-dark-blue transition-all">
                <span class="material-symbols-outlined text-base fill-icon">arrow_back</span> Back to Module
            </asp:HyperLink>
        </div>
    </div>
</asp:Panel>

<%-- CLIENT-SIDE QUIZ ENGINE --%>
<script>
    (function () {
        'use strict';

        var cards = Array.from(document.querySelectorAll('.question-card'));
        var total = parseInt(
            document.getElementById('<%= litTotalHidden.ClientID %>')?.value || '0', 10);
        var current = 0;
        var earned = 0;
        var answers = {};  // { qindex: { optionId, correct, pts } }

        if (cards.length === 0) return;
        showCard(0);

        // Show card
        function showCard(idx) {
            if (idx < 0 || idx >= cards.length) return;
            cards.forEach(function (c) { c.classList.add('hidden'); });
            var card = cards[idx];
            card.classList.remove('hidden');
            card.classList.add('question-slide');
            setTimeout(function () { card.classList.remove('question-slide'); }, 400);
            current = idx;
            refreshProgress();

            if (!answers[idx]) wireCard(card);
            else restoreCard(card);

            var btnPrev = card.querySelector('.btn-prev');
            if (btnPrev) {
                if (idx === 0) btnPrev.classList.add('hidden');
                else btnPrev.classList.remove('hidden');
            }
        }

        // Wire a fresh card
        function wireCard(card) {
            var opts = card.querySelectorAll('.opt-card');
            var btnSub = card.querySelector('.btn-submit');
            var btnPrv = card.querySelector('.btn-prev');

            opts.forEach(function (opt) {
                opt.addEventListener('click', function () {
                    opts.forEach(function (o) { o.classList.remove('selected'); });
                    opt.classList.add('selected');
                    if (btnSub) btnSub.removeAttribute('disabled');
                });
            });

            if (btnSub) btnSub.onclick = function () { submitCard(card); };
            if (btnPrv) btnPrv.onclick = function () { showCard(current - 1); };
        }

        // Submit answer
        function submitCard(card) {
            var selected = card.querySelector('.opt-card.selected');
            if (!selected) return;

            var isCorrect = selected.getAttribute('data-correct') === 'true';
            var pts = parseInt(card.getAttribute('data-points') || '0', 10);
            var qIdx = parseInt(card.getAttribute('data-qindex'), 10);

            answers[qIdx] = {
                optionId: selected.getAttribute('data-option-id'),
                correct: isCorrect,
                pts: isCorrect ? pts : 0
            };
            if (isCorrect) earned += pts;
            refreshProgress();

            lockOptions(card, selected);
            showFeedback(card, isCorrect, pts);

            var btnSub = card.querySelector('.btn-submit');
            var btnNext = card.querySelector('.btn-next');
            var btnFinish = card.querySelector('.btn-finish');
            if (btnSub) btnSub.classList.add('hidden');

            if (qIdx === total - 1) {
                if (btnFinish) {
                    btnFinish.classList.remove('hidden');
                    btnFinish.onclick = finishQuiz;
                }
            } else {
                if (btnNext) {
                    btnNext.classList.remove('hidden');
                    btnNext.onclick = function () { showCard(current + 1); };
                }
            }
        }

        // Lock options
        function lockOptions(card, selected) {
            card.querySelectorAll('.opt-card').forEach(function (opt) {
                opt.style.pointerEvents = 'none';
                var correct = opt.getAttribute('data-correct') === 'true';
                if (correct) {
                    opt.classList.add('correct');
                    var ck = opt.querySelector('.opt-check');
                    if (ck) ck.classList.remove('hidden');
                } else if (opt === selected && !correct) {
                    opt.classList.add('wrong');
                    var xk = opt.querySelector('.opt-x');
                    if (xk) xk.classList.remove('hidden');
                }
            });
        }

        // Show feedback
        function showFeedback(card, isCorrect, pts) {
            var area = card.querySelector('.feedback-area');
            if (!area) return;
            area.classList.remove('hidden');
            if (isCorrect) {
                var fc = card.querySelector('.feedback-correct');
                if (fc) {
                    fc.classList.remove('hidden');
                    fc.style.display = 'flex';
                    var ptsEl = fc.querySelector('.feedback-pts');
                    if (ptsEl) ptsEl.textContent =
                        '+' + pts + ' point' + (pts !== 1 ? 's' : '') + ' earned';
                }
            } else {
                var fw = card.querySelector('.feedback-wrong');
                if (fw) {
                    fw.classList.remove('hidden');
                    fw.style.display = 'flex';
                    var correctOpt = card.querySelector('.opt-card[data-correct="true"]');
                    var ansEl = fw.querySelector('.feedback-answer');
                    if (ansEl && correctOpt) {
                        var lbl = correctOpt.querySelector('.opt-label-box');
                        ansEl.textContent = 'Correct answer: ' +
                            (lbl ? lbl.textContent.trim() : '');
                    }
                }
            }
        }

        // Restore already-answered card
        function restoreCard(card) {
            var ans = answers[parseInt(card.getAttribute('data-qindex'), 10)];
            if (!ans) return;

            card.querySelectorAll('.opt-card').forEach(function (opt) {
                opt.style.pointerEvents = 'none';
                var correct = opt.getAttribute('data-correct') === 'true';
                if (correct) {
                    opt.classList.add('correct');
                    var ck = opt.querySelector('.opt-check');
                    if (ck) ck.classList.remove('hidden');
                } else if (opt.getAttribute('data-option-id') === ans.optionId && !correct) {
                    opt.classList.add('wrong');
                    var xk = opt.querySelector('.opt-x');
                    if (xk) xk.classList.remove('hidden');
                }
            });

            showFeedback(card, ans.correct, ans.pts);

            var btnSub = card.querySelector('.btn-submit');
            var btnNext = card.querySelector('.btn-next');
            var btnFinish = card.querySelector('.btn-finish');
            var qIdx = parseInt(card.getAttribute('data-qindex'), 10);

            if (btnSub) btnSub.classList.add('hidden');

            if (qIdx === total - 1) {
                if (btnFinish) {
                    btnFinish.classList.remove('hidden');
                    btnFinish.onclick = finishQuiz;
                }
            } else {
                if (btnNext) {
                    btnNext.classList.remove('hidden');
                    btnNext.onclick = function () { showCard(current + 1); };
                }
            }

            var btnPrv = card.querySelector('.btn-prev');
            if (btnPrv) {
                if (qIdx === 0) btnPrv.classList.add('hidden');
                else {
                    btnPrv.classList.remove('hidden');
                    btnPrv.onclick = function () { showCard(current - 1); };
                }
            }
        }

        // Progress
        function refreshProgress() {
            var bar = document.getElementById('quizProgressBar');
            var curr = document.getElementById('qCurrent');
            var pts = document.getElementById('qScore');
            if (bar) bar.style.width = (total > 0 ? (current + 1) / total * 100 : 0) + '%';
            if (curr) curr.textContent = current + 1;
            if (pts) pts.textContent = earned + ' pts earned';
        }

        // Finish — post to server
        function finishQuiz() {
            var answersArr = Object.keys(answers).map(function (idx) {
                var card = cards[parseInt(idx, 10)];
                return {
                    questionId: card ? card.getAttribute('data-qid') : '',
                    optionId: answers[idx].optionId,
                    correct: answers[idx].correct,
                    pts: answers[idx].pts
                };
            });

            document.getElementById('hdnSubmitAnswers').value = JSON.stringify(answersArr);
            document.getElementById('hdnEarnedPts').value = earned;
            document.getElementById('hdnFinish').value = '1';

            // Student.master wraps everything in <form id="form1">
            var masterForm = document.getElementById('form1') || document.forms[0];
            if (masterForm) masterForm.submit();
        }

        // Confetti (only on results panel)
        var zone = document.getElementById('confettiZone');
        if (zone) {
            var colors = ['#f9d006', '#2563eb', '#84cc16', '#ef4444', '#8b5cf6'];
            for (var i = 0; i < 20; i++) {
                var dot = document.createElement('div');
                dot.className = 'confetti-dot';
                dot.style.background = colors[i % colors.length];
                dot.style.left = (Math.random() * 100) + '%';
                dot.style.top = (Math.random() * 100) + '%';
                dot.style.setProperty('--tx', (Math.random() * 60 - 30) + 'px');
                dot.style.setProperty('--ty', (Math.random() * 60 - 30) + 'px');
                dot.style.animationDelay = (Math.random() * .5) + 's';
                zone.appendChild(dot);
            }
        }

    })();
</script>

</div>
</asp:Content>

