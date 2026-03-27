<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="teacherRegistration.aspx.cs"
         Inherits="MathSphere.teacherRegistration"
         MasterPageFile="~/Auth.master" Async="true" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    Teacher Registration — MathSphere
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <div class="max-w-6xl mx-auto">

        <div class="text-center mb-10">
            <h1 class="text-5xl font-black tracking-tight text-math-dark-blue">
                Join <span class="text-math-blue">MathSphere</span> as a Teacher
            </h1>
            <p class="mt-3 text-lg font-semibold text-gray-500">
                Create your free educator account and inspire the next generation.
            </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-[420px_1fr] overflow-hidden rounded-[2.75rem]
                    bg-white/70 backdrop-blur-md border border-gray-100
                    shadow-[0_18px_60px_rgba(0,0,0,0.08)]">

            <div class="relative p-10 md:p-12 bg-gradient-to-br from-math-dark-blue via-math-blue to-math-blue
                        text-white overflow-hidden flex flex-col justify-center">

                <div class="absolute -top-24 -right-24 size-72 rounded-full bg-primary/20 blur-3xl"></div>
                <div class="absolute -bottom-28 -left-28 size-72 rounded-full bg-white/10 blur-3xl"></div>

                <div class="absolute inset-0 opacity-10 pointer-events-none select-none">
                    <span class="absolute top-10 left-8 text-7xl font-black text-white">&sum;</span>
                    <span class="absolute bottom-16 right-8 text-7xl font-black text-white">&pi;</span>
                    <span class="absolute top-1/2 right-1/4 text-5xl font-black text-white">&Delta;</span>
                </div>

                <div class="relative z-10">
                    <div class="mb-10">
                        <div class="bg-primary w-24 h-32 rounded-r-2xl border-l-8 border-white
                                    flex items-center justify-center
                                    shadow-[10px_10px_0px_rgba(0,0,0,0.25)] relative">
                            <span class="material-symbols-outlined text-math-blue text-5xl fill-icon">menu_book</span>
                            <div class="absolute -top-7 -right-5 bg-math-green w-16 h-9 rounded-sm
                                        rotate-[-15deg] shadow-[4px_4px_0px_rgba(0,0,0,0.25)]
                                        flex items-center justify-center">
                                <span class="material-symbols-outlined text-white text-xl fill-icon">school</span>
                            </div>
                        </div>
                    </div>

                    <div class="flex items-center gap-3 mb-6">
                        <div class="size-12 rounded-2xl bg-primary text-math-dark-blue flex items-center
                                    justify-center shadow-lg shadow-primary/20 shrink-0">
                            <span class="material-symbols-outlined fill-icon text-2xl">school</span>
                        </div>
                        <div>
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-white/70">Educator</div>
                            <div class="text-xl font-black tracking-tight">Empower math wizards</div>
                        </div>
                    </div>

                    <h2 class="text-3xl font-black leading-tight">
                        Your classroom.<br />
                        Your students.<br />
                        <span class="text-primary">Your impact.</span>
                    </h2>

                    <p class="mt-4 text-white/75 font-semibold leading-relaxed">
                        Set assignments, track progress, and watch your students level up — all in one place.
                    </p>

                    <div class="mt-10 flex flex-wrap gap-2">
                        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                                     bg-white/10 border border-white/15 text-sm font-black">
                            <span class="material-symbols-outlined fill-icon text-base">assignment</span>
                            Assignments
                        </span>
                        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                                     bg-white/10 border border-white/15 text-sm font-black">
                            <span class="material-symbols-outlined fill-icon text-base">insights</span>
                            Analytics
                        </span>
                        <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full
                                     bg-white/10 border border-white/15 text-sm font-black">
                            <span class="material-symbols-outlined fill-icon text-base">groups</span>
                            1,200+ Teachers
                        </span>
                    </div>
                </div>
            </div>

            <div class="p-10 md:p-12">
                <div class="max-w-xl">

                    <div class="mb-8">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Registration</div>
                        <h3 class="text-3xl md:text-4xl font-black text-math-dark-blue mt-2">
                            Create Account
                        </h3>
                    </div>

                    <div class="space-y-5">

                        <div class="space-y-2">
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Full Name</div>
                            <asp:TextBox ID="txtFullName" runat="server"
                                placeholder="Dr. Sarah Euler"
                                CssClass="w-full px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                          font-semibold text-math-dark-blue placeholder:text-gray-400
                                          shadow-sm transition-all duration-200
                                          focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10 focus:bg-white" />
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server"
                                ControlToValidate="txtFullName"
                                ErrorMessage="Full name is required."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic"
                                ValidationGroup="RegisterGroup" />
                        </div>

                        <div class="space-y-2">
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Email</div>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                                placeholder="yourname@example.com"
                                CssClass="w-full px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                          font-semibold text-math-dark-blue placeholder:text-gray-400
                                          shadow-sm transition-all duration-200
                                          focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10 focus:bg-white" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ErrorMessage="Email is required."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic"
                                ValidationGroup="RegisterGroup" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                ErrorMessage="Enter a valid email address."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic"
                                ValidationGroup="RegisterGroup" />
                        </div>

                        <div class="space-y-2">
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Password</div>

                            <div class="relative">
                                <%-- ? Added ClientIDMode="Static" --%>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                                    ClientIDMode="Static"
                                    placeholder="Min. 8 characters"
                                    CssClass="w-full pr-14 px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                              font-semibold text-math-dark-blue placeholder:text-gray-400
                                              shadow-sm transition-all duration-200
                                              focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10 focus:bg-white" />

                                <%-- ? Replaced <%= txtPassword.ClientID %> with hardcoded 'txtPassword' --%>
                                <button type="button"
                                    class="absolute right-4 top-1/2 -translate-y-1/2
                                           size-10 rounded-xl bg-white/60 border border-gray-200
                                           flex items-center justify-center
                                           hover:bg-white hover:border-math-blue/20 transition-all"
                                    onclick="togglePassword('txtPassword', this)"
                                    aria-label="Show password">
                                    <span class="material-symbols-outlined text-gray-500">visibility</span>
                                </button>
                            </div>

                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                                ControlToValidate="txtPassword"
                                ErrorMessage="Password is required."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic"
                                ValidationGroup="RegisterGroup" />
                            <asp:RegularExpressionValidator ID="revPassword" runat="server"
                                ControlToValidate="txtPassword"
                                ValidationExpression=".{8,}"
                                ErrorMessage="Password must be at least 8 characters."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic"
                                ValidationGroup="RegisterGroup" />
                        </div>

                        <div class="space-y-2">
                            <div class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Confirm Password</div>

                            <div class="relative">
                                <%-- ? Added ClientIDMode="Static" --%>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                                    ClientIDMode="Static"
                                    placeholder="Re-enter password"
                                    CssClass="w-full pr-14 px-5 py-4 bg-white/70 border border-gray-200 rounded-2xl
                                              font-semibold text-math-dark-blue placeholder:text-gray-400
                                              shadow-sm transition-all duration-200
                                              focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10 focus:bg-white" />

                                <%-- ? Replaced <%= txtConfirmPassword.ClientID %> with hardcoded 'txtConfirmPassword' --%>
                                <button type="button"
                                    class="absolute right-4 top-1/2 -translate-y-1/2
                                           size-10 rounded-xl bg-white/60 border border-gray-200
                                           flex items-center justify-center
                                           hover:bg-white hover:border-math-blue/20 transition-all"
                                    onclick="togglePassword('txtConfirmPassword', this)"
                                    aria-label="Show password">
                                    <span class="material-symbols-outlined text-gray-500">visibility</span>
                                </button>
                            </div>

                            <asp:RequiredFieldValidator ID="rfvConfirm" runat="server"
                                ControlToValidate="txtConfirmPassword"
                                ErrorMessage="Please confirm your password."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic"
                                ValidationGroup="RegisterGroup" />
                            <asp:CompareValidator ID="cvPasswords" runat="server"
                                ControlToValidate="txtConfirmPassword"
                                ControlToCompare="txtPassword"
                                ErrorMessage="Passwords do not match."
                                CssClass="block text-red-500 text-sm font-semibold"
                                Display="Dynamic"
                                ValidationGroup="RegisterGroup" />
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
                            CssClass="rounded-2xl border px-4 py-3">
                            <div class="flex items-start gap-3">
                                <span class="material-symbols-outlined">error</span>
                                <asp:Label ID="lblMessage" runat="server"
                                    CssClass="text-sm font-semibold" />
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
                            Text="Create My Classroom"
                            OnClick="btnRegister_Click"
                            ValidationGroup="RegisterGroup"
                            CssClass="w-full bg-math-blue text-white font-black py-4 rounded-2xl
                                      uppercase tracking-widest text-sm
                                      shadow-lg shadow-math-blue/20
                                      hover:bg-math-dark-blue transition-all active:scale-[0.99]
                                      cursor-pointer mt-2" />

                        <div class="pt-4 text-center border-t border-gray-100">
                            <span class="text-xs font-black uppercase tracking-widest text-gray-400">
                                Already have an account?
                            </span>
                            <div class="mt-3 flex flex-wrap justify-center gap-3">
                                <asp:LinkButton ID="btnLogin" runat="server"
                                    OnClick="btnLogin_Click"
                                    CssClass="px-5 py-3 rounded-2xl bg-white/70 border border-gray-100
                                              font-black text-[11px] uppercase tracking-widest text-math-blue
                                              hover:bg-white hover:border-math-blue/20 transition-all">
                                    Back to Login
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnStudentJoin" runat="server"
                                    OnClick="btnStudentJoin_Click"
                                    CssClass="px-5 py-3 rounded-2xl bg-white/70 border border-gray-100
                                              font-black text-[11px] uppercase tracking-widest text-math-dark-blue
                                              hover:bg-white hover:border-math-blue/20 transition-all">
                                    Join as Student
                                </asp:LinkButton>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </div>

    <script>
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

