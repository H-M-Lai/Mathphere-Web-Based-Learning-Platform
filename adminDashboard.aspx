<%@ Page Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="adminDashboard.aspx.cs" Inherits="MathSphere.adminDashboard" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere Admin - System Analytics
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <meta http-equiv="refresh" content="30" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
    <style>
        .chart-skeleton {
            background: linear-gradient(90deg, #f3f4f6 25%, #e5e7eb 50%, #f3f4f6 75%);
            background-size: 200% 100%;
            animation: shimmer 1.4s infinite;
            border-radius: 1rem;
        }
        @keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />
    <asp:Literal ID="litAlertBadge" runat="server" Visible="false" />

        <!-- Page Header -->
    <section class="relative mb-12 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-4">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">insights</span>
                    Admin dashboard
                </div>
                <div class="space-y-3">
                    <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">System Analytics</h2>
                    <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                        Keep an eye on platform health, user activity, and operational alerts from one shared control center.
                    </p>
                </div>
            </div>
            <div class="flex flex-wrap items-center gap-3 lg:gap-4">
                <div class="inline-flex items-center gap-3 rounded-full border border-green-100 bg-green-50 px-5 py-3 shadow-sm">
                    <div class="size-2.5 rounded-full bg-math-green animate-pulse"></div>
                    <span class="text-[11px] font-black uppercase tracking-[0.24em] text-math-dark-blue">Server online</span>
                </div>
                <div class="inline-flex items-center gap-3 rounded-full border border-yellow-100 bg-yellow-50 px-5 py-3 shadow-sm" title="Page auto-refreshes every 30 seconds">
                    <span class="material-symbols-outlined text-primary text-lg fill-icon">autorenew</span>
                    <span class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-500">Refresh in</span>
                    <span id="refreshCountdown" class="text-sm font-black text-math-dark-blue tabular-nums">30s</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Cards -->
    <div class="mb-12 grid grid-cols-1 gap-6 md:grid-cols-3">
        <asp:Repeater ID="rptStatsCards" runat="server" OnItemDataBound="rptStatsCards_ItemDataBound">
            <ItemTemplate>
                <asp:Literal ID="litStatsCard" runat="server"></asp:Literal>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- Charts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 mb-10">
        <!-- Platform activity chart -->
        <section class="lg:col-span-8 rounded-[2.75rem] border border-white/70 bg-white/90 p-8 lg:p-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="flex items-center justify-between mb-8">
                <div>
                    <h3 class="text-2xl font-black uppercase tracking-tight text-math-dark-blue">Platform Activity</h3>
                    <p class="text-sm font-bold text-gray-400 italic">Daily logins over the last 30 days</p>
                </div>
                <div class="flex gap-4">
                    <div class="flex items-center gap-2">
                        <div class="size-3 rounded-full bg-math-blue"></div>
                        <span class="text-[10px] font-black uppercase text-gray-500 tracking-wider">Students</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <div class="size-3 rounded-full bg-math-green"></div>
                        <span class="text-[10px] font-black uppercase text-gray-500 tracking-wider">Teachers</span>
                    </div>
                </div>
            </div>
            <%-- Skeleton shown while data loads --%>
            <div id="lineChartSkeleton" class="chart-skeleton h-[350px] w-full"></div>
            <%-- Canvas shown after data arrives --%>
            <div id="lineChartWrap" class="h-[350px] relative w-full hidden">
                <canvas id="lineChart"></canvas>
            </div>
            <%-- Shown when DB returns no rows --%>
            <p id="lineChartEmpty" class="hidden text-center text-xs font-black text-gray-300 uppercase tracking-widest py-20">
                No login data available for the last 30 days
            </p>
        </section>
        <!-- Role distribution chart -->
        <section class="lg:col-span-4 flex flex-col items-center rounded-[2.75rem] border border-white/70 bg-white/90 p-8 lg:p-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <h3 class="text-xl font-black uppercase tracking-tight mb-8 self-start text-math-dark-blue">Role Distribution</h3>
            <%-- Skeleton --%>
            <div id="donutSkeleton" class="chart-skeleton size-64 rounded-full mb-8"></div>
            <%-- Canvas + centre label --%>
            <div id="donutWrap" class="relative size-64 mb-8 hidden">
                <canvas id="donutChart"></canvas>
                <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
                    <div class="size-32 bg-white rounded-full flex flex-col items-center justify-center shadow-inner border-2 border-gray-50">
                        <%-- Filled by JS with real total from DB --%>
                        <span id="donutTotal" class="text-2xl font-black text-math-dark-blue">—</span>
                        <span class="text-[8px] font-black text-gray-400 uppercase tracking-widest">Total Users</span>
                    </div>
                </div>
            </div>
            <div class="w-full space-y-3">
                <asp:Repeater ID="rptRoleDistribution" runat="server" OnItemDataBound="rptRoleDistribution_ItemDataBound">
                    <ItemTemplate>
                        <asp:Literal ID="litRoleItem" runat="server"></asp:Literal>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </section>
    </div>

    <!-- Activity Log Table -->
    <section class="overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 p-8 lg:p-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="flex items-center justify-between mb-8">
            <h3 class="text-2xl font-black uppercase tracking-tight flex items-center gap-3 text-math-dark-blue">
                <span class="material-symbols-outlined text-math-dark-blue">list_alt</span>
                Recent Activity Log
            </h3>
            <asp:Button ID="btnExportLogs" runat="server" Text="Export Logs"
                OnClick="btnExportLogs_Click"
                CssClass="rounded-full border border-blue-100 bg-blue-50 px-5 py-3 text-xs font-black uppercase tracking-[0.2em] text-blue-600 transition-all hover:border-blue-200 hover:bg-blue-100 cursor-pointer" />
        </div>
        <div class="overflow-x-auto">
            <table class="w-full" id="activityLogTable">
                <thead class="bg-gray-50 rounded-xl">
                    <tr class="text-left">
                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest">Event Type</th>
                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest">Description</th>
                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest">Timestamp</th>
                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y-2 divide-gray-50" id="logBodyTop">
                    <asp:Repeater ID="rptActivityLog" runat="server" OnItemDataBound="rptActivityLog_ItemDataBound">
                        <ItemTemplate>
                            <asp:Literal ID="litActivityRow" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
                <tbody class="divide-y-2 divide-gray-50 hidden" id="logBodyExtra"></tbody>
            </table>
            <div id="logLoadingSpinner" class="hidden py-6 flex items-center justify-center gap-3 text-gray-400">
                <span class="material-symbols-outlined animate-spin text-math-blue">progress_activity</span>
                <span class="text-xs font-black uppercase tracking-widest">Loading audit trail…</span>
            </div>
        </div>
                <button type="button" id="btnAuditTrail" onclick="toggleAuditTrail()"
                class="mt-6 flex w-full items-center justify-center gap-2 rounded-full border border-gray-200 bg-gray-50/80 px-5 py-3 text-xs font-black uppercase tracking-[0.22em] text-gray-500 transition-all hover:border-blue-100 hover:bg-white hover:text-blue-600">
            <span class="material-symbols-outlined text-sm" id="auditTrailIcon">expand_more</span>
            <span id="auditTrailLabel">View Full System Audit Trail</span>
        </button>
    </section>

    <script>
        // Countdown timer
        (function () {
            var el = document.getElementById('refreshCountdown');
            if (!el) return;
            var secs = 30;
            var iv = setInterval(function () {
                secs--;
                if (secs <= 0) { el.textContent = '…'; clearInterval(iv); }
                else {
                    el.textContent = secs + 's';
                    if (secs <= 10) el.style.color = '#f9d006';
                }
            }, 1000);
        })();

        PageMethods.set_path('/adminDashboard.aspx');

        // Colour palette (matches Tailwind brand colours)
        var C = {
            blue: '#2563eb',
            green: '#84cc16',
            yellow: '#f9d006',
            purple: '#8b5cf6',
            gray: '#9ca3af'
        };

        // -
        //  LINE CHART — Platform Activity
        //  Calls GetPlatformActivityData() WebMethod.
        //  Replaces the old hardcoded SVG paths entirely.
        // -
        PageMethods.GetPlatformActivityData(
            function (data) {
                document.getElementById('lineChartSkeleton').classList.add('hidden');

                if (!data || !data.labels || data.labels.length === 0) {
                    document.getElementById('lineChartEmpty').classList.remove('hidden');
                    return;
                }

                document.getElementById('lineChartWrap').classList.remove('hidden');
                new Chart(document.getElementById('lineChart').getContext('2d'), {
                    type: 'line',
                    data: {
                        labels: data.labels,           // real dates from DB e.g. "01 Mar"
                        datasets: [
                            {
                                label: 'Students',
                                data: data.students,   // real daily counts from StudentLoginDaily
                                borderColor: C.blue,
                                backgroundColor: 'rgba(37,99,235,0.08)',
                                borderWidth: 3,
                                pointRadius: 3,
                                pointHoverRadius: 6,
                                tension: 0,
                                fill: true
                            },
                            {
                                label: 'Teachers',
                                data: data.teachers,   // real daily counts from StudentLoginDaily
                                borderColor: C.green,
                                backgroundColor: 'rgba(132,204,22,0.08)',
                                borderWidth: 3,
                                pointRadius: 3,
                                pointHoverRadius: 6,
                                tension: 0,
                                fill: true
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                mode: 'index', intersect: false,
                                backgroundColor: '#fff',
                                titleColor: '#1e2d5b', bodyColor: '#6b7280',
                                borderColor: '#e5e7eb', borderWidth: 1,
                                padding: 10,
                                titleFont: { weight: 'bold' }
                            }
                        },
                        scales: {
                            x: {
                                grid: { display: false },
                                ticks: { font: { size: 10, weight: 'bold' }, color: '#9ca3af', maxTicksLimit: 8, maxRotation: 0 }
                            },
                            y: {
                                beginAtZero: true,
                                grid: { color: 'rgba(229,231,235,0.6)' },
                                ticks: { font: { size: 10, weight: 'bold' }, color: '#9ca3af', maxTicksLimit: 5, precision: 0 }
                            }
                        }
                    }
                });
            },
            function () {
                document.getElementById('lineChartSkeleton').classList.add('hidden');
                var el = document.getElementById('lineChartEmpty');
                el.textContent = 'Could not load activity data.';
                el.classList.remove('hidden');
            }
        );

        // -
        //  DONUT CHART — Role Distribution
        //  Calls GetRoleDistributionChart() WebMethod.
        //  Replaces the old hardcoded stroke-dasharray="75 100"/"20 100"/"5 100"
        //  and the hardcoded "100%" / "Total Staff" centre label.
        // -
        PageMethods.GetRoleDistributionChart(
            function (data) {
                document.getElementById('donutSkeleton').classList.add('hidden');

                if (!data || !data.labels || data.labels.length === 0) return;

                // Map role names ? brand colours
                var roleColors = { student: C.blue, students: C.blue, teacher: C.green, teachers: C.green, admin: C.yellow, admins: C.yellow };
                var colors = data.labels.map(function (l, i) {
                    return roleColors[l.toLowerCase()] || [C.purple, C.gray][i % 2];
                });

                // Update centre label with real total from DB
                var total = data.values.reduce(function (a, b) { return a + b; }, 0);
                document.getElementById('donutTotal').textContent = total.toLocaleString();

                document.getElementById('donutWrap').classList.remove('hidden');
                new Chart(document.getElementById('donutChart').getContext('2d'), {
                    type: 'doughnut',
                    data: {
                        labels: data.labels,
                        datasets: [{ data: data.values, backgroundColor: colors, borderWidth: 0, hoverOffset: 6 }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '60%',
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#fff',
                                titleColor: '#1e2d5b', bodyColor: '#6b7280',
                                borderColor: '#e5e7eb', borderWidth: 1, padding: 10,
                                callbacks: {
                                    label: function (ctx) {
                                        var pct = ((ctx.parsed / total) * 100).toFixed(1);
                                        return ' ' + ctx.label + ': ' + ctx.parsed + ' (' + pct + '%)';
                                    }
                                }
                            }
                        }
                    }
                });
            },
            function () {
                document.getElementById('donutSkeleton').classList.add('hidden');
            }
        );

        // Audit trail toggle
        var _auditLoaded = false, _auditExpanded = false;

        function toggleAuditTrail() {
            var extra = document.getElementById('logBodyExtra');
            var spinner = document.getElementById('logLoadingSpinner');
            var icon = document.getElementById('auditTrailIcon');
            var label = document.getElementById('auditTrailLabel');
            var btn = document.getElementById('btnAuditTrail');

            // Collapse if already expanded
            if (_auditExpanded) {
                extra.classList.add('hidden');
                icon.textContent = 'expand_more';
                label.textContent = 'View Full System Audit Trail';
                _auditExpanded = false;
                return;
            }

            // Re-expand without re-fetching
            if (_auditLoaded) {
                extra.classList.remove('hidden');
                icon.textContent = 'expand_less';
                label.textContent = 'Collapse Audit Trail';
                _auditExpanded = true;
                return;
            }

            // First open — fetch all logs
            spinner.classList.remove('hidden');
            btn.disabled = true;

            PageMethods.GetAllActivityLogs(
                function (rows) {
                    spinner.classList.add('hidden');
                    btn.disabled = false;
                    extra.innerHTML = '';

                    var valid = (rows || []).filter(function (r) {
                        return r && r.eventType && r.eventType.trim();
                    });

                    if (valid.length === 0) {
                        extra.innerHTML = noMoreRows();
                    } else {
                        // Show ALL rows in the expanded body (the top 5 are already
                        // rendered server-side, so we show everything here for the
                        // full audit trail — admins can scroll through all of them)
                        extra.innerHTML = valid.map(buildRow).join('');
                    }

                    _auditLoaded = true;
                    _auditExpanded = true;
                    extra.classList.remove('hidden');
                    icon.textContent = 'expand_less';
                    label.textContent = 'Collapse Audit Trail';
                },
                function (err) {
                    spinner.classList.add('hidden');
                    btn.disabled = false;
                    showAuditError('Could not load audit trail: ' +
                        ((err && err.Message) ? err.Message : JSON.stringify(err)));
                }
            );
        }

        function buildRow(r) {
            var pr = (r.priority || '').toLowerCase();
            var s = (r.status || '').toLowerCase();
            var ev = (r.eventType || '').toLowerCase();

            var sBg = 'gray-100', sTxt = 'gray-600';
            if (pr === 'urgent' || pr === 'high') { sBg = 'red-100'; sTxt = 'red-500'; }
            else if (s === 'success' || s === 'ok') { sBg = 'green-100'; sTxt = 'math-green'; }
            else if (s === 'flagged' || s === 'warning') { sBg = 'yellow-100'; sTxt = 'primary'; }
            else if (s === 'error' || s === 'failed') { sBg = 'red-100'; sTxt = 'red-500'; }
            else if (s === 'auto' || s === 'info') { sBg = 'blue-100'; sTxt = 'math-blue'; }
            else if (pr === 'medium') { sBg = 'yellow-100'; sTxt = 'primary'; }

            var iBg = 'blue-100', iClr = 'math-blue', icon = 'event';
            if (pr === 'urgent' || pr === 'high') { iBg = 'red-100'; iClr = 'red-500'; }
            else if (pr === 'medium') { iBg = 'yellow-100'; iClr = 'primary'; }

            if (ev.includes('login') && ev.includes('fail')) icon = 'lock_person';
            else if (ev.includes('security')) icon = 'security';
            else if (ev.includes('login')) icon = 'login';
            else if (ev.includes('register') || ev.includes('create')) icon = 'person_add';
            else if (ev.includes('backup')) icon = 'cloud_upload';
            else if (ev.includes('forum') && ev.includes('flag')) icon = 'flag';
            else if (ev.includes('ticket') || ev.includes('help')) icon = 'support_agent';
            else if (ev.includes('user')) icon = 'person';

            var esc = function (t) { var d = document.createElement('div'); d.textContent = t || ''; return d.innerHTML; };

            // Resolve button — only for failed logins with an open alert
            var resolveBtn = '';
            var isFailedLogin = ev.includes('login') && (ev.includes('fail') || pr === 'high');
            if (isFailedLogin && r.alertId) {
                resolveBtn = '<button type="button" onclick="resolveFromLog(\'' + esc(r.alertId) + '\', this)" ' +
                    'class="ml-2 px-2 py-1 bg-red-100 hover:bg-red-500 text-red-500 hover:text-white ' +
                    'rounded-lg text-[10px] font-black uppercase transition-all border border-red-200 ' +
                    'hover:border-red-500 inline-flex items-center gap-1">' +
                    '<span class="material-symbols-outlined text-xs">check_circle</span> Resolve</button>';
            }

            var rowId = r.alertId ? 'id="logrow-' + esc(r.alertId) + '"' : '';
            return '<tr class="hover:bg-gray-50/50 transition-colors" ' + rowId + '>' +
                '<td class="px-6 py-4"><div class="flex items-center gap-3">' +
                '<div class="size-8 bg-' + iBg + ' rounded-lg flex items-center justify-center text-' + iClr + '">' +
                '<span class="material-symbols-outlined text-sm">' + icon + '</span></div>' +
                '<span class="font-bold text-sm">' + esc(r.eventType) + '</span></div></td>' +
                '<td class="px-6 py-4 font-medium text-sm text-gray-600">' + esc(r.description) + '</td>' +
                '<td class="px-6 py-4 text-sm font-bold text-gray-400 italic">' + esc(r.timestamp) + '</td>' +
                '<td class="px-6 py-4"><div class="flex items-center gap-2">' +
                '<span class="px-3 py-1 bg-' + sBg + ' text-' + sTxt +
                ' rounded-full text-[10px] font-black uppercase">' + esc(r.status) + '</span>' +
                resolveBtn + '</div></td></tr>';
        }

        function resolveFromLog(alertId, btn) {
            if (!alertId) return;
            btn.disabled = true;
            btn.innerHTML = '<span class="material-symbols-outlined text-xs animate-spin">progress_activity</span> Resolving…';

            PageMethods.ResolveAlert(alertId, function (success) {
                if (success) {
                    // Update the resolved row immediately
                    var row = document.getElementById('logrow-' + alertId);
                    if (row) {
                        var td = row.querySelector('td:last-child');
                        td.innerHTML = '<span class="px-3 py-1 bg-green-100 text-math-green ' +
                            'rounded-full text-[10px] font-black uppercase">Resolved</span>';
                    }
                    // Also hide resolve button on any other rows with same alertId
                    document.querySelectorAll('[data-alert-id="' + alertId + '"]').forEach(function (b) {
                        b.style.display = 'none';
                    });
                    // Reload page after short delay so stats cards update
                    setTimeout(function () { location.reload(); }, 800);
                } else {
                    btn.disabled = false;
                    btn.innerHTML = '<span class="material-symbols-outlined text-xs">check_circle</span> Resolve';
                }
            }, function () {
                btn.disabled = false;
                btn.innerHTML = '<span class="material-symbols-outlined text-xs">check_circle</span> Resolve';
            });
        }

        function noMoreRows() {
            return '<tr><td colspan="4" class="px-6 py-6 text-center text-xs font-black text-gray-300 uppercase tracking-widest">No additional records</td></tr>';
        }
        function showAuditError(msg) {
            var extra = document.getElementById('logBodyExtra');
            extra.innerHTML = '<tr><td colspan="4" class="px-6 py-4 text-center text-xs font-black text-red-400 uppercase">' + msg + '</td></tr>';
            extra.classList.remove('hidden');
        }
    </script>

</asp:Content>




