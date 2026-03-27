<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="studentAssessment.aspx.cs" Inherits="MathSphere.studentAssessment" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Assessment
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

<asp:HiddenField ID="hdnAssessmentId" runat="server" />
<asp:HiddenField ID="hdnAttemptId"    runat="server" />
<asp:HiddenField ID="hdnTimeLimit"    runat="server" Value="60" />
<asp:HiddenField ID="hdnAnswersJson"  runat="server" />
<asp:Button ID="btnSubmitHidden" runat="server" OnClick="btnSubmitAssessment_Click" Style="display:none" />

<style>
    .opt-label { cursor:pointer; transition:all 0.18s ease; }
    .opt-label:hover { background:#eff6ff; border-color:#93c5fd; }
    .opt-label:has(input:checked) { background:#dbeafe; border-color:#2563eb; }
    .opt-label:has(input:checked) .opt-letter { background:#2563eb; color:#fff; border-color:#2563eb; }
    .opt-label:has(input:checked) .opt-text   { color:#1e3a8a; font-weight:900; }
    .tf-btn { transition:all 0.18s ease; }
    .tf-btn.selected-true  { background:#dbeafe; border-color:#2563eb; color:#1e3a8a; font-weight:900; }
    .tf-btn.selected-false { background:#fee2e2; border-color:#f87171; color:#991b1b; font-weight:900; }
    #timerDisplay { font-variant-numeric:tabular-nums; }
    .timer-danger { color:#ef4444!important; animation:pulse-r 1s infinite; }
    @keyframes pulse-r { 0%,100%{opacity:1}50%{opacity:0.5} }
    @keyframes cardIn { from { opacity: 0; transform: translateY(20px) scale(.98); } to { opacity: 1; transform: translateY(0) scale(1); } }
    .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
    .q-dot { width:32px;height:32px;border-radius:8px;font-size:11px;font-weight:900;
             display:flex;align-items:center;justify-content:center;cursor:pointer;
             border:2px solid transparent;transition:all 0.15s; }
    .q-dot.unanswered { background:#f1f5f9;color:#94a3b8;border-color:#e2e8f0; }
    .q-dot.answered   { background:#dcfce7;color:#15803d;border-color:#86efac; }
    .q-dot.current    { background:#2563eb;color:#fff;border-color:#1d4ed8; }
    #progBar { transition:width 0.3s ease; }
</style>

<div class="page-enter space-y-6">
    <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-3 max-w-3xl">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">assignment</span>
                Knowledge check
            </div>
            <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Student Assessment</h2>
            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Stay focused, track your progress question by question, and submit when you are confident in your answers.</p>
        </div>
    </section>

    <%-- -- Sticky top bar -- --%>
    <div class="sticky top-[64px] z-40 -mx-4 md:-mx-6 px-4 md:px-6">
        <div class="bg-white/95 backdrop-blur-md border border-gray-200 rounded-2xl shadow-md px-5 py-3
                    flex items-center justify-between gap-4 flex-wrap">
            <div class="min-w-0">
                <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Assessment</p>
                <h1 class="text-sm font-black text-math-dark-blue truncate max-w-xs">
                    <asp:Literal ID="litHeaderTitle" runat="server" />
                </h1>
            </div>
            <div class="flex items-center gap-3 flex-1 min-w-[140px] max-w-xs">
                <div class="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden">
                    <div id="progBar" class="h-full bg-math-blue rounded-full" style="width:0%"></div>
                </div>
                <span id="progLabel" class="text-xs font-black text-gray-400 whitespace-nowrap">0/0</span>
            </div>
            <div class="flex items-center gap-2 px-4 py-2 bg-gray-50 border border-gray-200 rounded-2xl">
                <span class="material-symbols-outlined text-math-blue text-base fill-icon">schedule</span>
                <span id="timerDisplay" class="text-base font-black text-math-dark-blue">--:--</span>
            </div>
            <button type="button" onclick="showSubmitModal()"
                class="px-5 py-2 bg-primary text-math-dark-blue font-black text-xs uppercase tracking-widest
                       rounded-xl hover:bg-yellow-400 transition-all shadow-sm">Submit</button>
        </div>
    </div>

    <%-- -- Main layout -- --%>
    <div class="grid grid-cols-1 xl:grid-cols-[1fr_240px] gap-6">

        <%-- Questions --%>
        <div class="space-y-6">
            <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                <ItemTemplate>
                    <asp:Literal ID="litQuestionCard" runat="server" />
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <%-- Nav sidebar --%>
        <aside class="xl:sticky xl:top-[140px] xl:self-start space-y-4">
            <div class="bg-white border border-gray-100 rounded-3xl p-5 shadow-sm">
                <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-3">Navigator</p>
                <div id="qNavDots" class="flex flex-wrap gap-2 mb-4"></div>
                <div class="space-y-2 pt-3 border-t border-gray-100">
                    <div class="flex items-center gap-2">
                        <span class="size-3 rounded bg-green-100 border border-green-300 inline-block"></span>
                        <span class="text-xs font-semibold text-gray-400">Answered</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="size-3 rounded bg-gray-100 border border-gray-200 inline-block"></span>
                        <span class="text-xs font-semibold text-gray-400">Unanswered</span>
                    </div>
                </div>
            </div>
            <button type="button" onclick="showSubmitModal()"
                class="w-full py-4 bg-primary text-math-dark-blue font-black text-sm uppercase tracking-widest
                       rounded-2xl shadow-lg hover:bg-yellow-400 transition-all">
                Finish &amp; Submit
            </button>
        </aside>
    </div>
</div>

<%-- -- Submit modal -- --%>
<div id="submitModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center bg-black/50 backdrop-blur-sm">
    <div class="bg-white rounded-3xl p-8 shadow-2xl w-full max-w-sm mx-4">
        <div class="size-16 rounded-2xl bg-primary/20 flex items-center justify-center mx-auto mb-4">
            <span class="material-symbols-outlined text-math-dark-blue text-3xl fill-icon">assignment_turned_in</span>
        </div>
        <h3 class="text-xl font-black text-math-dark-blue text-center mb-1">Submit Assessment?</h3>
        <p id="submitMsg" class="text-sm text-gray-500 text-center mb-6"></p>
        <div class="flex gap-3">
            <button type="button" onclick="closeSubmitModal()"
                class="flex-1 py-3.5 bg-gray-100 text-math-dark-blue font-black text-sm rounded-2xl hover:bg-gray-200">Review</button>
            <button type="button" onclick="doSubmit()"
                class="flex-1 py-3.5 bg-primary text-math-dark-blue font-black text-sm rounded-2xl hover:bg-yellow-400 shadow-lg">Submit Now</button>
        </div>
    </div>
</div>

<script>
(function(){
    var QUESTIONS  = <%= QuestionsJson %>;
    var TIME_LIMIT = parseInt(document.getElementById('<%= hdnTimeLimit.ClientID %>').value,10)||60;
    var answers    = {};
    var secs       = TIME_LIMIT * 60;
    var timer;
    var total      = QUESTIONS.length;

    // Timer
    function tick(){
        secs--;
        var m=Math.floor(secs/60),s=secs%60;
        var el=document.getElementById('timerDisplay');
        el.textContent=(m<10?'0':'')+m+':'+(s<10?'0':'')+s;
        if(secs<=60) el.classList.add('timer-danger');
        if(secs<=0){clearInterval(timer);doSubmit();}
    }

    // Progress
    function refreshProgress(){
        var done=Object.keys(answers).length;
        var pct=total>0?Math.round(done/total*100):0;
        document.getElementById('progBar').style.width=pct+'%';
        document.getElementById('progLabel').textContent=done+'/'+total;
    }

    // Nav dots
    function buildDots(){
        var c=document.getElementById('qNavDots');
        QUESTIONS.forEach(function(q,i){
            var d=document.createElement('div');
            d.className='q-dot unanswered';
            d.textContent=i+1;
            d.id='dot-'+q.questionId;
            d.onclick=function(){
                var el=document.getElementById('qcard-'+q.questionId);
                if(el) el.scrollIntoView({behavior:'smooth',block:'center'});
            };
            c.appendChild(d);
        });
    }

    function setDot(qid,state){
        var d=document.getElementById('dot-'+qid);
        if(d) d.className='q-dot '+state;
    }

    // Public: called from inline onchange/onclick
    window.recordAnswer=function(qid,val){
        if(val===''||val===null||val===undefined){
            delete answers[qid]; setDot(qid,'unanswered');
        } else {
            answers[qid]=val; setDot(qid,'answered');
        }
        refreshProgress();
    };

    // TF toggle helper
    window.tfPick=function(qid,val,btnTrue,btnFalse){
        answers[qid]=val;
        setDot(qid,'answered');
        refreshProgress();
        document.getElementById(btnTrue).className ='tf-btn flex-1 py-4 rounded-2xl border-2 font-black text-sm uppercase tracking-widest'+(val==='True' ?' selected-true':' bg-white border-gray-200 text-gray-600 hover:bg-gray-50');
        document.getElementById(btnFalse).className='tf-btn flex-1 py-4 rounded-2xl border-2 font-black text-sm uppercase tracking-widest'+(val==='False'?' selected-false':' bg-white border-gray-200 text-gray-600 hover:bg-gray-50');
    };

    // Modal
    window.showSubmitModal=function(){
        var done=Object.keys(answers).length;
        var left=total-done;
        var msg=done+' of '+total+' questions answered.';
        if(left>0) msg+=' '+left+' unanswered.';
        document.getElementById('submitMsg').textContent=msg;
        document.getElementById('submitModal').classList.remove('hidden');
    };
    window.closeSubmitModal=function(){
        document.getElementById('submitModal').classList.add('hidden');
    };
    window.doSubmit=function(){
        clearInterval(timer);
        document.getElementById('submitModal').classList.add('hidden');
        var payload=[];
        QUESTIONS.forEach(function(q){
            payload.push({questionId:q.questionId,answer:answers[q.questionId]||''});
        });
        document.getElementById('<%= hdnAnswersJson.ClientID %>').value=JSON.stringify(payload);
        document.getElementById('<%= btnSubmitHidden.ClientID %>').click();
    };

    document.addEventListener('DOMContentLoaded',function(){
        buildDots();
        refreshProgress();
        // init timer display
        var m=Math.floor(secs/60),s=secs%60;
        document.getElementById('timerDisplay').textContent=(m<10?'0':'')+m+':'+(s<10?'0':'')+s;
        timer=setInterval(tick,1000);
        document.getElementById('submitModal').addEventListener('click',function(e){
            if(e.target===this) closeSubmitModal();
        });
    });
})();
</script>

</asp:Content>





