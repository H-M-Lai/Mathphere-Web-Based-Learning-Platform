<%@ Page Language="C#" MasterPageFile="~/Admin.master" AutoEventWireup="true" CodeBehind="systemSetting.aspx.cs" Inherits="MathSphere.systemSetting" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere Admin - System Settings
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        input[type="range"] {
            -webkit-appearance: none;
            appearance: none;
            height: 0.5rem;
            border-radius: 9999px;
            background: #e5e7eb;
            width: 100%;
        }
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 1.5rem;
            height: 1.5rem;
            border-radius: 9999px;
            cursor: pointer;
            border: 4px solid #ffffff;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            background: #2563eb;
        }
        input[type="range"]::-moz-range-thumb {
            width: 1.5rem;
            height: 1.5rem;
            border-radius: 9999px;
            cursor: pointer;
            border: 4px solid #ffffff;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            background: #2563eb;
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Save success toast --%>
    <div id="toastMsg" class="fixed top-6 right-6 z-[9999] hidden">
        <div class="flex items-center gap-3 rounded-2xl bg-math-dark-blue px-6 py-4 text-sm font-black uppercase tracking-wider text-white shadow-[0_18px_40px_rgba(30,58,138,0.25)]">
            <span class="material-symbols-outlined text-math-green">check_circle</span>
            <span>Settings saved and applied to all users.</span>
        </div>
    </div>

    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-16 -top-16 size-52 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-48 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">tune</span>
                    Admin controls
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">System Settings</h2>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Configure gamification rules, reminder automation, and live platform settings that apply across the system.
                </p>
            </div>
            <div class="grid gap-3 sm:grid-cols-3 xl:min-w-[430px]">
                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Scope</p>
                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Points, streaks, reminders</p>
                </div>
                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Mode</p>
                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Live database configuration</p>
                </div>
                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Effect</p>
                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Changes apply to all users</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Settings Grid -->
    <div class="grid grid-cols-1 xl:grid-cols-2 gap-8 mb-10">

        <!-- Points Allocation -->
        <section class="flex flex-col rounded-[2.5rem] border border-white/70 bg-white/90 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
            <div class="flex items-center gap-4 mb-8">
                <div class="flex size-12 items-center justify-center rounded-2xl bg-math-blue/10 text-math-blue shadow-sm">
                    <span class="material-symbols-outlined text-2xl fill-icon">military_tech</span>
                </div>
                <div>
                    <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">Points Allocation</h3>
                    <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Stored in studentScoreEventTable</p>
                </div>
            </div>

            <div class="space-y-6">

                <%-- Flashcard Completion — applies to flashcardCompletionTable --%>
                <div class="grid grid-cols-2 gap-6 items-center">
                    <div>
                        <label class="text-sm font-black text-math-dark-blue uppercase tracking-tighter block">Flashcard Completion</label>
                        <p class="text-[10px] text-gray-400 font-bold mt-0.5">Points per completed flashcard set</p>
                    </div>
                    <div class="relative">
                        <asp:TextBox ID="txtFlashcardCompletion" runat="server" Text="10" TextMode="Number"
                            CssClass="w-full bg-gray-50 border-2 border-gray-100 rounded-2xl py-3 px-5 font-black text-math-blue focus:ring-0 focus:border-math-blue" />
                        <span class="absolute right-4 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-300">PTS</span>
                    </div>
                </div>

                <%-- Quiz Perfect Score — applies to QuizAttempt / assessmentAttemptTable --%>
                <div class="grid grid-cols-2 gap-6 items-center">
                    <div>
                        <label class="text-sm font-black text-math-dark-blue uppercase tracking-tighter block">Quiz Perfect Score</label>
                        <p class="text-[10px] text-gray-400 font-bold mt-0.5">Bonus for 100% on QuizAttempt</p>
                    </div>
                    <div class="relative">
                        <asp:TextBox ID="txtQuizPerfectScore" runat="server" Text="50" TextMode="Number"
                            CssClass="w-full bg-gray-50 border-2 border-gray-100 rounded-2xl py-3 px-5 font-black text-math-blue focus:ring-0 focus:border-math-blue" />
                        <span class="absolute right-4 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-300">PTS</span>
                    </div>
                </div>

                <%-- Streak Bonus - applies to StudentStreak --%>
                <div class="grid grid-cols-2 gap-6 items-center">
                    <div>
                        <label class="text-sm font-black text-math-dark-blue uppercase tracking-tighter block">Streak Bonus (7-Day)</label>
                        <p class="text-[10px] text-gray-400 font-bold mt-0.5">Bonus when StudentStreak.currentStreak = 7</p>
                    </div>
                    <div class="relative">
                        <asp:TextBox ID="txtStreakBonus" runat="server" Text="100" TextMode="Number"
                            CssClass="w-full bg-gray-50 border-2 border-gray-100 rounded-2xl py-3 px-5 font-black text-math-blue focus:ring-0 focus:border-math-blue" />
                        <span class="absolute right-4 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-300">PTS</span>
                    </div>
                </div>

            </div>
        </section>

        <!-- Right column -->
        <div class="space-y-8">

            <!-- Streak Calculation controls StudentStreak logic -->
            <section class="rounded-[2.5rem] border border-white/70 bg-white/90 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
                <div class="flex items-center gap-4 mb-8">
                    <div class="flex size-12 items-center justify-center rounded-2xl bg-math-green/10 text-math-green shadow-sm">
                        <span class="material-symbols-outlined text-2xl fill-icon">local_fire_department</span>
                    </div>
                    <div>
                        <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">Streak Calculation</h3>
                        <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Controls StudentStreak</p>
                    </div>
                </div>

                <div class="space-y-6">
                    <div class="flex justify-between items-end">
                        <div>
                            <label class="text-sm font-black text-math-dark-blue uppercase tracking-tighter block">Daily Activity Window</label>
                            <p class="text-[10px] text-gray-400 font-bold mt-0.5">Window within which a login counts as "active today"</p>
                        </div>
                        <span id="activityWindowValue" runat="server"
                              class="text-2xl font-black text-math-green whitespace-nowrap ml-4">
                            24 <span class="text-xs uppercase">Hours</span>
                        </span>
                    </div>
                    <input id="rngActivityWindow" runat="server" type="range" min="1" max="48" value="24" class="w-full" />
                    <div class="flex justify-between text-[10px] font-black text-gray-300 uppercase">
                        <span>1 Hour</span><span>24 Hours</span><span>48 Hours</span>
                    </div>
                </div>
            </section>

            <!-- Reminder Rules — controls notificationTable inserts -->
            <section class="rounded-[2.5rem] border border-white/70 bg-white/90 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
                <div class="flex items-center gap-4 mb-8">
                    <div class="flex size-12 items-center justify-center rounded-2xl bg-primary/10 text-primary shadow-sm">
                        <span class="material-symbols-outlined text-2xl fill-icon">notifications_active</span>
                    </div>
                    <div>
                        <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">Reminder Rules</h3>
                        <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Inserts into notificationTable when threshold met</p>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-6 items-center">
                    <div>
                        <label class="text-sm font-black text-math-dark-blue uppercase tracking-tighter block">Inactivity Threshold</label>
                        <p class="text-[10px] text-gray-400 font-bold mt-0.5">Days since last activity before reminder fires</p>
                    </div>
                    <div class="relative">
                        <asp:TextBox ID="txtInactivityThreshold" runat="server" Text="3" TextMode="Number"
                            CssClass="w-full bg-gray-50 border-2 border-gray-100 rounded-2xl py-3 px-5 font-black text-primary focus:ring-0 focus:border-primary" />
                        <span class="absolute right-4 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-300 uppercase">Days</span>
                    </div>
                </div>
            </section>

        </div>
    </div>

    <!-- Last saved info + Save button -->
    <div class="mb-16 flex flex-col gap-4 rounded-[2.25rem] border border-white/70 bg-white/90 px-8 py-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)] md:flex-row md:items-center md:justify-between">
        <p class="text-xs font-bold text-gray-400 italic flex items-center gap-2">
            <span class="material-symbols-outlined text-sm">history</span>
            Last saved:
            <asp:Literal ID="litLastUpdated"   runat="server" Text="Never" /> &nbsp;·&nbsp;
            by <asp:Literal ID="litLastUpdatedBy" runat="server" Text="—" />
        </p>

        <asp:LinkButton ID="btnSave" runat="server" OnClick="btnSave_Click"
            CssClass="inline-flex items-center gap-3 rounded-2xl bg-primary px-8 py-4 text-base font-black uppercase tracking-[0.18em] text-math-dark-blue shadow-[0_10px_24px_rgba(249,208,6,0.22)] transition-all hover:bg-yellow-300 hover:-translate-y-0.5">
            <span class="material-symbols-outlined font-black">save</span>
            Save &amp; Apply to All Users
        </asp:LinkButton>
    </div>

    <!-- Live stats from DB -->
    <div class="grid grid-cols-1 gap-6 md:grid-cols-3">

        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex size-14 items-center justify-center rounded-2xl bg-blue-50 text-math-blue shadow-sm">
                <span class="material-symbols-outlined text-3xl fill-icon">person_celebrate</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-math-blue uppercase tracking-widest">Growth</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    +<asp:Literal ID="litGrowth" runat="server" Text="0" />
                    <span class="text-sm font-bold text-gray-400">This Week</span>
                </div>
            </div>
        </div>

        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex size-14 items-center justify-center rounded-2xl bg-green-50 text-math-green shadow-sm">
                <span class="material-symbols-outlined text-3xl fill-icon">how_to_reg</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-math-green uppercase tracking-widest">Active Rate</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litActiveRate" runat="server" Text="0%" />
                    <span class="text-sm font-bold text-gray-400">Verified</span>
                </div>
            </div>
        </div>

        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex size-14 items-center justify-center rounded-2xl bg-yellow-50 text-primary shadow-sm">
                <span class="material-symbols-outlined text-3xl fill-icon">shield_person</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-primary uppercase tracking-widest">Staff Count</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litStaffCount" runat="server" Text="0" />
                    <span class="text-sm font-bold text-gray-400">Privileged</span>
                </div>
            </div>
        </div>

    </div>

    <script>
        // Live slider label
        (function () {
            var range = document.getElementById('<%= rngActivityWindow.ClientID %>');
            var label = document.getElementById('<%= activityWindowValue.ClientID %>');
            if (!range || !label) return;
            function render() {
                label.innerHTML = range.value + ' <span class="text-xs uppercase">Hours</span>';
            }
            range.addEventListener('input', render);
            render();
        })();

        // Show toast after successful save postback
        (function () {
            if ('<%= toastFlag %>' !== '1') return;
            var t = document.getElementById('toastMsg');
            if (!t) return;
            t.classList.remove('hidden');
            setTimeout(function () { t.classList.add('hidden'); }, 3500);
        })();
    </script>

</asp:Content>




