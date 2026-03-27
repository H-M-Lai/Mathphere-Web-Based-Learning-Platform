<%@ Page Language="C#" MasterPageFile="~/Auth.master" AutoEventWireup="true"
    CodeBehind="ResetPassword.aspx.cs" Inherits="MathSphere.ResetPassword" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Reset Password • MathSphere
</asp:Content>

<asp:Content ID="HeadBlock" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(20px) scale(.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .card-in {
            animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both;
        }
    </style>
</asp:Content>


<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

<%-- Inline styles for strength bar animation --%>
<style>
    .pw-wrap { position:relative; }
    .pw-wrap .eye-btn {
        position:absolute; right:14px; top:50%; transform:translateY(-50%);
        background:none; border:none; cursor:pointer; padding:4px;
        color:#9ca3af; transition:color .2s;
    }
    .pw-wrap .eye-btn:hover { color:#2563eb; }
    .pw-wrap input { padding-right: 2.75rem !important; }

    /* Strength bar */
    .strength-bar-track {
        height:6px; border-radius:99px; background:#e5e7eb;
        overflow:hidden; transition:all .3s;
    }
    .strength-bar-fill {
        height:100%; border-radius:99px;
        transition:width .4s cubic-bezier(.4,0,.2,1), background .4s;
        width:0%;
    }
    .strength-label {
        font-size:11px; font-weight:900; letter-spacing:.08em;
        text-transform:uppercase; margin-top:4px;
    }
</style>

<div class="max-w-5xl mx-auto card-in">

    <div class="text-center mb-10">
        <h1 class="text-5xl font-black tracking-tight text-math-dark-blue">
            Reset <span class="text-math-blue">Password</span>
        </h1>
        <p class="mt-3 text-lg font-semibold text-gray-500">
            Enter your email and we'll send you a secure reset link.
        </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-[360px_1fr] overflow-hidden rounded-[2.75rem]
                bg-white/70 backdrop-blur-md border border-gray-100
                shadow-[0_18px_60px_rgba(0,0,0,0.08)]">

        <!-- Left decorative panel -->
        <div class="relative p-10 md:p-12 bg-gradient-to-br from-math-dark-blue via-math-blue
                    to-math-blue text-white overflow-hidden">
            <div class="absolute -top-24 -right-24 size-72 rounded-full bg-primary/20 blur-3xl"></div>
            <div class="absolute -bottom-28 -left-28 size-72 rounded-full bg-white/10 blur-3xl"></div>
            <div class="relative z-10">
                <div class="flex items-center gap-3 mb-8">
                    <div class="size-12 rounded-2xl bg-primary text-math-dark-blue flex items-center
                                justify-center shadow-lg shadow-primary/20">
                        <span class="material-symbols-outlined fill-icon text-2xl">lock_reset</span>
                    </div>
                    <div>
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-white/70">Security</div>
                        <div class="text-xl font-black tracking-tight">Reset Password</div>
                    </div>
                </div>
                <h2 class="text-3xl font-black leading-tight">
                    Secure link.<br />
                    <span class="text-primary">Instant reset.</span>
                </h2>
                <p class="mt-4 text-white/75 font-semibold leading-relaxed">
                    We'll send a secure reset link to your registered email.
                    The link expires in <strong>30 minutes</strong>.
                </p>
                <div class="mt-8 flex flex-wrap gap-2">
                    <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                                 bg-white/10 border border-white/15 text-sm font-black">
                        <span class="material-symbols-outlined fill-icon text-base">timer</span>
                        30 min expiry
                    </span>
                    <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                                 bg-white/10 border border-white/15 text-sm font-black">
                        <span class="material-symbols-outlined fill-icon text-base">verified_user</span>
                        Secure token
                    </span>
                </div>
                <div class="mt-8 p-4 rounded-2xl bg-white/10 border border-white/20">
                    <p class="text-white/80 text-sm font-semibold leading-relaxed">
                        <span class="material-symbols-outlined fill-icon text-base align-middle mr-1">info</span>
                        If you signed up with <strong>Google</strong>, use
                        <strong>Continue with Google</strong> on the login page instead.
                    </p>
                </div>

                <%-- Password rules reminder (shown when reset form is active) --%>
                <div id="pwRules" class="mt-6 p-4 rounded-2xl bg-white/10 border border-white/20 hidden">
                    <p class="text-white/90 text-[11px] font-black uppercase tracking-wider mb-3">
                        Password must have:
                    </p>
                    <ul class="space-y-1.5 text-sm">
                        <li id="rule-len"  class="flex items-center gap-2 text-white/60"><span class="text-base">&#9675;</span> 8+ characters</li>
                        <li id="rule-up"   class="flex items-center gap-2 text-white/60"><span class="text-base">&#9675;</span> Uppercase letter</li>
                        <li id="rule-lo"   class="flex items-center gap-2 text-white/60"><span class="text-base">&#9675;</span> Lowercase letter</li>
                        <li id="rule-num"  class="flex items-center gap-2 text-white/60"><span class="text-base">&#9675;</span> Number</li>
                        <li id="rule-sym"  class="flex items-center gap-2 text-white/60"><span class="text-base">&#9675;</span> Special character</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Right content -->
        <div class="p-10 md:p-12">
            <div class="max-w-xl">

                <!-- STEP 1: Request reset link -->
                <asp:Panel ID="pnlRequestForm" runat="server">
                    <div class="mb-8">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Step 1</div>
                        <h3 class="text-3xl font-black text-math-dark-blue mt-2">Enter your email</h3>
                    </div>
                    <div class="space-y-6">

                        <div class="space-y-2">
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Email Address</div>
                            <asp:TextBox ID="txtRequestEmail" runat="server"
                                CssClass="w-full px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                         font-semibold text-math-dark-blue placeholder:text-gray-400
                                         shadow-sm transition-all duration-200
                                         focus:outline-none focus:border-math-blue/40 focus:ring-4
                                         focus:ring-math-blue/10 focus:bg-white"
                                placeholder="yourname@example.com" />
                            <asp:RequiredFieldValidator ID="rfvRequestEmail" runat="server"
                                ControlToValidate="txtRequestEmail"
                                ErrorMessage="Email is required."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic" ValidationGroup="RequestGroup" />
                            <asp:RegularExpressionValidator ID="revRequestEmail" runat="server"
                                ControlToValidate="txtRequestEmail"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                ErrorMessage="Enter a valid email address."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic" ValidationGroup="RequestGroup" />
                        </div>

                        <asp:Panel ID="pnlRequestError" runat="server" Visible="false"
                            CssClass="rounded-2xl border border-red-200 bg-red-50 px-4 py-3">
                            <div class="flex items-start gap-3">
                                <span class="material-symbols-outlined text-red-500">error</span>
                                <asp:Label ID="lblRequestError" runat="server"
                                    CssClass="text-red-700 font-semibold text-sm" />
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlEmailSent" runat="server" Visible="false"
                            CssClass="rounded-2xl border border-green-200 bg-green-50 px-4 py-3">
                            <div class="flex items-start gap-3">
                                <span class="material-symbols-outlined text-green-500 fill-icon">mark_email_read</span>
                                <div>
                                    <div class="text-green-800 font-black text-sm">Check your inbox!</div>
                                    <div class="text-green-700 font-semibold text-sm mt-1">
                                        If this email is registered with a local account, a reset link has been sent.
                                        It expires in 30 minutes.
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Button ID="btnSendLink" runat="server"
                            Text="Send Reset Link"
                            OnClick="btnSendLink_Click"
                            ValidationGroup="RequestGroup"
                            CssClass="w-full bg-math-blue text-white font-black py-4 rounded-2xl
                                      uppercase tracking-widest text-sm shadow-lg shadow-math-blue/20
                                      hover:bg-math-dark-blue transition-all active:scale-[0.99]" />

                        <div class="pt-2 text-center">
                            <a href="Login.aspx"
                               class="inline-flex items-center gap-2 text-math-blue font-black
                                      uppercase tracking-widest text-[11px] hover:underline">
                                <span class="material-symbols-outlined text-base">arrow_back</span>
                                Back to Login
                            </a>
                        </div>
                    </div>
                </asp:Panel>

                <!-- STEP 2: Set new password -->
                <%-- NOTE: Panel starts Visible=false but Page_Load always sets it to true
                     when a token is in the URL (on both GET and POST).
                     This ensures txtNewPassword / txtConfirmPassword are rendered
                     and their .Text values are non-empty when btnReset_Click fires. --%>
                <asp:Panel ID="pnlResetForm" runat="server" Visible="false">
                    <div class="mb-8">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Step 2</div>
                        <h3 class="text-3xl font-black text-math-dark-blue mt-2">Set new password</h3>
                        <p class="text-sm text-gray-500 font-semibold mt-1">Choose a strong password you haven't used before.</p>
                    </div>

                    <div class="space-y-6">

                        <!-- New Password with eye toggle -->
                        <div class="space-y-2">
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">New Password</div>
                            <div class="pw-wrap">
                                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                                    ClientIDMode="Static"
                                    CssClass="w-full px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                             font-semibold text-math-dark-blue placeholder:text-gray-400
                                             shadow-sm transition-all duration-200
                                             focus:outline-none focus:border-math-blue/40 focus:ring-4
                                             focus:ring-math-blue/10 focus:bg-white"
                                    placeholder="••••••••"
                                    oninput="onPasswordInput(this)" />
                                <button type="button" class="eye-btn" onclick="toggleEye('txtNewPassword','eyeNew')"
                                        tabindex="-1" aria-label="Toggle password visibility">
                                    <span id="eyeNew" class="material-symbols-outlined text-xl">visibility</span>
                                </button>
                            </div>

                            <%-- Live strength meter — updated by JS oninput --%>
                            <div id="strengthWrap" class="pt-1">
                                <div class="strength-bar-track">
                                    <div id="strengthBar" class="strength-bar-fill"></div>
                                </div>
                                <div id="strengthLabel" class="strength-label text-gray-300">Enter a password</div>
                            </div>

                            <asp:RequiredFieldValidator ID="rfvNew" runat="server"
                                ControlToValidate="txtNewPassword"
                                ErrorMessage="New password is required."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic" ValidationGroup="ResetGroup" />
                        </div>

                        <!-- Confirm Password with eye toggle -->
                        <div class="space-y-2">
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Confirm Password</div>
                            <div class="pw-wrap">
                                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                                    ClientIDMode="Static"
                                    CssClass="w-full px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                             font-semibold text-math-dark-blue placeholder:text-gray-400
                                             shadow-sm transition-all duration-200
                                             focus:outline-none focus:border-math-blue/40 focus:ring-4
                                             focus:ring-math-blue/10 focus:bg-white"
                                    placeholder="••••••••" />
                                <button type="button" class="eye-btn" onclick="toggleEye('txtConfirmPassword','eyeConf')"
                                        tabindex="-1" aria-label="Toggle confirm password visibility">
                                    <span id="eyeConf" class="material-symbols-outlined text-xl">visibility</span>
                                </button>
                            </div>
                            <asp:RequiredFieldValidator ID="rfvConfirm" runat="server"
                                ControlToValidate="txtConfirmPassword"
                                ErrorMessage="Please confirm your password."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic" ValidationGroup="ResetGroup" />
                            <asp:CompareValidator ID="cvMatch" runat="server"
                                ControlToCompare="txtNewPassword"
                                ControlToValidate="txtConfirmPassword"
                                ErrorMessage="Passwords do not match."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic" ValidationGroup="ResetGroup" />
                        </div>

                        <!-- Server-side reset error -->
                        <asp:Panel ID="pnlResetError" runat="server" Visible="false"
                            CssClass="rounded-2xl border border-red-200 bg-red-50 px-4 py-3">
                            <div class="flex items-start gap-3">
                                <span class="material-symbols-outlined text-red-500">error</span>
                                <asp:Label ID="lblResetError" runat="server"
                                    CssClass="text-red-700 font-semibold text-sm" />
                            </div>
                        </asp:Panel>

                        <!-- Success message -->
                        <asp:Panel ID="pnlResetSuccess" runat="server" Visible="false"
                            CssClass="rounded-2xl border border-green-200 bg-green-50 px-4 py-3">
                            <div class="flex items-start gap-3">
                                <span class="material-symbols-outlined text-green-500 fill-icon">check_circle</span>
                                <div>
                                    <div class="text-green-800 font-black text-sm">Password updated!</div>
                                    <div class="text-green-700 font-semibold text-sm mt-1">
                                        You can now
                                        <a href="Login.aspx" class="underline font-black">log in</a>
                                        with your new password.
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Button ID="btnReset" runat="server"
                            Text="Reset Password"
                            OnClick="btnReset_Click"
                            ValidationGroup="ResetGroup"
                            CssClass="w-full bg-math-blue text-white font-black py-4 rounded-2xl
                                      uppercase tracking-widest text-sm shadow-lg shadow-math-blue/20
                                      hover:bg-math-dark-blue transition-all active:scale-[0.99]" />

                    </div>
                </asp:Panel>

                <!-- TOKEN INVALID / EXPIRED -->
                <asp:Panel ID="pnlTokenInvalid" runat="server" Visible="false">
                    <div class="rounded-2xl border border-red-200 bg-red-50 px-6 py-8 text-center">
                        <span class="material-symbols-outlined text-red-400 text-5xl">link_off</span>
                        <div class="text-red-700 font-black text-lg mt-3">Link expired or invalid</div>
                        <div class="text-red-600 font-semibold text-sm mt-2">
                            This reset link has expired or has already been used.
                        </div>
                        <a href="ResetPassword.aspx"
                           class="inline-block mt-6 px-6 py-3 bg-math-blue text-white font-black
                                  rounded-2xl uppercase tracking-widest text-sm
                                  hover:bg-math-dark-blue transition-all">
                            Request New Link
                        </a>
                    </div>
                </asp:Panel>

            </div>
        </div>
    </div>
</div>

<%-- JavaScript: eye toggle + strength meter + rules checklist --%>
<script>
    // Show rules panel on the left whenever the reset form is visible
    (function () {
        var rp = document.getElementById('<%=pnlResetForm.ClientID%>');
        if (rp && rp.style.display !== 'none') {
            var rules = document.getElementById('pwRules');
            if (rules) rules.classList.remove('hidden');
        }
    })();

    // Eye / visibility toggle
    function toggleEye(inputId, iconId) {
        var inp  = document.getElementById(inputId);
        var icon = document.getElementById(iconId);
        if (!inp) return;
        if (inp.type === 'password') {
            inp.type  = 'text';
            if (icon) icon.textContent = 'visibility_off';
        } else {
            inp.type  = 'password';
            if (icon) icon.textContent = 'visibility';
        }
    }

    // Password strength meter
    function onPasswordInput(input) {
        var pw    = input.value;
        var score = 0;
        var rules = {
            'rule-len' : pw.length >= 8,
            'rule-up'  : /[A-Z]/.test(pw),
            'rule-lo'  : /[a-z]/.test(pw),
            'rule-num' : /[0-9]/.test(pw),
            'rule-sym' : /[^A-Za-z0-9]/.test(pw)
        };

        // Update rule checklist on the left panel
        for (var id in rules) {
            var el = document.getElementById(id);
            if (!el) continue;
            var passed = rules[id];
            el.style.color = passed ? '#86efac' : 'rgba(255,255,255,0.4)';
            el.querySelector('span').innerHTML = passed ? '&#10003;' : '&#9675;';
            if (passed) score++;
        }

        // Score 0-5 ? visual bar
        var bar    = document.getElementById('strengthBar');
        var label  = document.getElementById('strengthLabel');
        if (!bar || !label) return;

        var pct, color, text, textColor;
        if (pw.length === 0) {
            pct = 0; color = '#e5e7eb'; text = 'Enter a password'; textColor = '#d1d5db';
        } else if (score <= 1) {
            pct = 15;  color = '#ef4444'; text = 'Very Weak';  textColor = '#ef4444';
        } else if (score === 2) {
            pct = 35;  color = '#f97316'; text = 'Weak';       textColor = '#f97316';
        } else if (score === 3) {
            pct = 58;  color = '#eab308'; text = 'Fair';       textColor = '#ca8a04';
        } else if (score === 4) {
            pct = 80;  color = '#84cc16'; text = 'Strong';     textColor = '#65a30d';
        } else {
            pct = 100; color = '#22c55e'; text = 'Very Strong'; textColor = '#16a34a';
        }

        bar.style.width      = pct + '%';
        bar.style.background = color;
        label.textContent    = text;
        label.style.color    = textColor;
    }
</script>

</asp:Content>



