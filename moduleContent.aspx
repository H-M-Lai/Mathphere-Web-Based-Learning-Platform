<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="moduleContent.aspx.cs" Inherits="MathSphere.moduleContent" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Module
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(20px) scale(.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
        @keyframes blockFocusPulse {
            0% { box-shadow: 0 0 0 0 rgba(37,99,235,.28); transform: translateY(0); }
            20% { box-shadow: 0 0 0 10px rgba(37,99,235,.12); }
            100% { box-shadow: 0 0 0 0 rgba(37,99,235,0); transform: translateY(0); }
        }
        .block-focus-flash {
            position: relative;
            border-color: rgba(37,99,235,.35) !important;
            box-shadow: 0 18px 40px rgba(37,99,235,.14);
            animation: blockFocusPulse 1.2s ease-out 1;
        }
    </style>
</asp:Content>
<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

<script>
    function flashFocusBlock(el) {
        if (!el) return;
        el.classList.remove("block-focus-flash");
        void el.offsetWidth;
        el.classList.add("block-focus-flash");
        window.setTimeout(function () { el.classList.remove("block-focus-flash"); }, 1500);
    }

    function focusBlockById(blockId) {
        if (!blockId) return;
        var el = document.getElementById("block-" + blockId);
        if (!el) return;
        el.scrollIntoView({ behavior: "smooth", block: "start" });
        window.setTimeout(function () { flashFocusBlock(el); }, 180);
    }

    function scrollToNextBlock() {
        var sections = document.querySelectorAll('section[id^="block-"]');
        for (var i = 0; i < sections.length; i++) {
            if (!sections[i].classList.contains('border-l-math-green')) {
                sections[i].scrollIntoView({ behavior: 'smooth', block: 'start' });
                return;
            }
        }
        var banner = document.getElementById('module-complete');
        if (banner) banner.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
</script>

<div class="page-enter mb-10">
    <div class="text-center max-w-2xl mx-auto mb-10">
        <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 mb-3">Active Lesson Flow</p>
        <p class="text-lg font-bold text-gray-500">Work through each block in order and track your progress as you go.</p>
    </div>

    <asp:Panel ID="pnlActionError" runat="server" Visible="false">
        <div class="max-w-3xl mx-auto mb-8 px-5 py-4 rounded-2xl bg-red-50 border border-red-200 text-red-700 font-semibold shadow-sm">
            <div class="flex items-start gap-3">
                <span class="material-symbols-outlined text-red-500 fill-icon">error</span>
                <asp:Literal ID="litActionError" runat="server" />
            </div>
        </div>
    </asp:Panel>

<div class="grid grid-cols-1 lg:grid-cols-[320px_1fr] gap-8">

    <%-- SIDEBAR --%>
    <aside class="space-y-6">
        <div class="surface-card p-6">
            <div class="flex items-center justify-between mb-5">
                <div>
                    <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Modules</p>
                    <h2 class="text-lg font-black tracking-tight text-math-dark-blue mt-1">Browse</h2>
                </div>
                <div class="size-10 rounded-2xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center">
                    <span class="material-symbols-outlined text-math-blue fill-icon">menu_book</span>
                </div>
            </div>
            <div class="space-y-2">
                <asp:Repeater ID="rptModules" runat="server">
                    <ItemTemplate>
                        <a href='moduleContent.aspx?moduleId=<%# Eval("moduleID") %>'
                           class="group flex items-center justify-between gap-3 px-4 py-3 rounded-2xl
                                  bg-white/60 border border-gray-100
                                  hover:bg-white hover:border-math-blue/20 transition-all">
                            <span class="font-black text-sm text-math-dark-blue truncate"><%# Eval("ModuleName") %></span>
                            <span class="material-symbols-outlined text-gray-300 group-hover:text-math-blue transition-colors">chevron_right</span>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </aside>

    <%-- MAIN --%>
    <main class="space-y-8">

        <%-- Module Header + Progress Bar --%>
        <section class="surface-card p-8">
            <div class="flex items-start justify-between gap-6 mb-6">
                <div class="min-w-0">
                    <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Learning Session</p>
                    <h1 class="text-4xl md:text-5xl font-black tracking-tight text-math-dark-blue mt-2">
                        <asp:Literal ID="litModuleTitle" runat="server" />
                    </h1>
                    <p class="mt-4 text-lg font-semibold text-gray-500 leading-relaxed">
                        <asp:Literal ID="litModuleDescription" runat="server" />
                    </p>
                </div>
                <div class="hidden md:flex size-14 rounded-2xl bg-primary text-math-dark-blue items-center justify-center shadow-lg shadow-primary/20 flex-shrink-0">
                    <span class="material-symbols-outlined fill-icon text-3xl">school</span>
                </div>
            </div>
            <div class="space-y-2">
                <div class="flex justify-between text-sm font-black">
                    <span class="text-gray-500">Your Progress</span>
                    <span class="text-math-blue">
                        <asp:Literal ID="litProgressDone" runat="server" /> /
                        <asp:Literal ID="litProgressTotal" runat="server" /> blocks
                        (<asp:Literal ID="litProgressPct" runat="server" />%)
                    </span>
                </div>
                <div class="h-3 w-full bg-gray-100 rounded-full overflow-hidden border border-gray-200">
                    <asp:Panel ID="pnlProgressFill" runat="server"
                               CssClass="h-full bg-math-blue rounded-full transition-all duration-500">
                    </asp:Panel>
                </div>
            </div>
        </section>

        <%-- CONTENT BLOCKS --%>
        <asp:Repeater ID="rptBlocks" runat="server">
            <ItemTemplate>

                <%-- ------------------------------------------------
                     LOCKED block
                     Uses a code-behind helper to avoid Visible= text rendering
                ----------------------------------------------------- --%>
                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsLocked")) %>'>
                    <section id='<%# "block-" + Eval("BlockID").ToString().Trim() %>'
                             class="surface-card p-8 opacity-50 pointer-events-none select-none">
                        <div class="flex items-center gap-4">
                            <div class="size-12 rounded-2xl bg-gray-200 flex items-center justify-center flex-shrink-0">
                                <span class="material-symbols-outlined text-gray-400 text-2xl">lock</span>
                            </div>
                            <div>
                                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400"><%# Eval("BlockType") %></p>
                                <h2 class="text-xl font-black text-gray-400 mt-1"><%# Eval("Title") %></h2>
                                <p class="text-sm font-semibold text-gray-400 mt-1">Complete the previous block to unlock this one.</p>
                            </div>
                        </div>
                    </section>
                </asp:PlaceHolder>

                <%-- VIDEO block --%>
                <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsLocked")) && Eval("BlockType").ToString() == "Video" %>'>
                    <section id='<%# "block-" + Eval("BlockID").ToString().Trim() %>'
                             class='<%# Convert.ToBoolean(Eval("IsCompleted")) ? "surface-card p-8 border-l-4 border-l-math-green" : "surface-card p-8" %>'>

                        <div class="flex items-start justify-between gap-6 mb-6">
                            <div class="min-w-0">
                                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Video Lesson</p>
                                <h2 class="text-2xl md:text-3xl font-black text-math-dark-blue mt-2"><%# Eval("Title") %></h2>
                            </div>
                            <div class="flex items-center gap-3">
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-math-green/10 border border-math-green/20 text-math-green text-xs font-black uppercase tracking-widest">
                                        <span class="material-symbols-outlined text-sm fill-icon">check_circle</span> Completed
                                    </span>
                                </asp:PlaceHolder>
                                <div class="size-12 rounded-2xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center flex-shrink-0">
                                    <span class="material-symbols-outlined text-math-blue fill-icon">play_circle</span>
                                </div>
                            </div>
                        </div>

                        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm mb-4">
                            <iframe class="w-full h-72 md:h-96"
                                    src='<%# Eval("VideoUrl") %>'
                                    frameborder="0" allowfullscreen loading="lazy">
                            </iframe>
                        </div>

                        <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("VideoCaption").ToString()) %>'>
                            <p class="text-sm font-semibold text-gray-400 italic mb-4"><%# Eval("VideoCaption") %></p>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("VideoNotes").ToString()) %>'>
                            <div class="mb-6 p-4 rounded-2xl bg-math-blue/5 border border-math-blue/10 text-gray-600 font-semibold text-sm">
                                <%# Eval("VideoNotes") %>
                            </div>
                        </asp:PlaceHolder>

                        <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsCompleted")) %>'>
                            <asp:Button runat="server" Text="Mark Complete &amp; Continue"
                                CommandArgument='<%# Eval("BlockID") %>'
                                OnClick="btnNext_Click" CausesValidation="false" UseSubmitBehavior="false"
                                CssClass="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-blue text-white
                                          font-black text-sm uppercase tracking-widest shadow-lg shadow-math-blue/20
                                          hover:bg-math-dark-blue transition-all cursor-pointer" />
                        </asp:PlaceHolder>
                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                            <div class="flex items-center gap-3 flex-wrap">
                                <div class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-math-green/10 border border-math-green/20 text-math-green font-black text-sm uppercase tracking-widest">
                                    <span class="material-symbols-outlined text-base fill-icon">check_circle</span> Completed
                                </div>
                                <span class="text-xs font-semibold text-gray-400">You can rewatch this video anytime above.</span>
                            </div>
                        </asp:PlaceHolder>
                    </section>
                </asp:PlaceHolder>

                <%-- TEXT / PDF block --%>
                <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsLocked")) && Eval("BlockType").ToString() == "Text" %>'>
                    <section id='<%# "block-" + Eval("BlockID").ToString().Trim() %>'
                             class='<%# Convert.ToBoolean(Eval("IsCompleted")) ? "surface-card p-8 border-l-4 border-l-math-green" : "surface-card p-8" %>'>

                        <div class="flex items-start justify-between gap-6 mb-6">
                            <div class="min-w-0">
                                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Reading</p>
                                <h2 class="text-2xl md:text-3xl font-black text-math-dark-blue mt-2"><%# Eval("Title") %></h2>
                            </div>
                            <div class="flex items-center gap-3">
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-math-green/10 border border-math-green/20 text-math-green text-xs font-black uppercase tracking-widest">
                                        <span class="material-symbols-outlined text-sm fill-icon">check_circle</span> Completed
                                    </span>
                                </asp:PlaceHolder>
                                <div class="size-12 rounded-2xl bg-math-green/10 border border-math-green/10 flex items-center justify-center flex-shrink-0">
                                    <span class="material-symbols-outlined text-math-green fill-icon">menu_book</span>
                                </div>
                            </div>
                        </div>

                        <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("TextContent").ToString().Trim()) %>'>
                            <div class="text-gray-600 font-semibold leading-relaxed text-base md:text-lg mb-6">
                                <%# Eval("TextContent") %>
                            </div>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("FileUrl").ToString().Trim()) %>'>
                            <a href='<%# ResolveUrl(Eval("FileUrl").ToString()) %>' target="_blank"
                               class="inline-flex items-center gap-3 px-5 py-3 rounded-2xl bg-math-dark-blue text-white
                                      font-black text-sm uppercase tracking-widest hover:bg-math-blue transition-colors shadow-lg mb-6">
                                <span class="material-symbols-outlined fill-icon">picture_as_pdf</span>
                                Download PDF
                            </a>
                        </asp:PlaceHolder>

                        <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsCompleted")) %>'>
                            <asp:Button runat="server" Text="Mark Complete &amp; Continue"
                                CommandArgument='<%# Eval("BlockID") %>'
                                OnClick="btnNext_Click" CausesValidation="false" UseSubmitBehavior="false"
                                CssClass="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-blue text-white
                                          font-black text-sm uppercase tracking-widest shadow-lg shadow-math-blue/20
                                          hover:bg-math-dark-blue transition-all cursor-pointer" />
                        </asp:PlaceHolder>
                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                            <div class="flex items-center gap-3 flex-wrap">
                                <div class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-math-green/10 border border-math-green/20 text-math-green font-black text-sm uppercase tracking-widest">
                                    <span class="material-symbols-outlined text-base fill-icon">check_circle</span> Completed
                                </div>
                                <span class="text-xs font-semibold text-gray-400">You can re-read or re-download anytime above.</span>
                            </div>
                        </asp:PlaceHolder>
                    </section>
                </asp:PlaceHolder>

                <%-- FLASHCARD block --%>
                <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsLocked")) && Eval("BlockType").ToString().StartsWith("Flashcard") %>'>
                    <section id='<%# "block-" + Eval("BlockID").ToString().Trim() %>'
                             class='<%# Convert.ToBoolean(Eval("IsCompleted")) ? "surface-card p-8 border-l-4 border-l-math-green" : "surface-card p-8" %>'>

                        <div class="flex items-start justify-between gap-6 mb-6">
                            <div class="min-w-0">
                                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Flashcards</p>
                                <h2 class="text-2xl md:text-3xl font-black text-math-dark-blue mt-2"><%# Eval("Title") %></h2>
                                <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("FlashcardSetTitle").ToString()) %>'>
                                    <p class="mt-2 text-sm font-semibold text-gray-400">Set: <%# Eval("FlashcardSetTitle") %></p>
                                </asp:PlaceHolder>
                            </div>
                            <div class="flex items-center gap-3">
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-math-green/10 border border-math-green/20 text-math-green text-xs font-black uppercase tracking-widest">
                                        <span class="material-symbols-outlined text-sm fill-icon">check_circle</span> Completed
                                    </span>
                                </asp:PlaceHolder>
                                <div class="size-12 rounded-2xl bg-primary/20 border border-primary/30 flex items-center justify-center flex-shrink-0">
                                    <span class="material-symbols-outlined text-math-dark-blue fill-icon">style</span>
                                </div>
                            </div>
                        </div>

                        <div class="flex flex-wrap gap-3">
                            <a href='<%# "Flashcard.aspx?setId=" + Eval("FlashcardSetID") + "&moduleId=" + ModuleId %>'
                               class='<%# Convert.ToBoolean(Eval("IsCompleted"))
                                        ? "inline-flex items-center gap-3 px-6 py-3 rounded-2xl bg-white border-2 border-primary text-math-dark-blue font-black text-sm uppercase tracking-widest hover:bg-primary/10 transition-colors shadow-sm"
                                        : "inline-flex items-center gap-3 px-6 py-3 rounded-2xl bg-primary text-math-dark-blue font-black text-sm uppercase tracking-widest hover:bg-yellow-400 transition-colors shadow-lg shadow-primary/20" %>'>
                                <span class="material-symbols-outlined fill-icon"><%# Convert.ToBoolean(Eval("IsCompleted")) ? "replay" : "play_arrow" %></span>
                                <%# Convert.ToBoolean(Eval("IsCompleted")) ? "Practice Again" : "Start Flashcards" %>
                            </a>

                            <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("FlashcardAttempted")) %>'>
                                    <asp:Button runat="server" Text="Mark Complete &amp; Continue"
                                        CommandArgument='<%# Eval("BlockID") %>'
                                        OnClick="btnNext_Click" CausesValidation="false" UseSubmitBehavior="false"
                                        CssClass="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-blue text-white
                                                  font-black text-sm uppercase tracking-widest shadow-lg shadow-math-blue/20
                                                  hover:bg-math-dark-blue transition-all cursor-pointer" />
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("FlashcardAttempted")) %>'>
                                    <div class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl
                                                bg-gray-100 border border-gray-200 text-gray-400
                                                font-black text-sm uppercase tracking-widest">
                                        <span class="material-symbols-outlined text-base">lock</span>
                                        Complete the flashcards first
                                    </div>
                                </asp:PlaceHolder>
                            </asp:PlaceHolder>

                            <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                <div class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-math-green/10 border border-math-green/20 text-math-green font-black text-sm uppercase tracking-widest">
                                    <span class="material-symbols-outlined text-base fill-icon">check_circle</span> Completed
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </section>
                </asp:PlaceHolder>

                <%-- QUIZ block --%>
                <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsLocked")) && Eval("BlockType").ToString() == "Quiz" %>'>
                    <section id='<%# "block-" + Eval("BlockID").ToString().Trim() %>'
                             class='<%# Convert.ToBoolean(Eval("IsCompleted")) ? "surface-card p-8 border-l-4 border-l-math-green" : "surface-card p-8" %>'>

                        <div class="flex items-start justify-between gap-6 mb-6">
                            <div class="min-w-0">
                                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Quiz</p>
                                <h2 class="text-2xl md:text-3xl font-black text-math-dark-blue mt-2"><%# Eval("Title") %></h2>
                                <p class="mt-2 text-sm font-semibold text-gray-400"><%# Eval("QuizTitle") %></p>
                            </div>
                            <div class="flex items-center gap-3">
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-math-green/10 border border-math-green/20 text-math-green text-xs font-black uppercase tracking-widest">
                                        <span class="material-symbols-outlined text-sm fill-icon">check_circle</span> Completed
                                    </span>
                                </asp:PlaceHolder>
                                <div class="size-12 rounded-2xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center flex-shrink-0">
                                    <span class="material-symbols-outlined text-math-blue fill-icon">quiz</span>
                                </div>
                            </div>
                        </div>

                        <div class="flex flex-wrap gap-3">
                            <a href='<%# "Quiz.aspx?blockId=" + Eval("BlockID").ToString().Trim() + "&moduleId=" + ModuleId %>'
                               class='<%# Convert.ToBoolean(Eval("IsCompleted"))
                                        ? "inline-flex items-center gap-3 px-6 py-3 rounded-2xl bg-white border-2 border-math-blue text-math-blue font-black text-sm uppercase tracking-widest hover:bg-math-blue/5 transition-colors shadow-sm"
                                        : "inline-flex items-center gap-3 px-6 py-3 rounded-2xl bg-math-blue text-white font-black text-sm uppercase tracking-widest hover:bg-math-dark-blue transition-colors shadow-lg shadow-math-blue/20" %>'>
                                <span class="material-symbols-outlined fill-icon"><%# Convert.ToBoolean(Eval("IsCompleted")) ? "replay" : "play_arrow" %></span>
                                <%# Convert.ToBoolean(Eval("IsCompleted")) ? "Reattempt Quiz" : "Start Quiz" %>
                            </a>

                            <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("QuizAttempted")) %>'>
                                    <asp:Button runat="server" Text="Mark Complete &amp; Continue"
                                        CommandArgument='<%# Eval("BlockID") %>'
                                        OnClick="btnNext_Click" CausesValidation="false" UseSubmitBehavior="false"
                                        CssClass="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-gray-100 text-gray-600
                                                  font-black text-sm uppercase tracking-widest border border-gray-200
                                                  hover:bg-gray-200 transition-all cursor-pointer" />
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("QuizAttempted")) %>'>
                                    <div class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl
                                                bg-gray-100 border border-gray-200 text-gray-400
                                                font-black text-sm uppercase tracking-widest">
                                        <span class="material-symbols-outlined text-base">lock</span>
                                        Attempt the quiz first
                                    </div>
                                </asp:PlaceHolder>
                            </asp:PlaceHolder>

                            <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                                <div class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-math-green/10 border border-math-green/20 text-math-green font-black text-sm uppercase tracking-widest">
                                    <span class="material-symbols-outlined text-base fill-icon">check_circle</span> Completed
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </section>
                </asp:PlaceHolder>

            </ItemTemplate>
        </asp:Repeater>

        <%-- MODULE ASSESSMENT --%>
        <asp:Panel ID="pnlAssessmentSection" runat="server" Visible="false">
            <section class="surface-card p-8">

                <div class="flex items-start justify-between gap-6 mb-6">
                    <div class="min-w-0">
                        <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Module Assessment</p>
                        <h2 class="text-2xl md:text-3xl font-black text-math-dark-blue mt-2">
                            <asp:Literal ID="litAssessmentTitle" runat="server" />
                        </h2>
                        <div class="flex flex-wrap gap-4 mt-3 text-sm font-bold text-gray-500">
                            <span class="flex items-center gap-1.5">
                                <span class="material-symbols-outlined text-base text-math-blue">help</span>
                                <asp:Literal ID="litAssessmentQuestions" runat="server" /> questions
                            </span>
                            <span class="flex items-center gap-1.5">
                                <span class="material-symbols-outlined text-base text-math-blue">grade</span>
                                <asp:Literal ID="litAssessmentMarks" runat="server" /> marks
                            </span>
                            <span class="flex items-center gap-1.5">
                                <span class="material-symbols-outlined text-base text-math-blue">timer</span>
                                <asp:Literal ID="litAssessmentTime" runat="server" />
                            </span>
                        </div>
                    </div>
                    <div class="size-12 rounded-2xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center flex-shrink-0">
                        <span class="material-symbols-outlined text-math-blue fill-icon">assignment</span>
                    </div>
                </div>

                <%-- Hidden values used by SetAssessmentLinks --%>
                <asp:HiddenField ID="hdnAssessmentId"   runat="server" />
                <asp:HiddenField ID="hdnAssessmentTime" runat="server" />

                <%-- Locked: complete all blocks first --%>
                <asp:Panel ID="pnlAssessmentLocked" runat="server" Visible="false">
                    <div class="flex items-center gap-3 p-5 rounded-2xl bg-gray-50 border border-gray-200">
                        <span class="material-symbols-outlined text-gray-400 text-2xl">lock</span>
                        <div>
                            <p class="font-black text-gray-600 text-sm">Assessment Locked</p>
                            <p class="text-xs font-semibold text-gray-400 mt-0.5">Complete all module blocks above to unlock this assessment.</p>
                        </div>
                    </div>
                </asp:Panel>

                <%-- Unlocked --%>
                <asp:Panel ID="pnlAssessmentUnlocked" runat="server" Visible="false">

                    <%-- Not yet attempted --%>
                    <asp:Panel ID="pnlAssessmentNotAttempted" runat="server" Visible="false">
                        <div class="flex flex-wrap gap-3">
                            <asp:HyperLink ID="lnkStartAssessment" runat="server"
                                CssClass="inline-flex items-center gap-3 px-6 py-3 rounded-2xl bg-math-blue text-white
                                          font-black text-sm uppercase tracking-widest shadow-lg shadow-math-blue/20
                                          hover:bg-math-dark-blue transition-all">
                                <span class="material-symbols-outlined fill-icon">play_arrow</span>
                                Start Assessment
                            </asp:HyperLink>
                        </div>
                    </asp:Panel>

                    <%-- Already attempted --%>
                    <asp:Panel ID="pnlAssessmentAttempted" runat="server" Visible="false">
                        <div class="flex items-center gap-3 mb-4 p-4 rounded-2xl bg-math-green/10 border border-math-green/20">
                            <span class="material-symbols-outlined text-math-green fill-icon">check_circle</span>
                            <div>
                                <p class="font-black text-math-dark-blue text-sm">Assessment Completed</p>
                                <p class="text-xs font-semibold text-gray-500 mt-0.5">
                                    Best score: <asp:Literal ID="litAssessmentBestScore" runat="server" />
                                </p>
                            </div>
                        </div>
                        <asp:HyperLink ID="lnkRetryAssessment" runat="server"
                            CssClass="inline-flex items-center gap-3 px-6 py-3 rounded-2xl bg-white border-2 border-math-blue
                                      text-math-blue font-black text-sm uppercase tracking-widest
                                      hover:bg-math-blue/5 transition-colors shadow-sm">
                            <span class="material-symbols-outlined fill-icon">replay</span>
                            Retry Assessment
                        </asp:HyperLink>
                    </asp:Panel>

                </asp:Panel>

            </section>
        </asp:Panel>

        <%-- Module Complete Banner --%>
        <div id="module-complete"></div>
        <asp:Panel ID="pnlModuleComplete" runat="server" Visible="false">
            <section class="surface-card p-10 text-center border-2 border-primary/40 bg-primary/5">
                <div class="mx-auto size-20 rounded-3xl bg-primary flex items-center justify-center mb-6 shadow-lg shadow-primary/20">
                    <span class="material-symbols-outlined text-4xl fill-icon text-math-dark-blue">emoji_events</span>
                </div>
                <h2 class="text-3xl font-black text-math-dark-blue mb-2">Module Complete!</h2>
                <p class="text-gray-500 font-semibold mb-8">You've finished all blocks in this module. Great work!</p>
                <a href="StudentDashboard.aspx"
                   class="inline-flex items-center gap-3 px-8 py-4 rounded-2xl bg-math-blue text-white
                          font-black text-sm uppercase tracking-widest shadow-lg shadow-math-blue/20
                          hover:bg-math-dark-blue transition-all">
                    <span class="material-symbols-outlined fill-icon">home</span>
                    Back to Dashboard
                </a>
            </section>
        </asp:Panel>

    </main>
</div>
</div>
</asp:Content>









