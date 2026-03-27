<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="resetUserPassword.aspx.cs" Inherits="MathSphere.resetUserPassword" %>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere Admin - Reset User Password</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="<%= ResolveUrl("~/Styles/resetUserPassword.css") %>" rel="stylesheet" />
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary":          "#f9d006",
                        "background-light": "#f8f8f5",
                        "math-blue":        "#2563eb",
                        "math-green":       "#84cc16",
                        "math-dark-blue":   "#1e3a8a",
                    },
                    fontFamily: { "display": ["Space Grotesk", "sans-serif"] },
                    borderRadius: { "DEFAULT": "1rem", "lg": "2rem", "xl": "3rem", "full": "9999px" }
                },
            },
        }
    </script>
</head>
<body class="min-h-screen flex relative">
<form id="form1" runat="server" class="w-full min-h-screen flex">

    <%-- Hidden fields carry data between server and client --%>
    <asp:HiddenField ID="hdnTargetUserId"   runat="server" />
    <asp:HiddenField ID="hdnTargetUserName" runat="server" />
    <asp:HiddenField ID="hdnTargetEmail"    runat="server" />

    <%-- BLURRED BACKGROUND — user management table (non-interactive) --%>
    <div class="blur-[3px] pointer-events-none select-none w-full">

        <%-- Sidebar --%>
        <aside class="w-64 min-h-screen bg-white border-r-2 border-gray-100 flex flex-col fixed top-0 left-0 z-10">
            <div class="p-6 border-b-2 border-gray-100">
                <div class="flex items-center gap-3">
                    <div class="size-9 bg-primary rounded-xl flex items-center justify-center shadow-md">
                        <span class="material-symbols-outlined text-math-dark-blue text-xl fill-icon">calculate</span>
                    </div>
                    <div>
                        <h1 class="text-math-dark-blue text-base font-black tracking-tighter italic leading-none">MATHSPHERE</h1>
                        <span class="text-[9px] font-bold text-math-blue tracking-[0.15em] uppercase">Admin Panel</span>
                    </div>
                </div>
            </div>
            <nav class="flex-1 p-4 space-y-1">
                <a href="#" class="flex items-center gap-3 px-4 py-3 rounded-2xl bg-math-dark-blue text-white font-black text-xs uppercase tracking-widest">
                    <span class="material-symbols-outlined fill-icon text-primary">group</span>Users
                </a>
                <a href="#" class="flex items-center gap-3 px-4 py-3 rounded-2xl text-gray-400 font-black text-xs uppercase tracking-widest hover:bg-gray-50 transition-colors">
                    <span class="material-symbols-outlined">layers</span>Courses
                </a>
                <a href="#" class="flex items-center gap-3 px-4 py-3 rounded-2xl text-gray-400 font-black text-xs uppercase tracking-widest hover:bg-gray-50 transition-colors">
                    <span class="material-symbols-outlined">bar_chart</span>Reports
                </a>
            </nav>
        </aside>

        <%-- Main area --%>
        <main class="ml-64 p-10 relative z-10">
            <div class="mb-8 flex items-center justify-between">
                <div>
                    <p class="text-[10px] font-black text-math-green uppercase tracking-[0.2em] mb-1">ADMIN PANEL</p>
                    <h2 class="text-4xl font-black text-math-dark-blue">User Management</h2>
                </div>
            </div>
            <%-- Stat Cards row --%>
            <div class="grid grid-cols-4 gap-5 mb-8">
                <div class="bg-white rounded-3xl p-6 border-2 border-gray-100 shadow-sm">
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Total Users</p>
                    <p class="text-3xl font-black text-math-dark-blue">12,492</p>
                </div>
                <div class="bg-white rounded-3xl p-6 border-2 border-gray-100 shadow-sm">
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Monthly Growth</p>
                    <p class="text-3xl font-black text-math-green">+240</p>
                </div>
                <div class="bg-white rounded-3xl p-6 border-2 border-gray-100 shadow-sm">
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Active Rate</p>
                    <p class="text-3xl font-black text-math-blue">94.2%</p>
                </div>
                <div class="bg-white rounded-3xl p-6 border-2 border-gray-100 shadow-sm">
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Staff & Admins</p>
                    <p class="text-3xl font-black text-primary">156</p>
                </div>
            </div>
            <%-- Table --%>
            <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-xl overflow-hidden">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-gray-50 border-b-4 border-math-blue/10">
                            <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-gray-400">User</th>
                            <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-gray-400">Email</th>
                            <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-gray-400">Role</th>
                            <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-gray-400">Status</th>
                            <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-gray-400 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr class="hover:bg-gray-50/50">
                            <td class="px-6 py-5">
                                <div class="flex items-center gap-4">
                                    <div class="size-12 rounded-2xl bg-blue-100 overflow-hidden border-2 border-white shadow-sm">
                                        <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuB-gsV24Ln-4Xx8Z9CizuY-NQLzPz_C4KCz4Lee6kDGTkZ-Ni0Bx5fmsd4cRFDkKaoHd6uFxsrI8ABSJ__lkGmLlTWGfaa9RBUVR5_22-XVKsrV4a_N35K6JL-hkCH9YKPVf5wsYTPQIm_JEbdGzEdFjpz-JJM3RrTmtMh3cQoAlnt9cI-D_RvURwEPClwb1ZjjehRrxd6gUxdqSLASasLtQ4oMEYskIzrWoW81KnC6nh8Kcah7dNptBBb_3qc-2ERyJcnveUAIbA" alt="Arthur" class="w-full h-full object-cover"/>
                                    </div>
                                    <div>
                                        <div class="font-black text-sm text-math-dark-blue">Prof. Arthur Pendragon</div>
                                        <div class="text-[10px] font-bold text-gray-400 uppercase tracking-tighter">ID: #MS-2940</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-5"><span class="text-sm font-medium text-gray-600">arthur.p@mathsphere.edu</span></td>
                            <td class="px-6 py-5"><span class="px-4 py-1.5 bg-blue-100 text-math-blue rounded-full text-[10px] font-black uppercase tracking-wider border border-blue-200">Teacher</span></td>
                            <td class="px-6 py-5"><span class="text-[10px] font-black uppercase text-math-green">Active</span></td>
                            <td class="px-6 py-5 text-right"><div class="flex justify-end gap-2">
                                <div class="size-9 rounded-xl bg-primary/10 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-primary">lock_reset</span></div>
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">edit</span></div>
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">delete</span></div>
                            </div></td>
                        </tr>
                        <tr>
                            <td class="px-6 py-5">
                                <div class="flex items-center gap-4">
                                    <div class="size-12 rounded-2xl bg-green-100 overflow-hidden border-2 border-white shadow-sm">
                                        <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuBCyt5_f0oCZP0Z9e-zwvCwWH4qlObX3d-i_RUpsgKSNY3h2w_blawl7FEH6GtSonm8Inndufdpi27ZlyVHFWiSlvZUxilaN53E84tJg2mOU8_jFxWDNcV52P-e38A58N5ODdgSV4RsZBGepkSWYtx2HXFSyAW7z48XjNpmqfSkWo40oArcre9yn6Xn03Nw0tpr2ACNz0DrYI7APEXb9aQJRQjHs5eXaHt-Y1IlnzyM7NDFre9WKg7o6Wc7-XoI8yJ_1ZXZmTHfkw" alt="Sarah" class="w-full h-full object-cover"/>
                                    </div>
                                    <div>
                                        <div class="font-black text-sm text-math-dark-blue">Sarah Jenkins</div>
                                        <div class="text-[10px] font-bold text-gray-400 uppercase tracking-tighter">ID: #MS-8812</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-5"><span class="text-sm font-medium text-gray-600">s.jenkins@mathsphere.edu</span></td>
                            <td class="px-6 py-5"><span class="px-4 py-1.5 bg-green-100 text-math-green rounded-full text-[10px] font-black uppercase tracking-wider border border-green-200">Student</span></td>
                            <td class="px-6 py-5"><span class="text-[10px] font-black uppercase text-math-green">Active</span></td>
                            <td class="px-6 py-5 text-right"><div class="flex justify-end gap-2">
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">lock_reset</span></div>
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">edit</span></div>
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">delete</span></div>
                            </div></td>
                        </tr>
                        <tr>
                            <td class="px-6 py-5">
                                <div class="flex items-center gap-4">
                                    <div class="size-12 rounded-2xl bg-gray-100 overflow-hidden border-2 border-white shadow-sm flex items-center justify-center">
                                        <span class="material-symbols-outlined text-gray-400 fill-icon">person</span>
                                    </div>
                                    <div>
                                        <div class="font-black text-sm text-gray-400">Marcus Wright</div>
                                        <div class="text-[10px] font-bold text-gray-300 uppercase tracking-tighter">ID: #MS-7721</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-5"><span class="text-sm font-medium text-gray-400">m.wright@mathsphere.com</span></td>
                            <td class="px-6 py-5"><span class="px-4 py-1.5 bg-green-100 text-math-green rounded-full text-[10px] font-black uppercase tracking-wider border border-green-200">Student</span></td>
                            <td class="px-6 py-5"><span class="text-[10px] font-black uppercase text-gray-400">Disabled</span></td>
                            <td class="px-6 py-5 text-right"><div class="flex justify-end gap-2">
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">lock_reset</span></div>
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">edit</span></div>
                                <div class="size-9 rounded-xl bg-gray-50 flex items-center justify-center"><span class="material-symbols-outlined text-xl text-gray-400">delete</span></div>
                            </div></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <%-- MODAL BACKDROP --%>
    <div class="fixed inset-0 rp-overlay z-50 flex items-center justify-center p-4" id="resetModal">
        <%-- Modal card --%>
        <div class="rp-card bg-white w-full max-w-[520px] rounded-[1.75rem] border-4 border-math-blue shadow-2xl overflow-hidden relative text-center flex flex-col items-center">

            <%-- Subtle decorative math symbols behind content --%>
            <div class="absolute -top-8 -left-8 opacity-[0.04] pointer-events-none select-none">
                <span class="material-symbols-outlined" style="font-size:160px;">percent</span>
            </div>
            <div class="absolute -bottom-8 -right-8 opacity-[0.04] pointer-events-none select-none">
                <span class="material-symbols-outlined" style="font-size:160px;">functions</span>
            </div>

            <%-- Content wrapper (sits above decorative layer) --%>
            <div class="relative z-10 w-full flex flex-col items-center px-8 pt-10 pb-8">

                <%-- Lock + Key illustration --%>
                <div class="rp-icon-cluster mb-7">
                    <%-- Yellow lock card --%>
                    <div class="rp-lock-card">
                        <span class="material-symbols-outlined fill-icon rp-lock-icon">lock</span>
                    </div>
                    <%-- Blue key badge overlapping --%>
                    <div class="rp-key-badge">
                        <span class="material-symbols-outlined fill-icon rp-key-icon">key</span>
                    </div>
                    <%-- Soft glow behind cluster --%>
                    <div class="rp-glow"></div>
                </div>

                <%-- Headline --%>
                <h2 class="text-math-blue text-3xl font-black tracking-tight uppercase mb-4">
                    Reset User Password?
                </h2>

                <%-- Body copy — user name injected by server --%>
                <p class="text-gray-600 text-[1.05rem] font-medium leading-relaxed mb-8 max-w-[380px]">
                    This will generate a temporary
                    <span class="font-bold text-math-blue underline decoration-primary decoration-4 underline-offset-4">magic link</span>
                    for <span id="rpUserName" class="font-black text-math-dark-blue">
                        <asp:Label ID="lblUserName" runat="server" Text="this user"></asp:Label>
                    </span>
                    to set a new password. The old password will be deactivated immediately.
                </p>

                <%-- Notify checkbox --%>
                <div class="flex items-center gap-3 mb-8 cursor-pointer rp-checkbox-wrap group" onclick="toggleNotify()">
                    <div class="relative flex items-center justify-center">
                        <asp:CheckBox ID="chkNotify" runat="server" CssClass="rp-hidden-chk" Checked="true"/>
                        <%-- Visual checkbox --%>
                        <div id="chkVisual" class="rp-chk-box rp-chk-on">
                            <span class="material-symbols-outlined text-white rp-chk-tick">check</span>
                        </div>
                    </div>
                    <label class="text-gray-700 font-semibold cursor-pointer select-none text-sm">
                        Send notification to user
                    </label>
                </div>

                <%-- Action buttons --%>
                <div class="flex flex-col sm:flex-row gap-3 w-full">
                    <asp:Button ID="btnConfirmReset" runat="server"
                        Text="Yes, Reset Password"
                        CssClass="rp-confirm-btn"
                        OnClick="btnConfirmReset_Click" />
                    <button type="button" onclick="cancelReset()"
                        class="rp-cancel-btn">
                        Cancel
                    </button>
                </div>
            </div>
        </div>
    </div>

    <%-- TOAST --%>
    <div class="um-toast" id="umToast"></div>

    <%-- SUCCESS BANNER (shown after confirm) --%>
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="fixed inset-0 rp-overlay z-50 flex items-center justify-center p-4">
            <div class="rp-card bg-white w-full max-w-[480px] rounded-[1.75rem] border-4 border-math-green shadow-2xl overflow-hidden text-center px-8 py-10 relative flex flex-col items-center">
                <div class="absolute -top-8 -left-8 opacity-[0.04] pointer-events-none">
                    <span class="material-symbols-outlined" style="font-size:160px;">check_circle</span>
                </div>
                <div class="size-20 bg-math-green/10 rounded-3xl flex items-center justify-center mb-6 shadow-inner">
                    <span class="material-symbols-outlined fill-icon text-math-green" style="font-size:48px;font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 48;">mark_email_read</span>
                </div>
                <h2 class="text-math-green text-3xl font-black tracking-tight uppercase mb-3">Magic Link Sent!</h2>
                <p class="text-gray-500 text-base font-medium leading-relaxed mb-8 max-w-[340px]">
                    A password reset link has been sent to
                    <span class="font-black text-math-dark-blue">
                        <asp:Label ID="lblSuccessName" runat="server" Text="the user"></asp:Label>
                    </span>.
                    The old password is now deactivated.
                </p>
                <button type="button" onclick="window.location.href='userManagement.aspx'"
                    class="rp-back-btn">
                    <span class="material-symbols-outlined text-lg">arrow_back</span>
                    Back to User Management
                </button>
            </div>
        </div>
    </asp:Panel>

</form>
<script>
    // Toggle notify checkbox visual
    function toggleNotify() {
        var real = document.querySelector('.rp-hidden-chk input[type="checkbox"]') ||
                   document.getElementById('<%= chkNotify.ClientID %>');
        var visual = document.getElementById('chkVisual');
        if (!real || !visual) return;
        real.checked = !real.checked;
        visual.className = real.checked ? 'rp-chk-box rp-chk-on' : 'rp-chk-box rp-chk-off';
    }

    // Cancel: go back to user management
    function cancelReset() {
        window.location.href = 'userManagement.aspx';
    }

    // Toast helper (shared with userManagement.aspx pattern)
    function showToast(msg) {
        var el = document.getElementById('umToast');
        if (!el) return;
        el.textContent = msg;
        el.classList.add('visible');
        setTimeout(function () { el.classList.remove('visible'); }, 3200);
    }
</script>
</body>
</html>

