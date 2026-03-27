<%@ Page Language="C#" MasterPageFile="~/Auth.master" AutoEventWireup="true"
    CodeBehind="Register.aspx.cs" Inherits="MathSphere.Register" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Create Account • MathSphere
</asp:Content>

<asp:Content ID="HeadBlock" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <style>

        .math-input:focus { outline:none; border-color:rgba(37,99,235,0.4); box-shadow:0 0 0 4px rgba(37,99,235,0.10); background:#fff; }
        #strengthBar { transition: width .35s ease, background-color .35s ease; }
        @keyframes cardIn { from{opacity:0;transform:translateY(20px) scale(.98)} to{opacity:1;transform:translateY(0) scale(1)} }
        .card-in { animation:cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
    </style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <div class="max-w-5xl mx-auto card-in">
        <div class="text-center mb-10">
            <h1 class="text-5xl font-black tracking-tight text-math-dark-blue">
                Join <span class="text-math-blue">MathSphere</span>
            </h1>
            <p class="mt-3 text-lg font-semibold text-gray-500">
                Create your student account and start your mission.
            </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-[380px_1fr] overflow-hidden rounded-[2.75rem]
                    bg-white/70 backdrop-blur-md border border-gray-100
                    shadow-[0_18px_60px_rgba(0,0,0,0.08)]">

            <div class="relative p-10 md:p-12 bg-gradient-to-br from-math-dark-blue via-math-blue to-math-blue
                        text-white overflow-hidden flex flex-col justify-between">
                <div class="absolute -top-24 -right-24 size-72 rounded-full bg-primary/20 blur-3xl pointer-events-none"></div>
                <div class="absolute -bottom-28 -left-28 size-72 rounded-full bg-white/10 blur-3xl pointer-events-none"></div>
                <div class="relative z-10">
                    <div class="flex items-center gap-3 mb-8">
                        <div class="size-12 rounded-2xl bg-primary text-math-dark-blue flex items-center justify-center shadow-lg shadow-primary/20">
                            <span class="material-symbols-outlined fill-icon text-2xl">school</span>
                        </div>
                        <div>
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-white/70">New here?</div>
                            <div class="text-xl font-black tracking-tight">Join the adventure</div>
                        </div>
                    </div>
                    <h2 class="text-3xl font-black leading-tight">
                        Start your<br/><span class="text-primary">mathematical</span><br/>journey today.
                    </h2>
                    <p class="mt-4 text-white/75 font-semibold leading-relaxed">
                        Track progress, complete missions, and climb the leaderboard.
                    </p>
                    <div class="mt-8 flex flex-wrap gap-2">
                        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 border border-white/15 text-sm font-black">
                            <span class="material-symbols-outlined fill-icon text-base">local_fire_department</span>Streaks
                        </span>
                        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 border border-white/15 text-sm font-black">
                            <span class="material-symbols-outlined fill-icon text-base">stars</span>XP
                        </span>
                        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 border border-white/15 text-sm font-black">
                            <span class="material-symbols-outlined fill-icon text-base">emoji_events</span>Rank
                        </span>
                    </div>
                </div>
                <div class="relative z-10 mt-10 grid grid-cols-4 gap-3 opacity-20 select-none">
                    <div class="text-center text-3xl font-black">&pi;</div>
                    <div class="text-center text-3xl font-black">&sum;</div>
                    <div class="text-center text-3xl font-black">&radic;</div>
                    <div class="text-center text-3xl font-black">&infin;</div>
                    <div class="text-center text-3xl font-black">&int;</div>
                    <div class="text-center text-3xl font-black">&Delta;</div>
                    <div class="text-center text-3xl font-black">&theta;</div>
                    <div class="text-center text-3xl font-black">&lambda;</div>
                </div>
            </div>

            <div class="p-10 md:p-12">
                <div class="mb-8">
                    <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Student Registration</div>
                    <h3 class="text-3xl md:text-4xl font-black text-math-dark-blue mt-2">Create Account</h3>
                </div>

                <div class="space-y-5">

                    <div class="space-y-2">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Full Name</div>
                        <asp:TextBox ID="txtFullName" runat="server"
                            CssClass="math-input w-full px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                     font-semibold text-math-dark-blue placeholder:text-gray-400 shadow-sm transition-all duration-200 ease-out"
                            placeholder="Alex Prime" />
                    </div>

                    <div class="space-y-2">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Email</div>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                            CssClass="math-input w-full px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                     font-semibold text-math-dark-blue placeholder:text-gray-400 shadow-sm transition-all duration-200 ease-out"
                            placeholder="yourname@example.com" />
                    </div>

                    <div class="space-y-2">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Password</div>
                        <div class="relative">
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                                ClientIDMode="Static"
                                CssClass="math-input w-full pr-14 px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                         font-semibold text-math-dark-blue placeholder:text-gray-400 shadow-sm transition-all duration-200 ease-out"
                                placeholder="••••••••" onkeyup="checkStrength(this.value)" />
                            <button type="button"
                                class="absolute right-4 top-1/2 -translate-y-1/2 size-10 rounded-xl bg-white/60 border border-gray-200
                                       flex items-center justify-center hover:bg-white hover:border-math-blue/20 transition-all"
                                onclick="togglePassword('txtPassword',this)" aria-label="Show password">
                                <span class="material-symbols-outlined text-gray-500">visibility</span>
                            </button>
                        </div>
                        <div class="h-1.5 w-full bg-gray-100 rounded-full overflow-hidden">
                            <div id="strengthBar" class="h-full w-0 rounded-full"></div>
                        </div>
                        <div id="strengthLabel" class="text-[10px] font-black uppercase tracking-widest text-gray-300 min-h-[16px]"></div>
                    </div>

                    <div class="space-y-2">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Confirm Password</div>
                        <div class="relative">
                            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                                ClientIDMode="Static"
                                CssClass="math-input w-full pr-14 px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                         font-semibold text-math-dark-blue placeholder:text-gray-400 shadow-sm transition-all duration-200 ease-out"
                                placeholder="••••••••" />
                            <button type="button"
                                class="absolute right-4 top-1/2 -translate-y-1/2 size-10 rounded-xl bg-white/60 border border-gray-200
                                       flex items-center justify-center hover:bg-white hover:border-math-blue/20 transition-all"
                                onclick="togglePassword('txtConfirmPassword',this)" aria-label="Show password">
                                <span class="material-symbols-outlined text-gray-500">visibility</span>
                            </button>
                        </div>
                    </div>

                    <!-- reCAPTCHA -->
                    <div class="flex justify-center">
                        <div class="g-recaptcha"
                             data-sitekey="<%= System.Configuration.ConfigurationManager.AppSettings["RecaptchaSiteKey"] %>">
                        </div>
                    </div>

                    <asp:Panel ID="pnlCaptchaError" runat="server" Visible="false"
                        CssClass="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-center">
                        <div class="flex items-center justify-center gap-3">
                            <span class="material-symbols-outlined text-red-500">security</span>
                            <span class="text-red-700 font-semibold text-sm">Please complete the CAPTCHA verification.</span>
                        </div>
                    </asp:Panel>

                    <% if (!string.IsNullOrWhiteSpace(Request.QueryString["error"])) { %>
                        <div class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3">
                            <div class="flex items-start gap-3">
                                <span class="material-symbols-outlined text-red-500">error</span>
                                <span class="text-red-700 font-semibold text-sm">
                                    <%= HttpUtility.HtmlEncode(Request.QueryString["error"]) %>
                                </span>
                            </div>
                        </div>
                        <% } %>

                    <asp:Panel ID="pnlMessage" runat="server" Visible="false"
                        CssClass="rounded-2xl border border-red-200 bg-red-50 px-4 py-3">
                        <div class="flex items-start gap-3">
                            <span class="material-symbols-outlined text-red-500">error</span>
                            <asp:Label ID="lblMessage" runat="server" CssClass="text-red-700 font-semibold text-sm" />
                        </div>
                    </asp:Panel>

                    <!-- Google Sign-In -->
                    <div class="relative flex items-center gap-3">
                        <div class="flex-1 h-px bg-gray-200"></div>
                        <span class="text-[11px] font-black uppercase tracking-widest text-gray-400">or</span>
                        <div class="flex-1 h-px bg-gray-200"></div>
                    </div>

                    <asp:HyperLink ID="lnkGoogle" runat="server"
                       class="w-full flex items-center justify-center gap-3 px-5 py-4 rounded-2xl
                              bg-white border border-gray-200 shadow-sm
                              font-black text-sm text-math-dark-blue
                              hover:bg-gray-50 hover:border-gray-300 transition-all">
                        <svg width="20" height="20" viewBox="0 0 48 48">
                            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.31-8.16 2.31-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                            <path fill="none" d="M0 0h48v48H0z"/>
                        </svg>
                        Sign up with Google
                    </asp:HyperLink>

                    <asp:Button ID="btnRegister" runat="server"
                        Text="Start My Adventure"
                        OnClick="btnRegister_Click"
                        CssClass="w-full bg-math-blue text-white font-black py-4 rounded-2xl
                                  uppercase tracking-widest text-sm shadow-lg shadow-math-blue/20
                                  hover:bg-math-dark-blue transition-all active:scale-[0.99] border-none mt-2 cursor-pointer" />
                    <div class="pt-4 text-center border-t border-gray-100">
                        <span class="text-xs font-black uppercase tracking-widest text-gray-400">
                            Already have an account?
                        </span>
                        <div class="mt-3 flex flex-wrap justify-center gap-3">
                            <a href="Login.aspx"
                               class="px-5 py-3 rounded-2xl bg-white/70 border border-gray-100
                                      font-black text-[11px] uppercase tracking-widest text-math-blue
                                      hover:bg-white hover:border-math-blue/20 transition-all">
                                Back to Login
                            </a>
                            <a href="teacherRegistration.aspx"
                               class="px-5 py-3 rounded-2xl bg-white/70 border border-gray-100
                                      font-black text-[11px] uppercase tracking-widest text-math-dark-blue
                                      hover:bg-white hover:border-math-blue/20 transition-all">
                                Join as Teacher
                            </a>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <script>
        function checkStrength(val) {
            var bar = document.getElementById('strengthBar');
            var label = document.getElementById('strengthLabel');
            if (!val) { bar.style.width = '0'; label.textContent = ''; return; }
            var score = 0;
            if (val.length >= 6) score++;
            if (val.length >= 10) score++;
            if (/[A-Z]/.test(val)) score++;
            if (/[0-9]/.test(val)) score++;
            if (/[^A-Za-z0-9]/.test(val)) score++;
            var levels = [
                { w: '20%', bg: '#f87171', txt: 'Too short' },
                { w: '40%', bg: '#fb923c', txt: 'Weak' },
                { w: '60%', bg: '#facc15', txt: 'Fair' },
                { w: '80%', bg: '#84cc16', txt: 'Good' },
                { w: '100%', bg: '#2563eb', txt: 'Strong' }
            ];
            var l = levels[Math.min(score, levels.length - 1)];
            bar.style.width = l.w; bar.style.backgroundColor = l.bg;
            label.textContent = l.txt; label.style.color = l.bg;
        }
        function togglePassword(inputId, btn) {
            const input = document.getElementById(inputId);
            if (!input) return;
            const icon = btn.querySelector('.material-symbols-outlined');
            const isHidden = input.type === "password";
            input.type = isHidden ? "text" : "password";
            if (icon) icon.textContent = isHidden ? "visibility_off" : "visibility";
            btn.setAttribute("aria-label", isHidden ? "Hide password" : "Show password");
        }
    </script>

</asp:Content>



