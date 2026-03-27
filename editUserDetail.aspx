<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="editUserDetail.aspx.cs" Inherits="MathSphere.editUserDetail" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere Admin - Edit User Details</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="<%= ResolveUrl("~/Styles/editUserDetail.css") %>" rel="stylesheet" type="text/css" />
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
</head>
<body class="min-h-screen flex relative overflow-hidden">

<form id="form1" runat="server" class="w-full min-h-screen flex">

    <asp:HiddenField ID="hdnUserId" runat="server" />

    <%-- SIDEBAR --%>
    <aside class="w-72 bg-white border-r-4 border-math-blue/10 flex flex-col sticky top-0 h-screen z-10 flex-shrink-0">
        <div class="p-8">
            <div class="flex items-center gap-3 mb-12">
                <div class="size-10 bg-primary rounded-xl flex items-center justify-center shadow-md shrink-0 border-b-4 border-yellow-600/20">
                    <span class="material-symbols-outlined text-math-dark-blue font-bold text-2xl">variables</span>
                </div>
                <div class="flex flex-col">
                    <h1 class="text-math-dark-blue text-xl font-black tracking-tighter italic leading-none">MATHSPHERE</h1>
                    <span class="text-[10px] font-black uppercase text-gray-400 tracking-widest leading-none mt-1">Admin Control</span>
                </div>
            </div>
            <nav class="flex flex-col gap-2">
                <a class="flex items-center gap-3 px-4 py-3 text-gray-500 hover:bg-gray-100 rounded-xl transition-all group text-sm font-black uppercase" href="<%= ResolveUrl("~/adminDashboard.aspx") %>">
                    <span class="material-symbols-outlined text-xl group-hover:text-math-blue">dashboard</span>
                    <span>Dashboard</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 bg-math-blue text-white rounded-xl shadow-lg shadow-math-blue/20 text-sm font-black uppercase" href="<%= ResolveUrl("~/userManagement.aspx") %>">
                    <span class="material-symbols-outlined text-xl fill-icon">manage_accounts</span>
                    <span>User Management</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 text-gray-500 hover:bg-gray-100 rounded-xl transition-all group text-sm font-black uppercase" href="<%= ResolveUrl("~/systemSetting.aspx") %>">
                    <span class="material-symbols-outlined text-xl group-hover:text-math-blue">settings</span>
                    <span>System Settings</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 text-gray-500 hover:bg-gray-100 rounded-xl transition-all group text-sm font-black uppercase" href="<%= ResolveUrl("~/forumModeration.aspx") %>">
                    <span class="material-symbols-outlined text-xl group-hover:text-math-blue">forum</span>
                    <span>Forum Moderation</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 text-gray-500 hover:bg-gray-100 rounded-xl transition-all group text-sm font-black uppercase" href="<%= ResolveUrl("~/AdminUI/helpCenterHub.aspx") %>">
                    <span class="material-symbols-outlined text-xl group-hover:text-math-blue">help_center</span>
                    <span>Help Center</span>
                </a>
            </nav>
        </div>
        <div class="mt-auto p-6 border-t-2 border-gray-50">
            <div class="bg-gray-50 flex items-center gap-3 p-3 rounded-2xl border-2 border-gray-100 shadow-sm">
                <div class="size-10 rounded-full border-2 border-primary overflow-hidden bg-yellow-100 flex-shrink-0">
                    <span class="material-symbols-outlined text-primary text-2xl flex items-center justify-center h-full w-full fill-icon">admin_panel_settings</span>
                </div>
                <div class="flex flex-col">
                    <div class="text-sm font-black text-math-dark-blue leading-none">SysAdmin_01</div>
                    <div class="text-[10px] font-bold text-gray-400 uppercase tracking-tighter mt-1">Super Admin</div>
                </div>
            </div>
        </div>
    </aside>

    <%-- BACKGROUND MAIN (blurred/dimmed) --%>
    <main class="flex-1 p-10 overflow-y-auto min-w-0 z-10">
        <header class="mb-10 flex justify-between items-end">
            <div>
                <h2 class="text-4xl font-black text-math-dark-blue mb-2">User Management</h2>
                <p class="text-lg text-gray-500 font-medium italic">Manage roles, reset security credentials, and control platform access.</p>
            </div>
            <button type="button" disabled
                class="bg-primary text-math-dark-blue font-black px-8 py-4 rounded-2xl shadow-[0_6px_0_0_#d4af37] flex items-center gap-3 uppercase tracking-tighter opacity-60 cursor-default">
                <span class="material-symbols-outlined font-bold">person_add</span>
                Add New User
            </button>
        </header>

        <%-- Ghost table behind the modal --%>
        <div class="bg-white rounded-[2.5rem] p-8 shadow-xl border-2 border-gray-100 mb-10 opacity-40 pointer-events-none select-none">
            <div class="h-14 bg-gray-100 rounded-2xl mb-8 w-full"></div>
            <table class="w-full">
                <thead>
                    <tr class="border-b-4 border-gray-50">
                        <th class="px-6 py-4 text-[10px] font-black text-gray-300 uppercase tracking-widest">User Details</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-300 uppercase tracking-widest">Email Address</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-300 uppercase tracking-widest">Role Assigned</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-300 uppercase tracking-widest">Status</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-300 uppercase tracking-widest text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y-2 divide-gray-50">
                    <tr>
                        <td class="px-6 py-5"><div class="h-10 bg-gray-100 rounded-xl w-40"></div></td>
                        <td class="px-6 py-5"><div class="h-4 bg-gray-100 rounded-lg w-44"></div></td>
                        <td class="px-6 py-5"><div class="h-6 bg-blue-50 rounded-full w-20"></div></td>
                        <td class="px-6 py-5"><div class="h-5 bg-green-50 rounded-full w-24"></div></td>
                        <td class="px-6 py-5"><div class="flex justify-end gap-2"><div class="size-9 bg-gray-100 rounded-xl"></div><div class="size-9 bg-gray-100 rounded-xl"></div><div class="size-9 bg-gray-100 rounded-xl"></div></div></td>
                    </tr>
                    <tr>
                        <td class="px-6 py-5"><div class="h-10 bg-gray-100 rounded-xl w-36"></div></td>
                        <td class="px-6 py-5"><div class="h-4 bg-gray-100 rounded-lg w-40"></div></td>
                        <td class="px-6 py-5"><div class="h-6 bg-green-50 rounded-full w-20"></div></td>
                        <td class="px-6 py-5"><div class="h-5 bg-green-50 rounded-full w-24"></div></td>
                        <td class="px-6 py-5"><div class="flex justify-end gap-2"><div class="size-9 bg-gray-100 rounded-xl"></div><div class="size-9 bg-gray-100 rounded-xl"></div><div class="size-9 bg-gray-100 rounded-xl"></div></div></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </main>

    <%-- EDIT MODAL (fixed overlay over everything) --%>
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4 eud-modal-overlay" id="editModal"
         style="background:rgba(15,23,42,0.55);backdrop-filter:blur(4px);">
        <div class="bg-white w-full max-w-4xl rounded-[3rem] shadow-[0_32px_64px_-12px_rgba(30,58,138,0.3)] border-8 border-white flex overflow-hidden relative eud-card">

            <%-- LEFT PANE --%>
            <div class="w-1/3 bg-math-blue/5 p-12 flex flex-col items-center justify-center relative overflow-hidden">
                <div class="absolute top-0 left-0 w-full h-full opacity-10 pointer-events-none">
                    <span class="material-symbols-outlined absolute text-8xl -top-10 -left-10 rotate-12">calculate</span>
                    <span class="material-symbols-outlined absolute text-8xl -bottom-10 -right-10 -rotate-12">functions</span>
                </div>
                <div class="relative z-10 space-y-8 text-center">
                    <div class="relative inline-block">
                        <span class="material-symbols-outlined eud-gear fill-icon text-math-blue"
                              style="font-size:100px;font-variation-settings:'FILL' 1,'wght' 700,'GRAD' 0,'opsz' 48;">settings</span>
                        <span class="material-symbols-outlined eud-edit-badge fill-icon text-primary absolute -bottom-4 -right-4 drop-shadow-lg"
                              style="font-size:60px;font-variation-settings:'FILL' 1,'wght' 700,'GRAD' 0,'opsz' 48;">edit_square</span>
                    </div>
                    <div>
                        <h4 class="text-math-dark-blue font-black text-xl italic leading-tight">ADMIN<br/>PANEL</h4>
                        <div class="h-1.5 w-12 bg-primary mx-auto mt-4 rounded-full"></div>
                    </div>
                </div>
            </div>

            <%-- RIGHT PANE — form --%>
            <div class="flex-1 p-12">
                <div class="flex justify-between items-start mb-8">
                    <div>
                        <h3 class="text-3xl font-black text-math-dark-blue tracking-tighter italic">EDIT USER DETAILS</h3>
                        <p class="text-xs font-bold text-gray-400 uppercase tracking-[0.2em] mt-1">Management Portal v2.0</p>
                    </div>
                    <a href="userManagement.aspx"
                       class="size-12 rounded-2xl bg-gray-100 hover:bg-red-50 text-gray-400 hover:text-red-500 flex items-center justify-center transition-all eud-close-btn">
                        <span class="material-symbols-outlined font-bold">close</span>
                    </a>
                </div>

                <%-- Error panel --%>
                <asp:Panel ID="pnlError" runat="server" Visible="false"
                    CssClass="mb-6 p-4 bg-red-50 border-2 border-red-100 rounded-2xl flex items-center gap-3">
                    <span class="material-symbols-outlined text-red-400 fill-icon">error_circle</span>
                    <asp:Literal ID="litError" runat="server" />
                </asp:Panel>

                <div class="space-y-6">

                    <%-- Full Name + Email --%>
                    <div class="grid grid-cols-2 gap-6">
                        <div class="space-y-2">
                            <label class="eud-label">Full Name</label>
                            <div class="relative">
                                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">person</span>
                                <asp:TextBox ID="txtFullName" runat="server" CssClass="eud-input pl-12" placeholder="Full name" />
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label class="eud-label">Email Address</label>
                            <div class="relative">
                                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">alternate_email</span>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="eud-input pl-12" placeholder="Email address" TextMode="Email" />
                            </div>
                        </div>
                    </div>

                    <%-- Role dropdown --%>
                    <div class="space-y-2">
                        <label class="eud-label">Assign User Role</label>
                        <div class="relative">
                            <asp:DropDownList ID="ddlRole" runat="server"
                                CssClass="eud-input appearance-none cursor-pointer font-black text-sm uppercase tracking-wider px-6">
                                <asp:ListItem Text="Student"              Value="student"   />
                                <asp:ListItem Text="Teacher"              Value="teacher"   />
                                <asp:ListItem Text="System Administrator" Value="admin"     />
                                <asp:ListItem Text="Content Moderator"    Value="moderator" />
                            </asp:DropDownList>
                            <span class="material-symbols-outlined fill-icon absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-math-blue"
                                  style="font-variation-settings:'FILL' 1,'wght' 700,'GRAD' 0,'opsz' 48;">expand_circle_down</span>
                        </div>
                    </div>

                    <%-- Account Status toggle --%>

                    <div class="flex items-center justify-between p-6 bg-gray-50 rounded-3xl border-2 border-dashed border-gray-200">
                        <div class="flex items-center gap-4">
                            <div class="p-3 bg-white rounded-2xl shadow-sm">
                                <span class="material-symbols-outlined text-math-dark-blue">power_settings_new</span>
                            </div>
                            <div>
                                <p class="text-sm font-black text-math-dark-blue uppercase tracking-tight">Account Status</p>
                                <p class="text-[10px] font-bold text-gray-400 uppercase">Toggle platform access</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-4">
                            <span class="text-[10px] font-black uppercase text-gray-400" id="statusLabel">Active</span>
                            <div class="flex items-center">
                                <input type="checkbox"
                                       id="modal_status_toggle"
                                       runat="server"
                                       ClientIDMode="Static"
                                       class="toggle-checkbox hidden" />
                                <label class="toggle-label w-14 h-7 rounded-full cursor-pointer p-1 transition-colors duration-300 flex items-center"
                                       for="modal_status_toggle"
                                       id="toggleTrack"
                                       style="background:#84cc16;">
                                    <div class="toggle-dot w-5 h-5 bg-white rounded-full shadow-md transition-transform duration-300 translate-x-7"
                                         id="toggleDot"></div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <%-- Buttons --%>
                    <div class="flex gap-4 pt-4">
                        <asp:Button ID="btnSaveChanges" runat="server" Text="Save Changes"
                            CssClass="eud-save-btn"
                            OnClick="btnSaveChanges_Click"
                            OnClientClick="return validateForm()" />
                        <a href="userManagement.aspx"
                           class="flex-1 bg-white border-4 border-math-blue text-math-blue font-black py-5 rounded-2xl hover:bg-math-blue hover:text-white transition-all uppercase tracking-tighter text-sm flex items-center justify-center">
                            CANCEL
                        </a>
                    </div>

                </div>
            </div>

        </div>
    </div>

    <%-- Decorative bg icons --%>
    <div class="fixed inset-0 pointer-events-none opacity-[0.03] overflow-hidden -z-10">
        <span class="material-symbols-outlined absolute text-[15rem] top-20 left-[10%] rotate-12 text-math-blue">person_search</span>
        <span class="material-symbols-outlined absolute text-[20rem] top-60 right-[5%] -rotate-12 text-math-green">group</span>
        <span class="material-symbols-outlined absolute text-[12rem] bottom-40 left-[15%] rotate-45 text-primary">badge</span>
        <span class="material-symbols-outlined absolute text-[25rem] bottom-10 right-[20%] -rotate-45 text-math-blue">manage_accounts</span>
    </div>

</form>

<div id="eudToast" class="eud-toast"></div>

<script>
// Toggle switch sync
(function () {
    const cb    = document.getElementById('modal_status_toggle');
    const track = document.getElementById('toggleTrack');
    const dot   = document.getElementById('toggleDot');
    const label = document.getElementById('statusLabel');

    function sync() {
        const on = cb && cb.checked;
        if (track) track.style.background = on ? '#84cc16' : '#d1d5db';
        if (dot)   dot.style.transform    = on ? 'translateX(1.75rem)' : 'translateX(0)';
        if (label) label.textContent      = on ? 'Active' : 'Disabled';
    }

    if (cb) { cb.addEventListener('change', sync); sync(); }
})();

// Client-side validation
function validateForm() {
    const name  = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
    const email = document.getElementById('<%= txtEmail.ClientID    %>').value.trim();
        if (!name) { showToast('Please enter the full name.'); return false; }
        if (!email) { showToast('Please enter an email address.'); return false; }
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            showToast('Please enter a valid email address.'); return false;
        }
        return true;
    }

    function showToast(msg) {
        const el = document.getElementById('eudToast');
        if (!el) return;
        el.textContent = msg;
        el.classList.add('visible');
        setTimeout(() => el.classList.remove('visible'), 3200);
    }
</script>
</body>
</html>


