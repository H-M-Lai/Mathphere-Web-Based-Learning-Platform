<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="studentAssessmentResult.aspx.cs" Inherits="MathSphere.studentAssessmentResult" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Assessment Results
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    @keyframes cardIn {
        from { opacity: 0; transform: translateY(20px) scale(.98); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }
    .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
</style>
</asp:Content>
<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .correct-card   { border-color:#86efac!important; background:#f0fdf4; }
    .incorrect-card { border-color:#fca5a5!important; background:#fff1f2; }
    .correct-badge  { background:#dcfce7;color:#15803d; }
    .incorrect-badge{ background:#fee2e2;color:#b91c1c; }
    .opt-correct    { background:#dcfce7;border-color:#86efac; }
    .opt-incorrect  { background:#fee2e2;border-color:#fca5a5; }
    .opt-missed     { background:#fef9c3;border-color:#fde68a; }
    .score-ring     { stroke-dasharray:283; stroke-dashoffset:283;
                      transition:stroke-dashoffset 1.2s cubic-bezier(0.4,0,0.2,1); }
</style>

<div class="page-enter space-y-8">
    <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-3 max-w-3xl">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">analytics</span>
                Result snapshot
            </div>
            <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Assessment Results</h2>
            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Review your score, check each answer, and use the breakdown below to decide what to focus on next.</p>
        </div>
    </section>

    <%-- -- Score hero card -- --%>
    <section class="bg-math-dark-blue rounded-3xl p-8 md:p-10 relative overflow-hidden shadow-2xl">
        <div class="absolute -top-12 -right-12 size-48 bg-white/5 rounded-full"></div>
        <div class="absolute bottom-0 left-0 size-32 bg-white/5 rounded-full"></div>

        <div class="relative z-10 flex flex-col md:flex-row items-center gap-8">

            <%-- Ring --%>
            <div class="relative flex-shrink-0">
                <svg width="160" height="160" viewBox="0 0 100 100" class="-rotate-90">
                    <circle cx="50" cy="50" r="45" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="10"/>
                    <circle id="scoreRing" cx="50" cy="50" r="45" fill="none"
                        stroke="#f9d006" stroke-width="10" stroke-linecap="round"
                        class="score-ring" />
                </svg>
                <div class="absolute inset-0 flex flex-col items-center justify-center">
                    <span id="scoreDisplay" class="text-4xl font-black text-white"></span>
                    <span class="text-[10px] font-black text-white/50 uppercase tracking-widest">Score</span>
                </div>
            </div>

            <%-- Stats --%>
            <div class="flex-1 space-y-3 text-center md:text-left">
                <asp:Panel ID="pnlPassFail" runat="server">
                    <%-- filled by code-behind --%>
                </asp:Panel>
                <h2 class="text-3xl font-black text-white">
                    <asp:Literal ID="litAssessmentTitle" runat="server" />
                </h2>
                <div class="flex flex-wrap gap-3 justify-center md:justify-start">
                    <div class="px-4 py-2 bg-white/10 rounded-2xl border border-white/20">
                        <span class="text-[10px] font-black text-white/50 uppercase block">Correct</span>
                        <span class="text-xl font-black text-math-green"><asp:Literal ID="litCorrectCount" runat="server"/></span>
                    </div>
                    <div class="px-4 py-2 bg-white/10 rounded-2xl border border-white/20">
                        <span class="text-[10px] font-black text-white/50 uppercase block">Wrong</span>
                        <span class="text-xl font-black text-red-400"><asp:Literal ID="litWrongCount" runat="server"/></span>
                    </div>
                    <div class="px-4 py-2 bg-white/10 rounded-2xl border border-white/20">
                        <span class="text-[10px] font-black text-white/50 uppercase block">Points</span>
                        <span class="text-xl font-black text-primary"><asp:Literal ID="litScore" runat="server"/> / <asp:Literal ID="litTotalPossible" runat="server"/></span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%-- -- Question review -- --%>
    <section class="space-y-4">
        <div class="flex items-center justify-between px-1">
            <h3 class="text-sm font-black text-math-dark-blue uppercase tracking-widest">Answer Review</h3>
        </div>
        <asp:Repeater ID="rptResults" runat="server" OnItemDataBound="rptResults_ItemDataBound">
            <ItemTemplate>
                <asp:Literal ID="litResultCard" runat="server" />
            </ItemTemplate>
        </asp:Repeater>
    </section>

    <%-- -- Actions -- --%>
    <div class="flex flex-wrap gap-4 justify-center">
        <asp:HyperLink ID="lnkBackToModule" runat="server"
            CssClass="inline-flex items-center gap-2 px-8 py-4 rounded-2xl bg-math-dark-blue text-white
                      font-black text-sm uppercase tracking-widest shadow-lg hover:bg-math-blue transition-colors">
            <span class="material-symbols-outlined fill-icon">arrow_back</span> Return to Module
        </asp:HyperLink>
        <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/StudentDashboard.aspx"
            CssClass="inline-flex items-center gap-2 px-8 py-4 rounded-2xl bg-white border-2 border-gray-200
                      text-math-dark-blue font-black text-sm uppercase tracking-widest hover:bg-gray-50 transition-colors">
            <span class="material-symbols-outlined fill-icon">home</span> Back to Dashboard
        </asp:HyperLink>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function(){
    var score   = parseInt('<%= ScorePct %>',10)||0;
    var ring    = document.getElementById('scoreRing');
    var display = document.getElementById('scoreDisplay');
    // circumference of r=45 is ~283
    var C = 2*Math.PI*45;
    ring.setAttribute('stroke-dasharray', C.toFixed(1));
    ring.setAttribute('stroke-dashoffset', C.toFixed(1));
    display.textContent = score+'%';
    setTimeout(function(){
        ring.style.strokeDashoffset = (C*(1-score/100)).toFixed(1);
    }, 100);
});
</script>

</div>
</asp:Content>



