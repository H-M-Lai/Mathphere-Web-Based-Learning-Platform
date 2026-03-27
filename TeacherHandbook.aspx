<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="TeacherHandbook.aspx.cs" Inherits="MathSphere.TeacherHandbook" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">Teacher Handbook</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
<style>
    #sectionModal {
        position:fixed;inset:0;z-index:9000;
        background:rgba(15,23,42,.6);backdrop-filter:blur(6px);
        display:none;align-items:center;justify-content:center;padding:1.5rem;
    }
    #sectionModal.open { display:flex !important; }
    #sectionModalBody  { max-height:65vh;overflow-y:auto; }

    .hb-card { transition:transform .18s,box-shadow .18s; }
    .hb-card:hover { transform:translateY(-4px);box-shadow:0 20px 40px rgba(37,99,235,.12); }

    .toc-link.active { color:#2563eb;background:#eff6ff; }
    html { scroll-behavior:smooth; }
</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- SECTION MODAL --%>
    <div id="sectionModal" onclick="hbBgClick(event)">
        <div class="bg-white w-full max-w-2xl rounded-[2.5rem] shadow-[0_35px_60px_-15px_rgba(0,0,0,0.3)] overflow-hidden"
             onclick="event.stopPropagation()">
            <div class="bg-math-dark-blue px-10 pt-10 pb-8">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <div id="modalChapter" class="inline-block px-3 py-1 bg-primary/20 text-primary rounded-full text-[10px] font-black uppercase tracking-widest mb-3"></div>
                        <h3 id="modalTitle" class="text-2xl font-black text-white uppercase tracking-tight italic leading-tight"></h3>
                    </div>
                    <button type="button" onclick="hbCloseModal()"
                            class="size-10 flex-shrink-0 bg-white/10 hover:bg-white/20 rounded-2xl flex items-center justify-center text-white transition-colors mt-1">
                        <span class="material-symbols-outlined text-xl">close</span>
                    </button>
                </div>
            </div>
            <div id="sectionModalBody" class="px-10 py-8">
                <div id="modalContent" class="text-gray-600 font-medium leading-relaxed text-sm space-y-4"></div>
            </div>
        </div>
    </div>

    <%-- HERO --%>
    <div class="mb-14">
        <div class="inline-flex items-center gap-2 bg-primary/20 text-math-dark-blue px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-widest mb-5">
            <span class="material-symbols-outlined text-base fill-icon">menu_book</span>
            Reference
        </div>
        <h1 class="text-5xl font-black text-math-dark-blue uppercase tracking-tighter italic leading-none mb-3">
            Teacher Handbook
        </h1>
        <p class="text-gray-500 font-medium text-lg max-w-2xl">
            Everything you need to know about managing courses, students, assessments, and the MathSphere platform.
        </p>
    </div>

    <%-- LAYOUT: TOC + CONTENT --%>
    <div class="grid grid-cols-1 lg:grid-cols-[260px_1fr] gap-10 items-start">

        <%-- Sticky TOC --%>
        <aside class="hidden lg:block sticky top-28">
            <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-6">
                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4">Contents</p>
                <nav class="flex flex-col gap-1">
                    <a href="#getting-started" class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">1. Getting Started</a>
                    <a href="#courses"          class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">2. Managing Courses</a>
                    <a href="#modules"          class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">3. Modules & Content</a>
                    <a href="#students"         class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">4. Student Management</a>
                    <a href="#assessments"      class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">5. Quizzes & Assessments</a>
                    <a href="#forum"            class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">6. Forum & Community</a>
                    <a href="#conduct"          class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">7. Code of Conduct</a>
                    <a href="#support"          class="toc-link text-sm font-bold text-gray-500 hover:text-math-blue transition-colors py-1.5 px-3 rounded-xl hover:bg-blue-50">8. Support & Contact</a>
                </nav>
            </div>

            <%-- Quick tips card --%>
            <div class="mt-6 bg-primary/10 border-2 border-primary/30 rounded-[2rem] p-6">
                <p class="text-[10px] font-black uppercase tracking-widest text-math-dark-blue mb-3 flex items-center gap-2"><span class="material-symbols-outlined text-sm">lightbulb</span><span>Quick Tips</span></p>
                <ul class="space-y-2 text-xs font-semibold text-gray-600">
                    <li class="flex items-start gap-2"><span class="material-symbols-outlined text-sm text-math-green mt-0.5">check_circle</span><span>Publish modules before enrolling students</span></li>
                    <li class="flex items-start gap-2"><span class="material-symbols-outlined text-sm text-math-green mt-0.5">check_circle</span><span>Set a quiz pass score for sequential locking</span></li>
                    <li class="flex items-start gap-2"><span class="material-symbols-outlined text-sm text-math-green mt-0.5">check_circle</span><span>Use the forum to post announcements</span></li>
                    <li class="flex items-start gap-2"><span class="material-symbols-outlined text-sm text-math-green mt-0.5">check_circle</span><span>Archive completed courses to keep things tidy</span></li>
                </ul>
            </div>
        </aside>

        <%-- Main handbook content --%>
        <div class="space-y-12">

            <%-- 1. Getting Started --%>
            <section id="getting-started" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-math-blue/10 rounded-xl flex items-center justify-center text-math-blue flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">rocket_launch</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">1. Getting Started</h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Getting Started','Your Account & Profile','Learn how to update your name, profile picture, and contact details from the Teacher Profile page. Your profile is visible to students enrolled in your courses — keep it professional and up to date.\n\nTo update your avatar, go to Profile > Edit Profile and upload a JPG or PNG image under 5 MB.\n\nYour email address is used for system notifications including password resets and account alerts. Contact your administrator if you need to change it.')">
                        <div class="size-10 bg-blue-50 rounded-2xl flex items-center justify-center text-math-blue mb-4 group-hover:bg-math-blue group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">manage_accounts</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Your Account & Profile</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">How to set up your profile, avatar, and account details.</p>
                    </div>

                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Getting Started','Navigating the Dashboard','Your Teacher Dashboard is your command centre. It shows a summary of your active courses, recent student activity, upcoming deadlines, and platform notifications.\n\nThe top navigation bar gives you quick access to:\n• Dashboard — overview and stats\n• Course — manage all your courses\n• Student — enrolment and progress tracking\n• Forum — class discussions\n• Profile — your account settings\n\nUse the Dashboard widgets to spot students who may need extra support based on their activity and streak data.')">
                        <div class="size-10 bg-green-50 rounded-2xl flex items-center justify-center text-math-green mb-4 group-hover:bg-math-green group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">dashboard</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Navigating the Dashboard</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">Understanding your dashboard layout and key widgets.</p>
                    </div>
                </div>
            </section>

            <%-- 2. Managing Courses --%>
            <section id="courses" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-yellow-50 rounded-xl flex items-center justify-center text-yellow-600 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">library_books</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">2. Managing Courses</h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Managing Courses','Creating a Course','To create a new course, go to Course > Create Course. Fill in:\n\n• Course Name — a clear, descriptive title\n• Description — what students will learn\n• End Date — when the course closes for enrolment\n• Auto Archive — whether to automatically archive it after the end date\n\nA newly created course starts as Draft. Students cannot see or enrol in a Draft course. Publish it once you have at least one module ready.\n\nTip: Plan your module structure before publishing so students have a complete experience from day one.')">
                        <div class="size-10 bg-yellow-50 rounded-2xl flex items-center justify-center text-yellow-600 mb-4 group-hover:bg-primary group-hover:text-math-dark-blue transition-colors">
                            <span class="material-symbols-outlined fill-icon">add_circle</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Creating a Course</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">Step-by-step guide to setting up a new course.</p>
                    </div>

                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Managing Courses','Course Statuses','Courses have three statuses:\n\n• Draft — only visible to you. Use this while you are still building the course.\n\n• Published — visible to students. They can enrol and access modules.\n\n• Archived — closed course. Students can no longer enrol but existing enrolees retain read access to content.\n\nYou can manually change the status at any time from the Course Settings page. If Auto Archive is enabled, the system will archive the course automatically on the end date.')">
                        <div class="size-10 bg-blue-50 rounded-2xl flex items-center justify-center text-math-blue mb-4 group-hover:bg-math-blue group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">label</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Course Statuses</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">Draft, Published, and Archived — what each status means.</p>
                    </div>
                </div>
            </section>

            <%-- 3. Modules & Content --%>
            <section id="modules" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-purple-50 rounded-xl flex items-center justify-center text-purple-600 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">view_module</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">3. Modules & Content</h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Modules & Content','Building a Module','Modules are the building blocks of a course. Each module contains ordered content blocks:\n\n• Video — embed a YouTube or hosted video URL\n• Text — rich text explanations and notes\n• Flashcard Set — a deck of question/answer cards\n• Quiz — multiple-choice questions with scoring\n• File — downloadable PDF or resource\n\nBlocks are displayed in the order you arrange them. Mark blocks as Required if students must complete them before progressing.\n\nModules also have a Preview toggle — enable this to let unenrolled students preview the module content before deciding to enrol.')">
                        <div class="size-10 bg-purple-50 rounded-2xl flex items-center justify-center text-purple-600 mb-4 group-hover:bg-purple-500 group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">build_circle</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Building a Module</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">Content block types and how to structure learning material.</p>
                    </div>

                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Modules & Content','Sequential Progress & Locking','Enable Sequential Progress on a module to require students to complete blocks in order before advancing.\n\nEnable Require Quiz Pass to lock the next module until the student achieves the minimum passing score on the current module\'s quiz.\n\nSet the Pass Score (0–100) to define what counts as passing.\n\nThese settings are configured per-module from the Module Access Rules panel. Use them carefully — overly strict locking can frustrate students who need to revisit content.')">
                        <div class="size-10 bg-red-50 rounded-2xl flex items-center justify-center text-red-500 mb-4 group-hover:bg-red-500 group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">lock</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Sequential Progress & Locking</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">Control the order students must complete content blocks.</p>
                    </div>
                </div>
            </section>

            <%-- 4. Student Management --%>
            <section id="students" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-green-50 rounded-xl flex items-center justify-center text-math-green flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">groups</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">4. Student Management</h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Student Management','Enrolment','Go to Student > Enrol Students to add students to your courses. You can search by name or student ID and enrol them individually.\n\nEnrolled students immediately gain access to all Published modules in that course.\n\nTo remove a student from a course, set their enrolment status to inactive. Their progress data is preserved — re-activating the enrolment restores full access.\n\nNote: Only administrators can create new student accounts. If a student is missing from the system, contact your administrator.')">
                        <div class="size-10 bg-green-50 rounded-2xl flex items-center justify-center text-math-green mb-4 group-hover:bg-math-green group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">person_add</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Enrolment</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">How to enrol and manage students in your courses.</p>
                    </div>

                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Student Management','Tracking Progress','From the Student page you can view each student\'s:\n\n• Enrolment status per course\n• Module completion percentage\n• Quiz scores and attempt history\n• Learning streak and XP total\n• Last activity date\n\nUse completion percentages to identify students who may be falling behind. Students with 0% progress after 7+ days may benefit from a follow-up message via the forum.\n\nThe leaderboard automatically ranks students by XP within each module — a healthy competitive element that encourages consistent engagement.')">
                        <div class="size-10 bg-blue-50 rounded-2xl flex items-center justify-center text-math-blue mb-4 group-hover:bg-math-blue group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">monitoring</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Tracking Progress</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">View completion rates, scores, streaks, and XP per student.</p>
                    </div>
                </div>
            </section>

            <%-- 5. Quizzes & Assessments --%>
            <section id="assessments" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-orange-50 rounded-xl flex items-center justify-center text-orange-500 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">quiz</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">5. Quizzes & Assessments</h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Quizzes & Assessments','Module Quizzes','Module quizzes live inside a Quiz content block. To create one:\n\n1. Open the module editor\n2. Add a Quiz block\n3. Enter your questions and multiple-choice options\n4. Mark the correct answer for each question\n5. Set point values per question\n6. Save — the quiz is immediately available to enrolled students\n\nStudents can retake quizzes. Each attempt is recorded. The system awards XP based on the score achieved, using the QuizPerfectScore threshold set by your administrator.\n\nQuiz results are viewable from the Student progress panel.')">
                        <div class="size-10 bg-orange-50 rounded-2xl flex items-center justify-center text-orange-500 mb-4 group-hover:bg-orange-500 group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">fact_check</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Module Quizzes</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">Creating and managing in-module quizzes with scoring.</p>
                    </div>

                    <div class="hb-card bg-white rounded-[2rem] p-6 border-2 border-gray-100 shadow-sm cursor-pointer group"
                         onclick="hbOpen('Quizzes & Assessments','Formal Assessments','Formal assessments differ from quizzes — they are standalone timed tests linked to a course (not a specific module block).\n\nTo create one, go to Course > Assessments > New Assessment and configure:\n\n• Title and description\n• Time limit (minutes)\n• Total marks and passing score\n• Start and end date\n• Published status\n\nAssessments support multiple question types. Student answers and scores are recorded in full. Use assessments for end-of-unit tests or graded tasks that require more control than a module quiz.')">
                        <div class="size-10 bg-red-50 rounded-2xl flex items-center justify-center text-red-500 mb-4 group-hover:bg-red-500 group-hover:text-white transition-colors">
                            <span class="material-symbols-outlined fill-icon">assignment</span>
                        </div>
                        <h4 class="font-black text-math-dark-blue text-base mb-2 group-hover:text-math-blue transition-colors">Formal Assessments</h4>
                        <p class="text-sm text-gray-500 font-medium leading-relaxed">Timed, graded course-level tests separate from module quizzes.</p>
                    </div>
                </div>
            </section>

            <%-- 6. Forum --%>
            <section id="forum" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-math-blue/10 rounded-xl flex items-center justify-center text-math-blue flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">forum</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">6. Forum & Community</h2>
                </div>

                <div class="bg-white rounded-[2rem] p-8 border-2 border-gray-100 shadow-sm">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="flex flex-col gap-2">
                            <div class="size-10 bg-blue-50 rounded-2xl flex items-center justify-center text-math-blue mb-1">
                                <span class="material-symbols-outlined fill-icon">post_add</span>
                            </div>
                            <h4 class="font-black text-math-dark-blue text-sm uppercase tracking-wide">Posting</h4>
                            <p class="text-xs text-gray-500 font-medium leading-relaxed">Use the forum to post announcements, answer questions, and start discussions. Tag your posts with the appropriate category so students can find them easily.</p>
                        </div>
                        <div class="flex flex-col gap-2">
                            <div class="size-10 bg-yellow-50 rounded-2xl flex items-center justify-center text-yellow-600 mb-1">
                                <span class="material-symbols-outlined fill-icon">verified</span>
                            </div>
                            <h4 class="font-black text-math-dark-blue text-sm uppercase tracking-wide">Top Solutions</h4>
                            <p class="text-xs text-gray-500 font-medium leading-relaxed">As a teacher, you can mark a reply as a Top Solution. This pins the best answer to the top of the thread, saving other students from reading through every comment.</p>
                        </div>
                        <div class="flex flex-col gap-2">
                            <div class="size-10 bg-red-50 rounded-2xl flex items-center justify-center text-red-400 mb-1">
                                <span class="material-symbols-outlined fill-icon">flag</span>
                            </div>
                            <h4 class="font-black text-math-dark-blue text-sm uppercase tracking-wide">Reporting</h4>
                            <p class="text-xs text-gray-500 font-medium leading-relaxed">Flag any post that violates community guidelines. Flagged posts are reviewed by administrators. You can also delete your own posts and comments at any time.</p>
                        </div>
                    </div>
                </div>
            </section>

            <%-- 7. Code of Conduct --%>
            <section id="conduct" class="scroll-mt-28">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-10 bg-red-50 rounded-xl flex items-center justify-center text-red-500 flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon">policy</span>
                    </div>
                    <h2 class="text-2xl font-black text-math-dark-blue uppercase tracking-tight">7. Code of Conduct</h2>
                </div>

                <div class="bg-white rounded-[2rem] border-2 border-gray-100 shadow-sm p-8">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
                        <div class="flex items-start gap-3 bg-green-50 rounded-2xl p-4 border border-green-100">
                            <span class="material-symbols-outlined text-base text-math-green mt-0.5">check_circle</span>
                            <p class="text-xs font-semibold text-gray-600">Treat all students with respect and impartiality regardless of ability level.</p>
                        </div>
                        <div class="flex items-start gap-3 bg-green-50 rounded-2xl p-4 border border-green-100">
                            <span class="material-symbols-outlined text-base text-math-green mt-0.5">check_circle</span>
                            <p class="text-xs font-semibold text-gray-600">Keep course content accurate, up to date, and appropriate for the student age group.</p>
                        </div>
                        <div class="flex items-start gap-3 bg-green-50 rounded-2xl p-4 border border-green-100">
                            <span class="material-symbols-outlined text-base text-math-green mt-0.5">check_circle</span>
                            <p class="text-xs font-semibold text-gray-600">Respond to forum questions and student queries in a timely and professional manner.</p>
                        </div>
                        <div class="flex items-start gap-3 bg-green-50 rounded-2xl p-4 border border-green-100">
                            <span class="material-symbols-outlined text-base text-math-green mt-0.5">check_circle</span>
                            <p class="text-xs font-semibold text-gray-600">Report technical issues or safeguarding concerns to the administrator immediately.</p>
                        </div>
                        <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                            <span class="material-symbols-outlined text-base text-red-500 mt-0.5">cancel</span>
                            <p class="text-xs font-semibold text-gray-600">Do not share student personal data outside of the platform or with unauthorised parties.</p>
                        </div>
                        <div class="flex items-start gap-3 bg-red-50 rounded-2xl p-4 border border-red-100">
                            <span class="material-symbols-outlined text-base text-red-500 mt-0.5">cancel</span>
                            <p class="text-xs font-semibold text-gray-600">Do not upload copyrighted material without proper authorisation or licensing.</p>
                        </div>
                    </div>
                    <p class="text-xs text-gray-400 font-medium">Violations of the Code of Conduct may result in account suspension. Refer to the <a href="Terms.aspx" class="text-math-blue font-black hover:underline">Terms & Conditions</a> for full details.</p>
                </div>
            </section>

            <%-- 8. Support --%>
            <section id="support" class="scroll-mt-28">
                <div class="bg-math-dark-blue rounded-[2rem] p-8 md:p-10 flex flex-col md:flex-row items-center justify-between gap-8">
                    <div class="flex items-center gap-5">
                        <div class="size-16 bg-white/10 rounded-2xl flex items-center justify-center flex-shrink-0">
                            <span class="material-symbols-outlined fill-icon text-3xl text-primary">support_agent</span>
                        </div>
                        <div>
                            <h3 class="text-xl font-black text-white uppercase tracking-tight mb-1">8. Support & Contact</h3>
                            <p class="text-blue-300 font-medium text-sm leading-relaxed max-w-md">
                                Can't find what you're looking for in this handbook? Browse the Help Center for published support articles or email your administrator directly.
                            </p>
                            <p class="text-blue-200/60 text-xs font-bold mt-2 uppercase tracking-widest">
                                <asp:Literal ID="litAdminEmail" runat="server" />
                            </p>
                        </div>
                    </div>
                    <div class="flex flex-col gap-3 flex-shrink-0">
                        <a href="TeacherSupport.aspx"
                           class="inline-flex items-center gap-2 bg-primary hover:bg-yellow-400 text-math-dark-blue font-black px-7 py-3.5 rounded-2xl uppercase tracking-widest text-sm shadow-lg transition-colors">
                            <span class="material-symbols-outlined text-base">article</span>
                            Help Center
                        </a>
                        <asp:HyperLink ID="lnkEmailAdmin" runat="server"
                            CssClass="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white border border-white/20 font-black px-7 py-3.5 rounded-2xl uppercase tracking-widest text-sm transition-colors">
                            <span class="material-symbols-outlined text-base">mail</span>
                            Email Admin
                        </asp:HyperLink>
                    </div>
                </div>
            </section>

        </div><%-- end main content --%>
    </div><%-- end grid --%>

    <%-- SCRIPTS --%>
    <script>
        // Modal
        function hbOpen(chapter, title, content) {
            document.getElementById('modalChapter').textContent = chapter;
            document.getElementById('modalTitle').textContent   = title;
            // Render newlines as paragraphs
            var html = content.split('\n').map(function(line) {
                return line.trim() === ''
                    ? ''
                    : '<p>' + line.replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</p>';
            }).filter(Boolean).join('');
            document.getElementById('modalContent').innerHTML = html;
            document.getElementById('sectionModal').classList.add('open');
            document.body.style.overflow = 'hidden';
        }
        function hbCloseModal() {
            document.getElementById('sectionModal').classList.remove('open');
            document.body.style.overflow = '';
        }
        function hbBgClick(e) {
            if (e.target === document.getElementById('sectionModal')) hbCloseModal();
        }
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') hbCloseModal();
        });

        // TOC active highlight on scroll
        (function() {
            var ids = ['getting-started','courses','modules','students','assessments','forum','conduct','support'];
            window.addEventListener('scroll', function() {
                var scrollY = window.scrollY + 150;
                ids.forEach(function(id) {
                    var el   = document.getElementById(id);
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

