<%@ Page Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="helpCenterHub.aspx.cs" Inherits="MathSphere.helpCenterHub" %>

<%-- ══ Title ══ --%>
<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere Admin — Help Center
</asp:Content>

<%-- ══ Head (page-specific styles) ══ --%>
<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/AdminUI/Styles/helpCenterHub.css") %>" rel="stylesheet" />
    <style>
        /* ── Delete modal ── */
        #hcDeleteModal {
            position: fixed; inset: 0; z-index: 9000;
            background: rgba(15,23,42,.55); backdrop-filter: blur(4px);
            display: none; align-items: center; justify-content: center; padding: 1.5rem;
        }
        #hcDeleteModal.open { display: flex !important; }

        /* ── Toast ── */
        #hcToast {
            position: fixed; bottom: 2rem; right: 2rem; z-index: 9999;
            background: #1e3a8a; color: #fff;
            padding: .9rem 1.6rem; border-radius: 1rem;
            font-weight: 900; font-size: .8rem; letter-spacing: .05em; text-transform: uppercase;
            box-shadow: 0 8px 32px rgba(30,58,138,.25);
            opacity: 0; transform: translateY(1rem);
            transition: opacity .3s, transform .3s;
            pointer-events: none;
        }
        #hcToast.visible { opacity: 1; transform: translateY(0); }
    </style>
</asp:Content>

<%-- ══ Main content ══ --%>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hfDeleteId"    runat="server" />
    <asp:HiddenField ID="hfDeleteTitle" runat="server" />

    <%-- ══ DELETE MODAL ══ --%>
    <div id="hcDeleteModal" onclick="hcBgClick(event)">
        <div class="bg-white w-full max-w-xl rounded-[2.5rem] shadow-[0_35px_60px_-15px_rgba(0,0,0,0.3)] overflow-hidden border border-slate-100"
             onclick="event.stopPropagation()">

            <div class="bg-red-50 pt-12 pb-8 flex flex-col items-center">
                <div class="w-20 h-20 bg-white rounded-full flex items-center justify-center shadow-lg mb-6 border-2 border-red-100">
                    <span class="material-symbols-outlined" style="font-size:2.5rem;color:#ef4444;font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 48">delete</span>
                </div>
                <h3 class="text-3xl font-black text-math-dark-blue uppercase tracking-tight italic">Delete Help Entry?</h3>
            </div>

            <div class="px-10 pt-8 pb-6 space-y-6">
                <p class="text-slate-600 text-center text-base leading-relaxed">
                    You are about to permanently remove this entry. This action cannot be undone.
                </p>

                <div class="bg-slate-50 border border-slate-100 rounded-2xl p-6 text-center">
                    <p class="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 mb-2">Entry Scheduled for Removal</p>
                    <p id="hcDeleteTitle" class="text-slate-800 italic font-semibold text-lg">"..."</p>
                </div>

                <div class="grid grid-cols-2 gap-4 pt-2">
                    <button type="button" onclick="hcCloseDelete()"
                        class="bg-white text-slate-500 border-2 border-slate-200 font-black py-4 rounded-2xl hover:bg-slate-50 transition-all uppercase tracking-widest text-sm">
                        Cancel
                    </button>
                    <asp:LinkButton ID="btnConfirmHcDelete" runat="server"
                        OnClick="btnConfirmHcDelete_Click"
                        CssClass="bg-red-500 text-white font-black py-4 rounded-2xl uppercase tracking-widest text-sm flex items-center justify-center transition-all hover:bg-red-600"
                        style="box-shadow:0 4px 0 0 #b91c1c;display:flex"
                        OnClientClick="if(!hcConfirmDeleteReady()){return false;}">
                        Confirm Delete
                    </asp:LinkButton>
                </div>
            </div>

            <div class="px-10 pb-8">
                <div class="flex items-center justify-center gap-2 text-slate-400 text-[10px] font-black uppercase tracking-[0.15em]">
                    <span class="material-symbols-outlined" style="font-size:14px">verified_user</span>
                    Security Clearance: Level 4 Admin Required
                </div>
            </div>
        </div>
    </div>

        <%-- ══ PAGE HEADER ══ --%>
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-16 -top-16 size-52 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-48 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">support_agent</span>
                    Help Center Hub
                </div>
                <h1 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Help Center Management</h1>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Create and manage support articles, FAQs, and documentation for users across the platform.
                </p>
            </div>
            <div class="flex flex-col items-start gap-4 sm:flex-row sm:items-center xl:justify-end">
                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm min-w-[180px]">
                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Published</p>
                    <p class="mt-2 text-2xl font-black text-math-dark-blue"><asp:Literal ID="litArticleCount" runat="server" Text="0" /></p>
                </div>
                <a href="helpCenter.aspx"
                   class="inline-flex items-center gap-3 rounded-[1.75rem] bg-primary px-8 py-4 text-sm font-black uppercase tracking-[0.18em] text-math-dark-blue shadow-[0_12px_24px_rgba(249,208,6,0.22)] transition-all hover:-translate-y-0.5 hover:bg-yellow-400">
                    <span class="material-symbols-outlined fill-icon">add_circle</span>
                    Create New Entry
                </a>
            </div>
        </div>
    </section>

    <%-- ══ SEARCH / FILTER ══ --%>
    <section class="mb-10">
        <div class="rounded-[2.25rem] border border-white/80 bg-white/90 p-5 shadow-[0_18px_40px_rgba(30,58,138,0.08)] backdrop-blur-sm">
            <div class="flex flex-col gap-4 xl:flex-row xl:items-center">
                <div class="relative flex-1">
                    <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-math-blue text-xl">search</span>
                    <input id="hcSearch"
                           class="w-full rounded-[1.5rem] border-2 border-gray-100 bg-gray-50 pl-12 pr-4 py-4 text-base font-semibold text-math-dark-blue placeholder-gray-300 outline-none transition-all focus:border-math-blue"
                           placeholder="Search entries, keywords, or categories..."
                           type="text"
                           oninput="hcApplyFilters()" />
                </div>
                <div class="flex flex-col gap-3 sm:flex-row sm:items-center xl:flex-shrink-0">
                    <div class="relative min-w-[220px]">
                        <select id="hcCategory"
                                class="w-full appearance-none rounded-[1.5rem] border-2 border-gray-100 bg-gray-50 px-5 pr-14 py-4 text-xs font-black uppercase tracking-[0.18em] text-math-dark-blue outline-none transition-all focus:border-math-blue cursor-pointer"
                                style="-webkit-appearance:none;-moz-appearance:none;appearance:none;background-image:none;"
                                onchange="hcApplyFilters()">
                            <option value="">All Categories</option>
                            <option value="account">Account</option>
                            <option value="courses">Courses</option>
                            <option value="payments">Payments</option>
                            <option value="technical">Technical</option>
                            <option value="draft">Draft</option>
                            <option value="published">Published</option>
                        </select>
                        <span class="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-math-blue fill-icon">expand_more</span>
                    </div>
                    <button type="button" onclick="hcApplyFilters()"
                            class="inline-flex items-center justify-center rounded-[1.5rem] bg-math-blue px-6 py-4 text-xs font-black uppercase tracking-[0.18em] text-white transition-all hover:bg-math-dark-blue">
                        Filter
                    </button>
                </div>
            </div>
        </div>
    </section>

    <%-- ══ ONE COLUMN : ARTICLES ══ --%>
    <div class="grid grid-cols-1 gap-8 mb-16">

        <%-- Articles column --%>
        <div class="space-y-6">
            <div class="flex items-center justify-between px-2">
                <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight flex items-center gap-2">
                    <span class="material-symbols-outlined text-math-green">article</span>
                    Help Articles
                </h3>
                <span class="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                    Article Library
                </span>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            <asp:Repeater ID="rptArticles" runat="server" OnItemDataBound="rptArticles_ItemDataBound">
                <ItemTemplate>
                    <asp:Literal ID="litCard" runat="server"></asp:Literal>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <%-- ══ STAT CARDS ══ --%>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div class="bg-blue-50 border-4 border-math-blue/10 rounded-3xl p-6 flex items-center gap-6 hover:border-math-blue/30 transition-all">
            <div class="size-14 bg-white rounded-2xl flex items-center justify-center text-math-blue shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">person_celebrate</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-math-blue uppercase tracking-widest">Growth</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    +<asp:Literal ID="litGrowth" runat="server" Text="0" />
                    <span class="text-sm font-bold opacity-60">This Week</span>
                </div>
            </div>
        </div>

        <div class="bg-green-50 border-4 border-math-green/10 rounded-3xl p-6 flex items-center gap-6 hover:border-math-green/30 transition-all">
            <div class="size-14 bg-white rounded-2xl flex items-center justify-center text-math-green shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">how_to_reg</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-math-green uppercase tracking-widest">Active Rate</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litActiveRate" runat="server" Text="0%" />
                    <span class="text-sm font-bold opacity-60">Verified</span>
                </div>
            </div>
        </div>

        <div class="bg-yellow-50 border-4 border-primary/10 rounded-3xl p-6 flex items-center gap-6 hover:border-primary/30 transition-all">
            <div class="size-14 bg-white rounded-2xl flex items-center justify-center text-primary shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">shield_person</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-primary uppercase tracking-widest">Staff Count</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litStaffCount" runat="server" Text="0" />
                    <span class="text-sm font-bold opacity-60">Privileged</span>
                </div>
            </div>
        </div>
    </div>

    <%-- ══ TOAST ══ --%>
    <div id="hcToast"></div>

    <script>
        // ── Filters ──────────────────────────────────────────────────────
        function hcApplyFilters() {
            var q = (document.getElementById('hcSearch').value || '').toLowerCase().trim();
            var cat = (document.getElementById('hcCategory').value || '').toLowerCase().trim();
            var cards = document.querySelectorAll('[data-hc-card="1"]');
            var faqN = 0, artN = 0;

            cards.forEach(function (c) {
                var text = (c.getAttribute('data-search') || '').toLowerCase();
                var ccat = (c.getAttribute('data-cat') || '').toLowerCase();
                var type = (c.getAttribute('data-type') || '').toLowerCase();
                var show = (!q || text.includes(q)) && (!cat || ccat === cat);
                c.style.display = show ? '' : 'none';
                if (show) { if (type === 'faq') faqN++; else artN++; }
            });
        }

        document.addEventListener('DOMContentLoaded', hcApplyFilters);

        function hcEdit(id) {
            window.location.href = 'helpCenter.aspx?edit=' + encodeURIComponent(id);
        }

        // ── Delete modal ─────────────────────────────────────────────────
        var _hcDeleteReady = false;

        function hcDelete(id, title) {
            document.getElementById('<%= hfDeleteId.ClientID %>').value    = id;
            document.getElementById('<%= hfDeleteTitle.ClientID %>').value = title;
            document.getElementById('hcDeleteTitle').textContent = '\u201c' + decodeURIComponent(title) + '\u201d';
            _hcDeleteReady = true;
            document.getElementById('hcDeleteModal').classList.add('open');
            document.body.style.overflow = 'hidden';
        }

        function hcCloseDelete() {
            document.getElementById('hcDeleteModal').classList.remove('open');
            document.body.style.overflow = '';
            _hcDeleteReady = false;
        }

        function hcConfirmDeleteReady() { return _hcDeleteReady; }

        function hcBgClick(e) {
            if (e.target === document.getElementById('hcDeleteModal')) hcCloseDelete();
        }

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') hcCloseDelete();
        });

        // ── Toast ────────────────────────────────────────────────────────
        function showHcToast(msg) {
            var el = document.getElementById('hcToast');
            el.textContent = msg;
            el.classList.add('visible');
            setTimeout(function () { el.classList.remove('visible'); }, 3200);
        }
    </script>

</asp:Content>



