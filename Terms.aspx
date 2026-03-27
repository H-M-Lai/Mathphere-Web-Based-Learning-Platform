<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true" CodeBehind="Terms.aspx.cs" Inherits="MathSphere.Terms" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">Terms n Conditions</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- HERO --%>
    <div class="mb-14 max-w-3xl">
        <div class="inline-flex items-center gap-2 bg-primary/20 text-math-dark-blue px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-widest mb-5">
            <span class="material-symbols-outlined text-base fill-icon">gavel</span>
            Legal
        </div>
        <h1 class="text-5xl font-black text-math-dark-blue uppercase tracking-tighter italic leading-none mb-4">
            Terms namp; Conditions
        </h1>
        <p class="text-gray-500 font-medium text-lg leading-relaxed">
            Last updated: <strong class="text-math-dark-blue">March 11, 2026</strong> nnbsp;·nnbsp;
            Please read these terms carefully before using MathSphere.
        </p>
    </div>

    <%-- LAYOUT --%>
    <div class="grid grid-cols-1 lg:grid-cols-[260px_1fr] gap-10 items-start">

        <%-- Sticky TOC --%>
        <aside class="hidden lg:block sticky top-28">
            <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-6">
                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4">On this page</p>
                <nav class="flex flex-col gap-1" id="tocNav">
                    <a href="#acceptance"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">1. Acceptance</a>
                    <a href="#eligibility"  class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">2. Eligibility</a>
                    <a href="#accounts"     class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">3. Accounts</a>
                    <a href="#conduct"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">4. Acceptable Use</a>
                    <a href="#content"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">5. User Content</a>
                    <a href="#ip"           class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">6. Intellectual Property</a>
                    <a href="#termination"  class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">7. Termination</a>
                    <a href="#disclaimer"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">8. Disclaimer</a>
                    <a href="#changes"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">9. Changes to Terms</a>
                    <a href="#tnc-contact"  class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">10. Contact</a>
                </nav>
            </div>

            <%-- Quick summary card --%>
            <div class="mt-6 bg-primary/10 border-2 border-primary/30 rounded-[2rem] p-6">
                <p class="text-[10px] font-black uppercase tracking-widest text-math-dark-blue mb-3">Quick Summary</p>
                <ul class="space-y-2 text-xs font-semibold text-gray-600">
                    <li class="flex items-start gap-2"><span class="text-math-green font-black mt-0.5">n#10003;</span> Use MathSphere for learning only</li>
                    <li class="flex items-start gap-2"><span class="text-math-green font-black mt-0.5">n#10003;</span> Keep your login credentials safe</li>
                    <li class="flex items-start gap-2"><span class="text-math-green font-black mt-0.5">n#10003;</span> Be respectful on the forum</li>
                    <li class="flex items-start gap-2"><span class="text-red-500 font-black mt-0.5">n#10007;</span> No cheating or sharing answers</li>
                    <li class="flex items-start gap-2"><span class="text-red-500 font-black mt-0.5">n#10007;</span> No scraping or automated access</li>
                </ul>
            </div>
        </aside>

        <%-- Content --%>
        <div class="space-y-8">

            <%-- Intro banner --%>
            <div class="bg-primary rounded-[2rem] p-8 border-4 border-primary/60">
                <div class="flex items-start gap-4">
                    <div class="size-12 bg-math-dark-blue/10 rounded-2xl flex items-center justify-center flex-shrink-0 mt-1">
                        <span class="material-symbols-outlined fill-icon text-2xl text-math-dark-blue">description</span>
                    </div>
                    <div>
                        <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-2">Agreement to Terms</h2>
                        <p class="text-math-dark-blue/70 font-medium leading-relaxed text-sm">
                            These Terms and Conditions govern your access to and use of the MathSphere learning platform operated by MathSphere Studios ("we", "us", "our"). By accessing or using MathSphere, you confirm that you have read, understood, and agree to be bound by these terms.
                        </p>
                    </div>
                </div>
            </div>

            <%-- Section 1 --%>
            <div id="acceptance" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue">
                        <span class="material-symbols-outlined fill-icon">handshake</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">1. Acceptance of Terms</h2>
                </div>
                <p class="text-sm text-gray-600 font-medium leading-relaxed">
                    By creating an account or using any feature of MathSphere, you agree to these Terms and our <a href="Privacy.aspx" class="text-math-blue font-black hover:underline">Privacy Policy</a>. If you do not agree, please discontinue use immediately. Your continued use of the platform after any updates to these terms constitutes acceptance of the revised terms.
                </p>
            </div>

            <%-- Section 2 --%>
            <div id="eligibility" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-green-50 rounded-xl flex items-center justify-center text-math-green">
                        <span class="material-symbols-outlined fill-icon">person_check</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">2. Eligibility</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>MathSphere is intended for use by students, teachers, and administrators associated with partnered schools and educational institutions.</p>
                    <p>Student accounts must be created by an authorised administrator or teacher. Students under 13 may only use the platform under the oversight of a responsible educator or guardian.</p>
                    <p>By registering, you represent that all information you provide is accurate and up to date.</p>
                </div>
            </div>

            <%-- Section 3 --%>
            <div id="accounts" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600">
                        <span class="material-symbols-outlined fill-icon">manage_accounts</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">3. Accounts namp; Security</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>You are responsible for maintaining the confidentiality of your login credentials. You must not share your password with any other person.</p>
                    <p>You must notify your administrator or our support team immediately if you suspect unauthorised access to your account.</p>
                    <p>MathSphere reserves the right to suspend or terminate accounts found to be in violation of these terms, used for fraudulent activity, or inactive for an extended period.</p>
                    <p>One account per person. Creating duplicate accounts is not permitted.</p>
                </div>
            </div>

            <%-- Section 4 --%>
            <div id="conduct" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-red-50 rounded-xl flex items-center justify-center text-red-500">
                        <span class="material-symbols-outlined fill-icon">policy</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">4. Acceptable Use</h2>
                </div>
                <p class="text-sm text-gray-600 font-medium mb-4">You agree NOT to use MathSphere to:</p>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                        <span class="text-red-500 font-black text-base mt-0.5">n#10007;</span>
                        <p class="text-xs font-semibold text-gray-600">Cheat, share quiz answers, or gain unfair academic advantages.</p>
                    </div>
                    <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                        <span class="text-red-500 font-black text-base mt-0.5">n#10007;</span>
                        <p class="text-xs font-semibold text-gray-600">Post abusive, offensive, discriminatory, or harmful content on the forum.</p>
                    </div>
                    <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                        <span class="text-red-500 font-black text-base mt-0.5">n#10007;</span>
                        <p class="text-xs font-semibold text-gray-600">Attempt to reverse-engineer, scrape, or gain unauthorised access to the platform.</p>
                    </div>
                    <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                        <span class="text-red-500 font-black text-base mt-0.5">n#10007;</span>
                        <p class="text-xs font-semibold text-gray-600">Impersonate another user, teacher, or administrator.</p>
                    </div>
                    <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                        <span class="text-red-500 font-black text-base mt-0.5">n#10007;</span>
                        <p class="text-xs font-semibold text-gray-600">Upload malicious files, scripts, or disruptive content of any kind.</p>
                    </div>
                    <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                        <span class="text-red-500 font-black text-base mt-0.5">n#10007;</span>
                        <p class="text-xs font-semibold text-gray-600">Use automated bots or scripts to manipulate scores, streaks, or rankings.</p>
                    </div>
                </div>
            </div>

            <%-- Section 5 --%>
            <div id="content" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-purple-50 rounded-xl flex items-center justify-center text-purple-500">
                        <span class="material-symbols-outlined fill-icon">edit_note</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">5. User Content</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>You retain ownership of content you post (forum posts, comments). By posting, you grant MathSphere a non-exclusive, royalty-free licence to display that content within the platform.</p>
                    <p>You are solely responsible for the content you submit. MathSphere reserves the right to remove any content that violates these terms or is otherwise deemed inappropriate, without prior notice.</p>
                    <p>Repeated violations of content policies may result in account suspension or permanent ban.</p>
                </div>
            </div>

            <%-- Section 6 --%>
            <div id="ip" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-math-blue/10 rounded-xl flex items-center justify-center text-math-blue">
                        <span class="material-symbols-outlined fill-icon">copyright</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">6. Intellectual Property</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>All course content, module materials, quizzes, flashcards, graphics, and platform design are the intellectual property of MathSphere Studios or its licensors. You may not copy, reproduce, distribute, or create derivative works from this content without explicit written permission.</p>
                    <p>The MathSphere name, logo, and branding are trademarks of MathSphere Studios. Unauthorised use is strictly prohibited.</p>
                </div>
            </div>

            <%-- Section 7 --%>
            <div id="termination" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-red-50 rounded-xl flex items-center justify-center text-red-500">
                        <span class="material-symbols-outlined fill-icon">block</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">7. Termination</h2>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>MathSphere Studios reserves the right to suspend or permanently deactivate any account at our discretion, including for violations of these terms, fraudulent activity, or prolonged inactivity.</p>
                    <p>Upon termination, your access to the platform and all associated data will be revoked. You may request data deletion by contacting your administrator.</p>
                    <p>Administrators may disable or delete student accounts at any time in accordance with their institution's policies.</p>
                </div>
            </div>

            <%-- Section 8 --%>
            <div id="disclaimer" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-orange-50 rounded-xl flex items-center justify-center text-orange-500">
                        <span class="material-symbols-outlined fill-icon">warning</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">8. Disclaimer of Warranties</h2>
                </div>
                <div class="bg-orange-50 border border-orange-200 rounded-2xl p-5 mb-5">
                    <p class="text-xs font-black text-orange-800 uppercase tracking-wide">Important notice</p>
                </div>
                <div class="space-y-3 text-sm text-gray-600 font-medium leading-relaxed">
                    <p>MathSphere is provided on an "as is" and "as available" basis. We make no warranties, express or implied, regarding uninterrupted availability, accuracy of content, or fitness for a particular purpose.</p>
                    <p>We are not liable for any loss of data, academic consequences, or indirect damages arising from use of the platform. Scheduled maintenance or unexpected outages may temporarily interrupt access.</p>
                </div>
            </div>

            <%-- Section 9 --%>
            <div id="changes" class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue">
                        <span class="material-symbols-outlined fill-icon">update</span>
                    </div>
                    <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">9. Changes to These Terms</h2>
                </div>
                <p class="text-sm text-gray-600 font-medium leading-relaxed">
                    We may update these Terms and Conditions from time to time. When we do, we will update the "Last updated" date at the top of this page. Significant changes will be communicated via an in-platform notification. Your continued use of MathSphere after changes are posted constitutes your acceptance of the revised terms.
                </p>
            </div>

            <%-- Section 10 --%>
            <div id="tnc-contact" class="bg-math-dark-blue text-white rounded-[2rem] p-8 scroll-mt-28">
                <div class="flex items-center gap-3 mb-5">
                    <div class="size-10 bg-white/20 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined fill-icon">mail</span>
                    </div>
                    <h2 class="text-xl font-black uppercase tracking-tight">10. Contact</h2>
                </div>
                <p class="text-blue-200 text-sm font-medium leading-relaxed mb-6">
                    If you have questions about these Terms and Conditions, please contact your school administrator or reach out to the MathSphere support team through the Help Center.
                </p>
                <div class="flex flex-wrap gap-3">
                    <a href="StudentSupport.aspx"
                       class="inline-flex items-center gap-2 bg-primary text-math-dark-blue font-black px-6 py-3 rounded-2xl text-sm uppercase tracking-widest hover:bg-yellow-400 transition-colors shadow-lg">
                        <span class="material-symbols-outlined text-base">support_agent</span>
                        Help Center
                    </a>
                    <a href="Privacy.aspx"
                       class="inline-flex items-center gap-2 bg-white/10 text-white border border-white/20 font-black px-6 py-3 rounded-2xl text-sm uppercase tracking-widest hover:bg-white/20 transition-colors">
                        <span class="material-symbols-outlined text-base">shield</span>
                        Privacy Policy
                    </a>
                </div>
            </div>

        </div>
    </div>

    <style>
        .toc-link.active { color: #2563eb; background: #eff6ff; }
    </style>

    <script>
        (function () {
            var sections = ['acceptance','eligibility','accounts','conduct','content','ip','termination','disclaimer','changes','tnc-contact'];
            window.addEventListener('scroll', function () {
                var scrollY = window.scrollY + 140;
                sections.forEach(function (id) {
                    var el = document.getElementById(id);
                    var link = document.querySelector('.toc-link[href="#' + id + '"]');
                    if (!el || !link) return;
                    if (el.offsetTop <= scrollY nn el.offsetTop + el.offsetHeight > scrollY) {
                        document.querySelectorAll('.toc-link').forEach(function(l){ l.classList.remove('active'); });
                        link.classList.add('active');
                    }
                });
            }, { passive: true });
        })();
    </script>

</asp:Content>


