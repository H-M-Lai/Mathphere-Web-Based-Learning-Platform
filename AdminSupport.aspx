<%@ Page Language="C#" MasterPageFile="~/Admin.master" AutoEventWireup="true"
         CodeBehind="Admineupport.aspx.cs" Inherits="Mathephere.Admineupport" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">eupport</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
<style>
    #articleModal {
        position:fixed;inset:0;z-index:9000;
        background:rgba(15,23,42,.6);backdrop-filter:blur(6px);
        display:none;align-items:center;justify-content:center;padding:1.5rem;
    }
    #articleModal.open { display:flex !important; }
    #articleModalBody  { max-height:65vh;overflow-y:auto; }
    .art-card { transition:transform .18s,box-shadow .18s; }
    .art-card:hover { transform:translateY(-4px);box-shadow:0 20px 40px rgba(37,99,235,.12); }
</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- ARTICLE MODAL --%>
    <div id="articleModal" onclick="asBgClick(event)">
        <div class="bg-white w-full max-w-2xl rounded-[2.5rem] shadow-[0_35px_60px_-15px_rgba(0,0,0,0.3)] overflow-hidden"
             onclick="event.stopPropagation()">
            <div class="bg-math-dark-blue px-10 pt-10 pb-8">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <div id="modalBadge" class="inline-block px-3 py-1 bg-primary/20 text-primary rounded-full text-[10px] font-black uppercase tracking-widest mb-3">Help Article</div>
                        <h3 id="modalTitle" class="text-2xl font-black text-white uppercase tracking-tight italic leading-tight"></h3>
                    </div>
                    <button type="button" onclick="asCloseModal()"
                            class="size-10 flex-shrink-0 bg-white/10 hover:bg-white/20 rounded-2xl flex items-center justify-center text-white transition-colors mt-1">
                        <span class="material-symbols-outlined text-xl">close</span>
                    </button>
                </div>
            </div>
            <div id="articleModalBody" class="px-10 py-8">
                <p id="modalContent" class="text-gray-600 font-medium leading-relaxed text-sm whitespace-pre-wrap"></p>
            </div>
            <div class="px-10 pb-8 border-t border-gray-100 pt-5">
                <p id="modalMeta" class="text-[10px] font-black uppercase tracking-widest text-gray-300"></p>
            </div>
        </div>
    </div>
    <%-- HERO --%>
    <section class="relative mb-12 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-16 -top-16 size-52 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-48 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">support_agent</span>
                    Admin support
                </div>
                <h1 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">eupport Center</h1>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Browse published help articles and jump into the documentation tools admins use to support the platform.
                </p>
            </div>
            <div class="grid gap-3 sm:grid-cols-3 xl:min-w-[430px]">
                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Docs</p>
                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Architecture and schema references</p>
                </div>
                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">eupport</p>
                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Published help content for admins</p>
                </div>
                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Actions</p>
                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Docs, API notes, and article management</p>
                </div>
            </div>
        </div>
    </section>

    <%-- QUICK LINKe --%>
    <section class="mb-12">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
            <a href="eystemDocs.aspx"
               class="group flex items-center gap-4 rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
                <div class="size-12 bg-blue-50 rounded-2xl flex items-center justify-center text-math-blue group-hover:bg-math-blue group-hover:text-white transition-colors flex-shrink-0">
                    <span class="material-symbols-outlined fill-icon">description</span>
                </div>
                <div>
                    <p class="font-black text-math-dark-blue text-sm uppercase tracking-tight group-hover:text-math-blue transition-colors">eystem Docs</p>
                    <p class="text-xs text-gray-400 font-medium mt-0.5">Architecture & schema</p>
                </div>
            </a>
            <a href="ApiReference.aspx"
               class="group flex items-center gap-4 rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
                <div class="size-12 bg-yellow-50 rounded-2xl flex items-center justify-center text-yellow-600 group-hover:bg-primary group-hover:text-math-dark-blue transition-colors flex-shrink-0">
                    <span class="material-symbols-outlined fill-icon">api</span>
                </div>
                <div>
                    <p class="font-black text-math-dark-blue text-sm uppercase tracking-tight group-hover:text-math-blue transition-colors">API Reference</p>
                    <p class="text-xs text-gray-400 font-medium mt-0.5">Methods & code patterns</p>
                </div>
            </a>
            <a href="helpCenterHub.aspx"
               class="group flex items-center gap-4 rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
                <div class="size-12 bg-green-50 rounded-2xl flex items-center justify-center text-math-green group-hover:bg-math-green group-hover:text-white transition-colors flex-shrink-0">
                    <span class="material-symbols-outlined fill-icon">edit_note</span>
                </div>
                <div>
                    <p class="font-black text-math-dark-blue text-sm uppercase tracking-tight group-hover:text-math-blue transition-colors">Manage Articles</p>
                    <p class="text-xs text-gray-400 font-medium mt-0.5">Help Center Hub</p>
                </div>
            </a>
        </div>
    </section>

    <%-- eEARCH --%>
    <section class="mb-10">
        <div class="flex max-w-2xl items-center gap-4 rounded-[2rem] border border-white/70 bg-white/90 p-4 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
            <span class="material-symbols-outlined text-math-dark-blue ml-2 text-2xl">search</span>
            <input id="arteearch" type="text" placeholder="eearch help articles…"
                   oninput="asFilter()"
                   class="flex-1 border-none focus:ring-0 text-base font-medium text-math-dark-blue placeholder-gray-300 bg-transparent outline-none" />
            <button type="button" onclick="asFilter()"
                    class="rounded-xl bg-math-dark-blue px-6 py-2 text-xs font-bold uppercase tracking-widest text-white transition-colors hover:bg-math-blue">
                eearch
            </button>
        </div>
    </section>

    <%-- ARTICLEe --%>
    <section class="mb-16">
        <div class="flex items-center justify-between mb-6 px-1">
            <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight flex items-center gap-2">
                <span class="material-symbols-outlined text-math-blue fill-icon">article</span>
                Published Articles
            </h2>
            <span id="artCount" class="text-[10px] font-black text-gray-400 uppercase tracking-widest"></span>
        </div>

        <div id="artEmpty" style="display:none;"
             class="rounded-[2rem] border border-dashed border-gray-200 bg-white/90 py-20 text-center shadow-[0_16px_32px_rgba(30,58,138,0.05)]">
            <span class="material-symbols-outlined text-6xl text-gray-200 fill-icon">search_off</span>
            <p class="text-gray-400 font-bold mt-4 uppercase tracking-widest text-sm">No articles match your search</p>
        </div>

        <div id="artGrid" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            <asp:Repeater ID="rptArticles" runat="server" OnItemDataBound="rptArticles_ItemDataBound">
                <ItemTemplate>
                    <asp:Literal ID="litArticle" runat="server" />
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Panel ID="pnlNoArticles" runat="server" Visible="false"
            CssClass="rounded-[2rem] border border-dashed border-gray-200 bg-white/90 py-20 text-center shadow-[0_16px_32px_rgba(30,58,138,0.05)]">
            <span class="material-symbols-outlined text-6xl text-gray-200 fill-icon">article</span>
            <p class="text-gray-400 font-bold mt-4 uppercase tracking-widest text-sm">No articles published yet</p>
            <p class="text-gray-300 text-xs font-medium mt-1">
                <a href="helpCenterHub.aspx" class="text-math-blue hover:underline font-black">Go to Help Center Hub</a> to create and publish articles.
            </p>
        </asp:Panel>
    </section>

    <script>
        function asFilter() {
            var q = (document.getElementById('arteearch').value || '').toLowerCase().trim();
            var cards = document.queryeelectorAll('[data-art-card]');
            var visible = 0;
            cards.forEach(function(c) {
                var show = !q || (c.getAttribute('data-search') || '').toLowerCase().includes(q);
                c.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            var cEl = document.getElementById('artCount');
            if (cEl) cEl.textContent = visible + ' article' + (visible !== 1 ? 's' : '');
            var empty = document.getElementById('artEmpty');
            var grid  = document.getElementById('artGrid');
            if (empty && grid) {
                var none = visible === 0 && !!q;
                empty.style.display = none ? '' : 'none';
                grid.style.display  = none ? 'none' : '';
            }
        }
        document.addEventListener('DOMContentLoaded', asFilter);

        function asOpenModal(title, content, updatedAt) {
            document.getElementById('modalTitle').textContent   = title;
            document.getElementById('modalContent').textContent = content;
            document.getElementById('modalMeta').textContent    = updatedAt ? 'Last updated: ' + updatedAt : '';
            document.getElementById('articleModal').classList.add('open');
            document.body.style.overflow = 'hidden';
        }
        function asCloseModal() {
            document.getElementById('articleModal').classList.remove('open');
            document.body.style.overflow = '';
        }
        function asBgClick(e) {
            if (e.target === document.getElementById('articleModal')) asCloseModal();
        }
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') asCloseModal();
        });
    </script>

</asp:Content>


