<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="Forum.aspx.cs" Inherits="Assignment.Forum" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Forum • MathSphere
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .collapsible { overflow: hidden; transition: max-height 0.35s ease; max-height: 0; }
    .collapsible.open { max-height: 2000px; }
    .ts-item {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 10px 12px; border-radius: 16px;
        background: #fefce8; border: 1.5px solid #fde68a;
        cursor: pointer; transition: all 0.2s;
    }
    .ts-item:hover { background: #fef9c3; }
    .cat-btn.active-cat {
        background: #eff6ff !important;
        color: #1e3a8a !important;
        border-color: #bfdbfe !important;
    }
    @keyframes cardIn { from { opacity: 0; transform: translateY(20px) scale(.98); } to { opacity: 1; transform: translateY(0) scale(1); } }
    .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
    .filter-chip.active {
        background: #1e3a8a !important;
        color: #f9d006 !important;
        border-color: #1e3a8a !important;
    }
</style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-enter">
    <!-- Page Header -->
    <div class="mb-10 text-center">
        <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 mb-3">Community Space</p>
        <h2 class="text-5xl font-black tracking-tight text-math-dark-blue mb-4">
            Student <span class="text-math-blue">Forum</span>
        </h2>
        <p class="text-lg font-semibold text-gray-500">
            Ask questions, share ideas, and learn together.
        </p>
    </div>

    <!-- SEARCH + FILTER BAR -->
    <div class="bg-white/80 backdrop-blur-md rounded-[2rem] p-5 border border-gray-100
                shadow-[0_8px_24px_rgba(0,0,0,0.06)] mb-8">
        <div class="flex flex-col md:flex-row gap-4 items-center">

            <div class="relative flex-1 w-full">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 text-xl">search</span>
                <input type="text" id="forumSearch"
                       placeholder="Search by title or content..."
                       oninput="applyForumFilters()"
                       class="w-full pl-12 pr-4 py-3.5 bg-gray-50 border-2 border-gray-100 rounded-2xl
                              font-bold text-sm text-math-dark-blue placeholder-gray-400
                              focus:border-math-blue focus:outline-none transition-all" />
            </div>

            <div class="relative flex-shrink-0">
                <select id="forumCategory" onchange="applyForumFilters()"
                        class="bg-gray-50 border-2 border-gray-100 rounded-2xl pl-5 pr-10 py-3.5
                               font-black text-xs uppercase tracking-widest text-math-dark-blue
                               focus:border-math-blue focus:outline-none cursor-pointer appearance-none">
                    <option value="">All Categories</option>
                    <asp:Literal ID="litCategoryOptions" runat="server" />
                </select>
            </div>

            <div class="flex gap-2 flex-shrink-0">
                <button type="button" data-status="" onclick="setForumStatus(this)"
                        class="filter-chip active px-4 py-2 border-2 border-gray-200 rounded-full
                               text-[10px] font-black uppercase tracking-widest text-gray-500 transition-all">
                    All
                </button>
                <button type="button" data-status="pinned" onclick="setForumStatus(this)"
                        class="filter-chip px-4 py-2 border-2 border-yellow-200 rounded-full
                               text-[10px] font-black uppercase tracking-widest text-yellow-600 transition-all">
                    Pinned
                </button>
            </div>

            <button type="button" onclick="resetForumFilters()"
                    class="bg-gray-100 p-3.5 rounded-2xl text-gray-400 hover:text-math-dark-blue transition-colors flex-shrink-0">
                <span class="material-symbols-outlined text-xl">refresh</span>
            </button>
        </div>
        <div class="mt-3 text-[10px] font-black uppercase tracking-widest text-gray-400" id="forumResultLabel">
            Showing all discussions
        </div>
    </div>

    <!-- THREE-COLUMN LAYOUT -->
    <div class="grid grid-cols-1 lg:grid-cols-[260px_1fr_260px] gap-8">

        <!-- LEFT SIDEBAR -->
        <aside class="hidden lg:flex flex-col gap-6 sticky top-6 self-start">

            <div class="bg-white rounded-[1.75rem] p-5 shadow-md border-2 border-gray-100">
                <asp:Button ID="btnStartDiscussion" runat="server" Text="Start Discussion"
                    CssClass="w-full bg-math-blue text-white font-black py-4 rounded-2xl
                              uppercase tracking-widest text-sm shadow-lg
                              hover:bg-math-dark-blue transition-all border-0 cursor-pointer"
                    OnClick="btnStartDiscussion_Click" />
            </div>

            <!-- Top Solutions -->
            <div class="bg-white rounded-[1.75rem] p-5 shadow-md border-2 border-gray-100">
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <p class="text-[9px] font-black uppercase tracking-widest text-gray-400 mb-0.5">Pinned</p>
                        <h3 class="text-base font-black text-math-dark-blue">Top Solutions</h3>
                    </div>
                    <div class="size-9 bg-yellow-50 rounded-2xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-lg fill-icon" style="color:#f9d006;">push_pin</span>
                    </div>
                </div>
                <div class="space-y-2" id="sidebarTopSolutions"></div>
            </div>

            <!-- Categories -->
            <div class="bg-white rounded-[1.75rem] p-5 shadow-md border-2 border-gray-100">
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <p class="text-[9px] font-black uppercase tracking-widest text-gray-400 mb-0.5">Modules</p>
                        <h3 class="text-base font-black text-math-dark-blue">Browse</h3>
                    </div>
                    <div class="size-9 bg-math-blue/10 rounded-2xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-lg text-math-blue fill-icon">menu_book</span>
                    </div>
                </div>
                <div class="space-y-1" id="sidebarCatList">
                    <button type="button" data-cat="" onclick="sidebarSetCat(this,'')"
                            class="cat-btn active-cat w-full flex items-center justify-between px-4 py-3 rounded-2xl
                                   text-sm font-black text-math-dark-blue border border-transparent hover:bg-blue-50 transition-colors group">
                        <span>All Posts</span>
                        <div class="flex items-center gap-1">
                            <span class="text-[10px] font-black text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full"><%= GetTotalForumPostCount() %></span>
                            <span class="material-symbols-outlined text-base text-gray-300 group-hover:text-math-blue">chevron_right</span>
                        </div>
                    </button>
                    <%-- Populated dynamically by JS from rendered categories --%>
                    <asp:Literal ID="litSidebarCategories" runat="server" />
                </div>
            </div>

            <div class="bg-white rounded-[1.75rem] p-5 shadow-md border-2 border-gray-100">
                <p class="text-[9px] font-black uppercase tracking-widest text-gray-400 mb-4">Overview</p>
                <div class="space-y-3">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold text-gray-500">Loaded Posts</span>
                        <span class="text-xs font-black text-math-dark-blue" id="statTotal">-</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold text-gray-500">Pinned</span>
                        <span class="text-xs font-black text-yellow-500" id="statPinned">-</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold text-gray-500">Showing</span>
                        <span class="text-xs font-black text-math-blue" id="statShowing">-</span>
                    </div>
                </div>
            </div>

        </aside>

        <!-- MAIN FEED -->
    <asp:UpdatePanel ID="upForumContent" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
        <main class="space-y-8 min-w-0">

            <div id="forumEmptyState" class="hidden text-center py-20">
                <div class="size-20 bg-gray-100 rounded-3xl flex items-center justify-center mx-auto mb-5">
                    <span class="material-symbols-outlined text-4xl text-gray-300">search_off</span>
                </div>
                <p class="text-sm font-black uppercase tracking-widest text-gray-400">No discussions match your filters</p>
            </div>

            <asp:Repeater ID="rptForum" runat="server" OnItemCommand="rptForum_ItemCommand">
                <ItemTemplate>
                    <div class="forum-post-item"
                         data-category='<%# (Eval("Category") ?? "").ToString().ToLower() %>'
                         data-pinned='<%# ((bool)Eval("IsTopSolution")).ToString().ToLower() %>'
                         data-searchable='<%# ((Eval("Title") ?? "") + " " + (Eval("Content") ?? "")).ToString().ToLower() %>'>

                        <div class='<%# (bool)Eval("IsTopSolution")
                            ? "bg-white/70 backdrop-blur-md rounded-[2.5rem] border-2 border-yellow-300 shadow-[0_12px_30px_rgba(249,208,6,0.18)] p-8 transition-all"
                            : "bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100 shadow-[0_12px_30px_rgba(0,0,0,0.06)] hover:shadow-[0_18px_45px_rgba(0,0,0,0.08)] hover:-translate-y-[1px] p-8 transition-all" %>'>

                            <%-- Pinned banner --%>
                            <asp:Panel runat="server" Visible='<%# (bool)Eval("IsTopSolution") %>'>
                                <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full
                                            bg-primary text-math-dark-blue font-black text-[11px]
                                            uppercase tracking-widest mb-4 shadow-sm">
                                    <span class="material-symbols-outlined text-sm fill-icon">push_pin</span>
                                    Pinned by Teacher
                                </div>
                            </asp:Panel>

                            <%-- Author meta --%>
                            <div class="flex items-center gap-3 mb-4">
                                <img src='<%# ResolveAvatar(Eval("AuthorAvatar").ToString()) %>'
                                     class="size-10 rounded-2xl object-cover bg-gray-100" alt="avatar" />
                                <div>
                                    <div class="flex items-center gap-2">
                                        <span class="font-black text-sm text-math-dark-blue">@<%# Eval("AuthorName") %></span>
                                        <asp:Panel runat="server" Visible='<%# (bool)Eval("AuthorIsTeacher") %>'>
                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full
                                                         bg-math-blue text-white text-[10px] font-black uppercase tracking-wider">
                                                <span class="material-symbols-outlined text-xs fill-icon">school</span> Teacher
                                            </span>
                                        </asp:Panel>
                                    </div>
                                    <div class="text-[11px] font-black uppercase tracking-[0.2em] text-gray-400">
                                        #<%# Eval("Category") %> · <%# Eval("TimeAgo") %>
                                    </div>
                                </div>
                            </div>

                            <%-- Title + Content --%>
                            <h3 class="text-2xl font-black text-math-dark-blue mb-3"><%# Eval("Title") %></h3>
                            <p class="text-gray-600 font-semibold leading-relaxed mb-4"><%# Eval("Content") %></p>

                            <%-- Attached image --%>
                            <asp:Panel runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("ImageUrl") as string) %>'>
                                <div class="mb-6">
                                    <img src='<%# ResolvePostImage(Eval("ImageUrl") as string) %>'
                                         class="max-h-80 rounded-3xl object-contain border border-gray-100 shadow-sm"
                                         alt="Post image" />
                                </div>
                            </asp:Panel>

                            <%-- Action buttons --%>
                            <div class="flex flex-wrap items-center gap-3 mb-6">

                                <asp:LinkButton runat="server"
                                    CommandName="ToggleLike"
                                    CommandArgument='<%# Eval("PostID") %>'
                                    CssClass='<%# (bool)Eval("IsLikedByMe")
                                        ? "inline-flex items-center gap-2 px-4 py-2 rounded-full border-2 border-math-green bg-math-green text-white transition-all hover:scale-105"
                                        : "inline-flex items-center gap-2 px-4 py-2 rounded-full border-2 border-gray-200 bg-white text-gray-500 hover:border-math-green/40 hover:text-math-green transition-all" %>'>
                                    <span class="material-symbols-outlined text-base fill-icon">thumb_up</span>
                                    <span class="text-[11px] font-black"><%# Eval("LikeCount") %></span>
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CommandName="ToggleComments"
                                    CommandArgument='<%# Eval("PostID") %>'
                                    CssClass='<%# (bool)Eval("ShowComments")
                                        ? "inline-flex items-center gap-2 px-4 py-2 rounded-full border-2 border-primary bg-primary text-math-dark-blue transition-all"
                                        : "inline-flex items-center gap-2 px-4 py-2 rounded-full border-2 border-gray-200 bg-white text-gray-500 hover:border-math-blue hover:text-math-blue transition-all" %>'>
                                    <span class="material-symbols-outlined text-base">chat_bubble</span>
                                    <span class="text-[11px] font-black"><%# Eval("CommentCount") %> Comments</span>
                                </asp:LinkButton>

                                <asp:Panel runat="server" Visible='<%# (bool)Eval("IsMyPost") %>'>
                                    <button type="button"
                                        onclick='openDeleteModal("<%# Eval("PostID") %>")'
                                        class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl
                                               bg-white/60 border border-gray-200 text-red-400
                                               hover:bg-red-50 hover:border-red-300 hover:text-red-600
                                               font-black text-sm transition-all active:scale-[0.95]">
                                        <span class="material-symbols-outlined text-base">delete</span> Delete
                                    </button>
                                </asp:Panel>

                            </div>

                            <%-- Comments panel --%>
                            <asp:Panel runat="server" Visible='<%# (bool)Eval("ShowComments") %>'>
                                <div class="border-t border-gray-100 pt-6 space-y-4">

                                    <asp:Repeater ID="rptComments" runat="server" DataSource='<%# Eval("Comments") %>'>
                                        <ItemTemplate>
                                            <div class='<%# (bool)Eval("AuthorIsTeacher")
                                                ? "flex gap-3 p-4 rounded-2xl bg-math-blue/5 border border-math-blue/15"
                                                : "flex gap-3 p-4 rounded-2xl bg-gray-50 border border-gray-100" %>'>
                                                <img src='<%# ResolveAvatar(Eval("AuthorAvatar").ToString()) %>'
                                                     class="size-8 rounded-xl object-cover bg-gray-200 shrink-0" alt="avatar" />
                                                <div class="min-w-0 flex-1">
                                                    <div class="flex items-center gap-2 mb-1">
                                                        <span class='<%# (bool)Eval("AuthorIsTeacher") ? "font-black text-sm text-math-blue" : "font-black text-sm text-math-dark-blue" %>'>
                                                            @<%# Eval("AuthorName") %>
                                                        </span>
                                                        <asp:Panel runat="server" Visible='<%# (bool)Eval("AuthorIsTeacher") %>'>
                                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-math-blue text-white text-[10px] font-black uppercase tracking-wider">
                                                                <span class="material-symbols-outlined text-xs fill-icon">school</span> Teacher
                                                            </span>
                                                        </asp:Panel>
                                                        <span class="text-[11px] text-gray-400 font-semibold"><%# Eval("TimeAgo") %></span>
                                                    </div>
                                                    <p class="text-sm text-gray-600 font-semibold leading-relaxed"><%# Eval("Content") %></p>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                    <div class="flex gap-3 pt-2">
                                        <asp:TextBox ID="txtComment" runat="server"
                                            Placeholder="Write a comment..." onkeydown="if(event.key==='Enter' ){event.preventDefault();}"
                                            CssClass="flex-1 px-4 py-3 rounded-2xl bg-white border border-gray-200
                                                      text-sm font-semibold text-math-dark-blue placeholder-gray-400
                                                      focus:outline-none focus:border-math-blue/40 transition-colors" />
                                        <asp:LinkButton runat="server"
                                            CommandName="SubmitComment"
                                            CommandArgument='<%# Eval("PostID") %>'
                                            CssClass="inline-flex items-center gap-2 px-5 py-3 rounded-2xl
                                                      bg-math-blue text-white font-black text-sm
                                                      shadow-lg hover:bg-math-dark-blue transition-all active:scale-[0.95]">
                                            <span class="material-symbols-outlined text-base fill-icon">send</span> Post
                                        </asp:LinkButton>
                                    </div>

                                </div>
                            </asp:Panel>

                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <div class="text-center">
                <asp:Button ID="btnLoadMore" runat="server"
                    Text="Load More Discussions"
                    CssClass="bg-math-blue text-white font-black px-12 py-5 rounded-2xl
                              uppercase tracking-widest text-sm shadow-lg
                              hover:bg-math-dark-blue transition-all border-0 cursor-pointer"
                    OnClick="btnLoadMore_Click" Visible="false" />
            </div>
                    <div class="text-center flex gap-4 justify-center">
            <asp:Button ID="btnShowLess" runat="server"
                Text="Show Less"
                CssClass="bg-gray-100 text-math-dark-blue font-black px-12 py-5 rounded-2xl
                          uppercase tracking-widest text-sm shadow
                          hover:bg-gray-200 transition-all border-0 cursor-pointer"
                OnClick="btnShowLess_Click" Visible="false" />

            <asp:Button ID="Button1" runat="server"
                Text="Load More Discussions"
                CssClass="bg-math-blue text-white font-black px-12 py-5 rounded-2xl
                          uppercase tracking-widest text-sm shadow-lg
                          hover:bg-math-dark-blue transition-all border-0 cursor-pointer"
                OnClick="btnLoadMore_Click" Visible="false" />
        </div>
        </main>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>

    <!-- Hidden delete controls -->
    <asp:HiddenField ID="hfDeletePostId" runat="server" Value="" />
    <asp:Button ID="btnDeleteConfirmed" runat="server"
        Style="display:none;" CausesValidation="false"
        OnClick="btnDeleteConfirmed_Click" />

    <!-- GUEST ACTION MODAL -->
    <div id="guestActionModal"
         class="fixed inset-0 z-[999] flex items-center justify-center p-4 hidden">
        <div class="absolute inset-0 bg-math-dark-blue/40 backdrop-blur-sm"
             onclick="closeGuestModal()"></div>
        <div class="relative bg-white rounded-[2.5rem] p-10 max-w-sm w-full text-center mt-32
                    shadow-[0_32px_64px_rgba(0,0,0,0.18)] border border-gray-100">

            <button type="button" onclick="closeGuestModal()"
                class="absolute top-5 right-5 size-9 rounded-full bg-gray-100 hover:bg-gray-200
                       flex items-center justify-center text-gray-500 transition-all">
                <span class="material-symbols-outlined text-lg">close</span>
            </button>

            <div class="size-20 rounded-3xl bg-math-blue/10 border border-math-blue/20
                        flex items-center justify-center mx-auto mb-5">
                <span class="material-symbols-outlined text-math-blue text-4xl">lock_open</span>
            </div>

            <h2 class="text-2xl font-black text-math-dark-blue mb-2">Members Only</h2>
            <p class="text-gray-500 font-semibold mb-1">
                You need an account to <span id="guestActionLabel" class="text-math-blue font-black"></span>.
            </p>
            <p class="text-sm text-gray-400 font-semibold mb-8">
                Create a free account to participate in discussions, like posts, and more!
            </p>

            <div class="flex flex-col gap-3">
                <a href="Login.aspx"
                   class="w-full inline-flex items-center justify-center gap-2 px-6 py-4
                          rounded-2xl bg-math-blue text-white font-black text-sm uppercase
                          tracking-widest hover:bg-math-dark-blue transition-all shadow-lg shadow-math-blue/20">
                    <span class="material-symbols-outlined text-base">login</span>
                    Sign In
                </a>
                <a href="Register.aspx"
                   class="w-full inline-flex items-center justify-center gap-2 px-6 py-3
                          rounded-2xl bg-gray-100 text-math-dark-blue font-black text-sm uppercase
                          tracking-widest hover:bg-gray-200 transition-all">
                    <span class="material-symbols-outlined text-base">person_add</span>
                    Create Free Account
                </a>
            </div>

            <div class="mt-6 pt-6 border-t border-gray-100 grid grid-cols-3 gap-3">
                <div class="flex flex-col items-center gap-1">
                    <div class="size-10 rounded-2xl bg-green-50 flex items-center justify-center">
                        <span class="material-symbols-outlined text-green-500 text-lg">forum</span>
                    </div>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-wide">Post & Reply</p>
                </div>
                <div class="flex flex-col items-center gap-1">
                    <div class="size-10 rounded-2xl bg-primary/10 flex items-center justify-center">
                        <span class="material-symbols-outlined text-primary text-lg">thumb_up</span>
                    </div>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-wide">Like Posts</p>
                </div>
                <div class="flex flex-col items-center gap-1">
                    <div class="size-10 rounded-2xl bg-math-blue/10 flex items-center justify-center">
                        <span class="material-symbols-outlined text-math-blue text-lg">stars</span>
                    </div>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-wide">Earn XP</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        var _forumStatus = '';

        function setForumStatus(btn) {
            document.querySelectorAll('.filter-chip').forEach(function(c) { c.classList.remove('active'); });
            btn.classList.add('active');
            _forumStatus = btn.dataset.status;
            applyForumFilters();
        }

        function sidebarSetCat(btn, cat) {
            document.querySelectorAll('.cat-btn').forEach(function(b) { b.classList.remove('active-cat'); });
            btn.classList.add('active-cat');
            var sel = document.getElementById('forumCategory');
            if (sel) sel.value = cat;
            applyForumFilters();
        }

        function applyForumFilters() {
            var q    = (document.getElementById('forumSearch').value || '').toLowerCase().trim();
            var sel  = document.getElementById('forumCategory');
            var cat  = sel ? (sel.value || '').toLowerCase() : '';
            var stat = _forumStatus.toLowerCase();

            var items = document.querySelectorAll('.forum-post-item');
            var shown = 0;

            items.forEach(function(item) {
                var matchQ    = !q    || item.dataset.searchable.includes(q);
                var matchCat  = !cat  || item.dataset.category === cat;
                var matchStat = !stat || (stat === 'pinned' && item.dataset.pinned === 'true');
                var visible   = matchQ && matchCat && matchStat;
                item.style.display = visible ? '' : 'none';
                if (visible) shown++;
            });

            var lbl = document.getElementById('forumResultLabel');
            if (lbl) lbl.textContent = shown === items.length
                ? 'Showing all ' + items.length + ' posts'
                : 'Showing ' + shown + ' of ' + items.length + ' posts';

            var empty = document.getElementById('forumEmptyState');
            if (empty) empty.classList.toggle('hidden', shown > 0);

            var pinned = document.querySelectorAll('.forum-post-item[data-pinned="true"]').length;
            var stTotal   = document.getElementById('statTotal');
            var stPinned  = document.getElementById('statPinned');
            var stShowing = document.getElementById('statShowing');
            if (stTotal)   stTotal.textContent   = items.length;
            if (stPinned)  stPinned.textContent  = pinned;
            if (stShowing) stShowing.textContent = shown;
        }

        function resetForumFilters() {
            var s = document.getElementById('forumSearch');
            var c = document.getElementById('forumCategory');
            if (s) s.value = '';
            if (c) c.value = '';
            var allChip = document.querySelector('.filter-chip[data-status=""]');
            if (allChip) setForumStatus(allChip);
            document.querySelectorAll('.cat-btn').forEach(function(b) { b.classList.remove('active-cat'); });
            var allCat = document.querySelector('.cat-btn[data-cat=""]');
            if (allCat) allCat.classList.add('active-cat');
        }

        function buildTopSolutionsSidebar() {
            var container = document.getElementById('sidebarTopSolutions');
            if (!container) return;

            var pinned = document.querySelectorAll('.forum-post-item[data-pinned="true"]');
            if (pinned.length === 0) {
                container.innerHTML = '<p class="text-xs text-gray-400 italic font-bold">No top solutions yet.</p>';
                return;
            }

            var html = '';
            pinned.forEach(function(item) {
                var titleEl  = item.querySelector('h3');
                var avatarEl = item.querySelector('img');
                var authorEl = item.querySelector('.font-black.text-sm.text-math-dark-blue');
                var title    = titleEl  ? titleEl.textContent.trim()  : 'Post';
                var avatar   = avatarEl ? avatarEl.src                : '';
                var author   = authorEl ? authorEl.textContent.trim() : '';
                if (title.length > 40) title = title.substring(0, 37) + '\u2026';

                html += '<div class="ts-item" onclick="scrollToForumPost(this)">' +
                    (avatar ? '<img src="' + avatar + '" class="size-7 rounded-xl object-cover flex-shrink-0 border border-yellow-200" alt=""/>' : '') +
                    '<div class="flex-1 min-w-0">' +
                    '<p class="text-xs font-black text-math-dark-blue leading-tight truncate">' + title + '</p>' +
                    '<p class="text-[10px] text-gray-400 font-bold mt-0.5">by ' + author + '</p>' +
                    '</div></div>';
            });
            container.innerHTML = html;
        }

        function scrollToForumPost(sidebarEl) {
            var p = sidebarEl.querySelector('p');
            if (!p) return;
            var titleSnippet = p.textContent.replace('\u2026', '').trim().substring(0, 20);
            document.querySelectorAll('.forum-post-item[data-pinned="true"]').forEach(function(item) {
                var h3 = item.querySelector('h3');
                if (h3 && h3.textContent.trim().startsWith(titleSnippet)) {
                    item.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    var card = item.querySelector('div');
                    if (card) {
                        card.style.outline = '3px solid #f9d006';
                        setTimeout(function() { card.style.outline = ''; }, 1800);
                    }
                }
            });
        }

        function ensureForumModalMounted(id) {
            var el = document.getElementById(id);
            if (el && el.parentElement !== document.body) {
                document.body.appendChild(el);
            }
            return el;
        }

        function openDeleteModal(postId) {
            document.getElementById('<%= hfDeletePostId.ClientID %>').value = postId;
            var deleteModal = ensureForumModalMounted('deleteModal');
            document.body.classList.add('app-modal-active');
            if (deleteModal) {
                deleteModal.classList.remove('hidden');
            }
        }
        function cancelDelete() {
            document.getElementById('deleteModal').classList.add('hidden');
            document.body.classList.remove('app-modal-active');
            document.getElementById('<%= hfDeletePostId.ClientID %>').value = '';
        }
        function showGuestModal(action) {
            var guestModal = ensureForumModalMounted('guestActionModal');
            document.getElementById('guestActionLabel').textContent = action;
            document.body.classList.add('app-modal-active');
            if (guestModal) {
                guestModal.classList.remove('hidden');
            }
        }
        function closeGuestModal() {
            document.getElementById('guestActionModal').classList.add('hidden');
            document.body.classList.remove('app-modal-active');
        }
        function executeDelete() {
            document.getElementById('deleteModal').classList.add('hidden');
            document.body.classList.remove('app-modal-active');
            document.getElementById('<%= btnDeleteConfirmed.ClientID %>').click();
        }
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { cancelDelete(); closeGuestModal(); }
        });

        function syncForumCategorySidebar() {
            var sel = document.getElementById('forumCategory');
            var cat = sel ? (sel.value || '') : '';
            document.querySelectorAll('.cat-btn').forEach(function(b) { b.classList.remove('active-cat'); });
            var target = document.querySelector('.cat-btn[data-cat="' + cat + '"]') || document.querySelector('.cat-btn[data-cat=""]');
            if (target) target.classList.add('active-cat');
        }

        function initForumUi() {
            buildTopSolutionsSidebar();
            syncForumCategorySidebar();
            applyForumFilters();
        }

        document.addEventListener('DOMContentLoaded', function () {
            initForumUi();
            if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    initForumUi();
                });
            }
        });
    </script>


    </div>
</asp:Content>

















