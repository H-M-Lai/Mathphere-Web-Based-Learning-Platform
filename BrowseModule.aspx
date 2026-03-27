<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true" CodeBehind="BrowseModule.aspx.cs" Inherits="Assignment.BrowseModule" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Browse Modules • MathSphere
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .course-filter-btn,
    input[type="submit"].course-filter-btn {
        padding: 0.6rem 1.25rem;
        border-radius: 1rem;
        font-weight: 900;
        font-size: 0.75rem;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        border: 2px solid #dbeafe;
        background: #ffffff;
        color: #1e3a8a;
        cursor: pointer;
        transition: all 0.18s;
        appearance: none;
        -webkit-appearance: none;
    }
    .course-filter-btn:hover,
    input[type="submit"].course-filter-btn:hover {
        background: #eff6ff;
        border-color: #93c5fd;
        color: #1e3a8a;
    }
    .course-filter-btn.active,
    input[type="submit"].course-filter-btn.active {
        background: #1e3a8a !important;
        color: #f9d006 !important;
        border-color: #1e3a8a !important;
        box-shadow: 0 4px 12px rgba(30,58,138,0.18);
    }
    @keyframes cardIn { from { opacity: 0; transform: translateY(20px) scale(.98); } to { opacity: 1; transform: translateY(0) scale(1); } }
    .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
    .browse-busy-grid { opacity: .62; transition: opacity .18s ease; }
    .browse-module-grid { min-height: 200px; }
    .course-filter-btn,
    input[type="submit"].course-filter-btn { transform: translateY(0); }
    .course-filter-btn:hover,
    input[type="submit"].course-filter-btn:hover { transform: translateY(-1px); }
    .course-filter-btn.active,
    input[type="submit"].course-filter-btn.active { transform: translateY(-1px) scale(1.01); }


</style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <%-- GUEST BANNER (server-side visible only for guests) --%>
    <asp:Panel ID="pnlGuestBanner" runat="server" Visible="false"
        CssClass="mb-8 flex flex-col sm:flex-row items-center gap-4 px-6 py-4
                  rounded-2xl bg-primary/10 border-2 border-primary/40">
        <span class="material-symbols-outlined text-primary text-2xl">info</span>
        <div class="flex-1 text-center sm:text-left">
            <p class="font-black text-math-dark-blue text-sm">You are browsing as a Guest</p>
            <p class="text-xs font-semibold text-gray-500 mt-0.5">
                Modules marked <strong>Preview Available</strong> are open now.
                Register free to unlock everything and track your progress.
            </p>
        </div>
        <a href="Register.aspx"
           class="shrink-0 px-5 py-2 bg-math-blue text-white font-black text-xs uppercase
                  tracking-widest rounded-xl hover:bg-math-dark-blue transition-all shadow-md">
            Register Free
        </a>
    </asp:Panel>

    <div class="page-enter mb-12 space-y-8">
        <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
            <div class="relative space-y-3 max-w-3xl mx-auto text-center">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">menu_book</span>
                    Learning library
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">
                    Explore <span class="text-math-blue">Modules</span>
                </h2>
                <p class="max-w-2xl mx-auto text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Browse your learning library, jump back into active topics, and find the next lesson to continue your progress.
                </p>
            </div>
        </section>

        <asp:UpdatePanel ID="upBrowseModules" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
        <div class="space-y-8">
        <div class="surface-card p-6 space-y-5">

    <div class="flex flex-col gap-4">
        <div class="relative flex-1 w-full group">
            <span class="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-gray-400 text-2xl
                         transition-colors duration-200 group-focus-within:text-math-blue">search</span>

            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="w-full min-h-[60px] pl-16 pr-14 py-4 bg-white/70 border border-gray-200 rounded-3xl
                          font-semibold text-math-dark-blue placeholder:text-gray-400
                          shadow-sm transition-all duration-200 ease-out
                          focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10 focus:bg-white"
                placeholder="Search modules..." data-search-mode="local" oninput="browseLiveFilter()" onkeydown="if(event.key==='Enter'){event.preventDefault();browseLiveFilter();}" />

            <button type="button"
                onclick="const t=document.getElementById('<%= txtSearch.ClientID %>');t.value='';browseLiveFilter();"
                class="absolute right-4 top-1/2 -translate-y-1/2 size-9 rounded-full bg-gray-100 hover:bg-gray-200
                       text-gray-500 hover:text-math-dark-blue flex items-center justify-center transition-all">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
        </div>
    </div>

    <%-- Course filter buttons --%>
    <asp:Panel ID="pnlCourseFilters" runat="server"
        CssClass="flex flex-wrap justify-center lg:justify-start gap-3">

        <asp:Button ID="btnAllTopics" runat="server" Text="All Topics"
            OnClick="btnCourse_Click" CommandArgument=""
            OnClientClick="return browseApplyFilterState(this, '');"
            CssClass="course-filter-btn" />

        <asp:Repeater ID="rptCourseFilters" runat="server"
            OnItemCommand="rptCourseFilters_ItemCommand"
            OnItemDataBound="rptCourseFilters_ItemDataBound">
            <ItemTemplate>
                <asp:Button ID="btnCourseFilter" runat="server"
                    Text='<%# Eval("CourseName") %>'
                    CommandName="FilterByCourse"
                    CommandArgument='<%# Eval("CourseID") %>'
                    CssClass="course-filter-btn" />
            </ItemTemplate>
        </asp:Repeater>

    </asp:Panel>
</div>

<%-- MODULE CARDS GRID --%>
    <div id="browseModuleGrid" class="browse-module-grid grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">

        <asp:Literal ID="litDbError" runat="server" Visible="false"></asp:Literal>

        <asp:Repeater ID="rptModules" runat="server" OnItemCommand="rptModules_ItemCommand">
            <ItemTemplate>

                <div class="module-card module-slide-in surface-card p-6 group relative" data-search='<%# ((Eval("ModuleTitle") ?? "") + " " + (Eval("CourseName") ?? "") + " " + (Eval("PreviewText") ?? "")).ToString().ToLowerInvariant() %>'>

                    <%-- Thumbnail --%>
                    <div class="relative w-full h-44 mb-4 rounded-3xl flex items-center justify-center overflow-hidden bg-gray-50">
                        <div class="w-16 h-16 bg-math-blue rounded-2xl flex items-center justify-center text-white
                                    shadow-lg shadow-math-blue/30 group-hover:scale-110 transition-transform">
                            <span class="material-symbols-outlined text-4xl"><%# Eval("Icon") %></span>
                        </div>

                        <%-- Lock badge — guest + non-previewable only --%>
                        <asp:Panel runat="server"
                            Visible='<%# IsGuest && !(bool)Eval("IsPreviewable") %>'>
                            <div class="absolute top-3 right-3 flex items-center gap-1 px-3 py-1
                                        rounded-full bg-math-dark-blue/90 text-white
                                        text-[10px] font-black uppercase tracking-widest shadow">
                                <span class="material-symbols-outlined text-sm leading-none">lock</span>
                                Members only
                            </div>
                        </asp:Panel>
                    </div>

                    <%-- Meta --%>
                    <div class="flex-1">
                        <div class="flex items-center gap-2 mb-3">
                            <span class="badge-pill bg-math-blue/10 text-math-blue border border-math-blue/10">
                                <%# Eval("CourseName") %>
                            </span>
                            <span class="text-gray-400 font-bold text-[10px] uppercase tracking-widest">
                                <%# Eval("PreviewText") %>
                            </span>
                        </div>

                        <h3 class="text-2xl font-black mb-4 leading-tight group-hover:text-math-blue transition-colors">
                            <%# Eval("ModuleTitle") %>
                        </h3>

                        <%-- Progress bar — logged-in only --%>
                        <asp:Panel runat="server" Visible='<%# !IsGuest %>'>
                            <div class="mb-6 space-y-2">
                                <div class="flex justify-between text-sm font-bold">
                                    <span>Progress</span>
                                    <span class="text-math-blue"><%# Eval("Progress") %>%</span>
                                </div>
                                <div class="h-3 bg-gray-100 rounded-full border border-gray-200 overflow-hidden">
                                    <div class="h-full bg-math-blue rounded-full"
                                         style="width:<%# Eval("Progress") %>%"></div>
                                </div>
                            </div>
                        </asp:Panel>
                    </div>

                    <%-- CTA — logged-in: server Button; guest: plain HTML button (no postback) --%>

                    <%-- Logged-in button --%>
                    <asp:Panel runat="server" Visible='<%# !IsGuest %>'>
                        <asp:Button ID="btnStartMission" runat="server"
                            Text="START MISSION"
                            CommandName="StartMission"
                            CommandArgument='<%# Eval("ModuleID") %>'
                            CssClass="w-full bg-math-blue text-white font-black py-4 rounded-2xl
                                      hover:bg-math-dark-blue transition-colors shadow-lg
                                      active:translate-y-1 uppercase tracking-widest text-sm cursor-pointer" />
                    </asp:Panel>

                    <%-- Guest: previewable ? go to content; locked ? open modal --%>
                    <asp:Panel runat="server" Visible='<%# IsGuest %>'>
                        <button type="button"
                            data-moduleid='<%# Eval("ModuleID") %>'
                            data-previewable='<%# (bool)Eval("IsPreviewable") ? "1" : "0" %>'
                            onclick="guestModuleClick(this)"
                            class='<%# (bool)Eval("IsPreviewable")
                                ? "w-full bg-math-blue text-white font-black py-4 rounded-2xl hover:bg-math-dark-blue transition-colors shadow-lg uppercase tracking-widest text-sm cursor-pointer"
                                : "w-full bg-gray-100 text-gray-400 font-black py-4 rounded-2xl uppercase tracking-widest text-sm cursor-pointer flex items-center justify-center gap-2 border-2 border-dashed border-gray-200" %>'>
                            <%# (bool)Eval("IsPreviewable") ? "PREVIEW MODULE" : "REGISTER TO UNLOCK" %>
                        </button>
                    </asp:Panel>

                </div>

            </ItemTemplate>
        </asp:Repeater>
    </div>

    <asp:Panel ID="pnlEmptyState" runat="server" Visible="false"
        CssClass="flex flex-col items-center py-20 text-center">
        <span class="material-symbols-outlined text-8xl text-gray-200 mb-4">search_off</span>
        <h3 class="text-2xl font-black text-gray-400">No Modules Found</h3>
        <p class="text-gray-400 font-bold">Try a different search or filter!</p>
    </asp:Panel>

    <asp:HiddenField ID="hfSelectedCourse" runat="server" Value="" />
        </div>
            </ContentTemplate>
        </asp:UpdatePanel>
        <script>
        function browseLiveFilter() {
            var input = document.getElementById('<%= txtSearch.ClientID %>');
            var query = input ? (input.value || '').toLowerCase().trim() : '';
            var cards = document.querySelectorAll('#browseModuleGrid .module-card');
            var visible = 0;

            cards.forEach(function (card) {
                var hay = (card.getAttribute('data-search') || '').toLowerCase();
                var show = !query || hay.indexOf(query) >= 0;
                card.style.display = show ? '' : 'none';
                if (show) visible++;
            });

            var empty = document.getElementById('<%= pnlEmptyState.ClientID %>');
            var grid = document.getElementById('browseModuleGrid');
            if (empty && grid) {
                empty.style.display = (cards.length > 0 && visible === 0) ? '' : 'none';
                grid.style.display = (cards.length > 0 && visible === 0) ? 'none' : '';
            }
        }

        function browseApplyFilterState(button, courseId) {
            var hidden = document.getElementById('<%= hfSelectedCourse.ClientID %>');
            if (hidden) hidden.value = courseId || '';
            browseSyncFilterClasses(courseId || '');
            return true;
        }

        function browseSyncFilterClasses(selectedCourseId) {
            var allBtn = document.getElementById('<%= btnAllTopics.ClientID %>');
            if (allBtn) {
                allBtn.className = (!selectedCourseId ? 'course-filter-btn active' : 'course-filter-btn');
            }

            var buttons = document.querySelectorAll('#<%= pnlCourseFilters.ClientID %> [data-course-id]');
            buttons.forEach(function (btn) {
                var courseId = btn.getAttribute('data-course-id') || '';
                btn.className = (courseId === selectedCourseId)
                    ? 'course-filter-btn active'
                    : 'course-filter-btn';
            });
        }

        function browseWireAsyncBusyState() {
            var panel = document.getElementById('<%= upBrowseModules.ClientID %>');
            var grid = document.getElementById('browseModuleGrid');
            if (!panel || !window.Sys || !Sys.WebForms || !Sys.WebForms.PageRequestManager) return;
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            if (!prm || panel.getAttribute('data-browse-busy-wired') === '1') return;
            panel.setAttribute('data-browse-busy-wired', '1');
            prm.add_beginRequest(function () { if (grid) grid.classList.add('browse-busy-grid'); });
            prm.add_endRequest(function () {
                grid = document.getElementById('browseModuleGrid');
                if (grid) grid.classList.remove('browse-busy-grid');
                var hidden = document.getElementById('<%= hfSelectedCourse.ClientID %>');
                browseSyncFilterClasses(hidden ? (hidden.value || '') : '');
                browseLiveFilter();
            });
        }

        document.addEventListener('DOMContentLoaded', function () {
            var hidden = document.getElementById('<%= hfSelectedCourse.ClientID %>');
            browseSyncFilterClasses(hidden ? (hidden.value || '') : '');
            browseWireAsyncBusyState();
            browseLiveFilter();
        });
    </script>

    <%-- GUEST REGISTER MODAL --%>
    <div id="guestRegisterModal"
         class="hidden fixed inset-0 z-[300] flex items-center justify-center p-4
                bg-black/60 backdrop-blur-sm">

        <div class="relative bg-white rounded-[2.5rem] shadow-2xl p-10 max-w-md w-full text-center
                    animate-[fadeInUp_0.25s_ease]">

            <%-- Close button --%>
            <button type="button" onclick="closeGuestModal()"
                class="absolute top-5 right-5 size-9 rounded-full bg-gray-100 hover:bg-gray-200
                       flex items-center justify-center text-gray-500 transition-all">
                <span class="material-symbols-outlined text-lg">close</span>
            </button>

            <%-- Icon --%>
            <div class="size-20 rounded-3xl bg-math-blue/10 border border-math-blue/20
                        flex items-center justify-center mx-auto mb-5">
                <span class="material-symbols-outlined text-math-blue text-4xl">lock_open</span>
            </div>

            <h2 class="text-2xl font-black text-math-dark-blue mb-2">Unlock This Module</h2>
            <p class="text-gray-500 font-semibold mb-1">
                This module is available to registered students only.
            </p>
            <p class="text-sm text-gray-400 font-semibold mb-8">
                Create a free account to access all modules, track your progress, and earn XP!
            </p>

            <div class="flex flex-col gap-3">
                <a href="Register.aspx"
                   class="w-full inline-flex items-center justify-center gap-2 px-6 py-4
                          rounded-2xl bg-math-blue text-white font-black text-sm uppercase
                          tracking-widest hover:bg-math-dark-blue transition-all shadow-lg shadow-math-blue/20">
                    <span class="material-symbols-outlined text-base">person_add</span>
                    Create Free Account
                </a>
                <a href="Login.aspx"
                   class="w-full inline-flex items-center justify-center gap-2 px-6 py-3
                          rounded-2xl bg-gray-100 text-math-dark-blue font-black text-sm uppercase
                          tracking-widest hover:bg-gray-200 transition-all">
                    Already have an account? Log in
                </a>
            </div>

            <%-- Perks strip --%>
            <div class="mt-6 pt-6 border-t border-gray-100 grid grid-cols-3 gap-3">
                <div class="flex flex-col items-center gap-1">
                    <div class="size-10 rounded-2xl bg-green-50 flex items-center justify-center">
                        <span class="material-symbols-outlined text-green-500 text-lg">trending_up</span>
                    </div>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-wide">Track Progress</p>
                </div>
                <div class="flex flex-col items-center gap-1">
                    <div class="size-10 rounded-2xl bg-primary/10 flex items-center justify-center">
                        <span class="material-symbols-outlined text-primary text-lg">stars</span>
                    </div>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-wide">Earn XP</p>
                </div>
                <div class="flex flex-col items-center gap-1">
                    <div class="size-10 rounded-2xl bg-math-blue/10 flex items-center justify-center">
                        <span class="material-symbols-outlined text-math-blue text-lg">emoji_events</span>
                    </div>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-wide">Win Badges</p>
                </div>
            </div>
        </div>
    </div>

    <script>

        // Guest click handler
        function guestModuleClick(btn) {
            if (btn.getAttribute('data-previewable') === '1') {
                window.location.href =
                    'moduleOverview.aspx?moduleId=' +
                    encodeURIComponent(btn.getAttribute('data-moduleid')) +
                    '&guest=1';
            } else {
                openGuestModal();
            }
        }

        function openGuestModal() { document.getElementById('guestRegisterModal').classList.remove('hidden'); }
        function closeGuestModal() { document.getElementById('guestRegisterModal').classList.add('hidden'); }

        // Close on backdrop click
        document.getElementById('guestRegisterModal').addEventListener('click', function (e) {
            if (e.target === this) closeGuestModal();
        });
        // Close on Escape
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeGuestModal();
        });
    </script>

</asp:Content>






























