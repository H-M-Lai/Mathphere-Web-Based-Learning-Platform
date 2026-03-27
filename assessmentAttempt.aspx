<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="assessmentAttempt.aspx.cs" Inherits="MathSphere.assessmentAttempt" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Assessment
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

<asp:HiddenField ID="hdnAssessmentId" runat="server" />
<asp:HiddenField ID="hdnModuleId"     runat="server" />
<asp:HiddenField ID="hdnTimeLimit"    runat="server" Value="0" />
<asp:HiddenField ID="hdnFinish"       runat="server" Value="0" />

<%-- Error panel --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="surface-card p-10 text-center max-w-lg mx-auto">
        <div class="size-16 rounded-3xl bg-red-100 flex items-center justify-center mx-auto mb-5">
            <span class="material-symbols-outlined text-red-400 text-3xl fill-icon">error</span>
        </div>
        <h2 class="text-2xl font-black text-math-dark-blue mb-2">Assessment Not Found</h2>
        <p class="text-gray-400 font-semibold mb-6"><asp:Literal ID="litError" runat="server" /></p>
        <a href="StudentDashboard.aspx"
           class="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-blue text-white
                  font-black text-sm uppercase tracking-widest hover:bg-math-dark-blue transition-all">
            <span class="material-symbols-outlined text-base fill-icon">home</span> Dashboard
        </a>
    </div>
</asp:Panel><%-- Main attempt panel --%>
<asp:Panel ID="pnlAttempt" runat="server" Visible="false">

    <section class="relative mb-8 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-3 max-w-3xl">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">assignment</span>
                Timed attempt
            </div>
            <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Assessment Attempt</h2>
            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Work through each question carefully, keep an eye on the timer, and submit your attempt when you are ready.</p>
        </div>
    </section>

    <%-- Sticky header with timer --%>
    <div class="sticky top-0 z-40 bg-white/90 backdrop-blur-md border-b border-gray-100
                shadow-sm mb-8 -mx-4 px-4 py-4">
        <div class="max-w-4xl mx-auto flex items-center justify-between gap-4 flex-wrap">
            <div>
                <p class="text-[10px] font-black uppercase tracking-[0.25em] text-gray-400">Assessment</p>
                <h1 class="text-xl font-black text-math-dark-blue">
                    <asp:Literal ID="litAttemptTitle" runat="server" />
                </h1>
            </div>

            <%-- Timer --%>
            <div id="timerWrap" class="flex items-center gap-3">
                <div class="flex items-center gap-2 px-5 py-3 rounded-2xl bg-math-blue/5
                            border-2 border-math-blue/20" id="timerBox">
                    <span class="material-symbols-outlined text-math-blue fill-icon">timer</span>
                    <span id="timerDisplay" class="text-2xl font-black text-math-dark-blue tabular-nums">--:--</span>
                    <span class="text-xs font-black text-gray-400 uppercase">remaining</span>
                </div>
                <asp:Panel ID="pnlNoTimer" runat="server" Visible="false">
                    <div class="flex items-center gap-2 px-5 py-3 rounded-2xl bg-gray-50 border border-gray-200">
                        <span class="material-symbols-outlined text-gray-400 fill-icon">all_inclusive</span>
                        <span class="text-sm font-black text-gray-500">No Time Limit</span>
                    </div>
                </asp:Panel>
            </div>

            <%-- Finish button (top) --%>
            <button type="button" onclick="confirmFinish()"
                class="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-green text-white
                       font-black text-sm uppercase tracking-widest shadow-lg shadow-green-200
                       hover:bg-green-600 transition-all">
                <span class="material-symbols-outlined text-base fill-icon">done_all</span>
                Finish Attempt
            </button>
        </div>
    </div>

    <div class="max-w-4xl mx-auto space-y-6 pb-32">

        <%-- Question stats row --%>
        <div class="flex flex-wrap gap-3">
            <div class="flex items-center gap-2 px-4 py-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
                <span class="material-symbols-outlined text-math-blue text-base fill-icon">help</span>
                <span class="text-sm font-black text-math-dark-blue">
                    <asp:Literal ID="litAttemptQCount" runat="server" /> Questions
                </span>
            </div>
            <div class="flex items-center gap-2 px-4 py-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
                <span class="material-symbols-outlined text-math-green text-base fill-icon">stars</span>
                <span class="text-sm font-black text-math-dark-blue">
                    <asp:Literal ID="litAttemptTotalMarks" runat="server" /> Total Marks
                </span>
            </div>
        </div>

        <%-- Questions list --%>
        <asp:Repeater ID="rptAttemptQuestions" runat="server"
                      OnItemDataBound="rptAttemptQuestions_ItemDataBound">
            <ItemTemplate>
                <div class="surface-card p-8">
                    <div class="flex items-start gap-4 mb-6">
                        <div class="shrink-0 size-10 rounded-2xl bg-math-dark-blue flex items-center justify-center">
                            <span class="text-white font-black text-sm"><%# Container.ItemIndex + 1 %></span>
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2 mb-2">
                                <asp:Literal ID="litQDiffBadge" runat="server"></asp:Literal>
                                <span class="text-[10px] font-black text-primary bg-primary/10
                                             px-2 py-0.5 rounded-full uppercase">
                                    <%# Eval("points") %> pt<%# Convert.ToInt32(Eval("points")) != 1 ? "s" : "" %>
                                </span>
                            </div>
                            <p class="text-lg font-black text-math-dark-blue leading-snug">
                                <%# HttpUtility.HtmlEncode(Eval("questionText").ToString()) %>
                            </p>
                        </div>
                    </div>

                    <%-- Options — selectable radio buttons --%>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3 pl-14">
                        <asp:Repeater ID="rptOptions" runat="server">
                            <ItemTemplate>
                                <label class="flex items-center gap-3 p-4 rounded-2xl border-2 border-gray-100
                                              bg-gray-50/50 hover:border-math-blue/30 hover:bg-math-blue/5
                                              cursor-pointer transition-all group">
                                    <input type="radio"
                                           name='question_<%# Eval("questionID") %>'
                                           value='<%# Eval("optionID") %>'
                                           class="sr-only peer" />
                                    <div class="shrink-0 size-8 rounded-xl border-2 border-gray-200 bg-white
                                                flex items-center justify-center font-black text-sm text-gray-400
                                                peer-checked:border-math-blue peer-checked:text-math-blue
                                                peer-checked:bg-math-blue/10 transition-all">
                                        <%# Eval("optionLabel") %>
                                    </div>
                                    <span class="font-semibold text-gray-700 text-sm leading-snug">
                                        <%# HttpUtility.HtmlEncode(Eval("optionText").ToString()) %>
                                    </span>
                                </label>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <%-- Bottom finish button --%>
        <div class="surface-card p-8 text-center">
            <p class="text-sm font-semibold text-gray-500 mb-4">
                Reviewed all questions? Submit your attempt when ready.
            </p>
            <button type="button" onclick="confirmFinish()"
                class="inline-flex items-center gap-3 px-10 py-4 rounded-2xl bg-math-green text-white
                       font-black text-sm uppercase tracking-widest shadow-lg shadow-green-200
                       hover:bg-green-600 transition-all">
                <span class="material-symbols-outlined text-base fill-icon">done_all</span>
                Finish Attempt
            </button>
        </div>

    </div>

</asp:Panel>

<%-- RESULTS --%>
<asp:Panel ID="pnlResults" runat="server" Visible="false">
    <div class="max-w-4xl mx-auto space-y-6 pb-16">

        <%-- Score card --%>
        <div class="surface-card p-10 text-center">
            <div class="size-20 rounded-3xl bg-math-green/10 border border-math-green/20
                        flex items-center justify-center mx-auto mb-5">
                <span class="material-symbols-outlined text-math-green fill-icon text-4xl">task_alt</span>
            </div>
            <h2 class="text-3xl font-black text-math-dark-blue mb-2">Attempt Submitted!</h2>

            <%-- Score display --%>
            <div class="flex items-center justify-center gap-4 my-6">
                <div class="bg-math-green/10 border-2 border-math-green/20 rounded-2xl px-8 py-4">
                    <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Your Score</p>
                    <p class="text-4xl font-black text-math-green">
                        <asp:Literal ID="litScoreDisplay" runat="server" />
                    </p>
                </div>
                <div class="bg-gray-50 border-2 border-gray-100 rounded-2xl px-8 py-4">
                    <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Percentage</p>
                    <p class="text-4xl font-black text-math-dark-blue">
                        <asp:Literal ID="litPercentDisplay" runat="server" />%
                    </p>
                </div>
            </div>

            <p class="text-gray-500 font-semibold mb-1">
                Submitted on <asp:Literal ID="litAttemptDate" runat="server" />.
            </p>
            <p class="text-sm text-gray-400 font-semibold mb-8">
                Review the answer key below to see which questions you got right.
            </p>
            <a id="lnkBackAfterAttempt" href="StudentDashboard.aspx"
               class="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-blue text-white
                      font-black text-sm uppercase tracking-widest hover:bg-math-dark-blue transition-all">
                <span class="material-symbols-outlined text-base fill-icon">arrow_back</span>
                Back to Module
            </a>
        </div>

        <%-- Answer key with student answers shown --%>
        <div class="surface-card p-8">
            <div class="flex items-center gap-2 mb-6">
                <span class="material-symbols-outlined text-primary fill-icon">key</span>
                <h3 class="text-sm font-black text-math-dark-blue uppercase tracking-widest">Answer Review</h3>
            </div>

            <asp:Repeater ID="rptAnswerKey" runat="server"
                          OnItemDataBound="rptAnswerKey_ItemDataBound">
                <ItemTemplate>
                    <div class="mb-4 p-5 rounded-2xl border-2 border-gray-100 bg-white">
                        <div class="flex items-start gap-3 mb-4">
                            <div class="shrink-0 size-8 rounded-xl bg-math-dark-blue flex items-center justify-center">
                                <span class="text-white font-black text-xs"><%# Eval("questionNumber") %></span>
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="flex items-center gap-2 mb-1">
                                    <asp:Literal ID="litAKDiffBadge" runat="server"></asp:Literal>
                                    <span class="text-[10px] font-black text-primary bg-primary/10 px-2 py-0.5 rounded-full">
                                        <%# Eval("points") %> pt<%# Convert.ToInt32(Eval("points")) != 1 ? "s" : "" %>
                                    </span>
                                    <asp:Literal ID="litResultBadge" runat="server"></asp:Literal>
                                </div>
                                <p class="text-sm font-bold text-math-dark-blue leading-snug">
                                    <%# HttpUtility.HtmlEncode(Eval("questionText").ToString()) %>
                                </p>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-2 pl-11">
                            <asp:Repeater ID="rptAKOptions" runat="server">
                                <ItemTemplate>
                                    <div class='<%# GetOptionClass((bool)Eval("IsCorrect"), (bool)Eval("IsSelected")) %>'>
                                        <div class='<%# GetOptionLabelClass((bool)Eval("IsCorrect"), (bool)Eval("IsSelected")) %>'>
                                            <%# Eval("optionLabel") %>
                                        </div>
                                        <span class='<%# GetOptionTextClass((bool)Eval("IsCorrect"), (bool)Eval("IsSelected")) %>'>
                                            <%# HttpUtility.HtmlEncode(Eval("optionText").ToString()) %>
                                        </span>
                                        <asp:Panel runat="server" Visible='<%# (bool)Eval("IsCorrect") %>'>
                                            <span class="material-symbols-outlined text-math-green fill-icon text-base">check_circle</span>
                                        </asp:Panel>
                                        <asp:Panel runat="server" Visible='<%# (bool)Eval("IsSelected") && !(bool)Eval("IsCorrect") %>'>
                                            <span class="material-symbols-outlined text-red-400 fill-icon text-base">cancel</span>
                                        </asp:Panel>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:Panel>

<%-- Finish confirmation modal --%>
<div id="finishModal" class="hidden fixed inset-0 bg-black/50 backdrop-blur-sm z-[100]
                              flex items-center justify-center p-4">
    <div class="bg-white rounded-[2rem] shadow-2xl p-10 max-w-md w-full text-center">
        <div class="size-16 rounded-3xl bg-math-green/10 flex items-center justify-center mx-auto mb-5">
            <span class="material-symbols-outlined text-math-green fill-icon text-3xl">done_all</span>
        </div>
        <h2 class="text-2xl font-black text-math-dark-blue mb-2">Finish Attempt?</h2>
        <p class="text-gray-500 font-semibold mb-6">
            Make sure you have answered all questions before submitting.
            Once submitted, you cannot change your answers.
        </p>
        <div class="flex gap-3 justify-center">
            <button type="button" onclick="closeModal()"
                class="px-6 py-3 rounded-2xl bg-gray-100 text-gray-700 font-black text-sm
                       uppercase tracking-widest hover:bg-gray-200 transition-all">
                Cancel
            </button>
            <button type="button" onclick="submitFinish()"
                class="px-6 py-3 rounded-2xl bg-math-green text-white font-black text-sm
                       uppercase tracking-widest shadow-lg shadow-green-200 hover:bg-green-600 transition-all">
                Yes, Finish
            </button>
        </div>
    </div>
</div>

<%-- Time's up modal --%>
<div id="timesUpModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-sm z-[110]
                               flex items-center justify-center p-4">
    <div class="bg-white rounded-[2rem] shadow-2xl p-10 max-w-md w-full text-center">
        <div class="size-16 rounded-3xl bg-red-100 flex items-center justify-center mx-auto mb-5">
            <span class="material-symbols-outlined text-red-400 fill-icon text-3xl">timer_off</span>
        </div>
        <h2 class="text-2xl font-black text-math-dark-blue mb-2">Time's Up!</h2>
        <p class="text-gray-500 font-semibold mb-6">
            Your time has expired. Your attempt is being recorded now.
        </p>
        <div class="inline-flex items-center gap-2 text-sm font-black text-gray-400">
            <span class="material-symbols-outlined text-base animate-spin">progress_activity</span>
            Submitting...
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';

    var timeLimitSeconds = parseInt(
        document.getElementById('<%= hdnTimeLimit.ClientID %>').value, 10) * 60;
    var hasTimer = timeLimitSeconds > 0;
    var timerBox     = document.getElementById('timerBox');
    var timerDisplay = document.getElementById('timerDisplay');
    var interval = null;
    var finished = false;

    if (!hasTimer) {
        if (timerBox) timerBox.style.display = 'none';
    } else {
        startTimer(timeLimitSeconds);
    }

    function startTimer(secs) {
        updateDisplay(secs);
        interval = setInterval(function () {
            secs--;
            updateDisplay(secs);
            if (secs <= 300 && timerBox) {
                timerBox.className = timerBox.className
                    .replace('border-math-blue/20', 'border-orange-300')
                    .replace('bg-math-blue/5', 'bg-orange-50');
                if (timerDisplay) timerDisplay.classList.add('text-orange-500');
            }
            if (secs <= 60 && timerBox) {
                timerBox.className = timerBox.className
                    .replace('border-orange-300', 'border-red-300')
                    .replace('bg-orange-50', 'bg-red-50');
                if (timerDisplay) {
                    timerDisplay.classList.remove('text-orange-500');
                    timerDisplay.classList.add('text-red-500');
                }
            }
            if (secs <= 0) { clearInterval(interval); timesUp(); }
        }, 1000);
    }

    function updateDisplay(secs) {
        if (!timerDisplay) return;
        var m = Math.floor(Math.abs(secs) / 60);
        var s = Math.abs(secs) % 60;
        timerDisplay.textContent =
            (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
    }

    function timesUp() {
        if (finished) return;
        finished = true;
        document.getElementById('timesUpModal').classList.remove('hidden');
        submitFinishNow();
    }

    window.confirmFinish = function () {
        if (finished) return;
        document.getElementById('finishModal').classList.remove('hidden');
    };

    window.closeModal = function () {
        document.getElementById('finishModal').classList.add('hidden');
    };

    window.submitFinish = function () {
        document.getElementById('finishModal').classList.add('hidden');
        if (finished) return;
        finished = true;
        if (interval) clearInterval(interval);
        submitFinishNow();
    };

    function submitFinishNow() {
        document.getElementById('<%= hdnFinish.ClientID %>').value = '1';
        var form = document.getElementById('form1') || document.forms[0];
        if (form) form.submit();
    }

    var resultsVisible = document.getElementById('<%= pnlResults.ClientID %>') !== null
        && document.getElementById('<%= pnlResults.ClientID %>').style.display !== 'none';

    if (!resultsVisible) {
        window.addEventListener('beforeunload', function (e) {
            if (!finished) { e.preventDefault(); e.returnValue = ''; }
        });
    }
})();
</script>

</asp:Content>

