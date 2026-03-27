<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="ModuleOverview.aspx.cs" Inherits="Assignment.ModuleOverview" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Module Overview • MathSphere
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

    <div class="page-enter mb-10">
        <div class="text-center max-w-2xl mx-auto mb-10">
            <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 mb-3">Guided Mission Map</p>
            <h2 class="text-5xl font-black mb-4 tracking-tight text-math-dark-blue"><asp:Literal ID="litHeroTitle" runat="server" /></h2>
            <p class="text-lg font-bold text-gray-500">See the full block roadmap, your current progress, and what unlocks next.</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-[320px_1fr] gap-10">

        <!-- SIDEBAR -->
        <aside class="space-y-6">

            <!-- Back + Mission card -->
            <div class="bg-white/70 backdrop-blur-md rounded-[2.25rem] p-6 border border-gray-100
                        shadow-[0_12px_30px_rgba(0,0,0,0.06)]">

                <asp:HyperLink runat="server" NavigateUrl="~/BrowseModule.aspx"
                    CssClass="inline-flex items-center gap-2 text-math-blue font-black text-xs uppercase tracking-widest no-underline hover:no-underline hover:translate-x-[-4px] transition-transform">
                    <span class="material-symbols-outlined text-lg leading-none">arrow_back</span>
                    Back to Modules
                </asp:HyperLink>

                <div class="mt-6">
                    <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Current Mission</div>
                    <h2 class="text-2xl font-black tracking-tight text-math-dark-blue mt-2">
                        <asp:Literal ID="litCurrentMission" runat="server" />
                    </h2>
                </div>
            </div>

            <!-- Block checklist / roadmap -->
            <div class="bg-white/70 backdrop-blur-md rounded-[2.25rem] p-6 border border-gray-100
                        shadow-[0_12px_30px_rgba(0,0,0,0.06)]">
                <div class="flex items-center justify-between mb-5">
                    <div>
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Blocks</div>
                        <h3 class="text-lg font-black tracking-tight text-math-dark-blue mt-1">Roadmap</h3>
                    </div>
                    <div class="size-10 rounded-2xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center">
                        <span class="material-symbols-outlined text-math-blue fill-icon">map</span>
                    </div>
                </div>

                <div class="space-y-2">
                    <asp:Repeater ID="rptSidebarModules" runat="server">
                        <ItemTemplate>
                            <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("IsLocked") %>'>
                                <a href='<%# string.IsNullOrEmpty((Eval("BlockId") ?? "").ToString())
                                        ? ("ModuleOverview.aspx?moduleId=" + Server.UrlEncode(ModuleId) + (IsGuest ? "&guest=1" : ""))
                                        : ("moduleContent.aspx?moduleId=" + Server.UrlEncode(ModuleId) + "&blockId=" + Server.UrlEncode((Eval("BlockId") ?? "").ToString()) + (IsGuest ? "&guest=1" : "") + "#block-" + Server.UrlEncode((Eval("BlockId") ?? "").ToString())) %>'
                                   class='<%# Eval("CssClass") %>'>
                                    <span class="material-symbols-outlined <%# Eval("IconFill") %>"><%# Eval("Icon") %></span>
                                    <span class="font-black text-sm truncate flex-1"><%# Eval("Title") %></span>
                                    <span class='text-[10px] font-black uppercase tracking-widest <%# (bool)Eval("IsCompleted") ? "text-math-green" : "text-gray-300" %>'>
                                        <%# (bool)Eval("IsCompleted") ? "Done" : "" %>
                                    </span>
                                </a>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("IsLocked") %>'>
                                <div class='<%# Eval("CssClass") %>'>
                                    <span class="material-symbols-outlined <%# Eval("IconFill") %>"><%# Eval("Icon") %></span>
                                    <span class="font-black text-sm truncate flex-1"><%# Eval("Title") %></span>
                                </div>
                            </asp:PlaceHolder>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

        </aside>

        <!-- MAIN CONTENT -->
        <main class="space-y-8">

            <!-- Page header + progress ring -->
            <section class="bg-white/70 backdrop-blur-md rounded-[2.75rem] p-8 border border-gray-100
                            shadow-[0_18px_60px_rgba(0,0,0,0.08)]">
                <div class="flex flex-col lg:flex-row lg:items-start justify-between gap-8">

                    <div class="min-w-0">
                        <div class="flex flex-wrap items-center gap-2 mb-5">
                            <span class="inline-flex items-center px-3 py-1.5 rounded-full bg-primary/25
                                         text-math-dark-blue text-[11px] font-black uppercase tracking-widest border border-primary/30">
                                MODULE <asp:Literal ID="litModuleNumber" runat="server" />
                            </span>
                            <span class="inline-flex items-center px-3 py-1.5 rounded-full bg-math-blue/10
                                         text-math-blue text-[11px] font-black uppercase tracking-widest border border-math-blue/10">
                                <asp:Literal ID="litCategory" runat="server" />
                            </span>
                        </div>

                        <h1 class="text-4xl md:text-5xl font-black tracking-tight text-math-dark-blue">
                            Module <span class="text-math-blue">Overview</span>
                        </h1>

                        <p class="mt-4 text-lg font-semibold text-gray-500 max-w-2xl">
                            <asp:Literal ID="litOverviewDesc" runat="server"
                                Text="Complete all topics to master the basics and unlock the final assessment." />
                        </p>
                    </div>

                    <!-- Circular progress ring -->
                    <div class="shrink-0">
                        <div class="bg-white/60 border border-gray-100 rounded-[2.25rem] p-6
                                    shadow-[0_12px_30px_rgba(0,0,0,0.06)]">
                            <div class="flex items-center gap-5">
                                <div class="relative size-24">
                                    <svg class="w-full h-full" viewBox="0 0 100 100">
                                        <circle cx="50" cy="50" r="34" fill="transparent"
                                                stroke="currentColor" stroke-width="10"
                                                class="text-gray-200"></circle>
                                        <circle id="circleProgress" runat="server"
                                                cx="50" cy="50" r="34" fill="transparent"
                                                stroke="currentColor" stroke-width="10"
                                                stroke-linecap="round"
                                                stroke-dasharray="213.63"
                                                class="text-math-green"
                                                style="transform: rotate(-90deg); transform-origin: 50% 50%;"></circle>
                                    </svg>
                                    <div class="absolute inset-0 flex items-center justify-center">
                                        <span class="text-xl font-black text-math-dark-blue">
                                            <asp:Literal ID="litModuleProgress" runat="server" />%
                                        </span>
                                    </div>
                                </div>
                                <div>
                                    <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Progress</div>
                                    <div class="text-lg font-black text-math-dark-blue mt-1">Module Completion</div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </section>

            <!-- Block cards grid -->
            <section>
                <div class="flex items-center justify-between mb-6">
                    <h2 class="text-xl font-black uppercase tracking-tight text-math-dark-blue/60">
                        All Blocks
                    </h2>
                    <span class="hidden sm:inline-flex items-center gap-2 px-4 py-2 rounded-full
                                 bg-white/60 border border-gray-100
                                 text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">
                        <span class="material-symbols-outlined text-base text-math-blue fill-icon">tips_and_updates</span>
                        Complete to unlock
                    </span>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                    <asp:Repeater ID="rptMainTopics" runat="server" OnItemCommand="rptMainTopics_ItemCommand">
                        <ItemTemplate>

                            <div class='bg-white/70 backdrop-blur-md rounded-[2.25rem] p-7 border border-gray-100
                                        shadow-[0_12px_30px_rgba(0,0,0,0.06)]
                                        hover:shadow-[0_18px_45px_rgba(0,0,0,0.08)] hover:-translate-y-[1px]
                                        transition-all group flex flex-col h-full <%# Eval("Opacity") %>
                                        <%# (bool)Eval("IsCompleted") ? "border-l-4 border-l-math-green" : "" %>'>

                                <!-- Icon + type badge + done badge -->
                                <div class="flex items-start justify-between mb-6">
                                    <div class='size-14 rounded-2xl flex items-center justify-center shadow-sm border
                                                <%# Eval("HoverScale") %>
                                                <%# Eval("IconBg") %>'>
                                        <span class='material-symbols-outlined text-3xl fill-icon <%# Eval("IconColor") %>'>
                                            <%# Eval("Icon") %>
                                        </span>
                                    </div>

                                    <div class="flex flex-col items-end gap-2">
                                        <span class="inline-flex items-center px-3 py-1.5 rounded-full
                                                     bg-gray-50 border border-gray-100
                                                     text-[10px] font-black uppercase tracking-widest text-gray-400">
                                            <%# Eval("BlockType") %>
                                        </span>
                                        <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("IsCompleted") %>'>
                                            <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full
                                                         bg-math-green/10 border border-math-green/20 text-math-green
                                                         text-[10px] font-black uppercase tracking-widest">
                                                <span class="material-symbols-outlined text-sm fill-icon">check_circle</span>
                                                Done
                                            </span>
                                        </asp:PlaceHolder>
                                    </div>
                                </div>

                                <!-- Block number + title -->
                                <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 mb-1">
                                    Block <%# Eval("OrderIndex") %>
                                </div>
                                <h3 class="text-2xl font-black text-math-dark-blue mb-3 flex-1
                                           group-hover:text-math-blue transition-colors">
                                    <%# Eval("Title") %>
                                </h3>

                                <p class="text-gray-500 font-semibold leading-relaxed mb-8">
                                    <%# Eval("Description") %>
                                </p>

                                <!-- ACTION BUTTON -->
                                <div>
                                    <%-- GUEST + unlocked ? plain <a> link to moduleContent --%>
                                    <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("IsGuestNav") %>'>
                                        <a href='<%# Eval("GuestHref") %>'
                                           class='<%# Eval("ButtonClass") %>'>
                                            <span class="leading-none"><%# Eval("ButtonText") %></span>
                                            <span class="material-symbols-outlined text-base leading-none"><%# Eval("ButtonIcon") %></span>
                                        </a>
                                    </asp:PlaceHolder>

                                    <%-- AUTHENTICATED: unlocked / completed --%>
                                    <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("IsGuestNav") && !(bool)Eval("IsLocked") %>'>
                                        <asp:LinkButton runat="server"
                                            CommandName="OpenTopic"
                                            CommandArgument='<%# Eval("BlockId") %>'
                                            CssClass='<%# Eval("ButtonClass") %>'>
                                            <span class="leading-none"><%# Eval("ButtonText") %></span>
                                            <span class="material-symbols-outlined text-base leading-none"><%# Eval("ButtonIcon") %></span>
                                        </asp:LinkButton>
                                    </asp:PlaceHolder>

                                    <%-- LOCKED (guests and students) --%>
                                    <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("IsLocked") %>'>
                                        <span class='<%# Eval("ButtonClass") %> pointer-events-none select-none'>
                                            <span class="leading-none"><%# Eval("ButtonText") %></span>
                                            <span class="material-symbols-outlined text-base leading-none"><%# Eval("ButtonIcon") %></span>
                                        </span>
                                    </asp:PlaceHolder>
                                </div>

                            </div>

                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </section>

            <%-- -- ASSESSMENT SECTION (shown after all blocks done) -- --%>
            <asp:Panel ID="pnlAssessment" runat="server" Visible="false">
                <section class="bg-white/70 backdrop-blur-md rounded-[2.75rem] p-8 border-2 border-primary/30
                                bg-primary/5 shadow-[0_18px_60px_rgba(0,0,0,0.08)]">

                    <div class="flex items-start justify-between gap-6 mb-6">
                        <div>
                            <p class="text-[11px] font-black uppercase tracking-[0.25em] text-primary mb-1">
                                Module Assessment
                            </p>
                            <h2 class="text-2xl font-black text-math-dark-blue">
                                <asp:Literal ID="litAssessmentTitle" runat="server" />
                            </h2>
                        </div>
                        <div class="size-12 rounded-2xl bg-primary/20 border border-primary/30
                                    flex items-center justify-center flex-shrink-0">
                            <span class="material-symbols-outlined text-math-dark-blue fill-icon">assignment</span>
                        </div>
                    </div>

                    <%-- Stats --%>
                    <div class="flex flex-wrap gap-3 mb-6">
                        <div class="flex items-center gap-2 px-4 py-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
                            <span class="material-symbols-outlined text-math-blue text-base fill-icon">help</span>
                            <span class="text-sm font-black text-math-dark-blue">
                                <asp:Literal ID="litAssessmentQuestions" runat="server" /> Questions
                            </span>
                        </div>
                        <div class="flex items-center gap-2 px-4 py-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
                            <span class="material-symbols-outlined text-math-green text-base fill-icon">stars</span>
                            <span class="text-sm font-black text-math-dark-blue">
                                <asp:Literal ID="litAssessmentMarks" runat="server" /> Marks
                            </span>
                        </div>
                        <div class="flex items-center gap-2 px-4 py-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
                            <span class="material-symbols-outlined text-primary text-base fill-icon">schedule</span>
                            <span class="text-sm font-black text-math-dark-blue">
                                <asp:Literal ID="litAssessmentTime" runat="server" />
                            </span>
                        </div>
                    </div>

                    <%-- LOCKED — not all blocks done --%>
                    <asp:Panel ID="pnlAssessmentLocked" runat="server" Visible="false">
                        <div class="flex items-center gap-3 p-4 rounded-2xl bg-gray-100 border border-gray-200">
                            <span class="material-symbols-outlined text-gray-400 text-2xl">lock</span>
                            <div>
                                <p class="font-black text-gray-500 text-sm">Assessment Locked</p>
                                <p class="text-xs font-semibold text-gray-400 mt-0.5">
                                    Complete all module blocks above to unlock this assessment.
                                </p>
                            </div>
                        </div>
                    </asp:Panel>

                    <%-- UNLOCKED — all blocks done --%>
                    <asp:Panel ID="pnlAssessmentUnlocked" runat="server" Visible="false">

                        <%-- Already attempted --%>
                        <asp:Panel ID="pnlAlreadyAttempted" runat="server" Visible="false">
                            <div class="flex items-center gap-4 flex-wrap mb-3">
                                <div class="flex items-center gap-2 px-4 py-2 bg-math-green/10
                                            border border-math-green/20 rounded-2xl">
                                    <span class="material-symbols-outlined text-math-green text-base fill-icon">check_circle</span>
                                    <span class="text-sm font-black text-math-green">Attempted</span>
                                    <span class="text-xs font-bold text-gray-500 ml-1">
                                        Best: <asp:Literal ID="litBestScore" runat="server" />
                                    </span>
                                </div>
                                <%-- Pass/fail badge --%>
                                <asp:Panel ID="pnlPassBadge" runat="server" Visible="false">
                                    <span class="flex items-center gap-1 px-3 py-2 bg-math-green/10 border 
                                                 border-math-green/20 rounded-2xl text-xs font-black text-math-green">
                                        <span class="material-symbols-outlined text-sm fill-icon">verified</span>
                                        Passed
                                    </span>
                                </asp:Panel>
                                <asp:Panel ID="pnlFailBadge" runat="server" Visible="false">
                                    <span class="flex items-center gap-1 px-3 py-2 bg-red-50 border 
                                                 border-red-200 rounded-2xl text-xs font-black text-red-400">
                                        <span class="material-symbols-outlined text-sm fill-icon">cancel</span>
                                        Not Passed — Try Again
                                    </span>
                                </asp:Panel>
                            </div>
                            <asp:HyperLink ID="lnkRetryAssessment" runat="server"
                                CssClass="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-white
                                          border-2 border-primary text-math-dark-blue font-black text-sm
                                          uppercase tracking-widest hover:bg-primary/10 transition-all shadow-sm">
                                <span class="material-symbols-outlined fill-icon">replay</span>
                                Reattempt Assessment
                            </asp:HyperLink>
                        </asp:Panel>

                        <%-- Not yet attempted --%>
                        <asp:Panel ID="pnlNotAttempted" runat="server" Visible="false">
                            <div class="flex items-center gap-3 p-4 rounded-2xl bg-white border border-primary/20 mb-4">
                                <span class="material-symbols-outlined text-primary fill-icon">info</span>
                                <p class="text-sm font-semibold text-gray-600">
                                    All blocks completed! Select your answers for each question directly
                                    in the system. A timer will count down — click
                                    <strong>Finish Attempt</strong> when done.
                                </p>
                            </div>
                            <asp:HyperLink ID="lnkStartAssessment" runat="server"
                                CssClass="inline-flex items-center gap-2 px-8 py-4 rounded-2xl bg-primary
                                          text-math-dark-blue font-black text-sm uppercase tracking-widest
                                          shadow-lg shadow-primary/20 hover:bg-yellow-400 transition-all">
                                <span class="material-symbols-outlined fill-icon">play_arrow</span>
                                Start Assessment
                            </asp:HyperLink>
                        </asp:Panel>

                    </asp:Panel>
                </section>
            </asp:Panel>

            <%-- Start Module CTA — hide if student already started --%>
                <asp:Panel ID="pnlStartModule" runat="server" Visible="false">
                    <section class="bg-white/70 backdrop-blur-md rounded-[2.75rem] p-8 border border-gray-100
                                    shadow-[0_18px_60px_rgba(0,0,0,0.08)] text-center">
                        <p class="text-gray-500 font-semibold mb-5">
                            Ready to start? Jump straight into the first block.
                        </p>
                        <asp:HyperLink runat="server" ID="lnkStartModule"
                            CssClass="inline-flex items-center gap-3 px-8 py-4 rounded-full
                                      bg-math-blue text-white font-black uppercase tracking-widest text-[13px]
                                      shadow-lg shadow-math-blue/20 hover:bg-math-dark-blue transition-all">
                            <span class="material-symbols-outlined fill-icon">rocket_launch</span>
                            Start This Module
                        </asp:HyperLink>
                    </section>
                </asp:Panel>
            </main>
        </div>

    <%-- Register modal is kept for any future use but no longer triggered by block buttons --%>
    <div id="guestRegisterModal"
         class="hidden fixed inset-0 z-[300] flex items-center justify-center p-4
                bg-black/60 backdrop-blur-sm">

        <div class="relative bg-white rounded-[2.5rem] shadow-2xl p-10 max-w-md w-full text-center">

            <button type="button" onclick="closeRegisterModal()"
                class="absolute top-5 right-5 size-9 rounded-full bg-gray-100 hover:bg-gray-200
                       flex items-center justify-center text-gray-500 transition-all">
                <span class="material-symbols-outlined text-lg">close</span>
            </button>

            <div class="size-20 rounded-3xl bg-math-blue/10 border border-math-blue/20
                        flex items-center justify-center mx-auto mb-5">
                <span class="material-symbols-outlined text-math-blue text-4xl">how_to_reg</span>
            </div>

            <h2 class="text-2xl font-black text-math-dark-blue mb-2">Create Your Account</h2>
            <p class="text-gray-500 font-semibold mb-1">Register to start learning and track your progress.</p>
            <p class="text-sm text-gray-400 font-semibold mb-8">Are you a student or a teacher?</p>

            <div class="flex flex-col gap-3">
                <a href="Register.aspx"
                   class="w-full inline-flex items-center justify-center gap-3 px-6 py-4
                          rounded-2xl bg-math-blue text-white font-black text-sm uppercase
                          tracking-widest hover:bg-math-dark-blue transition-all shadow-lg shadow-math-blue/20">
                    <span class="material-symbols-outlined text-base">school</span>
                    I'm a Student
                </a>
                <a href="teacherRegistration.aspx"
                   class="w-full inline-flex items-center justify-center gap-3 px-6 py-4
                          rounded-2xl bg-math-dark-blue text-white font-black text-sm uppercase
                          tracking-widest hover:bg-math-blue transition-all shadow-lg">
                    <span class="material-symbols-outlined text-base">cast_for_education</span>
                    I'm a Teacher
                </a>
                <a href="Login.aspx"
                   class="w-full inline-flex items-center justify-center gap-2 px-6 py-3
                          rounded-2xl bg-gray-100 text-math-dark-blue font-black text-sm uppercase
                          tracking-widest hover:bg-gray-200 transition-all">
                    Already have an account? Log in
                </a>
            </div>
        </div>
    </div>

    <script>
        function openRegisterModal() { document.getElementById('guestRegisterModal').classList.remove('hidden'); }
        function closeRegisterModal() { document.getElementById('guestRegisterModal').classList.add('hidden'); }
        document.getElementById('guestRegisterModal').addEventListener('click', function (e) {
            if (e.target === this) closeRegisterModal();
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeRegisterModal();
        });
    </script>

    </div>
</asp:Content>



