<%@ Page Language="C#" MasterPageFile="~/Admin.master" AutoEventWireup="true"
         CodeBehind="ApiReference.aspx.cs" Inherits="MathSphere.ApiReference" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">API Reference</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .toc-link.active { color:#2563eb;background:#eff6ff;border-radius:.75rem; }
    html { scroll-behavior:smooth; }
    .method-get    { background:#dcfce7;color:#166534; }
    .method-post   { background:#dbeafe;color:#1e40af; }
    .method-put    { background:#fef9c3;color:#854d0e; }
    .method-delete { background:#fee2e2;color:#991b1b; }
    .ep-card { transition:box-shadow .18s; }
    .ep-card:hover { box-shadow:0 8px 30px rgba(37,99,235,.10); }
    details > summary { cursor:pointer; list-style:none; }
    details > summary::-webkit-details-marker { display:none; }
    details[open] .chevron { transform:rotate(180deg); }
    .chevron { transition:transform .2s; }
    code, pre { font-family:'Courier New', monospace; }
</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- HERO --%>
    <div class="mb-14">
        <div class="inline-flex items-center gap-2 bg-math-blue/10 text-math-blue px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-widest mb-5">
            <span class="material-symbols-outlined text-base fill-icon">api</span>
            Internal Reference
        </div>
        <h1 class="text-5xl font-black text-math-dark-blue uppercase tracking-tighter italic leading-none mb-3">
            API Reference
        </h1>
        <p class="text-gray-500 font-medium text-lg max-w-2xl">
            Internal service methods, database helpers, and key code patterns used across the MathSphere platform.
        </p>
        <div class="flex flex-wrap gap-3 mt-6">
            <span class="method-get px-3 py-1 rounded-full text-[11px] font-black uppercase tracking-widest">READ</span>
            <span class="method-post px-3 py-1 rounded-full text-[11px] font-black uppercase tracking-widest">CREATE</span>
            <span class="method-put px-3 py-1 rounded-full text-[11px] font-black uppercase tracking-widest">UPDATE</span>
            <span class="method-delete px-3 py-1 rounded-full text-[11px] font-black uppercase tracking-widest">DELETE</span>
        </div>
    </div>

    <%-- LAYOUT --%>
    <div class="grid grid-cols-1 lg:grid-cols-[240px_1fr] gap-10 items-start">

        <%-- TOC --%>
        <aside class="hidden lg:block sticky top-28">
            <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-6">
                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4">Sections</p>
                <nav class="flex flex-col gap-1">
                    <a href="#users"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">User Management</a>
                    <a href="#auth"       class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">Authentication</a>
                    <a href="#courses"    class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">Courses & Modules</a>
                    <a href="#progress"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">Progress & XP</a>
                    <a href="#help"       class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">Help & Support</a>
                    <a href="#settings"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">System Settings</a>
                    <a href="#email"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">Email Service</a>
                    <a href="#patterns"   class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue py-1.5 px-3 transition-colors">Code Patterns</a>
                </nav>
            </div>
            <div class="mt-5 bg-blue-50 border-2 border-blue-100 rounded-[2rem] p-5">
                <p class="text-[10px] font-black uppercase tracking-widest text-math-blue mb-2">Note</p>
                <p class="text-xs font-medium text-gray-500 leading-relaxed">This is an internal code reference, not a REST API. All methods are C# server-side helpers used within the MathSphere WebForms project.</p>
            </div>
        </aside>

        <%-- Content --%>
        <div class="space-y-10">

            <%-- User Management --%>
            <section id="users" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue">
                        <span class="material-symbols-outlined text-base fill-icon">group</span>
                    </span>
                    User Management
                </h2>
                <div class="space-y-3">
                    <%-- Endpoint cards --%>
                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-post px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">CREATE</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">CreateUser(fullName, email, role, password)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5 space-y-4">
                            <p class="text-sm text-gray-500 font-medium">Creates a new user account. Hashes the password with PBKDF2-SHA256 (100k iterations), generates a unique UserID via <code class="bg-gray-100 px-1.5 rounded-lg">GenerateNextUserId()</code> with UPDLOCK, inserts into <code class="bg-gray-100 px-1.5 rounded-lg">userTable</code> and <code class="bg-gray-100 px-1.5 rounded-lg">userRoleTable</code>, then fires <code class="bg-gray-100 px-1.5 rounded-lg">EmailService.SendWelcomeWithCredentials()</code>.</p>
                            <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-2">Parameters</p>
                                <table class="text-xs font-semibold w-full">
                                    <tr><td class="text-math-blue font-mono py-1 pr-4">fullName</td><td class="text-gray-500">string — user's display name</td></tr>
                                    <tr><td class="text-math-blue font-mono py-1 pr-4">email</td><td class="text-gray-500">string — must be unique in userTable</td></tr>
                                    <tr><td class="text-math-blue font-mono py-1 pr-4">role</td><td class="text-gray-500">string — "Admin" / "Teacher" / "Student"</td></tr>
                                    <tr><td class="text-math-blue font-mono py-1 pr-4">password</td><td class="text-gray-500">string — plain text, hashed before storage</td></tr>
                                </table>
                            </div>
                        </div>
                    </details>

                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-put px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">UPDATE</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">SetAccountStatus(userID, status)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5 space-y-4">
                            <p class="text-sm text-gray-500 font-medium">Enables or disables a user account by setting <code class="bg-gray-100 px-1.5 rounded-lg">accountStatus</code> bit. SuperAdmin (U001) cannot be disabled. Fires <code class="bg-gray-100 px-1.5 rounded-lg">SendAccountDisabled</code> or <code class="bg-gray-100 px-1.5 rounded-lg">SendAccountReactivated</code> email.</p>
                            <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-2">Parameters</p>
                                <table class="text-xs font-semibold w-full">
                                    <tr><td class="text-math-blue font-mono py-1 pr-4">userID</td><td class="text-gray-500">string — target user ID</td></tr>
                                    <tr><td class="text-math-blue font-mono py-1 pr-4">status</td><td class="text-gray-500">bool — true = active, false = disabled</td></tr>
                                </table>
                            </div>
                        </div>
                    </details>

                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-delete px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">DELETE</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">SoftDeleteUser(userID)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium">Sets <code class="bg-gray-100 px-1.5 rounded-lg">isDeleted = 1</code> and records <code class="bg-gray-100 px-1.5 rounded-lg">DeactivatedAt</code>. Data is retained for 90 days before a scheduled hard-delete purge. SuperAdmin (U001) cannot be deleted. Fires <code class="bg-gray-100 px-1.5 rounded-lg">SendAccountDeleted</code> email.</p>
                        </div>
                    </details>

                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-get px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">READ</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">GenerateNextUserId(rolePrefix)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium mb-3">Generates the next sequential user ID for a given role prefix using a SQL transaction with <code class="bg-gray-100 px-1.5 rounded-lg">UPDLOCK, HOLDLOCK</code> to prevent race conditions.</p>
                            <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100 text-xs font-mono text-math-blue">
                                "A" ? A00001, A00002 …<br/>
                                "T" ? T00001, T00002 …<br/>
                                "S" ? S00001, S00002 …
                            </div>
                        </div>
                    </details>
                </div>
            </section>

            <%-- Authentication --%>
            <section id="auth" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-red-50 rounded-xl flex items-center justify-center text-red-500">
                        <span class="material-symbols-outlined text-base fill-icon">lock</span>
                    </span>
                    Authentication
                </h2>
                <div class="space-y-3">
                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-get px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">READ</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">VerifyPassword(inputPassword, storedHash)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5 space-y-3">
                            <p class="text-sm text-gray-500 font-medium">Verifies a plain-text password against a stored hash. Splits on <code class="bg-gray-100 px-1.5 rounded-lg">:</code> to extract salt and hash. Uses PBKDF2-SHA256 with 100,000 iterations. Falls back to plain-text comparison for seeded accounts that have no colon separator.</p>
                            <div class="bg-red-50 rounded-2xl p-4 border border-red-100 text-xs font-semibold text-red-700">
                                ? Always use 100,000 iterations — changing this value will break verification for all existing hashed accounts.
                            </div>
                        </div>
                    </details>

                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-get px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">READ</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">HashPasswordPbkdf2(password)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium">Generates a new salted hash. Creates a cryptographically random 16-byte salt via <code class="bg-gray-100 px-1.5 rounded-lg">RNGCryptoServiceProvider</code>, derives a 32-byte key using <code class="bg-gray-100 px-1.5 rounded-lg">Rfc2898DeriveBytes</code> (SHA256, 100k iterations), and returns <code class="bg-gray-100 px-1.5 rounded-lg">base64(salt):base64(hash)</code>.</p>
                        </div>
                    </details>

                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-post px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">CREATE</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">CreatePasswordResetToken(userID, email)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium">Generates a GUID token, inserts it into <code class="bg-gray-100 px-1.5 rounded-lg">PasswordResetTokens</code> with <code class="bg-gray-100 px-1.5 rounded-lg">ExpiresAt = DateTime.UtcNow.AddMinutes(30)</code> and <code class="bg-gray-100 px-1.5 rounded-lg">IsUsed = 0</code>. Sends the reset link via <code class="bg-gray-100 px-1.5 rounded-lg">EmailService.SendPasswordResetLink()</code>. Google OAuth accounts are blocked from this flow.</p>
                        </div>
                    </details>
                </div>
            </section>

            <%-- Courses & Modules --%>
            <section id="courses" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600">
                        <span class="material-symbols-outlined text-base fill-icon">library_books</span>
                    </span>
                    Courses & Modules
                </h2>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8 space-y-4">
                    <p class="text-sm text-gray-500 font-medium leading-relaxed">Course and module management is handled by teacher-facing pages. The following describes the key DB entities and status lifecycle.</p>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="bg-yellow-50 rounded-2xl p-4 border border-yellow-100">
                            <p class="font-black text-math-dark-blue text-xs uppercase tracking-widest mb-2">Course Status</p>
                            <p class="text-xs text-gray-500 font-medium">Draft ? Published ? Archived. Auto-archive fires on course EndDate if enabled. Students can only access Published courses.</p>
                        </div>
                        <div class="bg-blue-50 rounded-2xl p-4 border border-blue-100">
                            <p class="font-black text-math-dark-blue text-xs uppercase tracking-widest mb-2">Module Access Rules</p>
                            <p class="text-xs text-gray-500 font-medium">Sequential Progress and Require Quiz Pass are per-module flags. Pass Score (0–100) defines the passing threshold for sequential unlock.</p>
                        </div>
                        <div class="bg-green-50 rounded-2xl p-4 border border-green-100">
                            <p class="font-black text-math-dark-blue text-xs uppercase tracking-widest mb-2">Content Block Types</p>
                            <p class="text-xs text-gray-500 font-medium">Video, Text, Flashcard Set, Quiz, File. Blocks are ordered. Required blocks must be completed before progression.</p>
                        </div>
                    </div>
                </div>
            </section>

            <%-- Progress & XP --%>
            <section id="progress" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-green-50 rounded-xl flex items-center justify-center text-math-green">
                        <span class="material-symbols-outlined text-base fill-icon">star</span>
                    </span>
                    Progress & XP
                </h2>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                    <table class="w-full text-xs font-semibold">
                        <thead class="bg-gray-50 border-b-2 border-gray-100">
                            <tr>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">Event</th>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">XP Source</th>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">Default</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-gray-600">
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Flashcard deck completed</td><td class="px-6 py-3 text-math-blue font-mono">FlashcardCompletion</td><td class="px-6 py-3">10 pts</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Perfect quiz score</td><td class="px-6 py-3 text-math-blue font-mono">QuizPerfectScore</td><td class="px-6 py-3">50 pts</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">7-day activity streak</td><td class="px-6 py-3 text-math-blue font-mono">StreakBonus7Day</td><td class="px-6 py-3">100 pts</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3">Streak reset after</td><td class="px-6 py-3 text-math-blue font-mono">InactivityThresholdDays</td><td class="px-6 py-3">3 days</td></tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <%-- Help & Support --%>
            <section id="help" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-purple-50 rounded-xl flex items-center justify-center text-purple-500">
                        <span class="material-symbols-outlined text-base fill-icon">support_agent</span>
                    </span>
                    Help & Support
                </h2>
                <div class="space-y-3">
                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-get px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">READ</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">GetPublishedArticles()</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium mb-3">Returns top 60 published help articles ordered by <code class="bg-gray-100 px-1.5 rounded-lg">updatedAt DESC</code>.</p>
                            <div class="bg-gray-900 rounded-2xl p-4 text-xs font-mono text-green-400">
                                SELECT TOP 60 articleID, title, content,<br/>
                                &nbsp;&nbsp;ISNULL(status,'Published') AS status, updatedAt<br/>
                                FROM dbo.HelpArticle<br/>
                                WHERE ISNULL(status,'Published') = 'Published'<br/>
                                ORDER BY updatedAt DESC;
                            </div>
                        </div>
                    </details>
                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-get px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">READ</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">GetActiveAdminEmail()</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium mb-3">Used by StudentSupport, TeacherSupport, and TeacherHandbook to populate the "Email Admin" mailto link dynamically.</p>
                            <div class="bg-gray-900 rounded-2xl p-4 text-xs font-mono text-green-400">
                                SELECT TOP 1 u.email FROM dbo.userTable u<br/>
                                JOIN dbo.userRoleTable ur ON ur.userID = u.userID<br/>
                                JOIN dbo.Role r ON r.roleID = ur.roleID<br/>
                                WHERE LOWER(r.roleName) = 'admin'<br/>
                                &nbsp;&nbsp;AND u.accountStatus = 1<br/>
                                &nbsp;&nbsp;AND ISNULL(u.isDeleted,0) = 0<br/>
                                ORDER BY u.CreatedAt ASC;
                            </div>
                        </div>
                    </details>
                </div>
            </section>

            <%-- System Settings --%>
            <section id="settings" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600">
                        <span class="material-symbols-outlined text-base fill-icon">tune</span>
                    </span>
                    System Settings
                </h2>
                <div class="space-y-3">
                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-get px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">READ</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">SystemSettingsHelper.GetSetting(key)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium">Reads a single setting value from <code class="bg-gray-100 px-1.5 rounded-lg">dbo.SystemSettings</code> by key. Returns null if the key doesn't exist. Always provide a fallback default in consuming code.</p>
                        </div>
                    </details>
                    <details class="ep-card bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                        <summary class="flex items-center gap-4 px-6 py-5 select-none">
                            <span class="method-put px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0">UPDATE</span>
                            <span class="font-black text-math-dark-blue text-sm flex-1">SystemSettingsHelper.SaveSetting(key, value, updatedByUserID)</span>
                            <span class="material-symbols-outlined text-gray-400 chevron">expand_more</span>
                        </summary>
                        <div class="px-6 pb-6 border-t border-gray-100 pt-5">
                            <p class="text-sm text-gray-500 font-medium">Upserts a setting using SQL MERGE. Records <code class="bg-gray-100 px-1.5 rounded-lg">UpdatedAt</code> and <code class="bg-gray-100 px-1.5 rounded-lg">UpdatedByUserID</code>. Called from <code class="bg-gray-100 px-1.5 rounded-lg">systemSetting.aspx</code> on save.</p>
                        </div>
                    </details>
                </div>
            </section>

            <%-- Email Service --%>
            <section id="email" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-blue-50 rounded-xl flex items-center justify-center text-math-blue">
                        <span class="material-symbols-outlined text-base fill-icon">mail</span>
                    </span>
                    Email Service
                </h2>
                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm overflow-hidden">
                    <table class="w-full text-xs font-semibold">
                        <thead class="bg-gray-50 border-b-2 border-gray-100">
                            <tr>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">Method</th>
                                <th class="text-left px-6 py-4 font-black text-math-dark-blue uppercase tracking-widest">Trigger</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-gray-600">
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">SendWelcomeWithCredentials(email, name, pwd, url)</td><td class="px-6 py-3">New account created by admin</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">SendPasswordResetLink(email, name, resetLink)</td><td class="px-6 py-3">Forgot password form submitted</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">SendAccountDisabled(email, name)</td><td class="px-6 py-3">Admin disables an account</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">SendAccountReactivated(email, name)</td><td class="px-6 py-3">Admin re-enables an account</td></tr>
                            <tr class="hover:bg-gray-50"><td class="px-6 py-3 font-mono text-math-blue">SendAccountDeleted(email, name)</td><td class="px-6 py-3">Admin soft-deletes an account</td></tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <%-- Code Patterns --%>
            <section id="patterns" class="scroll-mt-28">
                <h2 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-5 flex items-center gap-3">
                    <span class="size-8 bg-gray-100 rounded-xl flex items-center justify-center text-gray-500">
                        <span class="material-symbols-outlined text-base fill-icon">code</span>
                    </span>
                    Code Patterns
                </h2>
                <div class="space-y-4">
                    <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-6">
                        <p class="font-black text-math-dark-blue text-sm uppercase tracking-tight mb-3">Session Guard (add to every protected Page_Load)</p>
                        <div class="bg-gray-900 rounded-2xl p-5 text-xs font-mono text-green-400 leading-relaxed">
                            if (Session["UserID"] == null)<br/>
                            {<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;Response.Redirect("~/Login.aspx", true);<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;return;<br/>
                            }<br/>
                            string role = Session["Role"]?.ToString();<br/>
                            if (role != "Admin") // adjust per page<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;Response.Redirect("~/Login.aspx", true);
                        </div>
                    </div>
                    <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-6">
                        <p class="font-black text-math-dark-blue text-sm uppercase tracking-tight mb-3">Standard DB Connection Pattern</p>
                        <div class="bg-gray-900 rounded-2xl p-5 text-xs font-mono text-green-400 leading-relaxed">
                            private string CS =><br/>
                            &nbsp;&nbsp;ConfigurationManager<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;.ConnectionStrings["MathSphereDB"]<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;.ConnectionString;<br/><br/>
                            using (var con = new SqlConnection(CS))<br/>
                            using (var cmd = new SqlCommand(sql, con))<br/>
                            {<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;con.Open();<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;// execute<br/>
                            }
                        </div>
                    </div>
                </div>
            </section>

        </div>
    </div>

    <script>
        (function() {
            var ids = ['users','auth','courses','progress','help','settings','email','patterns'];
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

