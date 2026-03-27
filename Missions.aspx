<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
    CodeBehind="Missions.aspx.cs" Inherits="Assignment.Missions" %>
<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Missions • MathSphere
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
    <div class="page-enter">
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-3 max-w-3xl">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">flag</span>
                Mission tracker
            </div>
            <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Your Missions</h2>
            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Pick up the modules you have already started, see which rewards are active, and keep your progress moving forward.</p>
        </div>
    </section>

    <!-- Empty state -->
    <asp:Panel ID="pnlNoMissions" runat="server" Visible="false"
        CssClass="surface-card p-10 text-center">
        <div class="mx-auto size-16 rounded-3xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center mb-4">
            <span class="material-symbols-outlined text-math-blue text-4xl fill-icon">task_alt</span>
        </div>
        <div class="text-2xl font-black text-math-dark-blue">No active missions yet</div>
        <div class="mt-2 text-gray-500 font-semibold">Start a module and it will appear here.</div>
        <a href="BrowseModule.aspx"
           class="inline-flex mt-6 items-center justify-center px-6 py-3 rounded-2xl bg-math-blue text-white font-black
                  uppercase tracking-widest text-sm shadow-lg shadow-math-blue/20 hover:bg-math-dark-blue transition-all">
            Browse Modules
        </a>
    </asp:Panel>

    <!-- Live SystemSettings point values banner -->
    <asp:Panel ID="pnlSettingsBanner" runat="server" CssClass="mb-6 flex flex-wrap gap-3">
        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                     bg-math-blue/10 border border-math-blue/10
                     text-math-blue text-[11px] font-black uppercase tracking-widest">
            <span class="material-symbols-outlined text-sm fill-icon">style</span>
            Flashcard Reward: +<asp:Literal ID="litFlashcardPts" runat="server" /> pts
        </span>
        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                     bg-math-green/10 border border-math-green/10
                     text-math-green text-[11px] font-black uppercase tracking-widest">
            <span class="material-symbols-outlined text-sm fill-icon">quiz</span>
            Quiz Bonus: +<asp:Literal ID="litQuizPts" runat="server" /> pts
        </span>
        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                     bg-primary/20 border border-primary/30
                     text-math-dark-blue text-[11px] font-black uppercase tracking-widest">
            <span class="material-symbols-outlined text-sm fill-icon">local_fire_department</span>
            7-Day Streak: +<asp:Literal ID="litStreakPts" runat="server" /> pts
        </span>
    </asp:Panel>

    <!-- Missions grid -->
    <asp:Repeater ID="rptMissions" runat="server">
        <HeaderTemplate>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        </HeaderTemplate>
        <ItemTemplate>
            <a href='<%# "moduleOverview.aspx?moduleId=" + Eval("moduleID") %>'
               class="surface-card p-6 group cursor-pointer block">

                <div class="flex justify-between items-start mb-6">
                    <div class='<%# "w-16 h-16 rounded-2xl text-white flex items-center justify-center shadow-lg " + Eval("AccentClass") %>'>
                        <span class="material-symbols-outlined text-4xl fill-icon"><%# Eval("Icon") %></span>
                    </div>
                    <span class='<%# "badge-pill " + Eval("BadgeClass") %>'>
                        <%# Eval("courseName") %>
                    </span>
                </div>

                <h4 class="text-2xl font-black mb-2 text-math-dark-blue group-hover:text-math-blue transition-colors">
                    <%# Eval("moduleTitle") %>
                </h4>
                <p class="text-gray-500 text-sm mb-6 font-semibold leading-relaxed">
                    <%# Eval("moduleDescription") %>
                </p>

                <div class="space-y-2">
                    <div class="flex justify-between text-sm font-black">
                        <span class="text-gray-700">Progress</span>
                        <span class="text-math-blue"><%# Eval("progress") %>%</span>
                    </div>
                    <div class="h-3 w-full bg-gray-100 rounded-full overflow-hidden border border-gray-200">
                        <div class="h-full bg-math-blue rounded-full transition-all duration-500"
                             style='<%# "width:" + Eval("progress") + "%;" %>'></div>
                    </div>
                </div>

                <!-- Live XP reward hint from SystemSettings -->
                <div class="mt-5">
                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full
                                 bg-primary/20 border border-primary/30
                                 text-math-dark-blue text-[10px] font-black uppercase tracking-widest">
                        <span class="material-symbols-outlined text-sm fill-icon">bolt</span>
                        Flashcards in this module: +<%# Eval("FlashcardPts") %> pts
                    </span>
                </div>

            </a>
        </ItemTemplate>
        <FooterTemplate>
            </div>
        </FooterTemplate>
    </asp:Repeater>
    </div>
</asp:Content>



