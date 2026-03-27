<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
    CodeBehind="ReviewPastAttempt.aspx.cs" Inherits="Assignment.ReviewPastAttempt" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Review Past Attempts • MathSphere
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

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">    <div class="page-enter mb-12">
        <asp:LinkButton ID="btnBackDashboard" runat="server"
            OnClick="btnBackDashboard_Click"
            CausesValidation="false"
            CssClass="inline-flex items-center gap-2 text-math-blue font-black text-xs uppercase tracking-widest mb-4 hover:translate-x-[-4px] transition-transform">
            <span class="material-symbols-outlined text-lg">arrow_back</span>
            BACK TO DASHBOARD
        </asp:LinkButton>

        <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
            <div class="relative space-y-3 max-w-3xl">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">history</span>
                    Performance archive
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Review Past Attempts</h2>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Look back through your earlier results, spot patterns in your performance, and measure how your understanding is improving over time.</p>
            </div>
        </section>
    </div>

    <%-- Error banner --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false"
        CssClass="mb-6 bg-red-50 border-2 border-red-200 rounded-2xl px-6 py-4 flex items-center gap-3">
        <span class="material-symbols-outlined text-red-400">error</span>
        <asp:Label ID="lblError" runat="server" CssClass="font-bold text-sm text-red-600"></asp:Label>
    </asp:Panel>

    <%-- Empty state --%>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false"
        CssClass="bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100 shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-12 text-center">
        <span class="material-symbols-outlined text-6xl text-gray-300 block mb-4">assignment</span>
        <h3 class="text-2xl font-black text-gray-400 mb-2">No attempts yet</h3>
        <p class="text-gray-400 font-medium mb-6">Complete your first assessment to see progress here.</p>
        <asp:Button ID="btnGoMissions" runat="server"
            Text="Browse Missions"
            OnClick="btnGoMissions_Click"
            CausesValidation="false"
            CssClass="bg-math-blue text-white font-black px-8 py-3 rounded-2xl hover:bg-math-dark-blue transition-all shadow-lg uppercase tracking-widest text-sm border-0 cursor-pointer" />
    </asp:Panel>

    <%-- Main grid --%>
    <asp:Panel ID="pnlContent" runat="server" Visible="false">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">

            <%-- Left: attempt cards --%>
            <div class="lg:col-span-8 space-y-6">
                <asp:Repeater ID="rptAttempts" runat="server"
                              OnItemDataBound="rptAttempts_ItemDataBound"
                              OnItemCommand="rptAttempts_ItemCommand1">
                    <ItemTemplate>
                        <div class="bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100
                                    shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-6
                                    flex flex-col md:flex-row items-center gap-8">

                            <%-- Score visual --%>
                            <div class="relative size-24 shrink-0">

                                <%-- Quiz: SVG score ring --%>
                                <asp:Panel ID="pnlQuizCard" runat="server" Visible="false">
                                    <svg class="absolute inset-0 size-full -rotate-90" viewBox="0 0 100 100">
                                        <circle cx="50" cy="50" r="45" fill="none" stroke="#e5e7eb" stroke-width="10"/>
                                        <circle cx="50" cy="50" r="45" fill="none" stroke="#2563eb" stroke-width="10"
                                                stroke-dasharray="283"
                                                stroke-dashoffset="<asp:Literal ID="litRingOffset" runat="server" />"
                                                stroke-linecap="round"/>
                                    </svg>
                                    <div class="absolute inset-0 flex flex-col items-center justify-center">
                                        <span class="text-xl font-black text-math-dark-blue">
                                            <asp:Literal ID="litScorePct" runat="server" />%
                                        </span>
                                        <span class="text-[9px] font-black text-math-blue uppercase tracking-widest">Score</span>
                                    </div>
                                </asp:Panel>

                                <%-- Assessment: paper icon --%>
                                <asp:Panel ID="pnlPaperCard" runat="server" Visible="false">
                                    <div class="absolute inset-0 rounded-full border-4 border-gray-200
                                                flex flex-col items-center justify-center bg-gray-50">
                                        <span class="material-symbols-outlined text-gray-400 text-2xl">description</span>
                                        <span class="text-[9px] font-black text-gray-400 uppercase mt-0.5">Paper</span>
                                    </div>
                                </asp:Panel>
                            </div>

                            <%-- Info --%>
                            <div class="flex-1 text-center md:text-left">
                                <p class="text-gray-400 text-[10px] font-black uppercase tracking-widest mb-1">
                                    <asp:Literal ID="litAttemptDate" runat="server" />
                                </p>
                                <h3 class="text-xl font-black text-math-dark-blue leading-tight mb-1">
                                    <asp:Literal ID="litAttemptTitle" runat="server" />
                                </h3>
                                <p class="text-sm font-bold text-gray-500">
                                    Score: <asp:Literal ID="litScoreFrac" runat="server" />
                                </p>

                                <%-- Assessment note --%>
                                <asp:Panel ID="pnlPaperNote" runat="server" Visible="false">
                                    <span class="inline-flex items-center gap-1 mt-1 px-2 py-0.5
                                                 rounded-full bg-gray-100 text-gray-400 text-[10px] font-black uppercase">
                                        <span class="material-symbols-outlined text-sm">info</span>
                                        Marked by teacher
                                    </span>
                                </asp:Panel>
                            </div>

                            <%-- Action buttons --%>
                            <div class="flex flex-col sm:flex-row gap-3 w-full md:w-auto">

                                <%-- Quiz: Review Answers --%>
                                <asp:Panel ID="pnlQuizActions" runat="server" Visible="false">
                                    <asp:HyperLink ID="lnkReviewAnswers" runat="server"
                                        CssClass="block px-6 py-3 bg-math-blue text-white font-black rounded-2xl
                                                  hover:bg-math-dark-blue transition-colors shadow-lg shadow-math-blue/20
                                                  whitespace-nowrap uppercase tracking-widest text-xs text-center">
                                        REVIEW ANSWERS
                                    </asp:HyperLink>
                                </asp:Panel>

                                <%-- Assessment: View Answer Key --%>
                                <asp:Panel ID="pnlPaperActions" runat="server" Visible="false">
                                    <asp:HyperLink ID="lnkAnswerKey" runat="server"
                                        CssClass="block px-6 py-3 bg-primary text-math-dark-blue font-black rounded-2xl
                                                  hover:bg-yellow-400 transition-colors shadow-lg shadow-primary/20
                                                  whitespace-nowrap uppercase tracking-widest text-xs text-center">
                                        VIEW ANSWER KEY
                                    </asp:HyperLink>
                                </asp:Panel>

                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <%-- -- Right: summary panel (direct controls, not a repeater) - --%>
            <div class="lg:col-span-4 space-y-6">
                <asp:Panel ID="pnlSummary" runat="server" Visible="false">
                    <section class="bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100
                                    shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-8 flex flex-col items-center text-center">
                        <h3 class="text-xl font-black uppercase tracking-tight mb-8">Performance Summary</h3>

                        <%-- Mastery ring --%>
                        <div class="relative size-48 mb-8">
                            <svg class="absolute inset-0 size-full -rotate-90" viewBox="0 0 100 100">
                                <circle cx="50" cy="50" r="45" fill="none" stroke="#e5e7eb" stroke-width="8"/>
                                <circle cx="50" cy="50" r="45" fill="none" stroke="#2563eb" stroke-width="8"
                                        stroke-dasharray="283"
                                        stroke-dashoffset="<asp:Literal ID="litMasteryOffset" runat="server" />"
                                        stroke-linecap="round"/>
                            </svg>
                            <div class="absolute inset-0 flex flex-col items-center justify-center">
                                <span class="text-5xl font-black text-math-blue">
                                    <asp:Literal ID="litMasteryPct" runat="server" />%
                                </span>
                                <span class="text-xs font-black uppercase text-gray-400 tracking-widest mt-1">Average</span>
                            </div>
                        </div>

                        <div class="w-full space-y-4">
                            <div class="flex justify-between items-center p-4 bg-white/70 border border-gray-100 rounded-2xl">
                                <span class="font-bold text-gray-500 text-sm">Attempts</span>
                                <span class="font-black text-math-dark-blue">
                                    <asp:Literal ID="litStatAttempts" runat="server" />
                                </span>
                            </div>
                            <div class="flex justify-between items-center p-4 bg-white/70 border border-gray-100 rounded-2xl">
                                <span class="font-bold text-gray-500 text-sm">Assessments Tried</span>
                                <span class="font-black text-math-dark-blue">
                                    <asp:Literal ID="litStatAssessments" runat="server" />
                                </span>
                            </div>
                            <div class="flex justify-between items-center p-4 bg-white/70 border border-gray-100 rounded-2xl">
                                <span class="font-bold text-gray-500 text-sm">Average Quiz Score</span>
                                <span class="font-black text-math-green">
                                    <asp:Literal ID="litStatQuizAvg" runat="server" />
                                </span>
                            </div>
                            <div class="flex justify-between items-center p-4 bg-white/70 border border-gray-100 rounded-2xl">
                                <span class="font-bold text-gray-500 text-sm">Best Quiz Score</span>
                                <span class="font-black text-primary">
                                    <asp:Literal ID="litStatBestQuiz" runat="server" />
                                </span>
                            </div>
                        </div>
                    </section>
                </asp:Panel>
            </div>

        </div>
    </asp:Panel>

</asp:Content>



