<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true" CodeBehind="Leaderboard.aspx.cs" Inherits="Assignment.Leaderboard" %>

<asp:Content ID="Title" ContentPlaceHolderID="TitleContent" runat="server">
    Leaderboard - MathSphere
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
<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-enter">
    <div class="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-12">

        <!-- SIDEBAR -->
        <aside class="space-y-6">
    <div class="surface-card p-6">
        <div class="flex items-start justify-between mb-5">
            <div>
                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">How It Works</p>
                <h3 class="text-lg font-black tracking-tight text-math-dark-blue mt-1">Ranking Guide</h3>
            </div>
            <div class="size-10 rounded-2xl bg-math-blue/10 flex items-center justify-center border border-math-blue/10">
                <span class="material-symbols-outlined text-math-blue fill-icon">insights</span>
            </div>
        </div>

        <div class="space-y-4 text-sm font-semibold text-gray-600 leading-relaxed">
            <div class="rounded-2xl border border-gray-100 bg-gray-50/80 p-4">
                <p class="font-black text-math-dark-blue mb-1">Points Mode</p>
                <p>Ranks students by total XP earned across activities and modules.</p>
            </div>
            <div class="rounded-2xl border border-gray-100 bg-gray-50/80 p-4">
                <p class="font-black text-math-dark-blue mb-1">Streak Mode</p>
                <p>Ranks students by best streak, with current streak shown beside it.</p>
            </div>
            <div class="rounded-2xl border border-primary/20 bg-primary/10 p-4 text-math-dark-blue">
                <p class="font-black mb-1">Scope</p>
                <p>This board shows the global student ranking.</p>
            </div>
        </div>
    </div>
</aside>

        <!-- MAIN -->
        <asp:UpdatePanel ID="upLeaderboardMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
        <main class="space-y-10">

            <!-- Header -->
            <div class="text-center">
                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 mb-3">Performance Overview</p>
                <h2 class="text-5xl font-black text-math-dark-blue uppercase tracking-tight mb-6">
                    Student Leaderboard
                </h2>
                <p class="text-xl text-math-blue font-bold uppercase tracking-[0.3em]">
                    Track how students are performing overall
                </p>
            </div>

            <!-- TAB SWITCHER — Points vs Streak -->
            <div class="flex justify-center">
                <div class="text-center mb-4">
                    <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Ranking Mode</p>
                    <p class="text-sm font-semibold text-gray-500 mt-1">Switch between total XP and best streak.</p>
                </div>
            </div>

            <div class="flex justify-center">
                <div class="inline-flex items-center gap-3 p-2 bg-gray-100/80 rounded-[2rem] border border-gray-200 shadow-inner ring-1 ring-white/70">

                    <%-- Points tab --%>
                    <asp:LinkButton ID="btnTabPoints" runat="server" OnClick="btnTabPoints_Click"
                        CssClass='<%# TabPointsCss %>'>
                        <span class="material-symbols-outlined text-base fill-icon">star</span>
                        Points
                    </asp:LinkButton>

                    <%-- Streak tab --%>
                    <asp:LinkButton ID="btnTabStreak" runat="server" OnClick="btnTabStreak_Click"
                        CssClass='<%# TabStreakCss %>'>
                        <span class="material-symbols-outlined text-base fill-icon">local_fire_department</span>
                        Streak
                    </asp:LinkButton>

                </div>
            </div>

            <!-- TOP 3 PODIUM -->
            <div class="max-w-5xl mx-auto">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 items-stretch md:items-end">

                    <!-- Rank 2 -->
                    <div class="order-2 md:order-1 surface-card p-6 rounded-[2.25rem] text-center flex flex-col items-center min-h-[280px] justify-between">
                        <div class="w-full">
                            <span class="badge-pill bg-math-blue/10 text-math-blue border border-math-blue/10 mb-5 inline-flex mx-auto">
                                Rank 2
                            </span>
                            <asp:Image ID="imgRank2" runat="server"
                                CssClass="size-20 rounded-[1.75rem] object-cover bg-gray-100 mx-auto shadow-lg shadow-math-blue/10"
                                ImageUrl="~/Image/default-avatar.png" />
                            <div class="font-black text-2xl text-math-dark-blue mt-4 tracking-tight">
                                <asp:Literal ID="litRank2Name" runat="server" />
                            </div>
                        </div>
                        <div class="grid grid-cols-2 gap-3 w-full mt-6">
                            <div class="rounded-2xl border border-gray-100 bg-gray-50/90 px-4 py-3 text-left">
                                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400"><asp:Literal ID="litPodiumLabel2" runat="server" Text="Score" /></p>
                                <p class="text-sm font-black text-math-blue mt-1 leading-tight"><asp:Literal ID="litRank2XP" runat="server" /></p>
                            </div>
                            <div class="rounded-2xl border border-math-blue/10 bg-white px-4 py-3 text-left">
                                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400">Current</p>
                                <div class="mt-1 flex items-center justify-center md:justify-start gap-1.5 text-sm font-black text-math-blue leading-tight"><span><asp:Literal ID="litRank2Streak" runat="server" />D</span><span class="text-[14px] leading-none" aria-hidden="true">&#128293;</span></div>
                            </div>
                        </div>
                    </div>

                    <!-- Rank 1 -->
                    <div class="order-1 md:order-2 surface-card p-8 rounded-[2.75rem] text-center flex flex-col items-center min-h-[320px] justify-between relative overflow-hidden ring-1 ring-primary/25 shadow-[0_20px_60px_rgba(250,204,21,0.18)]">
                        <div class="absolute -top-20 -right-20 size-64 rounded-full bg-primary/15 blur-3xl"></div>
                        <div class="absolute -bottom-24 -left-24 size-72 rounded-full bg-primary/10 blur-3xl"></div>
                        <div class="relative z-10 w-full">
                            <span class="badge-pill bg-primary/20 text-math-dark-blue border border-primary/30 mb-5 inline-flex mx-auto gap-2">
                                <span class="material-symbols-outlined text-[16px]">workspace_premium</span>
                                Champion
                            </span>
                            <asp:Image ID="imgRank1" runat="server"
                                CssClass="size-24 rounded-[2rem] object-cover bg-gray-100 mx-auto shadow-[0_16px_35px_rgba(250,204,21,0.28)] border-4 border-white"
                                ImageUrl="~/Image/default-avatar.png" />
                            <div class="font-black text-[2rem] text-math-dark-blue mt-5 tracking-tight">
                                <asp:Literal ID="litRank1Name" runat="server" />
                            </div>
                        </div>
                        <div class="relative z-10 grid grid-cols-2 gap-4 w-full mt-6">
                            <div class="rounded-[1.6rem] bg-primary text-math-dark-blue px-5 py-4 text-left shadow-lg shadow-primary/20">
                                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-math-dark-blue/60"><asp:Literal ID="litPodiumLabel1" runat="server" Text="Score" /></p>
                                <p class="text-sm font-black mt-1 leading-tight"><asp:Literal ID="litRank1XP" runat="server" /></p>
                            </div>
                            <div class="rounded-[1.6rem] border border-primary/20 bg-white/90 backdrop-blur px-5 py-4 text-left">
                                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400">Current</p>
                                <div class="mt-1 flex items-center justify-center md:justify-start gap-1.5 text-sm font-black text-math-blue leading-tight"><span><asp:Literal ID="litRank1Streak" runat="server" />D</span><span class="text-[14px] leading-none" aria-hidden="true">&#128293;</span></div>
                            </div>
                        </div>
                    </div>

                    <!-- Rank 3 -->
                    <div class="order-3 surface-card p-6 rounded-[2.25rem] text-center flex flex-col items-center min-h-[280px] justify-between">
                        <div class="w-full">
                            <span class="badge-pill bg-math-green/10 text-math-green border border-math-green/10 mb-5 inline-flex mx-auto">
                                Rank 3
                            </span>
                            <asp:Image ID="imgRank3" runat="server"
                                CssClass="size-20 rounded-[1.75rem] object-cover bg-gray-100 mx-auto shadow-lg shadow-math-green/10"
                                ImageUrl="~/Image/default-avatar.png" />
                            <div class="font-black text-2xl text-math-dark-blue mt-4 tracking-tight">
                                <asp:Literal ID="litRank3Name" runat="server" />
                            </div>
                        </div>
                        <div class="grid grid-cols-2 gap-3 w-full mt-6">
                            <div class="rounded-2xl border border-gray-100 bg-gray-50/90 px-4 py-3 text-left">
                                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400"><asp:Literal ID="litPodiumLabel3" runat="server" Text="Score" /></p>
                                <p class="text-sm font-black text-math-green mt-1 leading-tight"><asp:Literal ID="litRank3XP" runat="server" /></p>
                            </div>
                            <div class="rounded-2xl border border-math-green/10 bg-white px-4 py-3 text-left">
                                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400">Current</p>
                                <div class="mt-1 flex items-center justify-center md:justify-start gap-1.5 text-sm font-black text-math-green leading-tight"><span><asp:Literal ID="litRank3Streak" runat="server" />D</span><span class="text-[14px] leading-none" aria-hidden="true">&#128293;</span></div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
            <div class="max-w-4xl mx-auto surface-card overflow-hidden">

                <%-- Header row --%>
                <div class="px-6 py-5 border-b border-gray-100 flex items-center justify-between">
                    <div>
                        <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Live Ranking</p>
                        <h3 class="text-lg font-black text-math-dark-blue mt-1">Student Rankings</h3>
                    </div>
                    <%-- Dynamic column label --%>
                    <span class="text-[11px] font-black uppercase tracking-[0.2em] text-gray-400 pr-2">
                        <asp:Literal ID="litSortLabel" runat="server" Text="XP" />
                    </span>
                </div>

                <asp:Repeater ID="rptLeaderboard" runat="server">
                    <ItemTemplate>
                        <div class="surface-soft m-4 p-5 group transition-all hover:-translate-y-[1px]">
                            <div class="grid grid-cols-1 md:grid-cols-[80px_1fr_160px_160px] gap-4 items-center">

                                <%-- Rank number --%>
                                <div class="font-black text-gray-400 group-hover:text-math-blue transition-colors">
                                    #<%# Eval("Rank") %>
                                </div>

                                <%-- Name + avatar --%>
                                <div class="flex items-center gap-4">
                                    <asp:Image ID="imgRowAvatar" runat="server"
                                        CssClass="size-12 rounded-2xl object-cover"
                                        ImageUrl='<%# ResolveAvatar(Eval("AvatarUrl").ToString()) %>' />
                                    <div>
                                        <div class="font-black text-math-dark-blue"><%# Eval("Name") %></div>
                                        <div class="text-xs font-bold text-gray-400 mt-0.5">
                                            Best streak: <%# Eval("BestStreak") %>d <span class="material-symbols-outlined fill-icon text-[14px] leading-none align-[-2px]">emoji_events</span>
                                        </div>
                                    </div>
                                </div>

                                <%-- Current streak --%>
                                <div class="flex items-center justify-center gap-2 text-orange-500 font-black">
                                    <span class="text-base leading-none">&#128293;</span><span><%# Eval("DisplayStreak") %>D now</span>
                                </div>

                                <%-- Primary stat: XP on points tab, BestStreak on streak tab --%>
                                <div class="md:text-right">
                                    <span class="badge-pill bg-math-blue/10 border border-math-blue/10 text-math-dark-blue">
                                        <%# ActiveTab == "streak" ? (Eval("BestStreak").ToString() + "D best") : (Convert.ToInt32(Eval("XP")).ToString("N0") + " XP") %>
                                    </span>
                                </div>

                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <div class="p-6 pt-2 flex justify-center">
                    <asp:LinkButton ID="btnLoadMore" runat="server" OnClick="btnLoadMore_Click"
                        CssClass="inline-flex items-center justify-center gap-2 px-8 py-3 rounded-2xl
                                  bg-white border border-gray-200 text-math-dark-blue font-black
                                  uppercase tracking-widest text-[11px]
                                  hover:bg-gray-50 transition-all shadow-sm"
                        Visible="false">
                        Load More
                        <span class="material-symbols-outlined text-base">expand_more</span>
                    </asp:LinkButton>
                </div>

            </div>

        </main>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <%-- Bind tab CSS on every page load so active state renders correctly --%>
    <script>
        // Re-apply tab styles after postback (Tailwind purge can drop dynamic classes)
        // No action needed — CSS is rendered server-side via TabPointsCss / TabStreakCss
    </script>

    </div>
</asp:Content>



















