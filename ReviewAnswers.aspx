<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="ReviewAnswers.aspx.cs" Inherits="Assignment.ReviewAnswers" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Review Answers • MathSphere
</asp:Content>

<asp:Content ID="HeadBlock" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .circular-progress {
            background: conic-gradient(var(--progress-color) calc(var(--percentage) * 1%), #e5e7eb 0);
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(20px) scale(.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
    </style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-enter">
    <section class="relative mb-8 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-3 max-w-3xl">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">fact_check</span>
                Answer breakdown
            </div>
            <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Review Answers</h2>
            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Review each question carefully, compare your choices with the correct solution, and understand where your score came from.</p>
        </div>
    </section>

    <%-- Back link --%>
    <a href="ReviewPastAttempt.aspx"
       class="inline-flex items-center gap-2 text-math-blue font-black text-xs uppercase
              tracking-widest mb-8 hover:translate-x-[-4px] transition-transform">
        <span class="material-symbols-outlined text-lg">arrow_back</span>
        BACK TO PAST ATTEMPTS
    </a>

    <%-- Error banner --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false"
        CssClass="mb-6 bg-red-50 border-2 border-red-200 rounded-2xl px-6 py-4 flex items-center gap-3">
        <span class="material-symbols-outlined text-red-400">error</span>
        <asp:Literal ID="litError" runat="server" />
    </asp:Panel>

    <%-- Main content panel (ID=pnlMain as referenced in code-behind ShowError) --%>
    <asp:Panel ID="pnlMain" runat="server" Visible="false">

        <%-- Header card --%>
        <div class="bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100
                    shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-8 mb-8
                    flex flex-col md:flex-row items-center gap-8">

            <%-- Quiz header: colored score ring --%>
            <asp:Panel ID="pnlQuizHeader" runat="server" Visible="false">
                <div class="relative size-28 shrink-0">
                    <svg class="absolute inset-0 size-full -rotate-90" viewBox="0 0 100 100">
                        <circle cx="50" cy="50" r="45" fill="none" stroke="#e5e7eb" stroke-width="8"/>
                        <circle cx="50" cy="50" r="45" fill="none" stroke="#2563eb" stroke-width="8"
                                stroke-dasharray="283"
                                stroke-dashoffset="<asp:Literal ID="litRingOffset" runat="server" />"
                                stroke-linecap="round"/>
                    </svg>
                    <div class="absolute inset-0 flex flex-col items-center justify-center">
                        <span class="text-3xl font-black text-math-dark-blue">
                            <asp:Literal ID="litScorePct" runat="server" />%
                        </span>
                        <span class="text-[10px] font-black uppercase tracking-widest text-math-blue">Score</span>
                    </div>
                </div>
            </asp:Panel>

            <%-- Assessment (paper) header --%>
            <asp:Panel ID="pnlPaperHeader" runat="server" Visible="false">
                <div class="size-28 shrink-0 rounded-3xl bg-primary/10 border border-primary/20
                            flex flex-col items-center justify-center">
                    <span class="material-symbols-outlined text-primary fill-icon text-4xl">description</span>
                    <span class="text-[10px] font-black text-primary uppercase mt-1">Paper</span>
                </div>
            </asp:Panel>

            <div class="flex-1 text-center md:text-left">
                <h2 class="text-2xl font-black text-math-dark-blue leading-tight">
                    <asp:Literal ID="litAttemptTitle" runat="server" />
                </h2>

                <div class="flex flex-wrap justify-center md:justify-start gap-3 mt-3">
                    <%-- Score fraction badge --%>
                    <span class="px-4 py-1.5 rounded-full border-2 border-math-blue/30 bg-math-blue/5
                                 text-math-dark-blue font-black text-sm">
                        SCORE: <asp:Literal ID="litScoreFrac" runat="server" />
                    </span>
                    <%-- Paper badge (shown via pnlPaperHeader visibility matching) --%>
                    <asp:Panel ID="pnlPaperBadge" runat="server" Visible="false">
                        <span class="inline-flex items-center gap-1.5 px-4 py-1.5 rounded-full
                                     border-2 border-primary/30 bg-primary/5
                                     text-math-dark-blue font-black text-sm">
                            <span class="material-symbols-outlined text-sm text-primary fill-icon">info</span>
                            ANSWER KEY — Teacher marks on paper
                        </span>
                    </asp:Panel>
                    <%-- Date --%>
                    <span class="px-4 py-1.5 rounded-full border border-gray-200 bg-gray-50
                                 text-gray-500 font-bold text-sm">
                        <asp:Literal ID="litAttemptDate" runat="server" />
                    </span>
                </div>
            </div>
        </div>

        <%-- Questions --%>
        <div class="space-y-5">
            <asp:Repeater ID="rptQuestions" runat="server"
                          OnItemDataBound="rptQuestions_ItemDataBound">
                <ItemTemplate>
                    <div class="bg-white/70 backdrop-blur-md rounded-[2rem] border border-gray-100
                                shadow-[0_8px_24px_rgba(0,0,0,0.05)] p-6">

                        <%-- Question header row --%>
                        <div class="flex items-start justify-between gap-4 mb-5">
                            <div class="flex items-start gap-3 flex-1 min-w-0">
                                <%-- Number bubble --%>
                                <div class="size-8 shrink-0 rounded-xl bg-math-blue flex items-center justify-center">
                                    <span class="font-black text-sm text-white"><%# Eval("Number") %></span>
                                </div>
                                <p class="flex-1 text-base font-black text-math-dark-blue leading-snug pt-1">
                                    <%# System.Web.HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %>
                                </p>
                            </div>

                            <%-- Quiz: correct / wrong badge --%>
                            <asp:Panel ID="pnlCorrectBadge" runat="server" Visible="false">
                                <div class="shrink-0 px-3 py-1.5 rounded-xl bg-math-green/10 border border-math-green/30 flex items-center gap-1.5">
                                    <span class="material-symbols-outlined text-math-green fill-icon text-sm">check_circle</span>
                                    <span class="text-[10px] font-black text-math-green uppercase tracking-widest">Correct</span>
                                    <span class="text-[10px] font-black text-gray-400 ml-1 border-l border-gray-200 pl-1">
                                        <asp:Literal ID="litPtsAwarded" runat="server" /> pts
                                    </span>
                                </div>
                            </asp:Panel>

                            <asp:Panel ID="pnlWrongBadge" runat="server" Visible="false">
                                <div class="shrink-0 px-3 py-1.5 rounded-xl bg-red-100 border border-red-200 flex items-center gap-1.5">
                                    <span class="material-symbols-outlined text-red-400 fill-icon text-sm">cancel</span>
                                    <span class="text-[10px] font-black text-red-400 uppercase tracking-widest">Wrong</span>
                                    <span class="text-[10px] font-black text-gray-400 ml-1 border-l border-gray-200 pl-1">
                                        <asp:Literal ID="litPtsAwardedWrong" runat="server" /> pts
                                    </span>
                                </div>
                            </asp:Panel>

                            <%-- Assessment: points badge only --%>
                            <asp:Panel ID="pnlPaperPts" runat="server" Visible="false">
                                <span class="shrink-0 px-3 py-1.5 rounded-xl bg-primary/10 border border-primary/20
                                             text-[10px] font-black text-primary uppercase tracking-widest">
                                    <%# Eval("Points") %> PTS
                                </span>
                            </asp:Panel>
                        </div>

                        <%-- Options --%>
                        <div class="space-y-2 pl-11">
                            <asp:Repeater ID="rptOptions" runat="server">
                                <ItemTemplate>
                                    <div class='<%# GetOptionClass((bool)Eval("IsCorrect"), (bool)Eval("WasSelected"), (bool)Eval("IsPaper")) %>'>
                                        <%-- Label bubble --%>
                                        <div class='<%# GetOptionLabelClass((bool)Eval("IsCorrect"), (bool)Eval("WasSelected"), (bool)Eval("IsPaper")) %>'>
                                            <%# Eval("OptionLabel") %>
                                        </div>
                                        <%-- Option text --%>
                                        <span class='<%# GetOptionTextClass((bool)Eval("IsCorrect"), (bool)Eval("WasSelected"), (bool)Eval("IsPaper")) %>'>
                                            <%# System.Web.HttpUtility.HtmlEncode(Eval("OptionText").ToString()) %>
                                        </span>
                                        <%-- CORRECT ANSWER label --%>
                                        <asp:Panel runat="server" Visible='<%# (bool)Eval("IsCorrect") %>'>
                                            <span class="ml-2 text-[9px] font-black text-math-green uppercase
                                                         tracking-widest flex items-center gap-1 shrink-0">
                                                <span class="material-symbols-outlined fill-icon text-sm">check_circle</span>
                                                CORRECT ANSWER
                                            </span>
                                        </asp:Panel>
                                        <%-- YOUR ANSWER label — quiz only, wrong pick --%>
                                        <asp:Panel runat="server"
                                                   Visible='<%# (bool)Eval("WasSelected") && !(bool)Eval("IsCorrect") && !(bool)Eval("IsPaper") %>'>
                                            <span class="ml-2 text-[9px] font-black text-red-400 uppercase
                                                         tracking-widest flex items-center gap-1 shrink-0">
                                                <span class="material-symbols-outlined fill-icon text-sm">cancel</span>
                                                YOUR ANSWER
                                            </span>
                                        </asp:Panel>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                            <asp:Panel ID="pnlTextAnswer" runat="server" Visible="false" CssClass="space-y-3">
                                <div class="p-4 rounded-2xl border-2 border-gray-100 bg-white">
                                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Your Answer</p>
                                    <p class="text-sm font-semibold text-math-dark-blue leading-relaxed">
                                        <asp:Literal ID="litStudentAnswerText" runat="server" />
                                    </p>
                                </div>
                                <asp:Panel ID="pnlCorrectAnswerText" runat="server" Visible="false">
                                    <div class="p-4 rounded-2xl border-2 border-math-green/30 bg-math-green/5">
                                        <p class="text-[10px] font-black text-math-green uppercase tracking-widest mb-2">Correct Answer</p>
                                        <p class="text-sm font-semibold text-math-dark-blue leading-relaxed">
                                            <asp:Literal ID="litCorrectAnswerText" runat="server" />
                                        </p>
                                    </div>
                                </asp:Panel>
                            </asp:Panel>

                        <%-- Hint panel — wired in ItemDataBound --%>
                        <asp:Panel ID="pnlHint" runat="server" Visible="false">
                            <div class="mt-4 pl-11 flex items-start gap-2 p-3 rounded-xl
                                        bg-primary/5 border border-primary/15">
                                <span class="material-symbols-outlined text-primary text-base shrink-0">lightbulb</span>
                                <p class="text-xs font-semibold text-gray-500 italic"><%# Eval("Hint") %></p>
                            </div>
                        </asp:Panel>

                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </asp:Panel>

</div>
</asp:Content>





