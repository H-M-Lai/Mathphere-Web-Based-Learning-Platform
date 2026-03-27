<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="Assignment.StudentDashboard" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Student Dashboard
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
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="space-y-3 max-w-3xl">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">dashboard</span>
                    Student overview
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">
                    Hi, <asp:Literal ID="litStudentName" runat="server" />
                </h2>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Here is a clear snapshot of your current progress, active modules, and the missions you can jump back into next.
                </p>
            </div>
            <div class="rounded-[2rem] border border-white/70 bg-white/85 px-6 py-5 shadow-[0_16px_34px_rgba(30,58,138,0.08)] min-w-[240px]">
                <div class="flex items-center gap-4">
                    <div class="size-12 rounded-2xl bg-math-blue/10 border border-math-blue/10 text-math-blue flex items-center justify-center">
                        <span class="material-symbols-outlined text-3xl fill-icon">emoji_events</span>
                    </div>
                    <div>
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Current Rank</div>
                        <div class="mt-1 text-xl font-black text-math-dark-blue">#<asp:Literal ID="litGlobalRank" runat="server" /> Global</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">

        <!-- Left Column -->
        <div class="lg:col-span-8 space-y-8">

            <!-- Missions -->
            <section>
                <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-8 gap-4">
                    <div class="flex items-center gap-4">
                        <h3 class="text-3xl font-black uppercase tracking-tight">Your Missions</h3>
                        <a class="hidden sm:inline-flex items-center gap-1 text-math-blue font-black text-xs uppercase tracking-widest no-underline hover:no-underline hover:translate-x-[4px] transition-transform"
                           href="Missions.aspx">
                            <span>View All</span>
                            <span class="material-symbols-outlined text-lg leading-none">chevron_right</span>
                        </a>
                    </div>
                </div>

                <!-- Empty state -->
                <asp:Panel ID="pnlNoMissions" runat="server" Visible="false"
                    CssClass="surface-card p-10 text-center">
                    <div class="mx-auto size-16 rounded-3xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center mb-4">
                        <span class="material-symbols-outlined text-math-blue text-4xl fill-icon">task_alt</span>
                    </div>
                    <div class="text-2xl font-black text-math-dark-blue">No active modules yet</div>
                    <div class="mt-2 text-gray-500 font-semibold">Start a module and it will appear here.</div>
                    <a href="BrowseModule.aspx"
                       class="inline-flex mt-6 items-center justify-center px-6 py-3 rounded-2xl bg-math-blue text-white font-black
                              uppercase tracking-widest text-sm shadow-lg shadow-math-blue/20 hover:bg-math-dark-blue transition-all">
                        Browse Modules
                    </a>
                </asp:Panel>

                <!-- Top 4 missions -->
                <asp:Repeater ID="rptTopMissions" runat="server">
                    <HeaderTemplate>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <a href='<%# "moduleOverview.aspx?moduleId=" + Eval("ModuleID") %>'
                           class="surface-card p-6 group cursor-pointer block">

                            <div class="flex justify-between items-start mb-6">
                                <div class='<%# "w-16 h-16 rounded-2xl text-white flex items-center justify-center shadow-lg " + Eval("AccentClass") %>'>
                                    <span class="material-symbols-outlined text-4xl fill-icon"><%# Eval("Icon") %></span>
                                </div>
                                <span class='<%# "badge-pill " + Eval("BadgeClass") %>'>
                                    <%# Eval("CourseName") %>
                                </span>
                            </div>

                            <h4 class="text-2xl font-black mb-2 text-math-dark-blue group-hover:text-math-blue transition-colors">
                                <%# Eval("ModuleTitle") %>
                            </h4>

                            <div class="text-gray-500 text-sm mb-6 font-semibold">
                                Module ID: <%# Eval("ModuleID") %>
                            </div>

                            <div class="space-y-2">
                                <div class="flex justify-between text-sm font-black">
                                    <span class="text-gray-700">Progress</span>
                                    <span class="text-math-blue"><%# Eval("Progress") %>%</span>
                                </div>
                                <div class="h-3 w-full bg-gray-100 rounded-full overflow-hidden border border-gray-200">
                                    <div class="h-full bg-math-blue rounded-full" style='<%# "width:" + Eval("Progress") + "%;" %>'></div>
                                </div>
                            </div>

                        </a>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </section>

            <!-- Quick Actions -->
            <section class="mt-8">
                <h3 class="text-xl font-black uppercase tracking-tight mb-4 text-math-dark-blue/60">Quick Actions</h3>

                <asp:LinkButton ID="btnReview" runat="server" OnClick="btnReview_Click"
                    CssClass="relative overflow-hidden group flex items-center justify-between
                              bg-gradient-to-br from-math-dark-blue via-math-blue to-math-blue text-white
                              p-6 rounded-[2.25rem]
                              shadow-[0_16px_45px_rgba(37,99,235,0.22)]
                              hover:shadow-[0_20px_55px_rgba(37,99,235,0.28)]
                              hover:-translate-y-[1px] transition-all">
                    <div class="absolute -top-20 -right-20 size-64 rounded-full bg-primary/15 blur-3xl"></div>
                    <div class="absolute -bottom-24 -left-24 size-72 rounded-full bg-white/10 blur-3xl"></div>

                    <div class="relative z-10 flex items-center gap-6">
                        <div class="bg-white/15 p-4 rounded-2xl group-hover:rotate-[4deg] transition-transform">
                            <span class="material-symbols-outlined text-4xl fill-icon">history_edu</span>
                        </div>
                        <div>
                            <div class="text-[11px] font-black opacity-80 uppercase tracking-[0.25em] mb-1">Review Center</div>
                            <div class="text-2xl font-black">Past Attempts</div>
                        </div>
                    </div>

                    <div class="relative z-10 flex items-center gap-4">
                        <span class="hidden sm:block text-sm font-bold opacity-70">See your previous results</span>
                        <div class="bg-white/10 size-12 rounded-full flex items-center justify-center group-hover:bg-white/15 transition-colors">
                            <span class="material-symbols-outlined font-bold group-hover:translate-x-1 transition-transform">arrow_forward</span>
                        </div>
                    </div>
                </asp:LinkButton>
            </section>

        </div>

        <!-- Right Sidebar -->
        <div class="lg:col-span-4 space-y-8">

            <!-- Leaderboard -->
            <section class="surface-card p-6 relative overflow-hidden">
                <div class="relative z-10">
                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center gap-3">
                            <span class="material-symbols-outlined text-math-blue text-3xl fill-icon">leaderboard</span>
                            <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">Leaderboard</h3>
                        </div>
                        <span class="badge-pill bg-math-blue/10 text-math-blue border border-math-blue/10">
                            Global
                        </span>
                    </div>

                    <div class="space-y-3 mb-6">

                        <!-- Rank 1 -->
                        <div class="surface-soft p-3 flex items-center gap-4">
                            <div class="relative">
                                <div class="size-10 rounded-full p-0.5 bg-primary">
                                    <asp:Image ID="imgRank1" runat="server" CssClass="w-full h-full object-cover rounded-full bg-white" AlternateText="Rank 1" />
                                </div>
                                <span class="absolute -top-2 -right-2 text-xl">&#128081;</span>
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="font-black text-sm truncate"><asp:Literal ID="litRank1Name" runat="server" /></div>
                                <div class="text-[10px] font-black uppercase tracking-widest text-gray-400">
                                    <asp:Literal ID="litRank1XP" runat="server" /> XP
                                </div>
                            </div>
                            <div class="text-lg font-black text-primary">#1</div>
                        </div>

                        <!-- Rank 2 -->
                        <div class="surface-soft p-3 flex items-center gap-4">
                            <div class="size-10 rounded-full p-0.5 bg-gray-200">
                                <asp:Image ID="imgRank2" runat="server" CssClass="w-full h-full object-cover rounded-full bg-white" AlternateText="Rank 2" />
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="font-black text-sm truncate"><asp:Literal ID="litRank2Name" runat="server" /></div>
                                <div class="text-[10px] font-black uppercase tracking-widest text-gray-400">
                                    <asp:Literal ID="litRank2XP" runat="server" /> XP
                                </div>
                            </div>
                            <div class="text-lg font-black text-gray-400">#2</div>
                        </div>

                        <!-- Rank 3 -->
                        <div class="surface-soft p-3 flex items-center gap-4">
                            <div class="size-10 rounded-full p-0.5 bg-orange-200">
                                <asp:Image ID="imgRank3" runat="server" CssClass="w-full h-full object-cover rounded-full bg-white" AlternateText="Rank 3" />
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="font-black text-sm truncate"><asp:Literal ID="litRank3Name" runat="server" /></div>
                                <div class="text-[10px] font-black uppercase tracking-widest text-gray-400">
                                    <asp:Literal ID="litRank3XP" runat="server" /> XP
                                </div>
                            </div>
                            <div class="text-lg font-black text-orange-400">#3</div>
                        </div>

                        <!-- Current User -->
                        <div class="flex items-center gap-4 p-4 rounded-2xl bg-primary/60 border border-primary/40
                                    shadow-[0_12px_30px_rgba(249,208,6,0.18)]">
                            <div class="size-12 rounded-2xl overflow-hidden border border-math-dark-blue/20 bg-white/70">
                                <asp:Image ID="imgLeaderboardUser" runat="server" CssClass="w-full h-full object-cover bg-blue-100" AlternateText="You" />
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="font-black text-math-dark-blue text-base truncate">
                                    You (<asp:Literal ID="litStudentNameSide" runat="server" />)
                                </div>
                                <div class="text-[10px] font-black uppercase tracking-widest text-math-dark-blue/70">
                                    <asp:Literal ID="litSideXP" runat="server" /> XP
                                </div>
                            </div>
                            <div class="inline-flex items-center px-3 py-1.5 rounded-2xl bg-math-dark-blue text-primary font-black text-lg">
                                #<asp:Literal ID="litSideRank" runat="server" />
                            </div>
                        </div>

                    </div>

                    <asp:Button ID="btnFullLeaderboard" runat="server" Text="Full Leaderboard"
                        CssClass="w-full rounded-2xl bg-math-blue text-white font-black py-4 text-sm uppercase tracking-widest
                                  shadow-lg shadow-math-blue/20 hover:shadow-math-blue/30 hover:scale-[1.01]
                                  transition-all active:scale-[0.99]"
                        OnClick="btnFullLeaderboard_Click" />
                </div>

                <span class="material-symbols-outlined absolute -bottom-6 -right-6 text-[140px] text-math-blue/10">
                    workspace_premium
                </span>
            </section>

        </div>
    </div>

    </div>
</asp:Content>



