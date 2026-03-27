<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="teacherForum.aspx.cs"
         Inherits="MathSphere.teacherForum" MasterPageFile="~/Teacher.master" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere — Teacher Forum &amp; Moderation
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* -- Top Solution pin banner -- */
        .pin-banner {
            background: linear-gradient(90deg, #f9d006 0%, #fbbf24 100%);
            color: #1e3a8a;
        }

        /* -- Resolved banner -- */
        .resolved-banner {
            background: #f0fdf4;
            border: 1.5px solid #bbf7d0;
            color: #15803d;
        }

        /* -- Post card: top-solution golden border -- */
        .post-card-pinned {
            border: 2.5px solid #f9d006 !important;
            box-shadow: 0 0 0 4px rgba(249,208,6,0.12), 0 8px 32px rgba(0,0,0,0.08);
        }

        /* -- Post card: resolved soft green border -- */
        .post-card-resolved {
            border: 2px solid #bbf7d0 !important;
            opacity: 0.92;
        }

        /* -- Sidebar active category -- */
        .sidebar-cat-btn.active-cat {
            background: #eff6ff;
            color: #1e3a8a;
        }
        .sidebar-cat-btn.active-cat span.material-symbols-outlined {
            color: #2563eb !important;
        }

        /* -- Top solution sidebar item -- */
        .ts-item {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 10px 12px;
            border-radius: 16px;
            background: #fefce8;
            border: 1.5px solid #fde68a;
            cursor: pointer;
            transition: all 0.2s;
        }
        .ts-item:hover { background: #fef9c3; }

        @keyframes likeRipple {
            0%   { transform: scale(1); }
            40%  { transform: scale(1.35); }
            100% { transform: scale(1); }
        }
        .like-btn.liked { animation: likeRipple 0.35s ease; }
        .like-btn.liked .like-icon { color: #2563eb !important; }
        .like-btn.liked .like-pill  { background: #dbeafe !important; color: #2563eb !important; }

        /* -- Comment thread indent -- */
        .comment-thread  { border-left: 3px solid #e5e7eb; }
        .feedback-thread { border-left: 3px solid #2563eb; }

        /* -- Smooth expand -- */
        .collapsible { overflow: hidden; transition: max-height 0.35s ease; max-height: 0; }
        .collapsible.open { max-height: 2000px; }

        /* -- Filter chip active -- */
        .filter-chip.active {
            background: #1e3a8a !important;
            color: #f9d006 !important;
            border-color: #1e3a8a !important;
        }

        /* -- Feedback badge -- */
        .teacher-badge { background: linear-gradient(135deg, #2563eb, #1e3a8a); }

        textarea::placeholder { font-style: italic; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-8">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">forum</span>
                Teacher forum
            </div>

            <div class="flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
                <div class="max-w-3xl space-y-3">
                    <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">
                        Forum &amp; Moderation
                    </h2>
                    <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                        Review student posts, add feedback, and moderate discussions from the same shared teacher workspace.
                    </p>
                </div>
                <div class="grid gap-3 sm:grid-cols-3 xl:min-w-[430px]">
                    <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Focus</p>
                        <p class="mt-2 text-sm font-bold text-math-dark-blue">Student discussion quality</p>
                    </div>
                    <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Actions</p>
                        <p class="mt-2 text-sm font-bold text-math-dark-blue">Resolve, pin, flag, feedback</p>
                    </div>
                    <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">View</p>
                        <p class="mt-2 text-sm font-bold text-math-dark-blue">Posts, categories, top solutions</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%-- Search + Filter Bar --%>
    <div class="mb-8 rounded-[2.25rem] border border-white/70 bg-white/90 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
        <div class="flex flex-col items-center gap-4 md:flex-row">

            <div class="relative flex-1 w-full">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 text-xl">search</span>
                <input type="text" id="tfSearch" placeholder="Search posts by title, student, or content..."
                       oninput="applyFilters()"
                       class="w-full rounded-2xl border border-gray-200 bg-gray-50 py-3.5 pl-12 pr-4 text-sm font-bold text-math-dark-blue outline-none transition-all focus:border-math-blue focus:bg-white focus:ring-0" />
            </div>

            <div class="relative">
                <select id="tfCategory" onchange="applyFilters()"
                        class="appearance-none bg-none rounded-2xl border border-gray-200 bg-gray-50 py-3.5 pl-5 pr-11 text-xs font-black uppercase tracking-widest text-math-dark-blue cursor-pointer outline-none transition-all focus:border-math-blue focus:bg-white focus:ring-0" style="-webkit-appearance:none;-moz-appearance:none;appearance:none;background-image:none;">
                    <option value="">All Categories</option>
                    <asp:Literal ID="litCategoryOptions" runat="server" />
                </select>
                <span class="absolute right-4 inset-y-0 flex items-center pointer-events-none text-gray-400 -translate-y-px">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
                </span>
            </div>

            <div class="flex flex-shrink-0 gap-2">
                <button type="button" data-status="" onclick="setStatus(this)"
                        class="filter-chip active rounded-full border-2 border-gray-200 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-gray-500 transition-all hover:border-math-dark-blue">
                    All
                </button>
                <button type="button" data-status="Published" onclick="setStatus(this)"
                        class="filter-chip rounded-full border-2 border-gray-200 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-gray-500 transition-all hover:border-math-dark-blue">
                    Active
                </button>
                <button type="button" data-status="Flagged" onclick="setStatus(this)"
                        class="filter-chip rounded-full border-2 border-red-200 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-red-400 transition-all">
                    Flagged
                </button>
                <button type="button" data-status="Resolved" onclick="setStatus(this)"
                        class="filter-chip rounded-full border-2 border-green-200 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-math-green transition-all">
                    Resolved
                </button>
            </div>

            <button type="button" onclick="resetFilters()"
                    class="flex-shrink-0 rounded-2xl bg-gray-100 p-3.5 text-gray-400 transition-colors hover:text-math-dark-blue">
                <span class="material-symbols-outlined text-xl">refresh</span>
            </button>
        </div>

        <div class="mt-4 text-[10px] font-black uppercase tracking-widest text-gray-400" id="tfResultLabel">
            Showing all posts
        </div>
    </div>

    <%-- Two-column layout --%>
    <div class="flex gap-6 items-start">

        <%-- LEFT SIDEBAR --%>
        <div class="hidden lg:flex flex-col gap-5 w-64 flex-shrink-0 sticky top-6">

            <%-- Top Solutions --%>
            <div class="rounded-[1.75rem] border border-white/70 bg-white/90 p-5 shadow-[0_16px_32px_rgba(30,58,138,0.06)]">
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <p class="text-[9px] font-black uppercase tracking-widest text-gray-400 mb-0.5">Pinned</p>
                        <h3 class="text-base font-black text-math-dark-blue">Top Solutions</h3>
                    </div>
                    <div class="size-9 bg-primary/20 rounded-2xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-lg text-primary fill-icon">push_pin</span>
                    </div>
                </div>
                <div class="space-y-2" id="sidebarTopSolutions">
                    <asp:Literal ID="litTopSolutions" runat="server" />
                </div>
            </div>

            <%-- Categories --%>
            <div class="rounded-[1.75rem] border border-white/70 bg-white/90 p-5 shadow-[0_16px_32px_rgba(30,58,138,0.06)]">
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <p class="text-[9px] font-black uppercase tracking-widest text-gray-400 mb-0.5">Modules</p>
                        <h3 class="text-base font-black text-math-dark-blue">Browse</h3>
                    </div>
                    <div class="size-9 bg-math-blue/10 rounded-2xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-lg text-math-blue fill-icon">menu_book</span>
                    </div>
                </div>
                <div class="space-y-1">
                    <button type="button" data-cat="" onclick="sidebarSetCat(this, '')"
                            class="sidebar-cat-btn w-full flex items-center justify-between px-4 py-3 rounded-2xl text-sm font-black text-math-dark-blue hover:bg-math-blue/5 transition-colors group active-cat">
                        <span>All Posts</span>
                        <div class="flex items-center gap-1">
                            <span class="text-[10px] font-black text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full"><%= GetTotalForumPostCount() %></span>
                            <span class="material-symbols-outlined text-base text-gray-300 group-hover:text-math-blue">chevron_right</span>
                        </div>
                    </button>
                    <asp:Literal ID="litCategoryNav" runat="server" />
                </div>
            </div>

            <%-- Quick stats --%>
            <div class="rounded-[1.75rem] border border-white/70 bg-white/90 p-5 shadow-[0_16px_32px_rgba(30,58,138,0.06)]">
                <p class="text-[9px] font-black uppercase tracking-widest text-gray-400 mb-3">Overview</p>
                <div class="space-y-3">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold text-gray-500">Total Posts</span>
                        <asp:Literal ID="litStatTotal" runat="server" />
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold text-gray-500">Flagged</span>
                        <asp:Literal ID="litStatFlagged" runat="server" />
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold text-gray-500">Resolved</span>
                        <asp:Literal ID="litStatResolved" runat="server" />
                    </div>
                </div>
            </div>

        </div>

        <%-- MAIN POST LIST --%>
        <div class="flex-1 min-w-0">
            <div class="space-y-6" id="tfPostList">
                <asp:Repeater ID="rptForumPosts" runat="server"
                              OnItemDataBound="rptForumPosts_ItemDataBound"
                              OnItemCommand="rptForumPosts_ItemCommand">
                    <ItemTemplate>

                <%-- Outer wrapper: carries data attrs for JS filtering.
                     data-status uses "Resolved" when isResolved=true so the chip filter works. --%>
                <div class='<%# "tf-post-item" %>'
                     data-status='<%# (bool)Eval("IsResolved") ? "Resolved" : Eval("Status").ToString() %>'
                     data-category='<%# Eval("Category") %>'
                     data-searchable='<%# (Eval("PostTitle") + " " + Eval("PostContent") + " " + Eval("StudentName")).ToString().ToLower() %>'>

                    <%-- TOP SOLUTION PIN BANNER --%>
                    <asp:PlaceHolder ID="phPinBanner" runat="server"
                                     Visible='<%# (bool)Eval("IsTopSolution") %>'>
                        <div class="pin-banner px-6 py-2 rounded-t-[2rem] flex items-center gap-2 text-[11px] font-black uppercase tracking-widest -mb-4 relative z-10">
                            <span class="material-symbols-outlined text-base fill-icon">push_pin</span>
                            Top Solution · Pinned by Teacher
                        </div>
                    </asp:PlaceHolder>

                    <%-- POST CARD --%>
                    <article class='<%#
                        "bg-white/95 rounded-[2rem] p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)] border border-white/70 transition-all hover:shadow-[0_22px_48px_rgba(30,58,138,0.12)] "
                        + ((bool)Eval("IsTopSolution") ? "post-card-pinned rounded-tl-none " : "")
                        + ((bool)Eval("IsResolved")    ? "post-card-resolved " : "") %>'>

                        <%-- Card header --%>
                        <div class="flex items-start justify-between mb-6">
                            <div class="flex items-center gap-4">
                                <div class="relative flex-shrink-0">
                                    <img src='<%# Eval("StudentAvatar") %>'
                                         class="size-14 rounded-2xl border-2 border-math-blue object-cover shadow-sm"
                                         alt='<%# Eval("StudentName") %>' />
                                    <div class="absolute -bottom-2 -right-2 bg-math-dark-blue text-primary text-[9px] font-black px-2 py-0.5 rounded-full border-2 border-white whitespace-nowrap">
                                        LVL <%# Eval("StudentLevel") %>
                                    </div>
                                </div>
                                <div>
                                    <div class="font-black text-base text-math-dark-blue">@<%# Eval("StudentName") %></div>
                                    <div class="flex items-center gap-1.5 text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-0.5">
                                        <span class="text-primary">#</span>
                                        <span><%# Eval("Category") %></span>
                                        <span class="text-gray-200">·</span>
                                        <span><%# Eval("TimeAgo") %></span>
                                    </div>
                                </div>
                            </div>
                            <asp:Literal ID="litStatusBadge" runat="server" />
                        </div>

                        <%-- Post title + content --%>
                        <div class="mb-6">
                            <h3 class="text-xl font-black text-math-dark-blue mb-2 leading-tight">
                                <%# Eval("PostTitle") %>
                            </h3>
                            <div class="text-sm text-gray-600 font-medium leading-relaxed space-y-2">
                                <%# RenderPostContent(Eval("PostContent")?.ToString()) %>
                            </div>
                        </div>

                        <%-- Resolved banner (shown only when resolved) --%>
                        <asp:Literal ID="litResolvedBanner" runat="server" />

                        <%-- Action row --%>
                        <div class="flex flex-wrap items-center gap-3 pt-5 border-t-2 border-gray-50 mt-4">

                            <%-- Like --%>
                            <button type="button"
                                    id='<%# "likeBtn_" + Eval("PostID") %>'
                                    onclick='<%# "toggleLike(this,\"" + Eval("PostID") + "\")" %>'
                                    class='<%# "like-btn flex items-center gap-2 px-4 py-2 rounded-full border-2 transition-all hover:scale-105 " + ((bool)Eval("IsLikedByTeacher") ? "border-math-blue bg-blue-50" : "border-gray-200 bg-white") %>'>
                                <span class='<%# "like-icon material-symbols-outlined text-base fill-icon " + ((bool)Eval("IsLikedByTeacher") ? "text-math-blue" : "text-gray-400") %>'>thumb_up</span>
                                <span class='<%# "like-pill text-[11px] font-black " + ((bool)Eval("IsLikedByTeacher") ? "text-math-blue" : "text-gray-500") %>'
                                      id='<%# "likeCount_" + Eval("PostID") %>'>
                                    <%# Eval("LikeCount") %>
                                </span>
                            </button>

                            <%-- Comments toggle --%>
                            <button type="button"
                                    onclick='<%# "toggleSection(\"comments_" + Eval("PostID") + "\")" %>'
                                    class="flex items-center gap-2 px-4 py-2 rounded-full border-2 border-gray-200 bg-white text-gray-500 hover:border-math-blue hover:text-math-blue transition-all">
                                <span class="material-symbols-outlined text-base">chat_bubble</span>
                                <span class="text-[11px] font-black">
                                    <asp:Literal ID="litCommentCount" runat="server" />Comments
                                </span>
                            </button>

                            <%-- Feedback toggle --%>
                            <button type="button"
                                    onclick='<%# "toggleSection(\"feedback_" + Eval("PostID") + "\")" %>'
                                    class="flex items-center gap-2 px-4 py-2 rounded-full border-2 border-math-blue/20 bg-blue-50 text-math-blue hover:bg-math-blue hover:text-white transition-all">
                                <span class="material-symbols-outlined text-base">rate_review</span>
                                <span class="text-[11px] font-black">Feedback</span>
                            </button>

                            <div class="ml-auto flex gap-2">

                                <%-- Resolve / Unresolve button --%>
                                <asp:LinkButton ID="btnResolve" runat="server"
                                    CommandName='<%# (bool)Eval("IsResolved") ? "Unresolve" : "Resolve" %>'
                                    CommandArgument='<%# Eval("PostID") %>'
                                    CssClass='<%# (bool)Eval("IsResolved")
                                        ? "flex items-center gap-1.5 px-4 py-2 rounded-full bg-green-50 text-math-green border-2 border-green-200 text-[11px] font-black hover:bg-red-50 hover:text-red-500 hover:border-red-200 transition-all"
                                        : "flex items-center gap-1.5 px-4 py-2 rounded-full bg-gray-50 text-gray-500 border-2 border-gray-200 text-[11px] font-black hover:bg-green-50 hover:text-math-green hover:border-green-200 transition-all" %>'
                                    title='<%# (bool)Eval("IsResolved") ? "Mark as unresolved" : "Mark as resolved" %>'>
                                    <span class="material-symbols-outlined text-base">
                                        <%# (bool)Eval("IsResolved") ? "undo" : "check_circle" %>
                                    </span>
                                    <%# (bool)Eval("IsResolved") ? "Reopen" : "Resolve" %>
                                </asp:LinkButton>

                                <%-- Mark / Unmark Top Solution --%>
                                <asp:LinkButton ID="btnSolve" runat="server"
                                    CommandName="Solve"
                                    CommandArgument='<%# Eval("PostID") %>'
                                    CssClass='<%# (bool)Eval("IsTopSolution")
                                        ? "flex items-center gap-1.5 px-4 py-2 rounded-full bg-primary/20 text-yellow-700 border-2 border-primary/40 text-[11px] font-black hover:bg-red-50 hover:text-red-500 hover:border-red-200 transition-all"
                                        : "flex items-center gap-1.5 px-4 py-2 rounded-full bg-math-green/10 text-math-green border-2 border-math-green/30 text-[11px] font-black hover:bg-math-green hover:text-white transition-all" %>'>
                                    <span class="material-symbols-outlined text-base"><%# (bool)Eval("IsTopSolution") ? "push_pin" : "verified" %></span>
                                    <%# (bool)Eval("IsTopSolution") ? "Unpin" : "Pin Solution" %>
                                </asp:LinkButton>

                                <%-- Flag toggle --%>
                                <asp:LinkButton ID="btnFlag" runat="server"
                                    CommandName="Flag"
                                    CommandArgument='<%# Eval("PostID") %>'
                                    CssClass='<%# (bool)Eval("IsFlagged")
                                        ? "flex items-center justify-center size-10 rounded-full bg-red-100 text-red-500 border-2 border-red-200 hover:bg-red-500 hover:text-white transition-all"
                                        : "flex items-center justify-center size-10 rounded-full bg-gray-50 text-gray-400 border-2 border-gray-200 hover:bg-primary hover:text-math-dark-blue transition-all" %>'
                                    title='<%# (bool)Eval("IsFlagged") ? "Remove flag" : "Flag for review" %>'>
                                    <span class="material-symbols-outlined text-base">
                                        <%# (bool)Eval("IsFlagged") ? "outlined_flag" : "flag" %>
                                    </span>
                                </asp:LinkButton>

                            </div>
                        </div>

                        <%-- COMMENTS SECTION --%>
                        <div id='<%# "comments_" + Eval("PostID") %>' class="collapsible">
                            <div class="mt-6 pt-5 border-t-2 border-gray-50">
                                <div class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4 flex items-center gap-2">
                                    <span class="material-symbols-outlined text-base">forum</span>
                                    Student Comments
                                </div>
                                <div class="space-y-3 comment-thread pl-4">
                                    <asp:Literal ID="litComments" runat="server" />
                                </div>
                            </div>
                        </div>

                        <%-- FEEDBACK SECTION --%>
                        <div id='<%# "feedback_" + Eval("PostID") %>' class="collapsible">
                            <div class="mt-6 pt-5 border-t-2 border-blue-50">
                                <div class="text-[10px] font-black uppercase tracking-widest text-math-blue mb-4 flex items-center gap-2">
                                    <span class="material-symbols-outlined text-base">rate_review</span>
                                    Teacher Feedback
                                </div>
                                <div class="space-y-3 feedback-thread pl-4 mb-4">
                                    <asp:Literal ID="litFeedback" runat="server" />
                                </div>

                                <%-- Only show feedback composer if not yet resolved --%>
                                <asp:PlaceHolder ID="phFeedbackComposer" runat="server"
                                                 Visible='<%# !(bool)Eval("IsResolved") %>'>
                                    <div class="bg-blue-50 rounded-2xl p-4 border-2 border-math-blue/10">
                                        <textarea id='<%# "fbText_" + Eval("PostID") %>'
                                                  placeholder="Write feedback for this student… (posting will auto-resolve this post)"
                                                  rows="3"
                                                  class="w-full bg-white border-2 border-gray-100 rounded-xl p-3 text-sm font-medium text-math-dark-blue resize-none outline-none focus:border-math-blue transition-all"></textarea>
                                        <div class="flex justify-end mt-2">
                                            <button type="button"
                                                    onclick='<%# "submitFeedback(\"" + Eval("PostID") + "\")" %>'
                                                    class="flex items-center gap-2 bg-math-blue text-white px-5 py-2 rounded-full text-[11px] font-black uppercase tracking-wider hover:bg-math-dark-blue transition-colors shadow-sm">
                                                <span class="material-symbols-outlined text-sm">send</span>
                                                Post Feedback &amp; Resolve
                                            </button>
                                        </div>
                                    </div>
                                </asp:PlaceHolder>

                                <%-- Show "already resolved" note when resolved --%>
                                <asp:PlaceHolder ID="phAlreadyResolved" runat="server"
                                                 Visible='<%# (bool)Eval("IsResolved") %>'>
                                    <div class="flex items-center gap-2 px-4 py-3 bg-green-50 border border-green-100 rounded-2xl text-[11px] font-black text-math-green">
                                        <span class="material-symbols-outlined text-base fill-icon">verified</span>
                                        This post has been resolved. Use the Reopen button to post additional feedback.
                                    </div>
                                </asp:PlaceHolder>
                            </div>
                        </div>

                    </article>
                </div>

                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <%-- Empty state --%>
            <div id="tfEmptyState" class="hidden text-center py-24">
                <div class="size-20 bg-gray-50 rounded-3xl border border-gray-100 flex items-center justify-center mx-auto mb-5 shadow-inner">
                    <span class="material-symbols-outlined text-4xl text-gray-300">search_off</span>
                </div>
                <p class="text-sm font-black uppercase tracking-widest text-gray-400">No posts match your filters</p>
            </div>
        </div>

    </div>

    <%-- Toast --%>
    <div id="tfToast"
         class="fixed bottom-8 left-1/2 -translate-x-1/2 translate-y-20 opacity-0 transition-all duration-400
                bg-math-dark-blue text-white px-7 py-3.5 rounded-full text-xs font-black uppercase tracking-wider
                shadow-xl pointer-events-none z-[9999] whitespace-nowrap">
    </div>

    <asp:HiddenField ID="hfFeedbackPostId" runat="server" Value="" />
    <asp:HiddenField ID="hfFeedbackText"   runat="server" Value="" />
    <asp:Button ID="btnFeedbackSubmit" runat="server" Style="display:none"
        CausesValidation="false" OnClick="btnFeedbackSubmit_Click" />

</asp:Content>

<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        // Sidebar category navigation
        function sidebarSetCat(btn, cat) {
            document.querySelectorAll('.sidebar-cat-btn').forEach(b => b.classList.remove('active-cat'));
            btn.classList.add('active-cat');
            document.getElementById('tfCategory').value = cat;
            applyFilters();
        }

        // Scroll to post from sidebar
        function scrollToPost(postId) {
            const items = document.querySelectorAll('.tf-post-item');
            for (const item of items) {
                if (item.querySelector('[id^="likeBtn_' + postId + '"]')) {
                    item.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    item.querySelector('article').style.boxShadow = '0 0 0 3px #2563eb55';
                    setTimeout(() => item.querySelector('article').style.boxShadow = '', 1800);
                    return;
                }
            }
        }

        // Filter state
        let _activeStatus = '';

        function setStatus(btn) {
            document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
            btn.classList.add('active');
            _activeStatus = btn.dataset.status;
            applyFilters();
        }

        function applyFilters() {
            const q    = (document.getElementById('tfSearch').value || '').toLowerCase().trim();
            const cat  = (document.getElementById('tfCategory').value || '').toLowerCase();
            const stat = _activeStatus.toLowerCase();

            const items = document.querySelectorAll('.tf-post-item');
            let shown = 0;

            items.forEach(item => {
                const matchQ    = !q    || item.dataset.searchable.includes(q);
                const matchCat  = !cat  || item.dataset.category.toLowerCase() === cat;
                const matchStat = !stat || item.dataset.status.toLowerCase() === stat;
                const visible   = matchQ && matchCat && matchStat;
                item.style.display = visible ? '' : 'none';
                if (visible) shown++;
            });

            const lbl = document.getElementById('tfResultLabel');
            lbl.textContent = shown === items.length
                ? 'Showing all ' + items.length + ' posts'
                : 'Showing ' + shown + ' of ' + items.length + ' posts';

            document.getElementById('tfEmptyState').classList.toggle('hidden', shown > 0);
        }

        function resetFilters() {
            document.getElementById('tfSearch').value   = '';
            document.getElementById('tfCategory').value = '';
            setStatus(document.querySelector('.filter-chip[data-status=""]'));
        }

        // Expand / collapse collapsible sections
        function toggleSection(id) {
            const el = document.getElementById(id);
            if (el) el.classList.toggle('open');
        }

        // Like / Unlike
        function toggleLike(btn, postId) {
            const countEl = document.getElementById('likeCount_' + postId);
            const iconEl  = btn.querySelector('.like-icon');
            const isLiked = btn.classList.contains('border-math-blue');
            const current = parseInt(countEl.textContent.trim()) || 0;

            // Optimistic UI
            if (isLiked) {
                btn.classList.remove('border-math-blue', 'bg-blue-50');
                btn.classList.add('border-gray-200', 'bg-white');
                iconEl.classList.remove('text-math-blue'); iconEl.classList.add('text-gray-400');
                countEl.classList.remove('text-math-blue'); countEl.classList.add('text-gray-500');
                countEl.textContent = Math.max(0, current - 1);
            } else {
                btn.classList.add('border-math-blue', 'bg-blue-50', 'liked');
                btn.classList.remove('border-gray-200', 'bg-white');
                iconEl.classList.add('text-math-blue'); iconEl.classList.remove('text-gray-400');
                countEl.classList.add('text-math-blue'); countEl.classList.remove('text-gray-500');
                countEl.textContent = current + 1;
                setTimeout(() => btn.classList.remove('liked'), 400);
            }

            function applyResult(data) {
                if (!data) return;
                if (!data.success && data.error) {
                    showToast('Like error: ' + data.error);
                    countEl.textContent = current;
                    return;
                }
                if (data.newCount !== undefined) countEl.textContent = data.newCount;
            }

            // Use PageMethods if ScriptManager has EnablePageMethods="true"
            if (typeof PageMethods !== 'undefined') {
                PageMethods.ToggleLike(postId,
                    function(r) { applyResult(r); },
                    function(e) { countEl.textContent = current; showToast('Could not save like.'); console.error('[ToggleLike]', e); }
                );
            } else {
                // Fallback: raw XHR
                var xhr = new XMLHttpRequest();
                xhr.open('POST', window.location.pathname + '/ToggleLike', true);
                xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
                xhr.onload = function() {
                    try {
                        var res = JSON.parse(xhr.responseText);
                        applyResult(res.d !== undefined ? res.d : res);
                    } catch(e) { /* keep optimistic */ }
                };
                xhr.onerror = function() { countEl.textContent = current; showToast('Could not save like.'); };
                xhr.send(JSON.stringify({ postId: postId }));
            }
        }

        // Submit Feedback
        function submitFeedback(postId) {
            const ta   = document.getElementById('fbText_' + postId);
            const text = (ta ? ta.value : '').trim();
            if (!text) { showToast('Please enter feedback text.'); return; }

            document.getElementById('<%= hfFeedbackPostId.ClientID %>').value = postId;
            document.getElementById('<%= hfFeedbackText.ClientID %>').value   = text;
            document.getElementById('<%= btnFeedbackSubmit.ClientID %>').click();
        }

        // Toast
        function showToast(msg) {
            const el = document.getElementById('tfToast');
            el.textContent = msg;
            el.classList.add('translate-y-0', 'opacity-100');
            el.classList.remove('translate-y-20', 'opacity-0');
            setTimeout(() => {
                el.classList.remove('translate-y-0', 'opacity-100');
                el.classList.add('translate-y-20', 'opacity-0');
            }, 3000);
        }

        // Init
        document.addEventListener('DOMContentLoaded', function () { applyFilters(); });
    </script>
</asp:Content>

