<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="studentEnroll.aspx.cs" Inherits="MathSphere.studentEnroll" %>

<%-- Title --%>
<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere — Student Enrolment
</asp:Content>

<%-- Head --%>
<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/studentEnroll.css") %>" rel="stylesheet" />
    <style>
        .modal-overlay {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            z-index: 99999 !important;
            margin: 0 !important;
            padding: 0 !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            background: rgba(15,23,42,0.58) !important;
            backdrop-filter: blur(14px) !important;
        }
        .modal-overlay.hidden {
            display: none !important;
        }

        /* Push enrol modal below sticky header */
        #enrolOverlay {
            padding-top: 80px !important;
            padding-bottom: 16px !important;
            align-items: flex-start !important;
            overflow-y: auto !important;
        }

        #enrolOverlay > div {
            width: 90vw;
            max-width: 860px;
            max-height: calc(100vh - 100px);
            min-height: 480px;
            margin: 0 auto;
            flex-shrink: 0;
        }

        /* Delete + success stay centered */
        #deleteOverlay > div,
        #successOverlay > div {
            margin: auto;
        }

        #toastMsg {
            z-index: 9999999 !important;
            position: fixed !important;
            bottom: 2rem !important;
            left: 50% !important;
            transform: translateX(-50%) !important;
        }


        .enrol-modal-shell {
            position: relative;
            border: 1px solid rgba(226,232,240,0.96);
            background: #ffffff;
            box-shadow: 0 32px 78px rgba(15, 23, 42, 0.26);
        }
        .enrol-modal-shell::before {
            content: '';
            position: absolute;
            inset: 0;
            pointer-events: none;
            background:
                radial-gradient(circle at top right, rgba(37,99,235,0.08), transparent 28%),
                radial-gradient(circle at bottom left, rgba(249,208,6,0.10), transparent 24%);
        }
        .enrol-pane {
            position: relative;
            z-index: 1;
            background: #ffffff;
        }
        .enrol-side-panel {
            position: relative;
            z-index: 1;
            overflow: hidden;
            background:
                radial-gradient(circle at top, rgba(255,255,255,0.14), transparent 38%),
                linear-gradient(160deg, #1e3a8a 0%, #2563eb 55%, #3b82f6 100%);
        }
        .enrol-side-panel::before {
            content: '';
            position: absolute;
            inset: 16px;
            border: 1px solid rgba(255,255,255,0.14);
            border-radius: 2rem;
            pointer-events: none;
        }
        .enrol-primary-btn {
            background: linear-gradient(135deg, #f9d006 0%, #ffd84d 100%);
            color: #1e3a8a !important;
            border: none !important;
            border-radius: 1.15rem;
            padding: 1rem 1.5rem;
            font-family: 'Space Grotesk', sans-serif;
            font-size: 0.8rem;
            font-weight: 900;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            box-shadow: 0 10px 22px rgba(249,208,6,0.28);
            transition: transform 0.18s ease, box-shadow 0.18s ease, filter 0.18s ease;
            cursor: pointer;
        }
        .enrol-primary-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 14px 28px rgba(249,208,6,0.34);
            filter: brightness(1.01);
        }
        .enrol-secondary-btn {
            border: 1px solid rgba(148,163,184,0.28);
            background: rgba(255,255,255,0.96);
            color: #475569;
            border-radius: 1.15rem;
            padding: 1rem 1.5rem;
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            transition: background 0.18s ease, border-color 0.18s ease, transform 0.18s ease;
        }
        .enrol-secondary-btn:hover {
            background: #f8fafc;
            border-color: rgba(37,99,235,0.18);
            transform: translateY(-1px);
        }

        body.enrol-modal-open {
            overflow: hidden;
        }
        body.enrol-modal-open form#teacherMasterForm > header,
        body.enrol-modal-open form#teacherMasterForm > footer {
            opacity: 0 !important;
            visibility: hidden !important;
            pointer-events: none !important;
        }
        body.enrol-modal-open form#teacherMasterForm > main {
            position: relative;
            z-index: 0 !important;
        }
    </style>
</asp:Content>

<%-- Main content --%>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Hidden fields --%>
    <asp:HiddenField ID="hdnDeleteStudentId" runat="server" />
    <asp:HiddenField ID="hdnSelectedWizards" runat="server" />
    <asp:HiddenField ID="hdnCurrentPage"     runat="server" Value="1" />
    <%-- PAGE HEADER --%>
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">groups</span>
                    Student roster
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">
                    Student Enrolment
                </h2>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Monitor student participation, manage enrolments, and track learning progress across your mathematics courses.
                </p>
            </div>
            <button type="button" onclick="openEnrolModal()"
                    class="enrol-new-btn inline-flex items-center justify-center gap-2 rounded-2xl bg-primary px-8 py-4 text-sm font-black uppercase tracking-widest text-math-dark-blue shadow-[0_10px_22px_rgba(249,208,6,0.28)] transition-all hover:-translate-y-0.5 hover:shadow-[0_14px_28px_rgba(249,208,6,0.34)] whitespace-nowrap flex-shrink-0">
                <span class="material-symbols-outlined fill-icon text-lg">person_add</span>
                Enrol New Student
            </button>
        </div>
    </section>

    <%-- ROSTER TABLE --%>
    <div class="bg-white rounded-[2.5rem] shadow-2xl overflow-hidden border-2 border-gray-100">

        <%-- Toolbar --%>
        <div class="px-8 py-6 border-b-2 border-gray-50 flex flex-col md:flex-row justify-between items-center gap-4">
            <h3 class="text-lg font-black text-math-dark-blue uppercase tracking-tight">Active Student Roster</h3>
            <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
                <div class="relative flex-grow md:flex-grow-0">
                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none">search</span>
                    <input type="text" id="searchInput" placeholder="Search students..." oninput="filterAndRender()"
                           class="se-search w-full md:w-64 pl-10 pr-4 py-2 bg-gray-50 border-2 border-gray-200 rounded-xl text-sm font-bold transition-all outline-none"/>
                </div>
                <div class="flex flex-wrap items-center gap-3">
                    <select id="courseFilter" onchange="filterAndRender()"
                            class="se-search px-4 py-2 bg-gray-50 border-2 border-gray-200 rounded-xl text-sm font-bold">
                        <option value="">All Courses</option>
                        <asp:Repeater ID="rptCourseFilter" runat="server">
                            <ItemTemplate>
                                <option value="<%# Eval("courseName") %>"><%# Eval("courseName") %></option>
                            </ItemTemplate>
                        </asp:Repeater>
                    </select>
                    <select id="statusFilter" onchange="filterAndRender()"
                            class="se-search px-4 py-2 bg-gray-50 border-2 border-gray-200 rounded-xl text-sm font-bold">
                        <option value="">All Status</option>
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                    <button type="button" onclick="clearFilters()"
                            class="flex items-center gap-2 px-4 py-2 bg-white border-2 border-gray-200 rounded-xl text-gray-600 hover:border-math-blue hover:text-math-blue transition-all font-bold text-sm">
                        <span class="material-symbols-outlined text-lg">restart_alt</span>Clear
                    </button>
                </div>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-gray-50 border-b-4 border-math-blue/10">
                        <th class="px-8 py-6 text-xs font-black uppercase tracking-widest text-gray-400">Student Name</th>
                        <th class="px-6 py-6 text-xs font-black uppercase tracking-widest text-gray-400">Course</th>
                        <th class="px-6 py-6 text-xs font-black uppercase tracking-widest text-gray-400">Avg. Score</th>
                        <th class="px-6 py-6 text-xs font-black uppercase tracking-widest text-gray-400">Progress</th>
                        <th class="px-6 py-6 text-xs font-black uppercase tracking-widest text-gray-400">Active Status</th>
                        <th class="px-8 py-6 text-xs font-black uppercase tracking-widest text-gray-400 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100" id="studentBody">
                    <asp:Repeater ID="rptStudents" runat="server" OnItemDataBound="rptStudents_ItemDataBound">
                        <ItemTemplate><asp:Literal ID="litRow" runat="server"></asp:Literal></ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <%-- Footer --%>
        <div class="bg-gray-50 px-8 py-6 flex items-center justify-between border-t-2 border-gray-100">
            <span class="text-sm font-bold text-gray-400 uppercase tracking-widest" id="showingLabel">
                Showing <asp:Literal ID="litShowing" runat="server" Text="0" /> of
                <asp:Literal ID="litTotal"   runat="server" Text="0" /> Students
            </span>
            <div class="flex gap-2" id="paginationBar"></div>
        </div>
    </div>

    <%-- Toast --%>
    <div id="toastMsg" class="se-toast"></div>

    <%-- ENROL MODAL --%>
    <div id="enrolOverlay" class="modal-overlay hidden">
        <div class="enrol-modal-shell relative h-full w-full max-w-5xl overflow-hidden rounded-[2.5rem]">
            <div class="grid h-full min-h-0 md:grid-cols-[minmax(0,1fr)_320px]">

                <%-- LEFT PANEL --%>
                <div class="enrol-pane relative flex min-w-0 min-h-0 flex-col overflow-hidden px-8 pb-7 pt-7 sm:px-10">
                    <button type="button" onclick="closeEnrolModal()"
                            class="absolute right-6 top-6 flex size-10 items-center justify-center rounded-2xl border border-slate-200 bg-white text-slate-500 shadow-sm transition-all hover:border-math-blue/20 hover:text-math-blue md:hidden">
                        <span class="material-symbols-outlined text-lg">close</span>
                    </button>

                    <div class="border-b border-slate-100 pb-6">
                        <div class="mb-5 inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.24em] text-math-blue">
                            <span class="material-symbols-outlined fill-icon text-sm">school</span>
                            Student Enrolment
                        </div>
                        <h1 class="text-3xl font-black tracking-tight text-math-dark-blue sm:text-[2rem]">Enrol New Students</h1>
                        <p class="mt-2 max-w-xl text-sm font-medium leading-6 text-slate-500">
                            Add learners to a destination course, invite them one by one, or upload a file for a faster class setup.
                        </p>

                        <div class="mt-6 grid gap-4 xl:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]">
                            <div class="relative xl:col-span-2">
                                <label class="mb-2 block text-[10px] font-black uppercase tracking-[0.22em] text-slate-400">Destination Course</label>
                                <asp:DropDownList ID="ddlCourse" runat="server"
                                    CssClass="modal-input w-full rounded-2xl bg-slate-50 py-3.5 pl-4 pr-12 text-sm font-bold text-math-dark-blue" />
                                <span class="material-symbols-outlined pointer-events-none absolute bottom-4 right-4 text-slate-400">expand_more</span>
                            </div>

                            <div class="relative xl:col-span-2" id="wizardSearchWrap">
                                <label class="mb-2 block text-[10px] font-black uppercase tracking-[0.22em] text-slate-400">Find Students</label>
                                <span class="material-symbols-outlined absolute left-4 top-[calc(50%+12px)] -translate-y-1/2 text-math-blue">search</span>
                                <input type="text" id="wizardSearch" placeholder="Search students by name, ID, or course..." oninput="filterWizards(this.value)"
                                       class="modal-input w-full rounded-2xl bg-slate-50 py-3.5 pl-12 pr-4 text-sm font-medium text-math-dark-blue placeholder:text-slate-300" />
                            </div>
                        </div>

                        <div class="mt-6 inline-flex rounded-[1.35rem] border border-slate-200 bg-slate-50 p-1.5">
                            <button type="button" id="tabAll" onclick="switchEnrolTab('all')"
                                    class="enrol-tab flex items-center gap-2 rounded-xl border-2 border-math-blue bg-blue-50 px-4 py-2.5 text-sm font-black text-math-blue shadow-sm transition-all">
                                <span class="material-symbols-outlined text-base">groups</span>
                                All Students
                            </button>
                            <button type="button" id="tabFile" onclick="switchEnrolTab('file')"
                                    class="enrol-tab flex items-center gap-2 rounded-xl border-2 border-transparent bg-transparent px-4 py-2.5 text-sm font-black text-slate-400 transition-all hover:text-slate-600">
                                <span class="material-symbols-outlined text-base">upload_file</span>
                                CSV / XLSX
                            </button>
                        </div>
                    </div>

                    <%-- Scrollable content --%>
                    <div class="custom-scrollbar min-h-0 flex-1 overflow-y-auto py-5">

                        <div id="wizardListView" class="space-y-2">
                            <asp:Repeater ID="rptWizards" runat="server" OnItemDataBound="rptWizards_ItemDataBound">
                                <ItemTemplate><asp:Literal ID="litWizardRow" runat="server"></asp:Literal></ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <div id="fileUploadView" class="hidden flex flex-col gap-4">
                            <div class="flex items-start gap-3 rounded-2xl border border-blue-200 bg-blue-50 px-4 py-3.5">
                                <span class="material-symbols-outlined mt-0.5 text-lg text-math-blue fill-icon">info</span>
                                <div>
                                    <p class="mb-0.5 text-[11px] font-black uppercase tracking-[0.18em] text-math-blue">File format</p>
                                    <p class="text-xs font-medium leading-relaxed text-slate-600">
                                        Use a single <code class="rounded border border-blue-200 bg-white px-1 font-mono font-bold text-math-dark-blue">email</code> column.
                                        Add one student email per row, for example <span class="font-mono text-slate-400">amirul@gmail.com</span>.
                                    </p>
                                </div>
                            </div>

                            <div id="fileDropZone"
                                 onclick="document.getElementById('<%= fuBulk.ClientID %>').click()"
                                 ondragover="handleFileDragOver(event)"
                                 ondragleave="handleFileDragLeave(event)"
                                 ondrop="handleFileDrop(event)"
                                 class="group flex min-h-[200px] cursor-pointer flex-col items-center justify-center rounded-[2rem] border-2 border-dashed border-math-blue/30 bg-slate-50/70 px-8 py-10 text-center transition-all hover:border-math-blue hover:bg-blue-50/40">
                                <div class="mb-4 flex size-16 items-center justify-center rounded-full bg-math-blue/10 transition-transform group-hover:scale-110">
                                    <span class="material-symbols-outlined text-4xl text-math-blue">file_upload</span>
                                </div>
                                <h3 class="text-lg font-black tracking-tight text-slate-800">Fast Track Enrolment</h3>
                                <p class="mt-1 text-sm font-medium text-slate-500">Drag and drop a file or click to browse.</p>
                                <p class="mt-1 text-xs font-medium text-slate-400">Accepts .csv or .xlsx</p>
                            </div>

                            <div id="selectedFileBadge"
                                 class="hidden items-center gap-3 rounded-2xl border-2 border-blue-200 bg-blue-50 px-4 py-3">
                                <span class="material-symbols-outlined text-2xl text-math-blue fill-icon" id="fileTypeIcon">description</span>
                                <div class="min-w-0 flex-1">
                                    <p id="selectedFileName" class="truncate text-sm font-black text-slate-800"></p>
                                    <p id="selectedFileSize" class="mt-0.5 text-xs font-medium text-slate-400"></p>
                                </div>
                                <button type="button" onclick="clearFileSelection()"
                                        class="flex size-8 items-center justify-center rounded-xl border border-slate-200 bg-white transition-colors hover:border-red-300 hover:bg-red-50">
                                    <span class="material-symbols-outlined text-sm text-slate-400 hover:text-red-500">close</span>
                                </button>
                            </div>

                            <asp:FileUpload ID="fuBulk" runat="server" CssClass="hidden" accept=".csv,.xlsx" onchange="handleFileSelect(this)" />
                        </div>
                    </div>

                    <%-- Fixed footer buttons --%>
                    <div class="border-t border-slate-100 pt-5">
                        <div id="btnAllStudentsWrap" class="flex items-center gap-3">
                            <asp:Button ID="btnSubmitEnrol" runat="server"
                                        Text="Add Selected to Class"
                                        CssClass="enrol-primary-btn flex-1"
                                        UseSubmitBehavior="true"
                                        OnClick="btnSubmitEnrol_Click"
                                        OnClientClick="return validateWizardSelection()" />
                            <button type="button" onclick="closeEnrolModal()"
                                    class="enrol-secondary-btn flex-1">
                                Cancel
                            </button>
                        </div>
                        <div id="btnFileWrap" class="hidden flex items-center gap-3">
                            <asp:Button ID="btnBulkEnrol" runat="server"
                                        Text="Upload &amp; Enrol Students"
                                        CssClass="enrol-primary-btn flex-1"
                                        UseSubmitBehavior="true"
                                        OnClick="btnBulkEnrol_Click"
                                        OnClientClick="return validateFileUpload()" />
                            <button type="button" onclick="closeEnrolModal()"
                                    class="enrol-secondary-btn flex-1">
                                Cancel
                            </button>
                        </div>
                    </div>
                </div>

                <%-- RIGHT PANEL --%>
                <div class="enrol-side-panel relative hidden min-h-0 md:flex flex-col items-center justify-center p-8 text-white text-center">
                    <button type="button" onclick="closeEnrolModal()"
                            class="absolute right-6 top-6 flex size-10 items-center justify-center rounded-2xl border border-white/10 bg-white/10 text-white/80 transition-all hover:bg-white/20 hover:text-white">
                        <span class="material-symbols-outlined text-lg">close</span>
                    </button>

                    <div class="flex max-w-[17rem] flex-col items-center justify-center gap-8">
                        <div class="flex size-32 items-center justify-center rounded-full border border-white/15 bg-white/10 shadow-[0_18px_40px_rgba(15,23,42,0.18)] backdrop-blur-sm">
                            <div class="rounded-[1.75rem] bg-white p-4 shadow-xl">
                                <span class="material-symbols-outlined text-[58px] leading-none text-math-blue fill-icon">groups_3</span>
                            </div>
                        </div>

                        <div class="space-y-4">
                            <div class="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/10 px-4 py-2 text-[10px] font-black uppercase tracking-[0.24em] text-white/80">
                                Ready to invite
                            </div>
                            <h2 class="text-3xl font-black tracking-tight text-white">Build your next class list.</h2>
                            <p class="text-sm font-medium leading-6 text-blue-100/90">
                                Search existing students or upload a file to enrol a full roster in one smoother flow.
                            </p>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
    <%-- DELETE MODAL --%>
    <div id="deleteOverlay" class="modal-overlay hidden">
        <div class="relative w-full max-w-lg bg-white rounded-[3rem] border-8 border-math-blue shadow-2xl px-10 pt-20 pb-10 md:px-12 text-center">
            <div class="absolute -top-16 left-1/2 -translate-x-1/2">
                <div class="size-28 bg-primary rounded-[2rem] flex items-center justify-center shadow-[0_12px_0_0_#d1af05] -rotate-3">
                    <span class="material-symbols-outlined text-6xl text-math-dark-blue fill-icon">remove_circle</span>
                </div>
            </div>
            <h2 class="text-3xl font-black text-math-dark-blue tracking-tighter uppercase italic mt-6">REMOVE STUDENT?</h2>
            <p class="text-lg font-medium text-gray-500 leading-relaxed mt-4">
                Are you sure you want to remove
                <span id="deleteStudentNameDisplay" class="text-math-blue font-black italic">this student</span>?
            </p>
            <div class="flex flex-col gap-4 mt-8">
                <asp:Button ID="btnConfirmDelete" runat="server" Text="YES, REMOVE STUDENT"
                            CssClass="delete-yes-btn w-full py-5 rounded-2xl font-black text-lg uppercase tracking-widest"
                            OnClick="btnConfirmDelete_Click" />
                <button type="button" onclick="closeDeleteModal()"
                        class="w-full py-4 bg-white text-math-blue border-4 border-math-blue rounded-2xl font-black text-sm uppercase tracking-[0.2em] hover:bg-math-blue/5 transition-all">
                    KEEP IN CLASS
                </button>
            </div>
        </div>
    </div>

    <%-- SUCCESS MODAL --%>
    <div id="successOverlay" class="modal-overlay hidden" style="z-index: 999999 !important;">
        <div class="relative w-full max-w-lg bg-white rounded-3xl shadow-2xl overflow-hidden mx-4">
            <div class="p-8 flex flex-col items-center text-center">

                <%-- Icon --%>
                <span class="material-symbols-outlined select-none fill-icon"
                      style="font-size:80px;line-height:1;color:#22c55e;">check_circle</span>

                <%-- Title --%>
                <h1 class="text-2xl font-black italic tracking-tighter mb-3 leading-none text-math-blue mt-4">
                    Wizards Summoned!
                </h1>

                <%-- Summary message --%>
                <p class="text-gray-500 text-sm font-semibold leading-relaxed max-w-sm mb-5">
                    <asp:Literal ID="litSuccessCount" runat="server" Text="Students" />
                </p>

                <%-- Enrolled / Skipped counters --%>
                <div class="flex items-center gap-6 mb-5 px-6 py-4 bg-gray-50 rounded-2xl w-full border border-gray-100">
                    <div class="flex-1 text-center">
                        <p class="text-xs font-bold uppercase tracking-widest text-gray-400 mb-1">Enrolled</p>
                        <p class="text-3xl font-black" style="color:#22c55e;">
                            <asp:Literal ID="litSuccessNum" runat="server" Text="0" />
                        </p>
                    </div>
                    <div class="w-px h-10 bg-gray-200"></div>
                    <div class="flex-1 text-center">
                        <p class="text-xs font-bold uppercase tracking-widest text-gray-400 mb-1">Skipped</p>
                        <p class="text-3xl font-black text-gray-400">
                            <asp:Literal ID="litErrorNum" runat="server" Text="0" />
                        </p>
                    </div>
                </div>

                <%-- Skipped detail --%>
                <div id="errorDetailWrap" class="hidden w-full mb-5">
                    <div class="bg-orange-50 border-2 border-orange-200 rounded-2xl overflow-hidden">
                        <div class="flex items-center gap-2 px-4 py-3 bg-orange-100 border-b border-orange-200">
                            <span class="material-symbols-outlined text-orange-500 text-base fill-icon">warning</span>
                            <p class="text-[10px] font-black uppercase tracking-widest text-orange-600">
                                Skipped — <asp:Literal ID="Literal1" runat="server" Text="0" /> row(s) not enrolled
                            </p>
                        </div>
                        <div class="max-h-32 overflow-y-auto px-4 py-3 text-left">
                            <asp:Literal ID="litErrorDetail" runat="server" />
                        </div>
                    </div>
                </div>

                <%-- Continue button --%>
                <button type="button" onclick="closeSuccessModal()"
                        class="success-roster-btn w-full h-14 text-math-dark-blue text-base font-black 
                               rounded-2xl flex items-center justify-center gap-3 group transition-all">
                    CONTINUE TO ROSTER
                    <span class="material-symbols-outlined transition-transform group-hover:translate-x-1">arrow_forward</span>
                </button>
            </div>
        </div>
    </div>

</asp:Content>

<%-- Page scripts --%>
<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    // Roster table
    const PAGE_SIZE = 4;
    let currentPage = 1, allRows = [];

    document.addEventListener('DOMContentLoaded', function () {
        allRows = Array.from(document.querySelectorAll('#studentBody tr'));
        render();
    });

    function filterAndRender() { currentPage = 1; render(); }

    function getFiltered() {
        const q = (document.getElementById('searchInput')?.value || '').toLowerCase().trim();
        const course = (document.getElementById('courseFilter')?.value || '').toLowerCase().trim();
        const status = (document.getElementById('statusFilter')?.value || '').toLowerCase().trim();
        return allRows.filter(r => {
            const t = r.textContent.toLowerCase();
            return (!q || t.includes(q)) && (!course || t.includes(course)) && (!status || t.includes(status));
        });
    }

    function clearFilters() {
        document.getElementById('searchInput').value = '';
        document.getElementById('courseFilter').value = '';
        document.getElementById('statusFilter').value = '';
        filterAndRender();
    }

    function render() {
        const filtered = getFiltered(), total = filtered.length;
        const pages = Math.max(1, Math.ceil(total / PAGE_SIZE));
        currentPage = Math.min(currentPage, pages);
        const start = (currentPage - 1) * PAGE_SIZE;
        const end = Math.min(start + PAGE_SIZE, total);
        allRows.forEach(r => r.style.display = 'none');
        filtered.slice(start, end).forEach(r => r.style.display = '');
        const lbl = document.getElementById('showingLabel');
        if (lbl) lbl.textContent = `Showing ${total === 0 ? 0 : end} of ${total} Students`;
        buildPagination(pages);
    }

    function buildPagination(pages) {
        const bar = document.getElementById('paginationBar');
        bar.innerHTML = '';
        bar.appendChild(arrowBtn('chevron_left', currentPage === 1, () => { currentPage--; render(); }));
        for (let i = 1; i <= pages; i++) {
            const btn = document.createElement('button'), pg = i;
            btn.type = 'button';
            btn.textContent = i;
            btn.onclick = () => { currentPage = pg; render(); };
            btn.className = i === currentPage
                ? 'size-10 flex items-center justify-center rounded-xl bg-math-blue text-white font-black shadow-lg shadow-math-blue/20'
                : 'size-10 flex items-center justify-center rounded-xl bg-white border-2 border-gray-200 text-gray-600 font-black hover:border-math-blue hover:text-math-blue transition-colors';
            bar.appendChild(btn);
        }
        bar.appendChild(arrowBtn('chevron_right', currentPage === pages, () => { currentPage++; render(); }));
    }

    function arrowBtn(icon, disabled, fn) {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.innerHTML = `<span class="material-symbols-outlined">${icon}</span>`;
        btn.onclick = fn;
        btn.disabled = disabled;
        btn.className = 'size-10 flex items-center justify-center rounded-xl bg-white border-2 border-gray-200 text-gray-400 hover:border-math-blue hover:text-math-blue transition-colors'
            + (disabled ? ' opacity-40 pointer-events-none' : '');
        return btn;
    }

    // Modals
    function openEnrolModal() { document.body.classList.add('enrol-modal-open'); document.getElementById('enrolOverlay').classList.remove('hidden'); }
    function closeEnrolModal() { document.body.classList.remove('enrol-modal-open'); document.getElementById('enrolOverlay').classList.add('hidden'); clearFileSelection(); }
    function closeDeleteModal() { document.getElementById('deleteOverlay').classList.add('hidden'); }
    function closeSuccessModal() { document.getElementById('successOverlay').classList.add('hidden'); }

    function confirmDelete(enrolId, name) {
        document.getElementById('<%= hdnDeleteStudentId.ClientID %>').value = enrolId;
        const el = document.getElementById('deleteStudentNameDisplay');
        if (el) el.textContent = name || 'this student';
        document.getElementById('deleteOverlay').classList.remove('hidden');
    }

    // Tab switch
    function switchEnrolTab(tab) {
        const isAll = tab === 'all';
        document.getElementById('wizardListView').classList.toggle('hidden', !isAll);
        document.getElementById('fileUploadView').classList.toggle('hidden', isAll);
        document.getElementById('wizardSearchWrap').classList.toggle('hidden', !isAll);
        document.getElementById('btnAllStudentsWrap').classList.toggle('hidden', !isAll);
        document.getElementById('btnFileWrap').classList.toggle('hidden', isAll);
        const ta = document.getElementById('tabAll'), tf = document.getElementById('tabFile');
        ta.classList.toggle('border-math-blue', isAll); ta.classList.toggle('text-math-blue', isAll);
        ta.classList.toggle('border-transparent', !isAll); ta.classList.toggle('text-slate-400', !isAll);
        tf.classList.toggle('border-math-blue', !isAll); tf.classList.toggle('text-math-blue', !isAll);
        tf.classList.toggle('border-transparent', isAll); tf.classList.toggle('text-slate-400', isAll);
    }

    // Wizard list
    function toggleWizard(row) {
        const check = row.querySelector('.wizard-check'), sel = row.dataset.selected === 'true';
        row.dataset.selected = sel ? 'false' : 'true';
        row.classList.toggle('border-blue-200', !sel);
        row.classList.toggle('bg-blue-50/40', !sel);
        row.classList.toggle('border-transparent', sel);
        check.innerHTML = sel ? '' : '<span class="material-symbols-outlined text-white text-base font-bold" style="font-variation-settings:\'FILL\' 1,\'wght\' 700,\'GRAD\' 0,\'opsz\' 48;">check</span>';
        check.style.background = sel ? '' : '#fbbf24';
        check.style.borderColor = sel ? 'rgba(37,99,235,0.3)' : '#2563eb';
    }

    function getSelectedWizards() {
        const ids = Array.from(document.querySelectorAll('#wizardListView .wizard-row[data-selected="true"]'))
            .map(r => r.dataset.id);
        document.getElementById('<%= hdnSelectedWizards.ClientID %>').value = ids.join(',');
        return ids;
    }

    function validateWizardSelection() {
        if (getSelectedWizards().length === 0) { showToast('Please select at least one student.'); return false; }
        return true;
    }

    function filterWizards(term) {
        const q = term.toLowerCase().trim();
        document.querySelectorAll('#wizardListView .wizard-row').forEach(r => {
            r.style.display = !q || r.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    }

    // File upload
    function handleFileDragOver(e) { e.preventDefault(); document.getElementById('fileDropZone').classList.add('border-math-blue', 'bg-blue-50/40'); }
    function handleFileDragLeave(e) { e.preventDefault(); document.getElementById('fileDropZone').classList.remove('border-math-blue', 'bg-blue-50/40'); }

    function handleFileDrop(e) {
        e.preventDefault();
        document.getElementById('fileDropZone').classList.remove('border-math-blue', 'bg-blue-50/40');
        const file = e.dataTransfer?.files[0]; if (!file) return;
        try { const dt = new DataTransfer(); dt.items.add(file); document.getElementById('<%= fuBulk.ClientID %>').files = dt.files; }
        catch { alert('Please use the Browse button in this browser.'); return; }
        showFileBadge(file);
        previewFileEmails(file);
    }

    function handleFileSelect(input) {
        if (input.files && input.files[0]) {
            showFileBadge(input.files[0]);
            previewFileEmails(input.files[0]);
        }
    }

    function showFileBadge(file) {
        const ext = file.name.split('.').pop().toLowerCase();
        if (!['csv','xlsx'].includes(ext)) { showToast('Only .csv or .xlsx files are supported.'); clearFileSelection(); return; }
        document.getElementById('fileDropZone').classList.add('hidden');
        document.getElementById('selectedFileName').textContent = file.name;
        document.getElementById('selectedFileSize').textContent = formatBytes(file.size);
        document.getElementById('fileTypeIcon').textContent     = ext === 'xlsx' ? 'table_view' : 'description';
        const b = document.getElementById('selectedFileBadge');
        b.classList.remove('hidden'); b.classList.add('flex');
    }

    function clearFileSelection() {
        const fu = document.getElementById('<%= fuBulk.ClientID %>'); if (fu) fu.value = '';
        document.getElementById('fileDropZone').classList.remove('hidden');
        const b = document.getElementById('selectedFileBadge');
        b.classList.add('hidden'); b.classList.remove('flex');
    }

    function validateFileUpload() {
        const fu  = document.getElementById('<%= fuBulk.ClientID %>');
        const ddl = document.getElementById('<%= ddlCourse.ClientID %>');
        if (!fu || !fu.files || fu.files.length === 0) { showToast('Please select a CSV or XLSX file.'); return false; }
        if (!ddl || !ddl.value) { showToast('Please select a course first.'); return false; }
        return true;
    }

    function formatBytes(b) {
        return b < 1048576 ? (b / 1024).toFixed(1) + ' KB' : (b / 1048576).toFixed(1) + ' MB';
    }

    // File preview: show email count before upload
    async function previewFileEmails(file) {
        const ext = file.name.split('.').pop().toLowerCase();

        if (ext === 'csv') {
            try {
                const text = await file.text();
                const lines = text.split('\n').map(l => l.trim()).filter(l => l);
                if (lines.length < 2) {
                    showToast('CSV appears empty or has no data rows.', 4000);
                    return;
                }
                const headers = lines[0].toLowerCase().split(',').map(h => h.trim());
                const emailIdx = headers.indexOf('email');
                if (emailIdx < 0) {
                    showToast('No "email" column found in CSV.', 4000);
                    return;
                }
                const emails = lines.slice(1)
                    .map(l => l.split(',')[emailIdx]?.trim())
                    .filter(e => e && e.length > 0);
                showToast(`${emails.length} email(s) found. Click Upload to enrol.`, 5000);
            } catch (err) {
                showToast('Could not read CSV file.', 4000);
            }
        } else if (ext === 'xlsx') {
            showToast(`${file.name} ready. Click Upload to enrol.`, 4000);
        }
    }

    // Toast
    function showToast(msg, duration) {
        duration = duration || 3200;
        const el = document.getElementById('toastMsg');
        el.textContent = msg;
        el.classList.add('visible');
        setTimeout(() => el.classList.remove('visible'), duration);
    }
</script>
</asp:Content>

