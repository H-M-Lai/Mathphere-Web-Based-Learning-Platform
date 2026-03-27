<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="teacherDashboard.aspx.cs" Inherits="MathSphere.teacherDashboard" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere - Teacher Dashboard
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/teacherDashboard.css") %>" rel="stylesheet" />
    <style>
        .chart-grid {
            background-image: linear-gradient(rgba(0,0,0,0.04) 1px, transparent 1px);
            background-size: 100% 25%;
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <script type="application/json" id="__chartData"><asp:Literal ID="litChartJson" runat="server" /></script>
    <script type="application/json" id="__maxAttempts"><asp:Literal ID="litMaxAttempts" runat="server" /></script>

    <div class="space-y-10">
        <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="absolute -right-16 -top-16 size-48 rounded-full bg-blue-100/70 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 h-32 w-40 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
            <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
                <div class="max-w-3xl space-y-4">
                    <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                        <span class="material-symbols-outlined text-sm fill-icon">school</span>
                        Teacher dashboard
                    </div>
                    <div class="space-y-3">
                        <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">
                            Welcome back, <asp:Literal ID="litTeacherName" runat="server" />.
                        </h2>
                        <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                            Keep an eye on classroom momentum, spot modules that need support, and move from insight to action without leaving your workspace.
                        </p>
                    </div>
                </div>
                <div class="grid grid-cols-1 gap-3 sm:grid-cols-3 xl:min-w-[420px]">
                    <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Focus</p>
                        <p class="mt-2 text-sm font-bold text-math-dark-blue">Classroom progress snapshot</p>
                    </div>
                    <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Signals</p>
                        <p class="mt-2 text-sm font-bold text-math-dark-blue">Quiz score, completion, attempts</p>
                    </div>
                    <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Workflow</p>
                        <p class="mt-2 text-sm font-bold text-math-dark-blue">Review modules and draft work</p>
                    </div>
                </div>
            </div>
        </section>

        <asp:Literal ID="litMsg" runat="server" />

        <div class="grid grid-cols-1 gap-6 xl:grid-cols-3">
            <section class="rounded-[2rem] border border-white/70 bg-white/90 p-7 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
                <div class="flex items-start justify-between gap-6">
                    <div>
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Total Students</p>
                        <h3 class="mt-3 text-4xl font-black text-math-dark-blue">
                            <asp:Literal ID="litTotalStudents" runat="server" />
                        </h3>
                        <p class="mt-2 text-sm font-bold text-gray-500">Students actively enrolled in your current classrooms.</p>
                    </div>
                    <div class="flex size-16 shrink-0 items-center justify-center rounded-[1.5rem] border border-blue-100 bg-blue-50 text-blue-600 shadow-inner">
                        <span class="material-symbols-outlined text-4xl">groups</span>
                    </div>
                </div>
            </section>

            <section class="rounded-[2rem] border border-white/70 bg-white/90 p-7 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
                <div class="flex items-start justify-between gap-6">
                    <div>
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Avg. Engagement</p>
                        <h3 class="mt-3 text-4xl font-black text-math-dark-blue">
                            <asp:Literal ID="litAvgEngagement" runat="server" />
                        </h3>
                        <p class="mt-2 text-sm font-bold text-gray-500">Average completion pace across active student-module pairs.</p>
                    </div>
                    <div class="flex size-16 shrink-0 items-center justify-center rounded-[1.5rem] border border-green-100 bg-green-50 text-green-600 shadow-inner">
                        <span class="material-symbols-outlined text-4xl">bolt</span>
                    </div>
                </div>
            </section>

            <section class="rounded-[2rem] border border-white/70 bg-white/90 p-7 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
                <div class="flex items-start justify-between gap-6">
                    <div>
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Draft Assessments</p>
                        <h3 class="mt-3 text-4xl font-black text-math-dark-blue">
                            <asp:Literal ID="litPendingAssessments" runat="server" />
                        </h3>
                        <p class="mt-2 text-sm font-bold text-gray-500">Assessments that still need review before publishing.</p>
                    </div>
                    <div class="flex size-16 shrink-0 items-center justify-center rounded-[1.5rem] border border-yellow-100 bg-yellow-50 text-yellow-600 shadow-inner">
                        <span class="material-symbols-outlined text-4xl">assignment</span>
                    </div>
                </div>
            </section>
        </div>

        <div class="grid grid-cols-1 gap-8 xl:grid-cols-12">
            <div class="xl:col-span-8">
                <section class="rounded-[2.75rem] border border-white/70 bg-white/90 p-8 lg:p-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
                    <div class="mb-10 flex flex-col gap-5 lg:flex-row lg:items-start lg:justify-between">
                        <div>
                            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                                <span class="material-symbols-outlined text-sm fill-icon">monitoring</span>
                                Live classroom signals
                            </div>
                            <h3 class="mt-4 text-2xl font-black tracking-tight text-math-dark-blue">
                                Classroom Performance Overview
                            </h3>
                            <p class="mt-2 text-sm font-bold text-gray-400 uppercase tracking-[0.24em]">
                                Per-module quiz score, completion, and attempt activity
                            </p>
                        </div>
                        <asp:DropDownList ID="ddlCourseFilter" runat="server"
                            AutoPostBack="True"
                            OnSelectedIndexChanged="ddlCourseFilter_SelectedIndexChanged"
                            CssClass="rounded-2xl border border-gray-200 bg-gray-50 px-6 py-3 text-xs font-black uppercase tracking-[0.2em] text-math-dark-blue shadow-sm cursor-pointer appearance-none">
                        </asp:DropDownList>
                    </div>

                    <div class="relative flex h-80 items-end rounded-[2rem] border border-gray-100 bg-gray-50/70 px-5 py-5">
                        <div class="absolute left-5 top-5 flex h-[calc(100%-2.5rem)] flex-col justify-between text-[10px] font-black text-gray-300">
                            <span>100%</span><span>75%</span><span>50%</span><span>25%</span><span>0%</span>
                        </div>
                        <div id="chartBars"
                             class="chart-grid ml-10 flex h-full w-full items-end justify-between rounded-[1.5rem] border-b border-gray-100 px-6 pb-4">
                        </div>
                    </div>

                    <div id="chartTooltip"
                         class="pointer-events-none absolute z-50 hidden rounded-2xl bg-math-dark-blue px-4 py-3 text-[11px] font-black text-white shadow-xl">
                    </div>

                    <div class="mt-8 flex flex-wrap items-center justify-center gap-6 lg:gap-10">
                        <div class="flex items-center gap-3">
                            <div class="size-3 rounded-full bg-blue-500"></div>
                            <span class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Avg Quiz Score</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="size-3 rounded-full" style="background:#84cc16"></div>
                            <span class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Completion</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="size-3 rounded-full bg-yellow-400"></div>
                            <span class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Attempts</span>
                        </div>
                    </div>
                </section>
            </div>

            <div class="xl:col-span-4">
                <section class="flex h-full flex-col rounded-[2.75rem] border border-white/70 bg-white/90 p-8 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
                    <div class="mb-8 flex items-start justify-between gap-4">
                        <div>
                            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                                <span class="material-symbols-outlined text-sm fill-icon">insights</span>
                                Top modules
                            </div>
                            <p class="mt-4 text-sm font-bold leading-6 text-gray-500">
                                A quick look at the strongest quiz performance across your published learning modules.
                            </p>
                        </div>
                    </div>

                    <div class="flex-1 space-y-4 overflow-y-auto pr-1">
                        <asp:Repeater ID="rptTopModules" runat="server">
                            <ItemTemplate>
                                <div class="rounded-[1.75rem] border border-gray-100 bg-gray-50/80 p-5 transition-all hover:-translate-y-1 hover:border-blue-100 hover:bg-white">
                                    <div class="mb-2 flex items-start justify-between gap-3">
                                        <span class="text-sm font-black text-math-dark-blue">
                                            <%# Eval("ModuleTitle") %>
                                        </span>
                                        <asp:Literal runat="server" Text='<%# Eval("HasScore").ToString() == "1"
                                            ? "<span class=\"rounded-full border border-blue-100 bg-blue-50 px-3 py-1 text-[10px] font-black text-blue-600\">" + Eval("AvgScoreFmt") + "%</span>"
                                            : "<span class=\"rounded-full border border-gray-100 bg-white px-3 py-1 text-[10px] font-black text-gray-300\">No data</span>" %>' />
                                    </div>
                                    <div class="mt-3 h-1.5 w-full rounded-full bg-gray-100">
                                        <asp:Literal runat="server" Text='<%# Eval("HasScore").ToString() == "1"
                                            ? "<div class=\"h-1.5 rounded-full bg-blue-500 transition-all\" style=\"width:" + Eval("BarWidth") + "%\"></div>"
                                            : "" %>' />
                                    </div>
                                    <span class="mt-2 block text-[10px] font-bold uppercase tracking-[0.2em] text-gray-400">Average quiz score</span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <a href="<%= ResolveUrl("~/courselistDashboard.aspx") %>"
                       class="mt-8 inline-flex items-center justify-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-5 py-3 text-xs font-black uppercase tracking-[0.22em] text-blue-600 transition-all hover:border-blue-200 hover:bg-blue-100">
                        View all modules
                        <span class="material-symbols-outlined text-sm">arrow_forward</span>
                    </a>
                </section>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    (function () {
        var chartDiv = document.getElementById('chartBars');
        if (!chartDiv) return;

        var jsonEl = document.getElementById('__chartData');
        var maxEl = document.getElementById('__maxAttempts');
        if (!jsonEl || !maxEl) return;

        var chartData;
        try { chartData = JSON.parse(jsonEl.textContent || jsonEl.innerText); }
        catch (e) { return; }

        if (!chartData || chartData.length === 0) {
            chartDiv.innerHTML = '<div class="w-full flex items-center justify-center text-gray-300 text-sm font-black uppercase tracking-widest">No data yet</div>';
            return;
        }

        var containerH = chartDiv.offsetHeight || 280;
        var barAreaH = containerH - 28;
        var tooltip = document.getElementById('chartTooltip');
        var html = '';

        chartData.forEach(function (m) {
            var quizPx = Math.round(m.quiz / 100 * barAreaH);
            var compPx = Math.round(m.comp / 100 * barAreaH);
            var attPx = Math.round(m.attPct / 100 * barAreaH);
            if (m.quiz > 0 && quizPx < 3) quizPx = 3;
            if (m.comp > 0 && compPx < 3) compPx = 3;
            if (m.att > 0 && attPx < 3) attPx = 3;

            html += '<div class="flex flex-col items-center gap-1 flex-1" style="height:' + containerH + 'px;justify-content:flex-end;">';
            html += '<div class="flex items-end gap-1 justify-center" style="height:' + barAreaH + 'px">';
            html += bar(quizPx, '#2563eb', m.quiz > 0, m.fullLabel, 'Quiz: ' + m.quiz + '%');
            html += bar(compPx, '#84cc16', m.comp > 0, m.fullLabel, 'Completion: ' + m.comp + '%');
            html += bar(attPx, '#f9d006', m.att > 0, m.fullLabel, 'Attempts: ' + m.att);
            html += '</div>';
            html += '<span style="font-size:9px;font-weight:900;color:#9ca3af;text-transform:uppercase;'
                + 'letter-spacing:-0.02em;text-align:center;max-width:52px;word-break:break-word;line-height:1.2;">'
                + escHtml(m.label) + '</span></div>';
        });

        chartDiv.innerHTML = html;

        chartDiv.querySelectorAll('.bar').forEach(function (b) {
            b.addEventListener('mouseenter', function (ev) {
                tooltip.textContent = b.getAttribute('data-label') + ' - ' + b.getAttribute('data-tip');
                tooltip.classList.remove('hidden');
                pos(ev);
            });
            b.addEventListener('mousemove', pos);
            b.addEventListener('mouseleave', function () { tooltip.classList.add('hidden'); });
        });

        function bar(h, color, hasVal, label, tip) {
            return '<div class="bar rounded-t-lg shadow-md cursor-pointer transition-all hover:brightness-110 hover:scale-105"'
                + ' style="width:14px;height:' + h + 'px;background:' + color + ';min-height:' + (hasVal ? 3 : 0) + 'px"'
                + ' data-label="' + escHtml(label) + '" data-tip="' + escHtml(tip) + '"></div>';
        }
        function pos(ev) {
            tooltip.style.left = (ev.pageX + 14) + 'px';
            tooltip.style.top = (ev.pageY - 36) + 'px';
        }
        function escHtml(s) {
            return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;')
                .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }
    })();
</script>
</asp:Content>