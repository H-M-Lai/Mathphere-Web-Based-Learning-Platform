<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherAssignment.aspx.cs" Inherits="Assignment.TeacherAssignment" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head runat="server">
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere - Teacher Assigned Missions</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = {
    darkMode: "class",
    theme: {
        extend: {
            colors: {
                "primary": "#f9d006",
                "background-light": "#f8f8f5",
                "math-blue": "#2563eb",
                "math-green": "#84cc16",
                "math-dark-blue": "#1e3a8a",
            },
            fontFamily: {
                "display": ["Space Grotesk", "sans-serif"]
            },
            borderRadius: {
                "DEFAULT": "1rem",
                "lg": "2rem",
                "xl": "3rem",
                "full": "9999px"
            },
        },
    },
}
    </script>
    <style type="text/tailwindcss">
        @layer base {
            body {
                @apply bg-background-light font-display text-math-dark-blue;
                background-image: 
                    linear-gradient(rgba(0, 0, 0, 0.03) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(0, 0, 0, 0.03) 1px, transparent 1px);
                background-size: 40px 40px;
            }
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .fill-icon { font-variation-settings: 'FILL' 1; }
        .module-card { @apply transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl; }
    </style>
</head>
<body class="min-h-screen relative overflow-x-hidden flex flex-col">
    <form id="form1" runat="server">
        <!-- Background icons -->
        <div class="fixed inset-0 pointer-events-none opacity-20 overflow-hidden">
            <span class="material-symbols-outlined absolute text-6xl top-40 left-[5%] rotate-12 text-primary">add</span>
            <span class="material-symbols-outlined absolute text-8xl top-80 right-[8%] -rotate-12 text-primary">percent</span>
            <span class="material-symbols-outlined absolute text-7xl bottom-60 left-[12%] rotate-45 text-primary">equal</span>
            <span class="material-symbols-outlined absolute text-9xl bottom-20 right-[15%] -rotate-[30deg] text-primary">close</span>
            <span class="material-symbols-outlined absolute text-5xl top-1/4 right-1/3 rotate-12 text-primary">function</span>
        </div>

        <!-- Header -->
        <header class="sticky top-0 z-50 flex items-center justify-between bg-white/90 backdrop-blur-md border-b-4 border-math-blue/10 px-8 py-4">
            <div class="flex items-center gap-3">
                <a class="flex items-center gap-3" href="#">
                    <div class="size-10 bg-primary rounded-xl flex items-center justify-center shadow-lg transform -rotate-3 border-2 border-math-dark-blue/10">
                        <span class="material-symbols-outlined text-math-dark-blue font-bold text-2xl">variables</span>
                    </div>
                    <h1 class="text-math-dark-blue text-2xl font-black tracking-tighter italic">MATHSPHERE</h1>
                </a>
            </div>
            <div class="flex items-center gap-8">
                <nav class="hidden lg:flex items-center gap-8">
                    <a class="font-bold text-sm text-gray-500 hover:text-math-blue transition-colors uppercase tracking-wider" href="#">DASHBOARD</a>
                    <a class="font-black text-sm text-math-blue border-b-2 border-math-blue pb-1 uppercase tracking-wider" href="#">MISSIONS</a>
                    <a class="font-bold text-sm text-gray-500 hover:text-math-blue transition-colors uppercase tracking-wider" href="#">MODULE</a>
                    <a class="font-bold text-sm text-gray-500 hover:text-math-blue transition-colors uppercase tracking-wider" href="#">LEADERBOARD</a>
                    <a class="font-bold text-sm text-gray-500 hover:text-math-blue transition-colors uppercase tracking-wider" href="#">FORUM</a>
                    <a class="font-bold text-sm text-gray-500 hover:text-math-blue transition-colors uppercase tracking-wider" href="#">PROFILE</a>
                    <div class="flex items-center gap-4">
    <!-- 7 Day Streak -->
    <div class="bg-primary text-math-dark-blue px-5 py-2 rounded-full flex items-center gap-2 shadow-md">
        <span class="material-symbols-outlined text-xl fill-icon">local_fire_department</span>
        <span class="font-black text-xs uppercase tracking-tight">7 Day Streak</span>
    </div>

    <!-- XP display -->
    <div class="flex items-center gap-2 pr-4 pl-1">
        <div class="size-6 bg-math-blue rounded-full flex items-center justify-center shadow-sm">
            <span class="material-symbols-outlined text-white text-xs fill-icon">star</span>
        </div>
        <span class="font-black text-sm text-math-dark-blue">2,450 XP</span>
    </div>

    <!-- Profile avatar -->
    <div class="size-11 rounded-full border-2 border-math-blue overflow-hidden hover:scale-105 transition-transform cursor-pointer">
        <img alt="User profile avatar" class="w-full h-full object-cover bg-blue-100"
             src="https://lh3.googleusercontent.com/aida-public/AB6AXuDg1e5aeNftJ_IavQH7KzMKe4Zml5J_-RaiJOKxKoiC6hq5CKeVPd-TEwXZs1vVOJHBlplFmWWejSz3ZrGhJqYG1pYN7UvbSghGf8DMejwLi626ggD869piYG3Q1dU8mD376BM0mpiaI2OAi-WO7D2VnZ7puMUsJxZ_gjxcdS_dR_8vVVa1YIWwpnIByjsfHiIh61axMqJBjZUtANvJzdr9bNmuc5gFSq-6Xyl0bc7sQMdN0m69DZurtPjRxxn-oyh6Y7vm5HrLuQ"/>
    </div>
</div>
                </nav>
            </div>
        </header>

        <!-- Main content -->
        <main class="flex-1 max-w-7xl mx-auto w-full px-8 py-12 z-10">
            <div class="mb-12 space-y-8">
                <div class="text-center max-w-2xl mx-auto mb-10">
                    <h2 class="text-5xl font-black mb-4 tracking-tight text-math-blue">Teacher <span class="text-math-dark-blue">Assignments</span></h2>
                    <p class="text-lg font-bold text-gray-500">Missions hand-picked by your instructor to accelerate your learning journey.</p>
                </div>

                <!-- Tabs + Search -->
                <div class="flex flex-col lg:flex-row gap-6 items-center bg-white p-4 rounded-[2.5rem] shadow-xl border-4 border-math-blue/5">
                    <div class="bg-gray-100 p-2 rounded-[1.8rem] flex w-full lg:w-auto">
                        <asp:Button ID="btnActiveAssignments" runat="server" Text="Active Assignments" CssClass="flex-1 lg:px-8 py-3 bg-white text-math-blue rounded-[1.5rem] font-black text-sm uppercase tracking-wider shadow-md" />
                        <asp:Button ID="btnCompletedAssignments" runat="server" Text="Completed" CssClass="flex-1 lg:px-8 py-3 bg-transparent text-gray-500 hover:text-math-blue rounded-[1.5rem] font-black text-sm uppercase tracking-wider transition-all" OnClick="btnCompletedAssignments_Click" />
                    </div>
                    <div class="relative flex-1 w-full">
                        <span class="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-gray-400 text-2xl">search</span>
                        <asp:TextBox ID="txtSearch" 
    runat="server" 
    AutoPostBack="true" 
    OnTextChanged="txtSearch_TextChanged" 
    CssClass="w-full pl-14 pr-6 py-4 bg-gray-50 border-2 border-gray-100 rounded-3xl font-bold text-math-dark-blue focus:ring-4 focus:ring-math-blue/20 focus:border-math-blue outline-none transition-all" 
    placeholder="Find a specific assignment..." />
                    </div>
                </div>
            </div>

            <!-- Assignments Grid -->
            <asp:Repeater ID="rptAssignments" runat="server" OnItemCommand="rptAssignments_ItemCommand">
                <ItemTemplate>
                    <div class="module-card bg-white rounded-[3rem] p-8 border-4 border-math-blue/10 shadow-xl flex flex-col group relative">
    <!-- Assigned By Badge -->
    <div class="absolute top-6 right-6 z-40 flex items-center gap-2 bg-primary/40 text-math-dark-blue px-3 py-1.5 rounded-full border border-primary/60">
    <span class="material-symbols-outlined text-sm fill-icon">nutrition</span>
    <span class="text-[10px] font-black uppercase"><%# Eval("AssignedBy") %> assigned this</span>
    </div>

    <!-- Icon Box -->
    <div class="relative w-full h-48 mb-8 rounded-[2rem] bg-math-blue/10 flex items-center justify-center overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-br from-math-blue/20 to-transparent"></div>
        <div class="relative z-10 size-32 bg-math-blue rounded-3xl shadow-2xl flex items-center justify-center rotate-6 group-hover:rotate-12 transition-transform duration-500">
            <span class="material-symbols-outlined text-6xl text-white"><%# Eval("Icon") %></span>
        </div>
    </div>

    <!-- Content -->
    <div class="flex-1">
        <div class="flex items-center gap-2 mb-3">
            <span class="px-3 py-1 bg-math-blue/10 text-math-blue rounded-full text-[10px] font-black uppercase"><%# Eval("Subject") %></span>
            <span class="text-gray-400 font-bold text-[10px]"><%# Eval("Due") %></span>
        </div>
        <h3 class="text-2xl font-black mb-4 leading-tight group-hover:text-math-blue transition-colors"><%# Eval("Title") %></h3>
        <div class="mb-6 space-y-2">
            <div class="flex justify-between text-xs font-black uppercase text-gray-400 px-1">
                <span>Progress</span>
                <span class="text-math-blue"><%# Eval("Progress") %>%</span>
            </div>
            <div class="h-3 w-full bg-gray-100 rounded-full overflow-hidden border border-gray-100">
                <div class="h-full bg-math-blue" style='width:<%# Eval("Progress") %>%'></div>
            </div>
        </div>
    </div>

    <!-- Start Mission Button -->
    <asp:Button ID="btnStartMission" runat="server" 
        Text="START MISSION" 
        CommandName="Start" 
        CommandArgument='<%# Eval("Title") %>' 
        CssClass="w-full bg-math-blue text-white py-4 rounded-2xl font-black text-lg shadow-lg shadow-math-blue/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2" />
</div>
                </ItemTemplate>
            </asp:Repeater>

        </main>

        <!-- Footer -->
        <footer class="py-10 px-8 border-t-4 border-math-blue/10 bg-white z-30">
            <div class="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-6">
                <div class="flex flex-col gap-2">
                    <div class="flex items-center gap-2">
                        <div class="size-6 bg-primary rounded-lg flex items-center justify-center">
                            <span class="material-symbols-outlined text-math-dark-blue text-xs font-bold">variables</span>
                        </div>
                        <span class="font-black text-math-dark-blue tracking-tighter italic text-xl uppercase">MathSphere</span>
                    </div>
                    <p class="text-sm font-bold text-gray-400">The ultimate playground for future mathematicians.</p>
                </div>
                <div class="flex gap-8">
                    <a class="text-sm font-black text-gray-500 hover:text-math-blue transition-colors" href="#">Privacy</a>
                    <a class="text-sm font-black text-gray-500 hover:text-math-blue transition-colors" href="#">Terms</a>
                    <a class="text-sm font-black text-gray-500 hover:text-math-blue transition-colors" href="#">Help Center</a>
                </div>
                <p class="text-xs font-bold text-gray-300">© 2024 MathSphere Studios. All Rights Calculated.</p>
            </div>
        </footer>
    </form>
</body>
</html>
