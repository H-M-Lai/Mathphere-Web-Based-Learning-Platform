<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="setCourseValidity.aspx.cs" Inherits="MathSphere.setCourseValidity" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere - Set Course Validity</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
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
                    fontFamily: { "display": ["Space Grotesk", "sans-serif"] },
                    borderRadius: { "DEFAULT": "1rem", "lg": "2rem", "xl": "3rem", "full": "9999px" }
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Space Grotesk', sans-serif; }
        
        /* Toggle switch */
        .toggle-wrapper { position: relative; display: inline-flex; align-items: center; cursor: pointer; }
        .toggle-track {
            width: 52px; height: 28px;
            background: #d1d5db;
            border-radius: 9999px;
            transition: background 0.25s ease;
            position: relative;
        }
        .toggle-track.on { background: #84cc16; }
        .toggle-thumb {
            position: absolute;
            top: 3px; left: 3px;
            width: 22px; height: 22px;
            background: white;
            border-radius: 50%;
            box-shadow: 0 1px 4px rgba(0,0,0,0.2);
            transition: transform 0.25s ease;
        }
        .toggle-track.on .toggle-thumb { transform: translateX(24px); }

        .button-shadow {
            box-shadow: 0 6px 0 0 #d4b105;
            transition: all 0.1s ease;
        }
        .button-shadow:hover { box-shadow: 0 2px 0 0 #d4b105; transform: translateY(4px); }
        .button-shadow:active { box-shadow: none; transform: translateY(6px); }
    </style>
</head>
<body class="min-h-screen relative overflow-x-hidden bg-gray-50">
    <form id="form1" runat="server">
        <!-- Decorative background -->
        <div class="fixed inset-0 pointer-events-none opacity-10 overflow-hidden">
            <span class="material-symbols-outlined absolute text-7xl top-20 left-[10%] rotate-12 text-blue-600">functions</span>
            <span class="material-symbols-outlined absolute text-8xl top-60 right-[5%] -rotate-12 text-green-500">change_history</span>
            <span class="material-symbols-outlined absolute text-6xl bottom-40 left-[15%] rotate-45 text-yellow-400">pie_chart</span>
            <span class="material-symbols-outlined absolute text-9xl bottom-10 right-[20%] -rotate-45 text-blue-600">architecture</span>
        </div>

        <!-- Hidden field to pass toggle state to server -->
        <asp:HiddenField ID="hdnAutoArchive" runat="server" Value="true" />

        <!-- Modal overlay -->
        <div class="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-[#1e3a8a]/20 backdrop-blur-md">
            <div class="bg-white w-full max-w-lg rounded-[2.5rem] shadow-[0_20px_50px_rgba(0,0,0,0.15)] border-2 border-gray-100 overflow-hidden">
                
                <!-- Header -->
                <div class="p-8 pb-0 flex flex-col items-center text-center">
                    <div class="size-16 bg-yellow-50 rounded-2xl flex items-center justify-center mb-4">
                        <span class="material-symbols-outlined text-yellow-400 text-4xl font-black">event_available</span>
                    </div>
                    <h3 class="text-3xl font-black text-[#1e3a8a] uppercase tracking-tight">Set Course Validity</h3>
                    <p class="text-gray-500 font-bold mt-1 uppercase tracking-widest text-xs">
                        <asp:Literal ID="litCourseName" runat="server" Text="Advanced Algebra II"></asp:Literal>
                    </p>
                </div>

                <!-- Fields -->
                <div class="p-8 space-y-6">
                    <asp:Panel ID="pnlError" runat="server" Visible="false"
                        CssClass="flex items-center gap-2 bg-red-50 border-2 border-red-200 rounded-2xl px-4 py-3">
                        <span class="material-symbols-outlined text-red-500 text-lg">error</span>
                        <asp:Label ID="lblError" runat="server"
                            CssClass="text-red-600 font-bold text-xs uppercase tracking-wide"></asp:Label>
                    </asp:Panel>
                    <div class="grid grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label class="block text-xs font-black uppercase tracking-widest text-[#1e3a8a]/60 ml-1">Start Date</label>
                            <div class="relative group">
                                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-blue-600 group-focus-within:text-[#1e3a8a] transition-colors text-xl pointer-events-none">calendar_today</span>
                                <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"
                                    CssClass="w-full pl-12 pr-4 py-4 bg-gray-50 border-2 border-gray-100 rounded-2xl focus:border-blue-600 focus:ring-0 font-bold text-[#1e3a8a] transition-all outline-none"></asp:TextBox>
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label class="block text-xs font-black uppercase tracking-widest text-[#1e3a8a]/60 ml-1">End Date</label>
                            <div class="relative group">
                                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-blue-600 group-focus-within:text-[#1e3a8a] transition-colors text-xl pointer-events-none">calendar_month</span>
                                <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"
                                    CssClass="w-full pl-12 pr-4 py-4 bg-gray-50 border-2 border-gray-100 rounded-2xl focus:border-blue-600 focus:ring-0 font-bold text-[#1e3a8a] transition-all outline-none"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <!-- Auto Archive Toggle (pure JS, value synced to hidden field) -->
                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-2xl border border-gray-100">
                        <div class="flex flex-col">
                            <span class="font-black text-sm text-[#1e3a8a] uppercase tracking-tight">Automatic Archiving</span>
                            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Archive course after end date</span>
                        </div>
                        <div class="toggle-wrapper" onclick="toggleAutoArchive()" id="toggleWrapper">
                            <div class="toggle-track on" id="toggleTrack">
                                <div class="toggle-thumb"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Date validation message -->
                    <div id="dateError" class="hidden text-red-500 text-xs font-bold uppercase tracking-widest text-center bg-red-50 rounded-xl p-3">
                        End date must be after start date.
                    </div>
                </div>

                <!-- Actions -->
                <div class="p-8 pt-0 flex flex-col gap-3">
                    <asp:Button ID="btnSaveValidity" runat="server" Text="SAVE VALIDITY 📅"
                        OnClick="btnSaveValidity_Click"
                        OnClientClick="return validateDates();"
                        CssClass="w-full bg-yellow-400 text-[#1e3a8a] font-black px-8 py-5 rounded-2xl button-shadow flex items-center justify-center gap-2 uppercase tracking-tighter text-lg cursor-pointer border-0" />

                    <asp:Button ID="btnCancel" runat="server" Text="CANCEL"
                        OnClientClick="history.back(); return false;"
                        CssClass="w-full bg-white text-gray-400 font-black px-8 py-4 rounded-2xl border-2 border-gray-100 hover:bg-gray-50 hover:text-[#1e3a8a] transition-all uppercase tracking-widest text-sm cursor-pointer border-0" />
                </div>
            </div>
        </div>
    </form>

    <script>
        var autoArchiveOn = true;

        function toggleAutoArchive() {
            autoArchiveOn = !autoArchiveOn;
            var track = document.getElementById('toggleTrack');
            var hidden = document.getElementById('<%= hdnAutoArchive.ClientID %>');
            if (autoArchiveOn) {
                track.classList.add('on');
                hidden.value = 'true';
            } else {
                track.classList.remove('on');
                hidden.value = 'false';
            }
        }

        function validateDates() {
            var startVal = document.getElementById('<%= txtStartDate.ClientID %>').value;
            var endVal = document.getElementById('<%= txtEndDate.ClientID %>').value;
            var errEl = document.getElementById('dateError');

            function showErr(msg) {
                errEl.textContent = msg;
                errEl.classList.remove('hidden');
            }
            errEl.classList.add('hidden');

            // End date required
            if (!endVal) {
                showErr('End date is required.');
                return false;
            }

            // Parse and check year lengths
            var startDate = startVal ? new Date(startVal) : null;
            var endDate = new Date(endVal);
            var maxYear = new Date().getFullYear() + 10;
            var today = new Date(); today.setHours(0, 0, 0, 0);

            if (startDate) {
                if (startDate.getFullYear() > maxYear) {
                    showErr('Start year is too far in the future (max ' + maxYear + ').');
                    return false;
                }
                if (startDate.getFullYear().toString().length !== 4) {
                    showErr('Start date year must be exactly 4 digits.');
                    return false;
                }
            }

            if (endDate.getFullYear().toString().length !== 4) {
                showErr('End date year must be exactly 4 digits.');
                return false;
            }
            if (endDate.getFullYear() > maxYear) {
                showErr('End year is too far in the future (max ' + maxYear + ').');
                return false;
            }
            if (endDate < today) {
                showErr('End date cannot be in the past.');
                return false;
            }
            if (startDate && endDate <= startDate) {
                showErr('End date must be after start date.');
                return false;
            }

            // Sync hidden toggle value before postback
            document.getElementById('<%= hdnAutoArchive.ClientID %>').value =
                autoArchiveOn ? 'true' : 'false';
            return true;
        }

        // Clamp year to 4 digits as user types
        function clampYear(inputId) {
            var input = document.getElementById(inputId);
            if (!input || !input.value) return;
            var parts = input.value.split('-');
            // parts[0] is the year portion in yyyy-mm-dd
            if (parts[0] && parts[0].length > 4) {
                parts[0] = parts[0].substring(0, 4);
                input.value = parts.join('-');
            }
        }

        window.onload = function () {
            var params     = new URLSearchParams(window.location.search);
            var courseName = params.get('courseName');
            if (courseName) {
                var litEl = document.querySelector('[id$="litCourseName"]');
                if (litEl) litEl.textContent = decodeURIComponent(courseName);
            }
            var arch = params.get('autoArchive');
            if (arch === 'false' && autoArchiveOn) {
                autoArchiveOn = true;
                toggleAutoArchive();
            }

            // Attach year clamping to both date inputs
            var sd = document.getElementById('<%= txtStartDate.ClientID %>');
            var ed = document.getElementById('<%= txtEndDate.ClientID %>');
            if (sd) sd.addEventListener('change', function() { clampYear('<%= txtStartDate.ClientID %>'); });
            if (ed) ed.addEventListener('change', function () { clampYear('<%= txtEndDate.ClientID %>'); });
        };
    </script>
</body>
</html>
