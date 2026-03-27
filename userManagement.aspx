<%@ Page Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="userManagement.aspx.cs" Inherits="MathSphere.userManagement" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere Admin - User Management
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/userManagement.css") %>" rel="stylesheet" />
    <style>
        .um-modal-overlay   { background: rgba(15,23,42,0.5); backdrop-filter: blur(4px); }
        .um-disable-overlay { background: rgba(15,23,42,0.5); backdrop-filter: blur(4px); }
        .um-toast {
            position: fixed; bottom: 2rem; left: 50%; transform: translateX(-50%) translateY(100px);
            background: #1e3a8a; color: #fff;
            padding: 0.875rem 1.75rem; border-radius: 9999px;
            font-family: 'Space Grotesk', sans-serif; font-weight: 900;
            font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.08em;
            box-shadow: 0 8px 32px rgba(37,99,235,0.3);
            transition: transform 0.4s cubic-bezier(.34,1.56,.64,1), opacity 0.3s;
            opacity: 0; z-index: 9999; pointer-events: none; white-space: nowrap;
        }
        .um-toast.visible { transform: translateX(-50%) translateY(0); opacity: 1; }
        .um-input {
            width: 100%; padding: 0.875rem 1rem;
            background: #f9fafb; border: 2px solid #f3f4f6;
            border-radius: 1rem; font-family: 'Space Grotesk', sans-serif;
            font-weight: 700; font-size: 0.875rem; color: #1e3a8a;
            outline: none; transition: border-color 0.2s;
        }
        .um-input:focus { border-color: #2563eb; }
        .um-label {
            display: block; font-size: 0.7rem; font-weight: 900;
            text-transform: uppercase; letter-spacing: 0.1em; color: #6b7280; margin-bottom: 0.25rem;
        }
        .dm-confirm-btn {
            width: 100%; padding: 1rem 2.5rem;
            background: #ef4444; color: #fff;
            font-family: 'Space Grotesk', sans-serif; font-weight: 900;
            font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.1em;
            border: 0; border-radius: 1rem; cursor: pointer;
            box-shadow: 0 4px 0 #b91c1c; transition: all 0.15s;
        }
        .dm-confirm-btn:hover  { background: #dc2626; }
        .dm-confirm-btn:active { transform: translateY(2px); box-shadow: none; }
        .toggle-dot.translate-x-5 { transform: translateX(1.25rem); }
        .um-select-clean {
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            background-image: none !important;
        }
        .um-select-clean::-ms-expand { display: none; }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Hidden fields for modals --%>
    <asp:HiddenField ID="hdnDeleteUserId"  runat="server" />
    <asp:HiddenField ID="hdnDisableUserId" runat="server" />
    <asp:HiddenField ID="hdnEnableUserId"  runat="server" />
    <asp:HiddenField ID="hdnResetUserId"   runat="server" />

    <%-- Hidden postback buttons (clicked from JS) --%>
    <asp:Button ID="btnEnableUser"    runat="server" Style="display:none" OnClick="btnEnableUser_Click"    CausesValidation="false" />
    <asp:Button ID="btnConfirmReset"  runat="server" Style="display:none" OnClick="btnConfirmReset_Click"  CausesValidation="false" />

    <!-- DISABLE MODAL -->
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4 um-disable-overlay hidden" id="disableModal">
        <div class="w-full max-w-2xl bg-white rounded-[2.5rem] shadow-2xl overflow-hidden border border-slate-200">
            <div class="bg-red-50 px-10 pt-10 pb-8 flex flex-col items-center text-center">
                <div class="w-20 h-20 bg-white rounded-3xl flex items-center justify-center shadow-lg mb-6">
                    <span class="material-symbols-outlined fill-icon text-red-500"
                          style="font-size:48px;font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 48;">person_off</span>
                </div>
                <h1 class="text-3xl font-black text-slate-800 uppercase tracking-tight mb-2">Disable User Account?</h1>
                <p class="text-slate-600 text-lg leading-snug">
                    You are about to suspend all access for <span id="disableUserName" class="font-black text-slate-900">this user</span>
                </p>
            </div>
            <div class="px-10 pt-8 pb-10">
                <div class="bg-slate-50 rounded-2xl p-6 border border-slate-100 mb-8">
                    <p class="text-slate-600 leading-relaxed text-center text-sm">
                        This user will no longer be able to log in, access course materials, or participate in community forums.
                        This action can be reversed later in User Management.
                    </p>
                </div>
                <div class="flex items-center justify-center gap-3 mb-10">
                    <input type="checkbox" id="chkNotifyDisable" runat="server"
                           class="w-5 h-5 rounded border-slate-300 text-red-500 focus:ring-red-500 cursor-pointer" />
                    <label for="chkNotifyDisable" class="text-slate-700 font-medium select-none cursor-pointer text-sm">
                        Notify user about this account suspension via email
                    </label>
                </div>
                <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
                    <asp:Button ID="btnConfirmDisable" runat="server" Text="Confirm Disable"
                        CssClass="dm-confirm-btn sm:w-auto" OnClick="btnConfirmDisable_Click" />
                    <button type="button" onclick="closeDisableModal()"
                        class="w-full sm:w-auto px-10 py-4 bg-white text-slate-500 font-black rounded-2xl border-2 border-slate-200 hover:bg-slate-50 transition-colors uppercase tracking-wider text-sm">
                        Cancel
                    </button>
                </div>
            </div>
            <div class="h-2 bg-gradient-to-r from-red-500 via-orange-400 to-red-500 opacity-20"></div>
        </div>
    </div>

    <!-- DELETE MODAL -->
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4 um-modal-overlay hidden" id="deleteModal">
        <div class="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl border-4 border-red-100 overflow-hidden text-center p-10">
            <div class="size-16 bg-red-50 rounded-2xl flex items-center justify-center mx-auto mb-5">
                <span class="material-symbols-outlined text-red-500 text-3xl fill-icon">delete_forever</span>
            </div>
            <h3 class="font-black text-2xl text-math-dark-blue italic mb-2">Delete Account?</h3>
            <p class="text-sm text-gray-400 font-medium mb-8 leading-relaxed">
                This will permanently delete <span id="deleteUserName" class="text-math-dark-blue font-black">this user</span>'s account. All data will be lost.
            </p>
            <div class="flex gap-4">
                <button type="button" onclick="closeDeleteModal()"
                    class="flex-1 py-4 border-2 border-gray-200 rounded-2xl font-black text-sm text-gray-500 hover:border-gray-300 transition-colors uppercase tracking-wider">Cancel</button>
                <asp:Button ID="btnConfirmDelete" runat="server" Text="Delete"
                    CssClass="flex-1 py-4 bg-red-500 text-white font-black text-sm rounded-2xl hover:bg-red-600 transition-colors uppercase tracking-wider border-0 cursor-pointer"
                    OnClick="btnConfirmDelete_Click" />
            </div>
        </div>
    </div>

    <!-- ADD USER MODAL -->
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4 um-modal-overlay hidden" id="addModal">
        <div class="bg-white w-full max-w-xl rounded-[2.5rem] shadow-2xl border-4 border-math-blue/10 overflow-hidden">
            <div class="p-8 border-b-2 border-gray-50 flex justify-between items-center bg-primary/10">
                <div>
                    <h3 class="text-2xl font-black text-math-dark-blue italic">Add New User</h3>
                    <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Create a new platform account</p>
                </div>
                <button type="button" onclick="closeAddModal()" class="size-10 rounded-full hover:bg-yellow-200 flex items-center justify-center transition-colors">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            <div class="p-8 space-y-5">
                <div class="grid grid-cols-2 gap-4">
                    <div class="space-y-2">
                        <label class="um-label">First Name</label>
                        <asp:TextBox ID="txtAddFirst" runat="server" CssClass="um-input" placeholder="e.g. Arthur" />
                    </div>
                    <div class="space-y-2">
                        <label class="um-label">Last Name</label>
                        <asp:TextBox ID="txtAddLast" runat="server" CssClass="um-input" placeholder="e.g. Pendragon" />
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="um-label">Email Address</label>
                    <asp:TextBox ID="txtAddEmail" runat="server" CssClass="um-input" placeholder="user@mathsphere.edu" TextMode="Email" />
                </div>
                <div class="space-y-2">
                    <label class="um-label">Assign Role</label>
                    <div class="relative">
                        <asp:DropDownList ID="ddlAddRole" runat="server" CssClass="um-input appearance-none pr-12 cursor-pointer">
                            <asp:ListItem Text="Student"              Value="student"   />
                            <asp:ListItem Text="Teacher"              Value="teacher"   />
                            <asp:ListItem Text="System Administrator" Value="admin"     />
                            <asp:ListItem Text="Content Moderator"    Value="moderator" />
                        </asp:DropDownList>
                        <span class="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400">expand_more</span>
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="um-label">Temporary Password</label>
                    <asp:TextBox ID="txtAddPassword" runat="server" CssClass="um-input" placeholder="Min. 8 characters" TextMode="Password" />
                </div>
            </div>
            <div class="p-8 bg-gray-50/50 border-t-2 border-gray-50 flex gap-4">
                <asp:Button ID="btnSaveAdd" runat="server" Text="Create Account"
                    CssClass="flex-1 bg-primary text-math-dark-blue font-black py-4 rounded-2xl shadow-lg hover:bg-yellow-400 active:scale-95 transition-all uppercase tracking-tighter border-0 cursor-pointer"
                    OnClick="btnSaveAdd_Click" OnClientClick="return validateAddForm()" />
                <button type="button" onclick="closeAddModal()"
                    class="flex-1 bg-white border-2 border-gray-200 text-gray-500 font-black py-4 rounded-2xl hover:bg-gray-100 transition-all uppercase tracking-tighter">Cancel</button>
            </div>
        </div>
    </div>

    <!-- PASSWORD RESET MODAL -->
    <input type="checkbox" id="chkNotifyReset" runat="server" checked="checked" style="display:none" />

    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4 um-modal-overlay hidden" id="resetModal">
        <div class="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl border-4 border-math-blue/20 overflow-hidden text-center p-10 relative">
            <div class="absolute -bottom-6 -right-6 opacity-5 pointer-events-none">
                <span class="material-symbols-outlined text-[140px] text-math-blue">functions</span>
            </div>
            <div class="absolute -top-6 -left-6 opacity-5 pointer-events-none">
                <span class="material-symbols-outlined text-[140px] text-math-blue">percent</span>
            </div>
            <div class="flex justify-center mb-6">
                <div class="relative w-40 h-28 flex items-center justify-center">
                    <div class="absolute inset-0 bg-primary/10 rounded-full blur-2xl"></div>
                    <div class="flex items-end gap-1 z-10">
                        <div class="size-20 bg-primary rounded-2xl flex items-center justify-center shadow-xl transform -rotate-12 border-4 border-white/40">
                            <span class="material-symbols-outlined text-4xl text-math-dark-blue fill-icon">lock</span>
                        </div>
                        <div class="size-16 bg-math-blue rounded-full flex items-center justify-center shadow-xl transform rotate-12 -ml-5 border-4 border-white">
                            <span class="material-symbols-outlined text-3xl text-white fill-icon">key</span>
                        </div>
                    </div>
                </div>
            </div>
            <h3 class="font-black text-2xl text-math-blue uppercase tracking-tight mb-3">Reset User Password?</h3>
            <p class="text-sm text-gray-500 font-medium mb-6 leading-relaxed px-2">
                This will generate a temporary <span class="font-black text-math-blue underline decoration-primary decoration-4 underline-offset-4">magic link</span> for
                <span id="resetUserName" class="text-math-dark-blue font-black">this user</span> to set a new password.
            </p>
            <%-- Notify toggle (UI only — actual checkbox is the hidden server-side one above) --%>
            <div class="flex items-center justify-center gap-3 mb-8 bg-gray-50 px-5 py-3 rounded-full border border-gray-200 mx-auto w-fit cursor-pointer hover:border-math-blue transition-colors"
                 onclick="toggleNotifyReset(this)">
                <div class="relative flex items-center">
                    <input type="checkbox" id="chkNotifyResetUI" checked
                           class="peer appearance-none size-5 rounded-md border-2 border-math-blue checked:bg-math-blue focus:ring-0 transition-colors cursor-pointer"/>
                    <span class="material-symbols-outlined absolute text-white opacity-0 peer-checked:opacity-100 transition-opacity pointer-events-none text-base leading-none">check</span>
                </div>
                <label for="chkNotifyResetUI" class="text-sm font-bold text-math-dark-blue cursor-pointer select-none">Send reset link to user</label>
            </div>
            <div class="flex flex-col sm:flex-row gap-3 w-full">
                <button type="button" onclick="confirmReset()"
                        class="flex-1 bg-primary hover:bg-yellow-400 text-math-dark-blue font-black py-4 px-6 rounded-full shadow-[0_4px_0_0_#ca9e00] active:translate-y-1 active:shadow-none transition-all uppercase tracking-tighter text-sm flex items-center justify-center gap-2">
                    Yes, Reset Password
                </button>
                <button type="button" onclick="closeResetModal()"
                        class="flex-1 bg-white border-2 border-math-blue text-math-blue font-black py-4 px-6 rounded-full hover:bg-blue-50 transition-all uppercase tracking-tighter text-sm">
                    Cancel
                </button>
            </div>
        </div>
    </div>
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-16 -top-16 size-52 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-48 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">manage_accounts</span>
                    Admin workspace
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">User Management</h2>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Manage platform access, role assignments, account status, and password recovery from one shared admin control center.
                </p>
            </div>
            <div class="flex w-full flex-col gap-3 sm:flex-row xl:w-auto">
                <button type="button" onclick="openAddModal()"
                    class="inline-flex items-center justify-center gap-3 rounded-2xl bg-primary px-7 py-4 text-sm font-black uppercase tracking-[0.18em] text-math-dark-blue shadow-[0_10px_24px_rgba(249,208,6,0.22)] transition-all hover:bg-yellow-300 hover:-translate-y-0.5">
                    <span class="material-symbols-outlined text-xl">person_add</span>
                    Add New User
                </button>
            </div>
        </div>

        <div class="relative mt-8 grid gap-3 md:grid-cols-3 xl:max-w-3xl">
            <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Control</p>
                <p class="mt-2 text-sm font-bold text-math-dark-blue">Roles, status, and account actions</p>
            </div>
            <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Security</p>
                <p class="mt-2 text-sm font-bold text-math-dark-blue">Reset access and protect privileged users</p>
            </div>
            <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">View</p>
                <p class="mt-2 text-sm font-bold text-math-dark-blue">Search, filter, and review every account</p>
            </div>
        </div>
    </section>

    <div class="mb-10 rounded-[2.5rem] border border-white/70 bg-white/90 p-8 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="flex flex-col items-center justify-between gap-6 mb-8 md:flex-row">
            <div class="relative flex-1 w-full max-w-xl">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">search</span>
                <input type="text" id="umSearch" placeholder="Search by name, email, or user ID..."
                       oninput="filterTable()"
                       class="w-full rounded-2xl border border-gray-200 bg-gray-50 py-4 pl-12 pr-4 text-sm font-bold text-math-dark-blue outline-none transition-all focus:border-math-blue focus:bg-white focus:ring-0" />
            </div>
            <div class="flex w-full gap-4 md:w-auto">
                <div class="relative">
                    <span class="material-symbols-outlined pointer-events-none absolute inset-y-0 left-4 flex items-center -translate-y-0.5 text-gray-400 text-lg leading-none">filter_alt</span>
                    <select id="filterRole" onchange="filterTable()"
                        class="um-select-clean rounded-2xl border border-gray-200 bg-gray-50 py-4 pl-12 pr-12 text-xs font-black uppercase tracking-widest text-math-dark-blue outline-none transition-all focus:border-math-blue focus:bg-white focus:ring-0 cursor-pointer">
                        <option value="">All Roles</option>
                        <option value="teacher">Teachers</option>
                        <option value="student">Students</option>
                        <option value="admin">Admins</option>
                    </select>
                    <span class="material-symbols-outlined pointer-events-none absolute inset-y-0 right-4 flex items-center -translate-y-0.5 text-gray-400 text-lg leading-none">expand_more</span>
                </div>
                <div class="relative">
                    <span class="material-symbols-outlined pointer-events-none absolute inset-y-0 left-4 flex items-center -translate-y-0.5 text-gray-400 text-lg leading-none">radio_button_checked</span>
                    <select id="filterStatus" onchange="filterTable()"
                        class="um-select-clean rounded-2xl border border-gray-200 bg-gray-50 py-4 pl-12 pr-12 text-xs font-black uppercase tracking-widest text-math-dark-blue outline-none transition-all focus:border-math-blue focus:bg-white focus:ring-0 cursor-pointer">
                        <option value="">All Status</option>
                        <option value="active">Active</option>
                        <option value="disabled">Disabled</option>
                    </select>
                    <span class="material-symbols-outlined pointer-events-none absolute inset-y-0 right-4 flex items-center -translate-y-0.5 text-gray-400 text-lg leading-none">expand_more</span>
                </div>
                <button type="button" onclick="resetFilters()"
                    class="flex items-center justify-center rounded-2xl bg-gray-100 p-4 text-gray-400 transition-colors hover:text-math-dark-blue">
                    <span class="material-symbols-outlined">refresh</span>
                </button>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left">
                <thead>
                    <tr class="border-b border-gray-100">
                        <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">User Details</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">Email Address</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">Role Assigned</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">Status</th>
                        <th class="px-6 py-4 text-[10px] font-black text-gray-400 uppercase tracking-widest text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100" id="umTableBody">
                    <asp:Repeater ID="rptUsers" runat="server" OnItemDataBound="rptUsers_ItemDataBound">
                        <ItemTemplate>
                            <asp:Literal ID="litUserRow" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <div class="mt-8 flex flex-col gap-4 border-t border-gray-100 pt-6 md:flex-row md:items-center md:justify-between">
            <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest" id="umShowingLabel">
                Showing 1–5 of <asp:Literal ID="litTotal" runat="server" Text="0" /> users
            </p>
            <div class="flex gap-2 items-center" id="umPagination"></div>
        </div>
    </div>

    <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex items-center gap-5">
                <div class="flex size-14 items-center justify-center rounded-2xl bg-blue-50 text-math-blue shadow-sm">
                    <span class="material-symbols-outlined text-3xl fill-icon">person_celebrate</span>
                </div>
                <div>
                    <div class="text-[10px] font-black uppercase tracking-[0.24em] text-math-blue">Growth</div>
                    <div class="text-2xl font-black text-math-dark-blue">
                        <asp:Literal ID="litGrowth" runat="server" Text="+0" /> <span class="text-sm font-bold text-gray-400">This Week</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex items-center gap-5">
                <div class="flex size-14 items-center justify-center rounded-2xl bg-green-50 text-math-green shadow-sm">
                    <span class="material-symbols-outlined text-3xl fill-icon">how_to_reg</span>
                </div>
                <div>
                    <div class="text-[10px] font-black uppercase tracking-[0.24em] text-math-green">Active Rate</div>
                    <div class="text-2xl font-black text-math-dark-blue">
                        <asp:Literal ID="litActiveRate" runat="server" Text="0%" /> <span class="text-sm font-bold text-gray-400">Verified</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex items-center gap-5">
                <div class="flex size-14 items-center justify-center rounded-2xl bg-yellow-50 text-primary shadow-sm">
                    <span class="material-symbols-outlined text-3xl fill-icon">shield_person</span>
                </div>
                <div>
                    <div class="text-[10px] font-black uppercase tracking-[0.24em] text-primary">Staff Count</div>
                    <div class="text-2xl font-black text-math-dark-blue">
                        <asp:Literal ID="litStaffCount" runat="server" Text="0" /> <span class="text-sm font-bold text-gray-400">Privileged</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="umToast" class="um-toast"></div>

    <script>
        // Pagination
        const PAGE_SIZE = 5;
        let currentPage = 1;
        let allRows = [];

        document.addEventListener('DOMContentLoaded', () => {
            allRows = Array.from(document.querySelectorAll('#umTableBody tr'));
            render();
        });

        function getFiltered() {
            const q = (document.getElementById('umSearch').value || '').toLowerCase().trim();
            const r = (document.getElementById('filterRole').value || '').toLowerCase();
            const s = (document.getElementById('filterStatus').value || '').toLowerCase();
            return allRows.filter(row => {
                const t = row.textContent.toLowerCase();
                return (!q || t.includes(q)) && (!r || row.dataset.role === r) && (!s || row.dataset.status === s);
            });
        }

        function filterTable() { currentPage = 1; render(); }
        function resetFilters() {
            ['umSearch', 'filterRole', 'filterStatus'].forEach(id => {
                const el = document.getElementById(id); if (el) el.value = '';
            });
            filterTable();
        }

        function render() {
            const filtered = getFiltered();
            const total = filtered.length;
            const pages = Math.max(1, Math.ceil(total / PAGE_SIZE));
            currentPage = Math.min(currentPage, pages);
            const start = (currentPage - 1) * PAGE_SIZE;
            const end = Math.min(start + PAGE_SIZE, total);
            allRows.forEach(r => r.style.display = 'none');
            filtered.slice(start, end).forEach(r => r.style.display = '');
            const lbl = document.getElementById('umShowingLabel');
            if (lbl) lbl.textContent = `Showing ${total === 0 ? 0 : start + 1}–${end} of ${total} users`;
            buildPagination(pages);
        }

        function buildPagination(pages) {
            const bar = document.getElementById('umPagination');
            bar.innerHTML = '';
            const prev = document.createElement('button');
            prev.type = 'button';
            prev.innerHTML = '<span class="material-symbols-outlined text-base leading-none">chevron_left</span><span>Prev</span>';
            prev.className = 'flex items-center gap-1 px-5 py-2.5 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all border-2 ' +
                (currentPage === 1 ? 'border-gray-100 text-gray-300 cursor-not-allowed bg-gray-50' : 'border-gray-200 text-gray-500 hover:border-math-blue hover:text-math-blue bg-white cursor-pointer');
            if (currentPage > 1) prev.onclick = () => { currentPage--; render(); };
            bar.appendChild(prev);

            const pill = document.createElement('div');
            pill.className = 'flex items-center gap-1 px-5 py-2.5 bg-math-blue text-white rounded-2xl text-[10px] font-black uppercase tracking-widest shadow-md select-none';
            pill.innerHTML = `Page <span id="umPageNum">${currentPage}</span> <span class="opacity-50">/ ${pages}</span>`;
            bar.appendChild(pill);

            const next = document.createElement('button');
            next.type = 'button';
            next.innerHTML = '<span>Next</span><span class="material-symbols-outlined text-base leading-none">chevron_right</span>';
            next.className = 'flex items-center gap-1 px-5 py-2.5 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all border-2 ' +
                (currentPage === pages ? 'border-gray-100 text-gray-300 cursor-not-allowed bg-gray-50' : 'border-gray-200 text-gray-500 hover:border-math-blue hover:text-math-blue bg-white cursor-pointer');
            if (currentPage < pages) next.onclick = () => { currentPage++; render(); };
            bar.appendChild(next);
        }        // Modal helpers
        function ensureUserModalMounted(id) {
            var el = document.getElementById(id);
            if (el && el.parentElement !== document.body) {
                document.body.appendChild(el);
            }
            return el;
        }
        function showModal(id) {
            var modal = ensureUserModalMounted(id);
            document.body.classList.add('app-modal-active');
            if (modal) modal.classList.remove('hidden');
        }
        function hideModal(id) {
            var modal = document.getElementById(id);
            if (modal) modal.classList.add('hidden');
            if (!document.querySelector('.um-modal-overlay:not(.hidden), .um-disable-overlay:not(.hidden)')) {
                document.body.classList.remove('app-modal-active');
            }
        }
        function openAddModal() { showModal('addModal'); }
        function closeAddModal() { hideModal('addModal'); }
        function closeDeleteModal() { hideModal('deleteModal'); }
        function closeDisableModal() { hideModal('disableModal'); }
        function closeResetModal() { hideModal('resetModal'); }

        // Delete modal
        function openDeleteModal(uid, name) {
            document.getElementById('<%= hdnDeleteUserId.ClientID %>').value = uid;
            document.getElementById('deleteUserName').textContent = decodeURIComponent(name);
            showModal('deleteModal');
        }

        // Disable modal
        function openDisableModal(uid, name) {
            document.getElementById('<%= hdnDisableUserId.ClientID %>').value = uid;
            document.getElementById('disableUserName').textContent = decodeURIComponent(name);
            showModal('disableModal');
        }

        // Status toggle
        function handleToggle(uid, name, cb) {
            if (cb.checked) {
                syncToggleVisual(cb, true);
                document.getElementById('<%= hdnEnableUserId.ClientID %>').value = uid;
                document.getElementById('<%= btnEnableUser.ClientID %>').click();
                showToast('Account re-enabled for ' + decodeURIComponent(name) + '.');
            } else {
                cb.checked = true;
                syncToggleVisual(cb, true);
                openDisableModal(uid, name);
            }
        }

        function syncToggleVisual(cb, on) {
            const wrap = cb.closest('.status-wrap');
            const track = cb.nextElementSibling;
            const label = wrap && wrap.querySelector('.status-label');
            if (track) track.style.background = on ? '#84cc16' : '#d1d5db';
            if (label) {
                label.textContent = on ? 'Active' : 'Disabled';
                label.className = 'status-label ml-3 text-[10px] font-black uppercase ' + (on ? 'text-math-green' : 'text-gray-400');
            }
        }

        // Reset modal
        var _resetUid = '', _resetName = '';

        function openResetModal(uid, name) {
            _resetUid = uid;
            _resetName = decodeURIComponent(name);
            document.getElementById('resetUserName').textContent = _resetName;
            // Pre-tick the UI checkbox
            const uiCb = document.getElementById('chkNotifyResetUI');
            if (uiCb) uiCb.checked = true;
            syncNotifyCheckbox(true);
            showModal('resetModal');
        }

        function toggleNotifyReset(wrapper) {
            const uiCb = document.getElementById('chkNotifyResetUI');
            if (!uiCb) return;
            uiCb.checked = !uiCb.checked;
            syncNotifyCheckbox(uiCb.checked);
        }

        // Keep the hidden server-side checkbox in sync with the UI checkbox
        function syncNotifyCheckbox(on) {
            const serverCb = document.getElementById('<%= chkNotifyReset.ClientID %>');
            if (serverCb) serverCb.checked = on;
        }

        // confirmReset now posts to server instead of just showing a toast
        function confirmReset() {
            if (!_resetUid) return;
            document.getElementById('<%= hdnResetUserId.ClientID %>').value = _resetUid;
            // Sync notify state one final time before postback
            const uiCb = document.getElementById('chkNotifyResetUI');
            syncNotifyCheckbox(uiCb ? uiCb.checked : true);
            document.getElementById('<%= btnConfirmReset.ClientID %>').click();
        }

        // Edit ? editUserDetail.aspx
        function openEditModal(uid) {
            window.location.href = 'editUserDetail.aspx?uid=' + encodeURIComponent(uid);
        }

        // Add form validation
        function validateAddForm() {
            const first = document.getElementById('<%= txtAddFirst.ClientID %>').value.trim();
            const last  = document.getElementById('<%= txtAddLast.ClientID %>').value.trim();
            const email = document.getElementById('<%= txtAddEmail.ClientID %>').value.trim();
            const pass  = document.getElementById('<%= txtAddPassword.ClientID %>').value;
            if (!first || !last) { showToast('Please enter the full name.'); return false; }
            if (!email) { showToast('Please enter an email address.'); return false; }
            if (pass.length < 8) { showToast('Password must be at least 8 characters.'); return false; }
            return true;
        }

        // Toast
        function showToast(msg) {
            const el = document.getElementById('umToast');
            el.textContent = msg; el.classList.add('visible');
            setTimeout(() => el.classList.remove('visible'), 3200);
        }
    </script>

</asp:Content>




