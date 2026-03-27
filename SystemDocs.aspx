<%@ Page Language="C#" MasterPageFile="~/Admin.master" AutoEventWireup="true"
         CodeBehind="SystemDocs.aspx.cs" Inherits="MathSphere.SystemDocs" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">System Docs</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
<style>
    #docModal {
        position:fixed;inset:0;z-index:9000;
        background:rgba(15,23,42,.65);backdrop-filter:blur(6px);
        display:none;align-items:center;justify-content:center;padding:1.5rem;
    }
    #docModal.open { display:flex !important; }
    #docModalBody  { max-height:68vh;overflow-y:auto; }
    .doc-card { transition:transform .18s,box-shadow .18s; }
    .doc-card:hover { transform:translateY(-4px);box-shadow:0 20px 40px rgba(37,99,235,.13); }
    .toc-link.active { color:#2563eb;background:#eff6ff;border-radius:.75rem; }
    html { scroll-behavior:smooth; }
    pre, code { font-family: 'Courier New', monospace; }
</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- MODAL --%>
    <div id="docModal" onclick="dmBgClick(event)">
        <div class="bg-white w-full max-w-2xl rounded-[2.5rem] shadow-[0_35px_60px_-15px_rgba(0,0,0,0.35)] overflow-hidden"
             onclick="event.stopPropagation()">
            <div class="bg-math-dark-blue px-10 pt-10 pb-8">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <div id="dmChapter" class="inline-block px-3 py-1 bg-primary/20 text-primary rounded-full text-[10px] font-black uppercase tracking-widest mb-3"></div>
                        <h3 id="dmTitle" class="text-2xl font-black text-white uppercase tracking-tight italic leading-tight"></h3>
                    </div>
                    <button type="button" onclick="dmClose()"
                            class="size-10 flex-shrink-0 bg-white/10 hover:bg-white/20 rounded-2xl flex items-center justify-center text-white transition-colors mt-1">
                        <span class="material-symbols-outlined text-xl">close</span>
                    </button>
                </div>
            </div>
            <div id="docModalBody" class="px-10 py-8">
                <div id="dmContent" class="text-gray-600 font-medium leading-relaxed text-sm space-y-3"></div>
            </div>
        </div>
    </div>

    <%-- HERO --%>
    <div class="mb-14">
        <div class="inline-flex items-center gap-2 bg-primary/20 text-math-dark-blue px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-widest mb-5">
            <span class="material-symbols-outlined text-base fill-icon">description</span>
            Internal Reference
        </div>
        <h1 class="text-5xl font-black text-math-dark-blue uppercase tracking-tighter italic leading-none mb-3">
            System Docs
        </h1>
        <p class="text-gray-500 font-medium text-lg max-w-2xl">
            Technical documentation for the MathSphere platform — architecture, database schema, authentication flows, and configuration reference.
        </p>
    </div>

    <%-- LAYOUT --%>
    <div class="grid grid-cols-1 lg:grid-cols-[240px_1fr] gap-10 items-start">

        <%-- TOC --%>
        <aside class="hidden lg:block sticky top-28">
            <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-6">
                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4">Contents</p>
                <nav class="flex flex-col gap-1">
                    <a href="#overview"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">1. Overview</a>
                    <a href="#arch"       class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">2. Architecture</a>
                    <a href="#database"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">3. Database Schema</a>
                    <a href="#auth"       class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">4. Authentication</a>
                    <a href="#roles"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">5. Roles & Permissions</a>
                    <a href="#settings"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">6. System Settings</a>
                    <a href="#email"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">7. Email Service</a>
                    <a href="#logs"       class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">8. Activity Logs</a>
                    <a href="#deploy"     class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">9. Deployment</a>
                </nav>
            </div>
        </aside>

        <%-- Content --%>
        <div class="space-y-12">

            <%-- 1. Overview --%>
            <section id="overview" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">info</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">1. Overview</h2>
                </div>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8">
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
                        <div class="bg-blue-50 rounded-2xl p-4 text-center">
                            <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Framework</p>
                            <p class="font-black text-math-dark-blue text-sm">ASP.NET WebForms</p>
                        </div>
                        <div class="bg-yellow-50 rounded-2xl p-4 text-center">
                            <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Language</p>
                            <p class="font-black text-math-dark-blue text-sm">C# / .NET</p>
                        </div>
                        <div class="bg-green-50 rounded-2xl p-4 text-center">
                            <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Database</p>
                            <p class="font-black text-math-dark-blue text-sm">SQL Server</p>
                        </div>
                        <div class="bg-purple-50 rounded-2xl p-4 text-center">
                            <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">UI</p>
                            <p class="font-black text-math-dark-blue text-sm">Tailwind CSS</p>
                        </div>
                    </div>
                    <p class="text-sm text-gray-600 font-medium leading-relaxed">
                        MathSphere is a school-facing e-learning platform built on ASP.NET WebForms with SQL Server. It supports three user roles — Admin, Teacher, and Student — each with dedicated master pages and role-scoped navigation. The platform handles course and module management, gamified learning (XP, streaks, leaderboards), assessments, a community forum, and a help/support system.
                    </p>
                </div>
            </section>

            <%-- 2. Architecture --%>
            <section id="arch" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">account_tree</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">2. Architecture</h2>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                    <div class="doc-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="dmOpen('Architecture','Master Pages & Routing','MathSphere uses three master pages:\n\n• Admin.master — sidebar navigation, admin profile card, logout button, activity log footer links.\n\n• Teacher.master — top navigation bar with sliding underline indicator, role pill, avatar.\n\n• Student.master — top navigation bar with XP/streak display.\n\nPage routing is handled by ASP.NET WebForms (.aspx files). Each role\'s pages sit in the project root and check Session[\"UserID\"] and Session[\"Role\"] on Page_Load for access control.\n\nConnection string key: MathSphereDB (defined in Web.config).')">
                        <div class="size-10 bg-yellow-50 rounded-2xl flex items-center justify-center text-yellow-600 mb-4 group-hover:bg-yellow-500 group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">layers</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-sm mb-2 group-hover:text-math-blue transition-colors uppercase tracking-tight">Master Pages & Routing</h4>
                        <p class="text-xs text-gray-400 font-medium">Admin, Teacher, Student master pages and session-based routing.</p>
                    </div>
                    <div class="doc-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="dmOpen('Architecture','Session & State Management','User sessions are managed via ASP.NET Session state. Key session variables:\n\n• Session[\"UserID\"] — e.g. A00001, T00001, S00001\n• Session[\"Role\"] — Admin / Teacher / Student\n• Session[\"FullName\"] — display name\n• Session[\"AvatarUrl\"] — profile picture path\n\nSessions are cleared and abandoned on logout via Session.Clear() + Session.Abandon() followed by Response.Redirect to Login.aspx.\n\nSession timeout is governed by the Web.config sessionState timeout value (default: 20 minutes of inactivity).')">
                        <div class="size-10 bg-blue-50 rounded-2xl flex items-center justify-center text-math-blue mb-4 group-hover:bg-math-blue group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">memory</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-sm mb-2 group-hover:text-math-blue transition-colors uppercase tracking-tight">Session & State</h4>
                        <p class="text-xs text-gray-400 font-medium">Session variables, timeouts, and logout behaviour.</p>
                    </div>
                    <div class="doc-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="dmOpen('Architecture','Project Structure','Key files and folders:\n\n/Image/ — static assets (logos, default avatar)\n/Admin/ — (optional) admin sub-pages\nAdmin.master / Teacher.master / Student.master\nLogin.aspx — entry point for all roles\nadminDashboard.aspx\nteacherDashboard.aspx\nstudentDashboard.aspx\nuserManagement.aspx\nsystemSetting.aspx\nhelpCenterHub.aspx\nSystemDocs.aspx\nApiReference.aspx\nAdminSupport.aspx\nTeacherHandbook.aspx\nTeacherSupport.aspx\nTeacherPrivacy.aspx\nStudentSupport.aspx\nPrivacy.aspx / Terms.aspx\nWeb.config — connection strings, app settings')">
                        <div class="size-10 bg-green-50 rounded-2xl flex items-center justify-center text-math-green mb-4 group-hover:bg-math-green group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">folder_open</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-sm mb-2 group-hover:text-math-blue transition-colors uppercase tracking-tight">Project Structure</h4>
                        <p class="text-xs text-gray-400 font-medium">File layout and key page inventory.</p>
                    </div>
                </div>
            </section>

            <%-- 3. Database Schema --%>
            <section id="database" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-green-50 rounded-xl flex items-center justify-center text-math-green flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">storage</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">3. Database Schema</h2>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <%-- Table cards --%>
                    <div class="doc-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="dmOpen('Database Schema','userTable','dbo.userTable — core user record\n\nuserID        nvarchar — A00001, T00001, S00001\nfullName      nvarchar\nemail         nvarchar (unique)\npasswordHash  nvarchar — base64(salt):base64(hash) or GOOGLE_AUTH\naccountStatus bit — 1 active, 0 disabled\nCreatedAt     datetime\nDeactivatedAt datetime (nullable)\nAvatarUrl     nvarchar (nullable)\nisDeleted     bit — soft delete flag\n\nSuperAdmin userID = U001 — cannot be disabled or deleted.')">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="size-8 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue">
                                <span class="material-symbols-outlined text-base fill-icon">table</span>
                            </span>
                            <h4 class="font-black text-math-dark-blue text-sm group-hover:text-math-blue transition-colors">userTable</h4>
                        </div>
                        <p class="text-xs text-gray-400 font-medium">Core user records for all roles.</p>
                    </div>
                    <div class="doc-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="dmOpen('Database Schema','userRoleTable & Role','dbo.Role\nroleID    int (PK)\nroleName  nvarchar — Admin, Teacher, Student\n\ndbo.userRoleTable\nuserID  nvarchar (FK ? userTable)\nroleID  int      (FK ? Role)\n\nA user may have one role entry. Role is read via JOIN in all permission checks.')">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="size-8 bg-purple-50 rounded-xl flex items-center justify-center text-purple-500">
                                <span class="material-symbols-outlined text-base fill-icon">table</span>
                            </span>
                            <h4 class="font-black text-math-dark-blue text-sm group-hover:text-math-blue transition-colors">userRoleTable & Role</h4>
                        </div>
                        <p class="text-xs text-gray-400 font-medium">Role assignment linking users to Admin/Teacher/Student.</p>
                    </div>
                    <div class="doc-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="dmOpen('Database Schema','HelpArticle','dbo.HelpArticle\narticleID     int (PK, identity)\nauthorUserID  nvarchar (FK -> userTable)\ntitle         nvarchar\ncontent       nvarchar(max)\ncreatedAt     datetime\nupdatedAt     datetime\nstatus        nvarchar - Draft / Published')">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="size-8 bg-green-50 rounded-xl flex items-center justify-center text-math-green">
                                <span class="material-symbols-outlined text-base fill-icon">table</span>
                            </span>
                            <h4 class="font-black text-math-dark-blue text-sm group-hover:text-math-blue transition-colors">HelpArticle</h4>
                        </div>
                        <p class="text-xs text-gray-400 font-medium">Help center article content table.</p>
                    </div>
                    <div class="doc-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="dmOpen('Database Schema','SystemSettings & Logs','dbo.SystemSettings\nSettingKey       nvarchar (PK)\nSettingValue     nvarchar\nDescription      nvarchar\nUpdatedAt        datetime\nUpdatedByUserID  nvarchar\n\nKnown keys: FlashcardCompletion, QuizPerfectScore,\nStreakBonus7Day, InactivityThresholdDays, DailyActivityWindowHours\n\ndbo.SysActivityLogTable\nLogID        int (PK, identity)\nEventType    nvarchar(100)\nDescription  nvarchar(100)\nCreatedAt    datetime\nStatus       nvarchar(50)\nPriority     nvarchar(50)\n\ndbo.PasswordResetTokens\nToken      nvarchar (PK)\nUserID     nvarchar\nEmail      nvarchar\nExpiresAt  datetime\nIsUsed     bit')">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="size-8 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600">
                                <span class="material-symbols-outlined text-base fill-icon">table</span>
                            </span>
                            <h4 class="font-black text-math-dark-blue text-sm group-hover:text-math-blue transition-colors">SystemSettings & Logs</h4>
                        </div>
                        <p class="text-xs text-gray-400 font-medium">Platform config keys, activity log, and password reset tokens.</p>
                    </div>
                </div>
            </section>

            <%-- 4. Authentication --%>
            <section id="auth" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-red-50 rounded-xl flex items-center justify-center text-red-500 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">lock</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">4. Authentication</h2>
                </div>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 space-y-5">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="bg-blue-50 rounded-2xl p-5 border border-blue-100">
                            <p class="font-black text-math-dark-blue text-sm mb-2 uppercase tracking-tight">Password Hashing</p>
                            <p class="text-xs text-gray-500 font-medium leading-relaxed">PBKDF2-SHA256, 100,000 iterations, 16-byte random salt, 32-byte hash. Stored as <code class="bg-white px-1 rounded">base64(salt):base64(hash)</code>. Seeded accounts use plain-text fallback (no colon separator).</p>
                        </div>
                        <div class="bg-green-50 rounded-2xl p-5 border border-green-100">
                            <p class="font-black text-math-dark-blue text-sm mb-2 uppercase tracking-tight">Google OAuth</p>
                            <p class="text-xs text-gray-500 font-medium leading-relaxed">Google Sign-In accounts store <code class="bg-white px-1 rounded">GOOGLE_AUTH</code> as passwordHash. These accounts cannot use the password reset flow.</p>
                        </div>
                        <div class="bg-yellow-50 rounded-2xl p-5 border border-yellow-100">
                            <p class="font-black text-math-dark-blue text-sm mb-2 uppercase tracking-tight">Password Reset</p>
                            <p class="text-xs text-gray-500 font-medium leading-relaxed">Tokens stored in <code class="bg-white px-1 rounded">PasswordResetTokens</code>. Valid for 30 minutes. Marked <code class="bg-white px-1 rounded">IsUsed = 1</code> immediately on redemption. Reset link sent via EmailService.</p>
                        </div>
                    </div>
                    <div class="bg-gray-50 rounded-2xl p-5 border border-gray-100">
                        <p class="font-black text-math-dark-blue text-sm mb-2 uppercase tracking-tight">User ID Format</p>
                        <p class="text-xs text-gray-500 font-medium">Admin: <code class="bg-white px-1 rounded">A00001</code> &nbsp;·&nbsp; Teacher: <code class="bg-white px-1 rounded">T00001</code> &nbsp;·&nbsp; Student: <code class="bg-white px-1 rounded">S00001</code> &nbsp;·&nbsp; SuperAdmin: <code class="bg-white px-1 rounded">U001</code> — generated via <code class="bg-white px-1 rounded">GenerateNextUserId()</code> with UPDLOCK + HOLDLOCK to prevent duplicates.</p>
                    </div>
                </div>
            </section>

            <%-- 5. Roles --%>
            <section id="roles" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-purple-50 rounded-xl flex items-center justify-center text-purple-500 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">admin_panel_settings</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">5. Roles & Permissions</h2>
                </div>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                    <table class="w-full text-xs font-semibold">
                        <thead class="bg-math-dark-blue text-white">
                            <tr>
                                <th class="text-left px-6 py-4 font-black uppercase tracking-widest">Capability</th>
                                <th class="text-center px-4 py-4 font-black uppercase tracking-widest">Admin</th>
                                <th class="text-center px-4 py-4 font-black uppercase tracking-widest">Teacher</th>
                                <th class="text-center px-4 py-4 font-black uppercase tracking-widest">Student</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-gray-600">
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Create / manage user accounts</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-gray-300">—</td><td class="text-center text-gray-300">—</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Disable / delete accounts</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-gray-300">—</td><td class="text-center text-gray-300">—</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Manage system settings</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-gray-300">—</td><td class="text-center text-gray-300">—</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Publish help articles</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-gray-300">—</td><td class="text-center text-gray-300">—</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Create & publish courses</td><td class="text-center text-gray-300">—</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-gray-300">—</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Enrol students in courses</td><td class="text-center text-gray-300">—</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-gray-300">—</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Create quizzes & assessments</td><td class="text-center text-gray-300">—</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-gray-300">—</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">View own progress & XP</td><td class="text-center text-gray-300">—</td><td class="text-center text-gray-300">—</td><td class="text-center text-math-green font-black">&#10003;</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Post in forum</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-math-green font-black">&#10003;</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">View help articles</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-math-green font-black">&#10003;</td><td class="text-center text-math-green font-black">&#10003;</td></tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <%-- 6. System Settings --%>
            <section id="settings" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">tune</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">6. System Settings</h2>
                </div>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                    <table class="w-full text-xs font-semibold">
                        <thead class="bg-gray-50 border-b-2 border-gray-100">
                            <tr>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">Key</th>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">Default</th>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">Description</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-gray-600">
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">FlashcardCompletion</td><td class="px-6 py-3">10 pts</td><td class="px-6 py-3">XP awarded per flashcard deck completion.</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">QuizPerfectScore</td><td class="px-6 py-3">50 pts</td><td class="px-6 py-3">XP awarded for achieving a perfect quiz score.</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">StreakBonus7Day</td><td class="px-6 py-3">100 pts</td><td class="px-6 py-3">Bonus XP for maintaining a 7-day activity streak.</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">InactivityThresholdDays</td><td class="px-6 py-3">3 days</td><td class="px-6 py-3">Days of no activity before streak resets.</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">DailyActivityWindowHours</td><td class="px-6 py-3">24 hrs</td><td class="px-6 py-3">Hours defining a single activity window (range 1–48).</td></tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <%-- 7. Email Service --%>
            <section id="email" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">mail</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">7. Email Service</h2>
                </div>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8">
                    <p class="text-sm text-gray-500 font-medium mb-5">All transactional emails are dispatched via <code class="bg-gray-100 px-2 py-0.5 rounded-lg text-math-blue">EmailService</code>. No marketing emails are sent.</p>
                    <div class="space-y-3">
                        <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100 flex items-start gap-4">
                            <span class="size-8 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue flex-shrink-0 mt-0.5"><span class="material-symbols-outlined text-base fill-icon">person_add</span></span>
                            <div><p class="font-black text-math-dark-blue text-xs mb-1">SendWelcomeWithCredentials</p><p class="text-xs text-gray-500 font-medium">Sent when an admin creates a new account. Includes login URL and temporary password.</p></div>
                        </div>
                        <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100 flex items-start gap-4">
                            <span class="size-8 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600 flex-shrink-0 mt-0.5"><span class="material-symbols-outlined text-base fill-icon">key</span></span>
                            <div><p class="font-black text-math-dark-blue text-xs mb-1">SendPasswordResetLink</p><p class="text-xs text-gray-500 font-medium">Sends a 30-minute expiry reset link. Token invalidated immediately on use.</p></div>
                        </div>
                        <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100 flex items-start gap-4">
                            <span class="size-8 bg-red-50 rounded-xl flex items-center justify-center text-red-400 flex-shrink-0 mt-0.5"><span class="material-symbols-outlined text-base fill-icon">block</span></span>
                            <div><p class="font-black text-math-dark-blue text-xs mb-1">SendAccountDisabled / Reactivated / Deleted</p><p class="text-xs text-gray-500 font-medium">Notifies user of account status changes triggered by admin actions.</p></div>
                        </div>
                    </div>
                </div>
            </section>

            <%-- 8. Activity Logs --%>
            <section id="logs" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-gray-100 rounded-xl flex items-center justify-center text-gray-500 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">history</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">8. Activity Logs</h2>
                </div>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 space-y-4">
                    <p class="text-sm text-gray-500 font-medium leading-relaxed">The <code class="bg-gray-100 px-2 py-0.5 rounded-lg text-math-blue">SysActivityLogTable</code> records platform events for audit and monitoring. Logs are retained for 12 months.</p>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                        <div class="bg-blue-50 rounded-2xl p-3 text-center border border-blue-100"><p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">EventType</p><p class="text-xs font-bold text-math-dark-blue">e.g. USER_LOGIN</p></div>
                        <div class="bg-green-50 rounded-2xl p-3 text-center border border-green-100"><p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Description</p><p class="text-xs font-bold text-math-dark-blue">Human-readable detail</p></div>
                        <div class="bg-yellow-50 rounded-2xl p-3 text-center border border-yellow-100"><p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Priority</p><p class="text-xs font-bold text-math-dark-blue">Low / Medium / High</p></div>
                        <div class="bg-red-50 rounded-2xl p-3 text-center border border-red-100"><p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Status</p><p class="text-xs font-bold text-math-dark-blue">Success / Warning / Error</p></div>
                    </div>
                </div>
            </section>

            <%-- 9. Deployment --%>
            <section id="deploy" class="scroll-mt-28">
                <div class="bg-math-dark-blue rounded-[2rem] p-8 md:p-10">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="size-10 bg-white/10 rounded-xl flex items-center justify-center flex-shrink-0">
                            <span class="material-symbols-outlined fill-icon text-primary">cloud_upload</span>
                        </div>
                        <h2 class="text-2xl font-black text-white uppercase tracking-tight">9. Deployment</h2>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                        <div class="bg-white/10 rounded-2xl p-5">
                            <p class="font-black text-primary text-xs uppercase tracking-widest mb-2">Web Server</p>
                            <p class="text-blue-200 text-xs font-medium leading-relaxed">Deploy via IIS on Windows Server. Publish the project using Visual Studio Publish ? File System or Web Deploy. Ensure the app pool is set to .NET CLR v4.0.</p>
                        </div>
                        <div class="bg-white/10 rounded-2xl p-5">
                            <p class="font-black text-primary text-xs uppercase tracking-widest mb-2">Database</p>
                            <p class="text-blue-200 text-xs font-medium leading-relaxed">Run the SQL setup scripts against your SQL Server instance. Update the <code class="bg-white/10 px-1 rounded">MathSphereDB</code> connection string in Web.config to point to your server.</p>
                        </div>
                        <div class="bg-white/10 rounded-2xl p-5">
                            <p class="font-black text-primary text-xs uppercase tracking-widest mb-2">Config Checklist</p>
                            <ul class="text-blue-200 text-xs font-medium space-y-1">
                                <li>&#10003; Update MathSphereDB connection string</li>
                                <li>&#10003; Set SMTP credentials in Web.config</li>
                                <li>&#10003; Set Google OAuth client ID</li>
                                <li>&#10003; Set reCAPTCHA site/secret keys</li>
                                <li>&#10003; Configure session timeout</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </section>

        </div>
    </div>

    <script>
        function dmOpen(chapter, title, content) {
            document.getElementById('dmChapter').textContent = chapter;
            document.getElementById('dmTitle').textContent   = title;
            var html = content.split('\n').map(function(line) {
                var t = line.trim();
                if (!t) return '';
                if (t.startsWith('•')) return '<p class="flex gap-2"><span class="text-math-blue font-black flex-shrink-0">•</span><span>' + t.slice(1).trim() + '</span></p>';
                if (t.startsWith('?')) return '<p class="flex gap-2"><span class="text-math-green font-black flex-shrink-0">&#10003;</span><span>' + t.slice(1).trim() + '</span></p>';
                return '<p>' + t + '</p>';
            }).filter(Boolean).join('');
            document.getElementById('dmContent').innerHTML = html;
            document.getElementById('docModal').classList.add('open');
            document.body.style.overflow = 'hidden';
        }
        function dmClose() {
            document.getElementById('docModal').classList.remove('open');
            document.body.style.overflow = '';
        }
        function dmBgClick(e) { if (e.target === document.getElementById('docModal')) dmClose(); }
        document.addEventListener('keydown', function(e) { if (e.key === 'Escape') dmClose(); });

        // TOC scroll highlight
        (function() {
            var ids = ['overview','arch','database','auth','roles','settings','email','logs','deploy'];
            window.addEventListener('scroll', function() {
                var y = window.scrollY + 150;
                ids.forEach(function(id) {
                    var el = document.getElementById(id);
                    var lk = document.querySelector('.toc-link[href="#'+id+'"]');
                    if (!el || !lk) return;
                    if (el.offsetTop <= y && el.offsetTop + el.offsetHeight > y) {
                        document.querySelectorAll('.toc-link').forEach(function(l){ l.classList.remove('active'); });
                        lk.classList.add('active');
                    }
                });
            }, { passive:true });
        })();
    </script>

</asp:Content>



