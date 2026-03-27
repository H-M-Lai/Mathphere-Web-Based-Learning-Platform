<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="TeacherPrivacy.aspx.cs" Inherits="MathSphere.TeacherPrivacy" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">Privacy Policy</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-14 max-w-3xl">
        <div class="inline-flex items-center gap-2 bg-math-blue/10 text-math-blue px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-widest mb-5">
            <span class="material-symbols-outlined text-base fill-icon">shield</span>
            Legal
        </div>
        <h1 class="text-5xl font-black text-math-dark-blue uppercase tracking-tighter italic leading-none mb-4">
            Privacy Policy
        </h1>
        <p class="text-gray-500 font-medium text-lg leading-relaxed">
            Last updated: <strong class="text-math-dark-blue">March 11, 2026</strong> &nbsp;·&nbsp;
            Effective immediately for all MathSphere users.
        </p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-[260px_1fr] gap-10 items-start">

        <%-- Sticky TOC --%>
        <aside class="hidden lg:block sticky top-28">
            <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-6">
                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4">On this page</p>
                <nav class="flex flex-col gap-1">
                    <a href="#info"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">1. Information We Collect</a>
                    <a href="#use"       class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">2. How We Use It</a>
                    <a href="#sharing"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">3. Sharing & Disclosure</a>
                    <a href="#cookies"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">4. Cookies</a>
                    <a href="#retention" class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">5. Data Retention</a>
                    <a href="#rights"    class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">6. Your Rights</a>
                    <a href="#security"  class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">7. Security</a>
                    <a href="#children"  class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">8. Children</a>
                    <a href="#contact"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">9. Contact Us</a>
                </nav>
            </div>
        </aside>

        <div class="space-y-8">

            <div class="bg-math-blue text-white rounded-[2rem] p-8">
                <div class="flex items-start gap-4">
                    <div class="size-12 bg-white/20 rounded-2xl flex items-center justify-center flex-shrink-0 mt-1">
                        <span class="material-symbols-outlined fill-icon text-2xl">privacy_tip</span>
                    </div>
                    <div>
                        <h2 class="text-xl font-black uppercase tracking-tight mb-2">Your Privacy Matters</h2>
                        <p class="text-blue-100 font-medium leading-relaxed text-sm">
                            MathSphere Studios ("we", "us", "our") is committed to protecting your personal information.
                            This policy explains what data we collect, why we collect it, and how we keep it safe.
                            By using MathSphere, you agree to the practices described below.
                        </p>
                    </div>
                </div>
            </div>

            <div id="info" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue">
                        <span class="material-symbols-outlined fill-icon">database</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">1. Information We Collect</h2>
                </div>
                <div class="space-y-4 text-gray-600 text-sm font-medium leading-relaxed">
                    <p><strong class="text-math-dark-blue">Account Data:</strong> When you register, we collect your full name, email address, school name, and a securely hashed password. Google Sign-In accounts do not store a local password.</p>
                    <p><strong class="text-math-dark-blue">Learning Data:</strong> We track your module progress, quiz attempts, flashcard completions, scores, streaks, and XP to personalise your experience and generate leaderboard rankings.</p>
                    <p><strong class="text-math-dark-blue">Usage Data:</strong> We log login dates and activity timestamps to calculate streaks and detect inactivity. We do not collect device fingerprints or IP addresses beyond standard server logs.</p>
                    <p><strong class="text-math-dark-blue">User-Generated Content:</strong> Forum posts and comments you create are stored and associated with your account.</p>
                    <p><strong class="text-math-dark-blue">Profile Media:</strong> If you upload a profile avatar, the image is stored on our servers and linked to your account.</p>
                </div>
            </div>

            <div id="use" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-green-50 rounded-xl flex items-center justify-center text-math-green">
                        <span class="material-symbols-outlined fill-icon">lightbulb</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">2. How We Use Your Data</h2>
                </div>
                <ul class="space-y-3 text-sm text-gray-600 font-medium">
                    <li class="flex items-start gap-3"><span class="size-5 bg-math-green/10 text-math-green rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 text-xs font-black">✓</span>Authenticate your login and maintain your session securely.</li>
                    <li class="flex items-start gap-3"><span class="size-5 bg-math-green/10 text-math-green rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 text-xs font-black">✓</span>Track learning progress, award XP, and calculate streaks.</li>
                    <li class="flex items-start gap-3"><span class="size-5 bg-math-green/10 text-math-green rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 text-xs font-black">✓</span>Display personalised dashboards, leaderboards, and recommendations.</li>
                    <li class="flex items-start gap-3"><span class="size-5 bg-math-green/10 text-math-green rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 text-xs font-black">✓</span>Send transactional emails (account creation, password reset, account status changes).</li>
                    <li class="flex items-start gap-3"><span class="size-5 bg-math-green/10 text-math-green rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 text-xs font-black">✓</span>Enable administrators and teachers to manage users and monitor platform health.</li>
                    <li class="flex items-start gap-3"><span class="size-5 bg-math-green/10 text-math-green rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 text-xs font-black">✓</span>Improve platform features using aggregated, anonymised usage statistics.</li>
                </ul>
            </div>

            <div id="sharing" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600">
                        <span class="material-symbols-outlined fill-icon">share</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">3. Sharing & Disclosure</h2>
                </div>
                <div class="bg-yellow-50 border border-yellow-200 rounded-2xl p-5 mb-5">
                    <p class="text-sm font-black text-yellow-800">⚠ We do not sell, rent, or trade your personal information to third parties.</p>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p><strong class="text-math-dark-blue">Service Providers:</strong> We may share data with trusted third-party services (e.g. email delivery, cloud hosting) strictly for operating the platform. They are contractually bound to protect your data.</p>
                    <p><strong class="text-math-dark-blue">Google OAuth:</strong> When you use Google Sign-In, your email and profile name are received from Google. We do not receive or store your Google password.</p>
                    <p><strong class="text-math-dark-blue">Legal Requirements:</strong> We may disclose data if required by law or to protect the rights, property, or safety of MathSphere, our users, or the public.</p>
                </div>
            </div>

            <div id="cookies" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-orange-50 rounded-xl flex items-center justify-center text-orange-500">
                        <span class="material-symbols-outlined fill-icon">cookie</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">4. Cookies</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>MathSphere uses <strong class="text-math-dark-blue">session cookies</strong> to maintain your login state using ASP.NET's built-in session management. These are essential for the platform to function and are deleted when you close your browser or log out.</p>
                    <p>We use reCAPTCHA on our login form. Google's reCAPTCHA service may set its own cookies subject to Google's Privacy Policy.</p>
                    <p>We do not use advertising cookies or third-party analytics trackers beyond what is described above.</p>
                </div>
            </div>

            <div id="retention" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-purple-50 rounded-xl flex items-center justify-center text-purple-500">
                        <span class="material-symbols-outlined fill-icon">schedule</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">5. Data Retention</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>Your account data is retained for as long as your account is active. Soft-deleted accounts (marked <code class="bg-gray-100 px-1.5 py-0.5 rounded-lg text-xs font-mono">isDeleted = 1</code>) are retained for up to <strong>90 days</strong> before permanent removal to allow recovery if needed.</p>
                    <p>Password reset tokens expire after <strong>30 minutes</strong> and are marked as used immediately upon redemption.</p>
                    <p>Activity logs are retained for platform audit and security purposes for up to <strong>12 months</strong>.</p>
                </div>
            </div>

            <div id="rights" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-math-blue/10 rounded-xl flex items-center justify-center text-math-blue">
                        <span class="material-symbols-outlined fill-icon">gavel</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">6. Your Rights</h2>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                        <p class="font-black text-math-dark-blue text-sm mb-1">Access</p>
                        <p class="text-xs text-gray-500 font-medium">Request a copy of the personal data we hold about you.</p>
                    </div>
                    <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                        <p class="font-black text-math-dark-blue text-sm mb-1">Correction</p>
                        <p class="text-xs text-gray-500 font-medium">Ask us to correct inaccurate or incomplete data via your profile settings or by contacting support.</p>
                    </div>
                    <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                        <p class="font-black text-math-dark-blue text-sm mb-1">Deletion</p>
                        <p class="text-xs text-gray-500 font-medium">Request deletion of your account and associated data by contacting an administrator.</p>
                    </div>
                    <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                        <p class="font-black text-math-dark-blue text-sm mb-1">Portability</p>
                        <p class="text-xs text-gray-500 font-medium">Request an export of your learning data in a machine-readable format where technically feasible.</p>
                    </div>
                </div>
            </div>

            <div id="security" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-green-50 rounded-xl flex items-center justify-center text-math-green">
                        <span class="material-symbols-outlined fill-icon">lock</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">7. Security</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>Passwords are hashed using <strong class="text-math-dark-blue">PBKDF2-SHA256 with 100,000 iterations</strong> and a random 128-bit salt — they are never stored in plain text.</p>
                    <p>All data is transmitted over HTTPS. Session tokens are managed server-side and invalidated on logout.</p>
                    <p>While we implement industry-standard measures, no system is 100% secure. Please use a strong, unique password and report any suspicious activity to our support team immediately.</p>
                </div>
            </div>

            <div id="children" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-pink-50 rounded-xl flex items-center justify-center text-pink-500">
                        <span class="material-symbols-outlined fill-icon">child_care</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">8. Children's Privacy</h2>
                </div>
                <p class="text-sm text-gray-600 font-medium leading-relaxed">
                    MathSphere is designed for school-age students and may be used by children under 13 only under the supervision of a parent, guardian, or educator. Student accounts are created by administrators or teachers; children cannot self-register. We do not knowingly collect personal data from children without appropriate consent. If you believe a child's data has been collected inappropriately, please contact us immediately.
                </p>
            </div>

            <div id="contact" class="bg-math-dark-blue text-white rounded-[2rem] p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-white/20 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined fill-icon">mail</span>
                    </div>
                    <h2 class="text-xl font-black uppercase tracking-tight">9. Contact Us</h2>
                </div>
                <p class="text-blue-200 text-sm font-medium leading-relaxed mb-6">
                    If you have any questions about this Privacy Policy or wish to exercise your data rights, please reach out to your school administrator or contact the MathSphere support team.
                </p>
                <a href="TeacherSupport.aspx"
                   class="inline-flex items-center gap-2 bg-primary text-math-dark-blue font-black px-6 py-3 rounded-2xl text-sm uppercase tracking-widest hover:bg-yellow-400 transition-colors shadow-lg">
                    <span class="material-symbols-outlined text-base">support_agent</span>
                    Go to Help Center
                </a>
            </div>

        </div>
    </div>

    <style>.toc-link.active { color:#2563eb;background:#eff6ff; }</style>
    <script>
        (function () {
            var sections = ['info','use','sharing','cookies','retention','rights','security','children','contact'];
            window.addEventListener('scroll', function () {
                var scrollY = window.scrollY + 140;
                sections.forEach(function (id) {
                    var el = document.getElementById(id);
                    var link = document.querySelector('.toc-link[href="#' + id + '"]');
                    if (!el || !link) return;
                    if (el.offsetTop <= scrollY && el.offsetTop + el.offsetHeight > scrollY) {
                        document.querySelectorAll('.toc-link').forEach(function(l){ l.classList.remove('active'); });
                        link.classList.add('active');
                    }
                });
            }, { passive: true });
        })();
    </script>

</asp:Content>
