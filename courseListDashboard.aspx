<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="courselistDashboard.aspx.cs" Inherits="MathSphere.courselistDashboard" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere - Course List
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/courselistDashboard.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hdnPageTarget" runat="server" />
    <asp:HiddenField ID="hdnActionCourseId" runat="server" />
    <asp:Button ID="btnChangePage" runat="server" OnClick="btnChangePage_Click" Style="display:none;" />
    <asp:Button ID="btnArchive" runat="server" OnClick="btnArchive_Click" Style="display:none;" />
    <asp:Button ID="btnDelete" runat="server" OnClick="btnDelete_Click" Style="display:none;" />

    <div class="space-y-10">
        <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
            <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
                <div class="max-w-3xl space-y-4">
                    <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                        <span class="material-symbols-outlined text-sm fill-icon">menu_book</span>
                        Teacher workspace
                    </div>
                    <div class="space-y-3">
                        <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Course List</h2>
                        <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                            Review active courses, keep archived classes tidy, and jump straight into the course you want to manage next.
                        </p>
                    </div>
                </div>
                <div class="flex flex-wrap items-center gap-3 lg:gap-4">
                    <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Overview</p>
                        <p class="mt-2 text-sm font-bold text-math-dark-blue">All courses in one place</p>
                    </div>
                    <button type="button"
                            onclick="window.location.href='<%= ResolveUrl("~/teacherCreateCourse.aspx") %>'"
                            class="inline-flex items-center justify-center gap-2 rounded-2xl bg-primary px-8 py-4 text-sm font-black uppercase tracking-widest text-math-dark-blue shadow-[0_10px_22px_rgba(249,208,6,0.28)] transition-all hover:-translate-y-0.5 hover:shadow-[0_14px_28px_rgba(249,208,6,0.34)] whitespace-nowrap flex-shrink-0">
                        <span class="material-symbols-outlined fill-icon text-lg">add_circle</span>
                        Create New Course
                    </button>
                </div>
            </div>
        </section>

        <asp:Panel ID="pnlSuccess" runat="server" Visible="false"
            CssClass="rounded-[1.75rem] border border-green-200 bg-green-50/90 px-6 py-4 shadow-sm">
            <div class="flex items-center gap-3">
                <span class="material-symbols-outlined text-green-600 text-2xl" style="font-variation-settings:'FILL' 1">check_circle</span>
                <asp:Label ID="lblSuccess" runat="server" CssClass="text-sm font-black uppercase tracking-[0.22em] text-green-700"></asp:Label>
            </div>
        </asp:Panel>

        <section class="overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="border-b border-gray-100 px-8 py-6 lg:px-10">
                <div class="flex flex-col gap-2 lg:flex-row lg:items-center lg:justify-between">
                    <div>
                        <h3 class="text-2xl font-black tracking-tight text-math-dark-blue">Your Courses</h3>
                        <p class="mt-1 text-sm font-bold text-gray-500">Open a course to manage its modules, enrolments, and assessments.</p>
                    </div>
                    <div class="inline-flex items-center gap-2 rounded-full border border-gray-200 bg-gray-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.22em] text-gray-500">
                        <span class="material-symbols-outlined text-sm">dashboard_customize</span>
                        Teacher course hub
                    </div>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left">
                    <thead>
                        <tr class="border-b border-gray-100 bg-gray-50/80">
                            <th class="px-8 py-5 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400 lg:px-10">Course Name</th>
                            <th class="px-6 py-5 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Modules</th>
                            <th class="px-6 py-5 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Enrolled Students</th>
                            <th class="px-6 py-5 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Validity</th>
                            <th class="px-6 py-5 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Status</th>
                            <th class="px-8 py-5 text-right text-[11px] font-black uppercase tracking-[0.24em] text-gray-400 lg:px-10">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <asp:Repeater ID="rptCourses" runat="server" OnItemDataBound="rptCourses_ItemDataBound">
                            <ItemTemplate>
                                <tr class="group cursor-pointer transition-colors hover:bg-gray-50/60"
                                    onclick="goToCourse('<%# Eval("CourseID") %>')">
                                    <td class="px-8 py-6 lg:px-10">
                                        <div class="flex items-center gap-4">
                                            <asp:Literal ID="litIconContainer" runat="server"></asp:Literal>
                                            <div>
                                                <div class="text-lg font-black text-math-dark-blue"><%# Eval("CourseName") %></div>
                                                <div class="text-[11px] font-bold uppercase tracking-[0.18em] text-gray-400">ID: <%# Eval("CourseID") %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-6">
                                        <div class="inline-flex items-center gap-2 rounded-full border border-gray-100 bg-gray-50 px-3 py-1.5">
                                            <span class="font-black text-math-dark-blue"><%# Eval("ModuleCount") %></span>
                                            <span class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-500">Units</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-6">
                                        <div class="flex -space-x-3 overflow-hidden">
                                            <asp:Literal ID="litStudentAvatars" runat="server"></asp:Literal>
                                        </div>
                                    </td>
                                    <td class="px-6 py-6"><asp:Literal ID="litValidity" runat="server"></asp:Literal></td>
                                    <td class="px-6 py-6"><asp:Literal ID="litStatus" runat="server"></asp:Literal></td>
                                    <td class="px-8 py-6 text-right lg:px-10" onclick="event.stopPropagation()">
                                        <button type="button"
                                            onclick="openContextMenu(event, '<%# Eval("CourseID") %>', '<%# Eval("Status") %>')"
                                            class="rounded-2xl border border-gray-100 bg-gray-50 p-2.5 text-gray-400 transition-all hover:border-blue-100 hover:bg-white hover:text-blue-600">
                                            <span class="material-symbols-outlined font-bold">more_vert</span>
                                        </button>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                            <tr>
                                <td colspan="6" class="px-8 py-20 text-center lg:px-10">
                                    <div class="mx-auto flex max-w-md flex-col items-center gap-5">
                                        <div class="flex size-24 items-center justify-center rounded-[2rem] border border-gray-100 bg-gray-50 shadow-inner">
                                            <span class="material-symbols-outlined text-5xl text-gray-300" style="font-variation-settings:'FILL' 1">menu_book</span>
                                        </div>
                                        <div class="space-y-2">
                                            <p class="text-lg font-black uppercase tracking-[0.24em] text-gray-400">No courses yet</p>
                                            <p class="text-sm font-semibold leading-6 text-gray-400">
                                                You have not created any courses yet. Start with one course shell and build from there.
                                            </p>
                                        </div>
                                        <button type="button"
                                                onclick="window.location.href='<%= ResolveUrl("~/teacherCreateCourse.aspx") %>'"
                                                class="inline-flex items-center justify-center gap-2 rounded-2xl bg-primary px-8 py-4 text-sm font-black uppercase tracking-widest text-math-dark-blue shadow-[0_10px_22px_rgba(249,208,6,0.28)] transition-all hover:-translate-y-0.5 hover:shadow-[0_14px_28px_rgba(249,208,6,0.34)] whitespace-nowrap flex-shrink-0">
                                            <span class="material-symbols-outlined fill-icon text-lg">add_circle</span>
                                            Create your first course
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </asp:Panel>
                    </tbody>
                </table>
            </div>

            <div class="flex flex-col gap-4 border-t border-gray-100 bg-gray-50/80 px-8 py-5 lg:flex-row lg:items-center lg:justify-between lg:px-10">
                <span class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-500">
                    <asp:Literal ID="litCourseCount" runat="server" />
                </span>
                <div class="flex flex-wrap gap-2">
                    <asp:Literal ID="litPager" runat="server" />
                </div>
            </div>
        </section>
    </div>

    <div id="contextMenu"
         class="fixed z-[200] hidden min-w-[220px] overflow-hidden rounded-[1.75rem] border border-white/70 bg-white/95 py-2 shadow-[0_20px_40px_rgba(15,23,42,0.12)]">
        <div id="ctxCourseLabel"
             class="mb-1 border-b border-gray-100 px-5 py-3 text-[10px] font-black uppercase tracking-[0.24em] text-gray-400"></div>

        <button type="button" id="ctxViewBtn"
                class="group flex w-full items-center gap-3 px-5 py-3 text-sm font-bold text-gray-700 transition-colors hover:bg-blue-50 hover:text-blue-600">
            <span class="material-symbols-outlined text-xl text-gray-400 group-hover:text-blue-500">visibility</span>
            View Details
        </button>
        <button type="button" id="ctxEditBtn"
                class="group flex w-full items-center gap-3 px-5 py-3 text-sm font-bold text-gray-700 transition-colors hover:bg-yellow-50 hover:text-yellow-700">
            <span class="material-symbols-outlined text-xl text-gray-400 group-hover:text-yellow-500">edit</span>
            Edit Course
        </button>
        <button type="button" id="ctxArchiveBtn"
                class="group flex w-full items-center gap-3 px-5 py-3 text-sm font-bold text-gray-700 transition-colors hover:bg-blue-50 hover:text-blue-800">
            <span class="material-symbols-outlined text-xl text-gray-400 group-hover:text-blue-700">inventory_2</span>
            <span>Archive Course</span>
        </button>
        <div class="mt-1 border-t border-gray-100 pt-1">
            <button type="button" id="ctxDeleteBtn"
                    class="group flex w-full items-center gap-3 px-5 py-3 text-sm font-bold text-gray-700 transition-colors hover:bg-red-50 hover:text-red-600">
                <span class="material-symbols-outlined text-xl text-gray-400 group-hover:text-red-500">delete</span>
                Delete Course
            </button>
        </div>
    </div>

    <div id="confirmOverlay"
         class="fixed inset-0 z-[300] hidden items-center justify-center bg-[#1e3a8a]/30 backdrop-blur-sm">
        <div class="mx-4 w-full max-w-sm rounded-[2rem] border border-white/70 bg-white/95 p-8 shadow-[0_24px_50px_rgba(15,23,42,0.16)]">
            <div id="confirmIcon" class="mx-auto mb-4 flex size-14 items-center justify-center rounded-2xl"></div>
            <h4 id="confirmTitle" class="mb-2 text-center text-xl font-black uppercase text-math-dark-blue"></h4>
            <p id="confirmMsg" class="mb-8 text-center text-sm font-bold text-gray-500"></p>
            <div class="flex gap-3">
                <button type="button" onclick="closeConfirm()"
                        class="flex-1 rounded-2xl border border-gray-200 bg-gray-50 py-3 text-xs font-black uppercase tracking-[0.22em] text-gray-500 transition-colors hover:bg-white">
                    Cancel
                </button>
                <button type="button" id="confirmOkBtn"
                        class="flex-1 rounded-2xl py-3 text-xs font-black uppercase tracking-[0.22em] transition-colors">
                    Confirm
                </button>
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    var _ctxId = '', _ctxStatus = '';

    document.addEventListener('DOMContentLoaded', function () {
        document.getElementById('ctxViewBtn').addEventListener('click', function () {
            closeContextMenu();
            window.location.href = 'courseDetail.aspx?courseId=' + encodeURIComponent(_ctxId);
        });

        document.getElementById('ctxEditBtn').addEventListener('click', function () {
            closeContextMenu();
            window.location.href = 'editCourseDetail.aspx?id=' + encodeURIComponent(_ctxId);
        });

        document.getElementById('ctxArchiveBtn').addEventListener('click', function () {
            closeContextMenu();
            showArchiveConfirm();
        });

        document.getElementById('ctxDeleteBtn').addEventListener('click', function () {
            closeContextMenu();
            showDeleteConfirm();
        });

        var params = new URLSearchParams(window.location.search);
        if (params.get('success') === '1') {
            var status = params.get('status') || 'Draft';
            var newId = params.get('newId') || '';
            showToast('Course ' + newId + ' created successfully as ' + status + '.');
            history.replaceState(null, '', window.location.pathname);
        }
        if (params.get('updated') === '1') {
            showToast('Course updated successfully.');
            history.replaceState(null, '', window.location.pathname);
        }
    });

    function openContextMenu(e, courseId, status) {
        e.stopPropagation();
        _ctxId = courseId;
        _ctxStatus = (status || '').trim();

        document.getElementById('ctxCourseLabel').textContent = 'Course: ' + courseId;

        var archIcon = document.querySelector('#ctxArchiveBtn .material-symbols-outlined');
        var archText = document.querySelector('#ctxArchiveBtn span:last-child');
        if (_ctxStatus.toLowerCase() === 'archived') {
            archIcon.textContent = 'unarchive';
            archText.textContent = 'Unarchive Course';
        } else {
            archIcon.textContent = 'inventory_2';
            archText.textContent = 'Archive Course';
        }

        var menu = document.getElementById('contextMenu');
        var rect = e.currentTarget.getBoundingClientRect();
        var menuW = 220;
        var left = rect.right - menuW;
        var top = rect.bottom + 6;
        if (left < 8) left = 8;
        if (top + 240 > window.innerHeight) top = rect.top - 240;

        menu.style.left = left + 'px';
        menu.style.top = top + 'px';
        menu.classList.remove('hidden');

        setTimeout(function () {
            document.addEventListener('click', closeContextMenu, { once: true });
        }, 0);
    }

    function closeContextMenu() {
        document.getElementById('contextMenu').classList.add('hidden');
    }

    function changePage(pg) {
        if (pg < 1) return;
        document.getElementById('<%= hdnPageTarget.ClientID %>').value = pg;
        document.getElementById('<%= btnChangePage.ClientID %>').click();
    }

    function showArchiveConfirm() {
        var isArchived = _ctxStatus.toLowerCase() === 'archived';
        document.getElementById('confirmIcon').innerHTML =
            '<span class="material-symbols-outlined text-3xl text-blue-700" style="font-variation-settings:\'FILL\' 1">inventory_2</span>';
        document.getElementById('confirmIcon').className =
            'mx-auto mb-4 flex size-14 items-center justify-center rounded-2xl bg-blue-50';
        document.getElementById('confirmTitle').textContent =
            isArchived ? 'Unarchive Course?' : 'Archive Course?';
        document.getElementById('confirmMsg').textContent = isArchived
            ? 'This will restore "' + _ctxId + '" to active status.'
            : 'Archiving "' + _ctxId + '" will hide it from students. You can unarchive it later.';
        var okBtn = document.getElementById('confirmOkBtn');
        okBtn.textContent = isArchived ? 'Unarchive' : 'Archive';
        okBtn.className = 'flex-1 rounded-2xl bg-blue-700 py-3 text-xs font-black uppercase tracking-[0.22em] text-white transition-colors hover:bg-blue-800';
        okBtn.onclick = confirmArchive;
        openConfirm();
    }

    function showDeleteConfirm() {
        document.getElementById('confirmIcon').innerHTML =
            '<span class="material-symbols-outlined text-3xl text-red-500" style="font-variation-settings:\'FILL\' 1">delete_forever</span>';
        document.getElementById('confirmIcon').className =
            'mx-auto mb-4 flex size-14 items-center justify-center rounded-2xl bg-red-50';
        document.getElementById('confirmTitle').textContent = 'Delete Course?';
        document.getElementById('confirmMsg').textContent =
            'This permanently deletes "' + _ctxId + '" and all its modules. This cannot be undone.';
        var okBtn = document.getElementById('confirmOkBtn');
        okBtn.textContent = 'Delete';
        okBtn.className = 'flex-1 rounded-2xl bg-red-500 py-3 text-xs font-black uppercase tracking-[0.22em] text-white transition-colors hover:bg-red-600';
        okBtn.onclick = confirmDelete;
        openConfirm();
    }

    function openConfirm() {
        var o = document.getElementById('confirmOverlay');
        o.classList.remove('hidden');
        o.classList.add('flex');
    }

    function closeConfirm() {
        var o = document.getElementById('confirmOverlay');
        o.classList.add('hidden');
        o.classList.remove('flex');
    }

    function confirmArchive() {
        closeConfirm();
        document.getElementById('<%= hdnActionCourseId.ClientID %>').value = _ctxId;
        document.getElementById('<%= btnArchive.ClientID %>').click();
    }

    function confirmDelete() {
        closeConfirm();
        document.getElementById('<%= hdnActionCourseId.ClientID %>').value = _ctxId;
        document.getElementById('<%= btnDelete.ClientID %>').click();
    }

    function showToast(msg) {
        var t = document.createElement('div');
        t.textContent = msg;
        t.style.cssText = 'position:fixed;bottom:2rem;left:50%;transform:translateX(-50%);' +
            'background:#1e3a8a;color:white;font-weight:800;font-size:0.875rem;' +
            'padding:0.85rem 1.5rem;border-radius:9999px;box-shadow:0 16px 32px rgba(30,58,138,0.22);' +
            'z-index:9999;transition:opacity 0.4s ease;white-space:nowrap;';
        document.body.appendChild(t);
        setTimeout(function () {
            t.style.opacity = '0';
            setTimeout(function () { t.remove(); }, 400);
        }, 3000);
    }

    function goToCourse(id) {
        window.location.href = 'courseDetail.aspx?courseId=' + encodeURIComponent(id);
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { closeContextMenu(); closeConfirm(); }
    });
</script>
</asp:Content>
