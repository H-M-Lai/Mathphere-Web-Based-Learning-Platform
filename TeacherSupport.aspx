<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="TeacherSupport.aspx.cs" Inherits="MathSphere.TeacherSupport" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">Help Center</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
<style>
    #articleModal {
        position:fixed;inset:0;z-index:9000;
        background:rgba(15,23,42,.6);backdrop-filter:blur(6px);
        display:none;align-items:center;justify-content:center;padding:1.5rem;
    }
    #articleModal.open { display:flex !important; }
    #articleModalBody { max-height:65vh; overflow-y:auto; }
    .art-card { transition:transform .18s,box-shadow .18s; }
    .art-card:hover { transform:translateY(-4px);box-shadow:0 20px 40px rgba(37,99,235,.12); }
</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- ARTICLE MODAL --%>
    <div id="articleModal" onclick="spBgClick(event)">
        <div class="bg-white w-full max-w-2xl rounded-[2.5rem] shadow-[0_35px_60px_-15px_rgba(0,0,0,0.3)] overflow-hidden border border-slate-100"
             onclick="event.stopPropagation()">
            <div class="bg-math-blue px-10 pt-10 pb-8">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <div id="modalBadge" class="inline-block px-3 py-1 bg-white/20 text-white rounded-full text-[10px] font-black uppercase tracking-widest mb-3"></div>
                        <h3 id="modalTitle" class="text-2xl font-black text-white uppercase tracking-tight italic leading-tight"></h3>
                    </div>
                    <button type="button" onclick="spCloseArticle()"
                            class="size-10 flex-shrink-0 bg-white/20 hover:bg-white/30 rounded-2xl flex items-center justify-center text-white transition-colors mt-1">
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
    <div class="mb-12">
        <div class="inline-flex items-center gap-2 bg-math-blue/10 text-math-blue px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-widest mb-5">
            <span class="material-symbols-outlined text-base fill-icon">support_agent</span>
            Help Center
        </div>
        <h1 class="text-5xl font-black text-math-dark-blue uppercase tracking-tighter italic leading-none mb-3">
            How can we help?
        </h1>
        <p class="text-gray-500 font-medium text-lg max-w-xl">
            Browse our support articles below. If you still need help, you can email your administrator directly.
        </p>
    </div>

    <%-- SEARCH BAR --%>
    <section class="mb-12">
        <div class="bg-white border-4 border-math-blue rounded-3xl p-4 flex items-center gap-4 shadow-xl max-w-2xl">
            <span class="material-symbols-outlined text-math-blue ml-2 text-2xl">search</span>
            <input id="artSearch" type="text" placeholder="Search help articles…"
                   oninput="spFilterArticles()"
                   class="flex-1 border-none focus:ring-0 text-base font-medium text-math-dark-blue placeholder-gray-300 bg-transparent outline-none" />
            <button type="button" onclick="spFilterArticles()"
                    class="bg-math-blue text-white px-6 py-2 rounded-xl font-bold uppercase tracking-widest text-xs hover:bg-math-dark-blue transition-colors">
                Search
            </button>
        </div>
    </section>

    <%-- ARTICLES --%>
    <section class="mb-16">
        <div class="flex items-center justify-between mb-6 px-1">
            <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight flex items-center gap-2">
                <span class="material-symbols-outlined text-math-blue fill-icon">article</span>
                Help Articles
            </h2>
            <span id="artCount" class="text-[10px] font-black text-gray-400 uppercase tracking-widest"></span>
        </div>

        <div id="artEmpty" style="display:none;"
             class="text-center py-20 bg-white rounded-[2rem] border-2 border-dashed border-gray-200">
            <span class="material-symbols-outlined text-6xl text-gray-200 fill-icon">search_off</span>
            <p class="text-gray-400 font-bold mt-4 uppercase tracking-widest text-sm">No articles match your search</p>
            <p class="text-gray-300 text-xs font-medium mt-1">Try a different keyword, or email us below.</p>
        </div>

        <div id="artGrid" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            <asp:Repeater ID="rptArticles" runat="server" OnItemDataBound="rptArticles_ItemDataBound">
                <ItemTemplate>
                    <asp:Literal ID="litArticle" runat="server" />
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Panel ID="pnlNoArticles" runat="server" Visible="false"
            CssClass="text-center py-20 bg-white rounded-[2rem] border-2 border-dashed border-gray-200">
            <span class="material-symbols-outlined text-6xl text-gray-200 fill-icon">article</span>
            <p class="text-gray-400 font-bold mt-4 uppercase tracking-widest text-sm">No articles published yet</p>
            <p class="text-gray-300 text-xs font-medium mt-1">Our team is working on it — check back soon.</p>
        </asp:Panel>
    </section>

    <%-- STILL NEED HELP --%>
    <section class="mb-8">
        <div class="bg-math-dark-blue rounded-[2rem] p-8 md:p-10 flex flex-col md:flex-row items-center justify-between gap-8">
            <div class="flex items-center gap-5">
                <div class="size-16 bg-white/10 rounded-2xl flex items-center justify-center flex-shrink-0">
                    <span class="material-symbols-outlined fill-icon text-3xl text-primary">mail</span>
                </div>
                <div>
                    <h3 class="text-xl font-black text-white uppercase tracking-tight mb-1">Still need help?</h3>
                    <p class="text-blue-300 font-medium text-sm leading-relaxed max-w-md">
                        Can't find what you're looking for? Send an email and your administrator will get back to you shortly.
                    </p>
                    <p class="text-blue-200/60 text-xs font-bold mt-2 uppercase tracking-widest">
                        <asp:Literal ID="litAdminEmail" runat="server" />
                    </p>
                </div>
            </div>
            <asp:HyperLink ID="lnkEmailAdmin" runat="server"
                CssClass="flex-shrink-0 inline-flex items-center gap-2 bg-primary hover:bg-yellow-400 text-math-dark-blue font-black px-8 py-4 rounded-2xl uppercase tracking-widest text-sm shadow-lg transition-colors">
                <span class="material-symbols-outlined text-base">send</span>
                Email Admin
            </asp:HyperLink>
        </div>
    </section>

    <script>
        function spFilterArticles() {
            var q = (document.getElementById('artSearch').value || '').toLowerCase().trim();
            var cards = document.querySelectorAll('[data-art-card]');
            var visible = 0;
            cards.forEach(function (c) {
                var show = !q || (c.getAttribute('data-search') || '').toLowerCase().includes(q);
                c.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            var countEl = document.getElementById('artCount');
            if (countEl) countEl.textContent = visible + ' article' + (visible !== 1 ? 's' : '');
            var empty = document.getElementById('artEmpty');
            var grid  = document.getElementById('artGrid');
            if (empty && grid) {
                var noResults = visible === 0 && !!q;
                empty.style.display = noResults ? '' : 'none';
                grid.style.display  = noResults ? 'none' : '';
            }
        }
        document.addEventListener('DOMContentLoaded', spFilterArticles);

        function spOpenArticle(title, content, category, updatedAt) {
            document.getElementById('modalTitle').textContent   = title;
            document.getElementById('modalContent').textContent = content;
            document.getElementById('modalBadge').textContent   = category;
            document.getElementById('modalMeta').textContent    = updatedAt ? 'Last updated: ' + updatedAt : '';
            document.getElementById('articleModal').classList.add('open');
            document.body.style.overflow = 'hidden';
        }
        function spCloseArticle() {
            document.getElementById('articleModal').classList.remove('open');
            document.body.style.overflow = '';
        }
        function spBgClick(e) {
            if (e.target === document.getElementById('articleModal')) spCloseArticle();
        }
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') spCloseArticle();
        });
    </script>

</asp:Content>

