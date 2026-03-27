<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="addNewUser.aspx.cs" Inherits="MathSphere.addNewUser" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere Admin - Add New User</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="<%= ResolveUrl("~/Styles/addNewUser.css") %>" rel="stylesheet" type="text/css" />
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f9d006",
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
<body class="min-h-screen relative font-display overflow-hidden">
    <form id="form1" runat="server">
    <!-- Blurred background (simulates the page behind) -->
    <div class="fixed inset-0 bg-gray-100 blur-overlay pointer-events-none" aria-hidden="true">
        <div class="flex h-full">
            <div class="w-72 bg-white border-r-4 border-blue-100 h-full"></div>
            <div class="flex-1 p-10">
                <div class="h-10 w-64 bg-gray-200 rounded-2xl mb-4 opacity-60"></div>
                <div class="h-5 w-96 bg-gray-200 rounded-xl opacity-40 mb-10"></div>
                <div class="bg-white rounded-[2rem] h-80 opacity-60"></div>
            </div>
        </div>
    </div>

    <!-- Backdrop overlay -->
    <div class="fixed inset-0 bg-[#1e3a8a]/30 backdrop-blur-md z-10"></div>

    <!-- Modal -->
    <div class="fixed inset-0 z-20 flex items-center justify-center p-4">
        <div class="bg-white w-full max-w-4xl rounded-[2.5rem] shadow-2xl overflow-hidden flex flex-col md:flex-row border-4 border-white modal-enter">

            <!-- Left panel (blue decorative) -->
            <div class="hidden md:flex md:w-2/5 bg-math-blue p-12 flex-col justify-center items-center text-center relative overflow-hidden">
                <!-- Background math symbols -->
                <div class="absolute inset-0 opacity-10">
                    <div class="grid grid-cols-3 gap-8 rotate-12 -translate-y-8 -translate-x-4">
                        <span class="material-symbols-outlined text-7xl text-white">functions</span>
                        <span class="material-symbols-outlined text-7xl text-white">calculate</span>
                        <span class="material-symbols-outlined text-7xl text-white">square_foot</span>
                        <span class="material-symbols-outlined text-7xl text-white">variables</span>
                        <span class="material-symbols-outlined text-7xl text-white">percent</span>
                        <span class="material-symbols-outlined text-7xl text-white">change_history</span>
                    </div>
                </div>

                <!-- Illustration -->
                <div class="relative z-10 mb-8 illustration-shadow">
                    <div class="flex flex-col items-center gap-4">
                        <div class="bg-primary size-24 rounded-[2rem] flex items-center justify-center shadow-xl transform -rotate-12 hover:rotate-0 transition-transform duration-500 border-4 border-white/20">
                            <span class="material-symbols-outlined text-6xl text-math-dark-blue fill-icon">person</span>
                        </div>
                        <div class="bg-white size-20 rounded-[1.5rem] flex items-center justify-center shadow-xl transform translate-x-10 -translate-y-4 rotate-12 hover:rotate-0 transition-transform duration-500 -mt-8">
                           <span class="material-symbols-outlined text-5xl text-math-blue fill-icon">key</span>
                        &nbsp;</div>
                    </div>
                </div>

                <div class="relative z-10 space-y-3">
                    <h4 class="text-white text-2xl font-black italic tracking-tighter uppercase">Join the Lab</h4>
                    <p class="text-blue-100 text-sm font-medium leading-relaxed max-w-xs">
                        Expand your math community by adding new scholars and educators to MathSphere.
                    </p>
                </div>
            </div>

            <!-- Right panel (form) -->
            <div class="flex-1 p-8 md:p-12 bg-white">
                    <asp:HiddenField ID="hdnActiveStatus" runat="server" Value="true" />

                    <div class="flex justify-between items-start mb-8">
                        <div>
                            <h3 class="text-3xl font-black text-math-dark-blue italic uppercase tracking-tighter">Create New Account</h3>
                            <p class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mt-1">Personnel registration portal</p>
                        </div>
                        <button type="button" onclick="window.location.href='<%= ResolveUrl("~/userManagement.aspx") %>'"
                                class="size-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors">
                            <span class="material-symbols-outlined text-gray-400">close</span>
                        </button>
                    </div>

                    <div class="space-y-5">
                        <!-- Name row -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="space-y-1.5">
                                <label class="an-label">First Name</label>
                                <asp:TextBox ID="txtFirst" runat="server" CssClass="an-input" placeholder="e.g. Arthur"></asp:TextBox>
                                <span id="errFirst" class="an-error hidden">First name is required.</span>
                            </div>
                            <div class="space-y-1.5">
                                <label class="an-label">Last Name</label>
                                <asp:TextBox ID="txtLast" runat="server" CssClass="an-input" placeholder="e.g. Pendragon"></asp:TextBox>
                                <span id="errLast" class="an-error hidden">Last name is required.</span>
                            </div>
                        </div>

                        <!-- Email -->
                        <div class="space-y-1.5">
                            <label class="an-label">Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="an-input" placeholder="user@mathsphere.edu" TextMode="Email"></asp:TextBox>
                            <span id="errEmail" class="an-error hidden">A valid email is required.</span>
                        </div>

                        <!-- Password -->
                        <div class="space-y-1.5">
                            <label class="an-label">Initial Password</label>
                            <div class="relative">
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="an-input pr-12" placeholder="Min. 8 characters" TextMode="Password"></asp:TextBox>
                                <button type="button" onclick="togglePwd()" id="pwdToggleBtn"
                                        class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-math-blue transition-colors">
                                    <span class="material-symbols-outlined text-xl" id="pwdEyeIcon">visibility</span>
                                </button>
                            </div>
                            <span id="errPwd" class="an-error hidden">Password must be at least 8 characters.</span>
                        </div>

                        <!-- Role -->
                        <div class="space-y-1.5">
                            <label class="an-label">Assign User Role</label>
                            <div class="relative">
                                <asp:DropDownList ID="ddlRole" runat="server" CssClass="an-input appearance-none cursor-pointer pr-12">
                                    <asp:ListItem Text="Student"              Value="student"   />
                                    <asp:ListItem Text="Teacher"              Value="teacher"   />
                                    <asp:ListItem Text="System Administrator" Value="admin"     />
                                </asp:DropDownList>
                                <span class="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-math-blue">expand_more</span>
                            </div>
                        </div>

                        <!-- Account Status toggle -->
                        <div class="flex items-center justify-between p-4 bg-gray-50 rounded-2xl border-2 border-gray-100">
                            <div>
                                <div class="text-[10px] font-black uppercase tracking-widest text-gray-400">Account Status</div>
                                <div class="text-sm font-bold text-math-dark-blue" id="statusText">Active by Default</div>
                            </div>
                            <div class="an-toggle-wrapper" onclick="toggleStatus()" id="statusToggle">
                                <div class="an-toggle-track on" id="statusTrack">
                                    <div class="an-toggle-thumb"></div>
                                </div>
                            </div>
                        </div>

                        <!-- Error summary -->
                        <div id="formError" class="hidden bg-red-50 border-2 border-red-100 rounded-2xl p-4 text-red-500 text-xs font-bold uppercase tracking-widest text-center"></div>

                        <!-- Actions -->
                        <div class="pt-2 flex flex-col sm:flex-row gap-4">
                            <asp:Button ID="btnCreate" runat="server" Text="Create User"
                                OnClick="btnCreate_Click"
                                OnClientClick="try { return validateForm(); } catch(e) { console.error(e); return true; }"
                                CssClass="flex-1 bg-primary hover:bg-yellow-400 text-math-dark-blue font-black py-4 px-8 rounded-2xl shadow-[0_6px_0_0_#d4af37] active:translate-y-1 active:shadow-none transition-all uppercase tracking-tighter text-base cursor-pointer border-0" />
                            <button type="button" onclick="window.location.href='userManagement.aspx'"
                                    class="flex-1 bg-white border-4 border-math-blue/10 text-math-blue font-black py-4 px-8 rounded-2xl hover:bg-blue-50 transition-all uppercase tracking-tighter">
                                Cancel
                            </button>
                        </div>
                    </div>
            </div>
        </div>
    </div>

    <script>
        // Password visibility toggle
        function togglePwd() {
            var inp  = document.getElementById('<%= txtPassword.ClientID %>');
            var icon = document.getElementById('pwdEyeIcon');
            if (inp.type === 'password') {
                inp.type = 'text';
                icon.textContent = 'visibility_off';
            } else {
                inp.type = 'password';
                icon.textContent = 'visibility';
            }
        }

        // Status toggle
        var statusOn = true;
        function toggleStatus() {
            statusOn = !statusOn;
            var track  = document.getElementById('statusTrack');
            var label  = document.getElementById('statusText');
            var hidden = document.getElementById('<%= hdnActiveStatus.ClientID %>');
            if (statusOn) {
                track.classList.add('on');
                label.textContent = 'Active by Default';
                hidden.value = 'true';
            } else {
                track.classList.remove('on');
                label.textContent = 'Inactive (Disabled)';
                hidden.value = 'false';
            }
        }

        // Client-side validation
        function validateForm() {
            var first = document.getElementById('<%= txtFirst.ClientID %>').value.trim();
            var last  = document.getElementById('<%= txtLast.ClientID  %>').value.trim();
            var email = document.getElementById('<%= txtEmail.ClientID %>').value.trim();
            var pwd   = document.getElementById('<%= txtPassword.ClientID %>').value;

            var valid = true;
            clearErrors();

            if (!first) { showErr('errFirst'); valid = false; }
            if (!last)  { showErr('errLast');  valid = false; }
            if (!email || !email.includes('@')) { showErr('errEmail'); valid = false; }
            if (pwd.length < 8) { showErr('errPwd'); valid = false; }

            if (!valid) {
                var fe = document.getElementById('formError');
                fe.textContent = 'Please fix the errors above before continuing.';
                fe.classList.remove('hidden');
            }
            return valid;
        }

        function clearErrors() {
            ['errFirst','errLast','errEmail','errPwd','formError'].forEach(function(id) {
                document.getElementById(id).classList.add('hidden');
            });
        }

        function showErr(id) {
            document.getElementById(id).classList.remove('hidden');
        }

        // Highlight inputs on focus
        document.querySelectorAll('.an-input').forEach(function(el) {
            el.addEventListener('focus', function() { clearErrors(); });
        });
    </script>
</form>
</body>
</html>

