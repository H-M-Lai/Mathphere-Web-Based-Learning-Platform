<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="fullModuleView.aspx.cs" Inherits="MathSphere.fullModuleView" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere - Full Syllabus
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/fullModuleView.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hdnDeleteModuleId" runat="server" />
    <asp:HiddenField ID="hdnEditModuleId" runat="server" />
    <asp:HiddenField ID="hdnViewModuleId" runat="server" />

    <div class="space-y-10">
        <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
            <div class="relative space-y-8">
                <div class="flex flex-wrap items-center gap-3">
                    <button type="button"
                            onclick="window.location.href='<%= ResolveUrl("~/courselistDashboard.aspx") %>'"
                            class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.24em] text-blue-600 transition-all hover:border-blue-200 hover:bg-blue-100">
                        <span class="material-symbols-outlined text-sm fill-icon">layers</span>
                        Courses
                    </button>
                    <div class="inline-flex items-center gap-2 rounded-full border border-gray-200 bg-white px-4 py-2 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">
                        <span class="material-symbols-outlined text-sm">grid_view</span>
                        Module Builder
                    </div>
                    <div class="inline-flex items-center gap-2 rounded-full border border-gray-200 bg-white px-4 py-2 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">
                        <span class="material-symbols-outlined text-sm">assignment</span>
                        Assessment Templates
                    </div>
                </div>

                <nav class="fmv-breadcrumb flex flex-wrap items-center gap-2 text-[10px] font-black uppercase tracking-[0.18em] text-gray-400">
                    <a href="<%= ResolveUrl("~/courselistDashboard.aspx") %>" class="transition-colors">Courses</a>
                    <span class="material-symbols-outlined text-sm">chevron_right</span>
                    <asp:HyperLink ID="lnkCourseDetail" runat="server" CssClass="transition-colors">
                        <asp:Literal ID="litCourseName" runat="server" Text="Course" />
                    </asp:HyperLink>
                    <span class="material-symbols-outlined text-sm text-math-blue">chevron_right</span>
                    <span class="text-math-blue">Full Syllabus</span>
                </nav>

                <div class="flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
                    <div class="max-w-3xl space-y-4">
                        <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                            <span class="material-symbols-outlined text-sm fill-icon">menu_book</span>
                            Course structure
                        </div>
                        <div class="space-y-3">
                            <h1 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Full Syllabus</h1>
                            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                                <asp:Literal ID="litCourseSubtitle" runat="server" Text="Curriculum management" />
                            </p>
                        </div>
                    </div>
                    <div class="flex flex-col gap-4 sm:flex-row xl:items-end">
                        <div class="stat-card">
                            <div class="text-center px-2">
                                <span class="block text-2xl font-black text-math-blue">
                                    <asp:Literal ID="litModuleCount" runat="server" Text="0" />
                                </span>
                                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400">Modules</span>
                            </div>
                            <div class="stat-divider"></div>
                            <div class="text-center px-2">
                                <span class="block text-2xl font-black text-math-green">
                                    <asp:Literal ID="litTotalItems" runat="server" Text="0" />
                                </span>
                                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400">Total Items</span>
                            </div>
                        </div>
                        <button type="button" onclick="openAddModuleModal()"
                                class="inline-flex items-center justify-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-5 py-3 text-xs font-black uppercase tracking-[0.22em] text-blue-600 transition-all hover:border-blue-200 hover:bg-blue-100">
                            <span class="material-symbols-outlined text-base">add_circle</span>
                            Add New Module
                        </button>
                    </div>
                </div>
            </div>
        </section>

        <section class="overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-8 shadow-[0_20px_48px_rgba(30,58,138,0.08)] lg:px-10">
            <div class="mb-8 flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
                <div>
                    <h2 class="text-2xl font-black tracking-tight text-math-dark-blue">Module Timeline</h2>
                    <p class="mt-1 text-sm font-bold text-gray-500">Update titles, adjust status, and open any module directly in the builder.</p>
                </div>
                <div class="inline-flex items-center gap-2 rounded-full border border-gray-200 bg-gray-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.22em] text-gray-500">
                    <span class="material-symbols-outlined text-sm">dashboard_customize</span>
                    Course map view
                </div>
            </div>

            <div class="space-y-4 mb-10" id="moduleList">
                <asp:Repeater ID="rptModules" runat="server" OnItemDataBound="rptModules_ItemDataBound">
                    <ItemTemplate>
                        <asp:Literal ID="litModuleRow" runat="server"></asp:Literal>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoModules" runat="server" Visible="false">
                    <div class="flex flex-col items-center py-16 text-center">
                        <div class="mx-auto mb-5 flex size-20 items-center justify-center rounded-3xl border border-gray-100 bg-gray-50 shadow-inner">
                            <span class="material-symbols-outlined text-4xl text-gray-300"
                                  style="font-variation-settings:'FILL' 1">grid_view</span>
                        </div>
                        <p class="mb-1 text-base font-black uppercase tracking-widest text-gray-400">
                            No Modules Yet
                        </p>
                        <p class="mb-6 text-sm font-semibold text-gray-300">
                            Click "Add New Module" below to build your first module.
                        </p>
                        <button type="button" onclick="openAddModuleModal()"
                                class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-5 py-3 text-xs font-black uppercase tracking-[0.22em] text-blue-600 transition-all hover:border-blue-200 hover:bg-blue-100">
                            <span class="material-symbols-outlined text-base">add_circle</span>
                            Add New Module
                        </button>
                    </div>
                </asp:Panel>
            </div>

            <button type="button" onclick="openAddModuleModal()" class="add-module-btn w-full">
                <div class="add-icon">
                    <span class="material-symbols-outlined text-3xl">add</span>
                </div>
                <span class="font-black text-sm uppercase tracking-widest">Add New Module</span>
            </button>
        </section>
    </div>

    <div id="fmvToast" class="fmv-toast"></div>

    <div id="addModuleOverlay" class="fmv-overlay hidden">
        <div class="fmv-modal-card w-full max-w-md">
            <div class="fmv-modal-header">
                <div class="flex items-center gap-3">
                    <div class="size-10 bg-math-blue/10 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-math-blue fill-icon">add_box</span>
                    </div>
                    <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">New Module</h3>
                </div>
                <button type="button" onclick="closeAddModuleModal()" class="fmv-close-btn">
                    <span class="material-symbols-outlined text-gray-400">close</span>
                </button>
            </div>
            <div class="space-y-5 p-8 pt-0">
                <div>
                    <label class="fmv-label">Module Title</label>
                    <asp:TextBox ID="txtNewModuleTitle" runat="server"
                        CssClass="fmv-input"
                        placeholder="e.g. Trigonometric Functions" />
                </div>
                <div>
                    <label class="fmv-label">Status</label>
                    <div class="fmv-select-wrap">
                        <asp:DropDownList ID="ddlNewModuleStatus" runat="server" CssClass="fmv-select">
                            <asp:ListItem Text="Active" Value="active" />
                            <asp:ListItem Text="Drafting" Value="drafting" />
                            <asp:ListItem Text="Locked" Value="locked" />
                        </asp:DropDownList>
                        <span class="material-symbols-outlined fmv-select-icon">expand_more</span>
                    </div>
                </div>
                <div class="flex gap-3 pt-2">
                    <button type="button" onclick="closeAddModuleModal()" class="fmv-btn-cancel">Cancel</button>
                    <asp:Button ID="btnSaveModule" runat="server" Text="Save Module"
                        OnClick="btnSaveModule_Click" CssClass="fmv-btn-primary" />
                </div>
            </div>
        </div>
    </div>

    <div id="editModuleOverlay" class="fmv-overlay hidden">
        <div class="fmv-modal-card w-full max-w-md">
            <div class="fmv-modal-header">
                <div class="flex items-center gap-3">
                    <div class="size-10 bg-primary/20 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-math-dark-blue fill-icon">edit_note</span>
                    </div>
                    <div>
                        <p class="text-[10px] font-black uppercase tracking-widest text-gray-400">Editing</p>
                        <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight">Edit Module</h3>
                    </div>
                </div>
                <button type="button" onclick="closeEditModuleModal()" class="fmv-close-btn">
                    <span class="material-symbols-outlined text-gray-400">close</span>
                </button>
            </div>
            <div class="space-y-5 p-8 pt-0">
                <div>
                    <label class="fmv-label">Module Title</label>
                    <asp:TextBox ID="txtEditModuleTitle" runat="server" CssClass="fmv-input" />
                </div>
                <div>
                    <label class="fmv-label">Status</label>
                    <div class="fmv-select-wrap">
                        <asp:DropDownList ID="ddlEditModuleStatus" runat="server" CssClass="fmv-select">
                            <asp:ListItem Text="Active" Value="active" />
                            <asp:ListItem Text="Drafting" Value="drafting" />
                            <asp:ListItem Text="Locked" Value="locked" />
                            <asp:ListItem Text="Currently Active" Value="current" />
                        </asp:DropDownList>
                        <span class="material-symbols-outlined fmv-select-icon">expand_more</span>
                    </div>
                </div>
                <div class="bg-gray-50 rounded-2xl px-5 py-4 flex items-center gap-3 border-2 border-gray-100">
                    <span class="material-symbols-outlined text-gray-400 text-xl">info</span>
                    <p class="text-xs font-bold text-gray-400">Changes are saved immediately and reflected in the course timeline.</p>
                </div>
                <div class="flex gap-3 pt-2">
                    <button type="button" onclick="closeEditModuleModal()" class="fmv-btn-cancel">Cancel</button>
                    <asp:Button ID="btnSaveEditModule" runat="server" Text="Save Changes"
                        OnClick="btnSaveEditModule_Click" CssClass="fmv-btn-primary" />
                </div>
            </div>
        </div>
    </div>

    <div id="viewPanelBackdrop"
         class="fixed inset-0 z-[290] bg-math-dark-blue/20 backdrop-blur-[2px] hidden"
         onclick="closeViewPanel()"></div>

    <div id="viewPanel" class="fmv-view-panel">
        <div class="flex justify-between items-start mb-8">
            <div class="flex items-center gap-4">
                <div class="size-12 bg-math-blue rounded-2xl flex items-center justify-center shadow-lg shadow-math-blue/20">
                    <span class="material-symbols-outlined text-white fill-icon text-2xl" id="vpIcon">functions</span>
                </div>
                <div>
                    <p class="text-[10px] font-black uppercase tracking-widest text-gray-400" id="vpModuleNumber">Module 01</p>
                    <h2 class="text-xl font-black text-math-dark-blue leading-tight" id="vpTitle">Module Title</h2>
                </div>
            </div>
            <button type="button" onclick="closeViewPanel()" class="fmv-close-btn mt-1">
                <span class="material-symbols-outlined text-gray-400">close</span>
            </button>
        </div>

        <div class="mb-6" id="vpBadgeWrap">
            <span class="badge badge-green" id="vpBadge">Active</span>
        </div>

        <div class="grid grid-cols-2 gap-4 mb-8">
            <div class="bg-gray-50 rounded-2xl p-4 border-2 border-gray-100">
                <span class="text-[10px] font-black uppercase tracking-widest text-gray-400 block mb-1">Content Items</span>
                <span class="text-3xl font-black text-math-dark-blue" id="vpItemCount">0</span>
            </div>
            <div class="bg-blue-50 rounded-2xl p-4 border-2 border-blue-100">
                <span class="text-[10px] font-black uppercase tracking-widest text-math-blue block mb-1">Module No.</span>
                <span class="text-3xl font-black text-math-blue" id="vpNumber">01</span>
            </div>
        </div>

        <div class="mb-8">
            <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4">Content Breakdown</p>
            <div class="space-y-3" id="vpContentList">
                <div class="flex items-center justify-between px-4 py-3 bg-white rounded-xl border-2 border-gray-100">
                    <div class="flex items-center gap-3">
                        <span class="material-symbols-outlined text-math-blue fill-icon text-lg">play_circle</span>
                        <span class="text-sm font-bold text-math-dark-blue">Video Lessons</span>
                    </div>
                    <span class="text-sm font-black text-math-dark-blue">8</span>
                </div>
                <div class="flex items-center justify-between px-4 py-3 bg-white rounded-xl border-2 border-gray-100">
                    <div class="flex items-center gap-3">
                        <span class="material-symbols-outlined text-math-green fill-icon text-lg">quiz</span>
                        <span class="text-sm font-bold text-math-dark-blue">Practice Quizzes</span>
                    </div>
                    <span class="text-sm font-black text-math-dark-blue">5</span>
                </div>
                <div class="flex items-center justify-between px-4 py-3 bg-white rounded-xl border-2 border-gray-100">
                    <div class="flex items-center gap-3">
                        <span class="material-symbols-outlined text-primary fill-icon text-lg">description</span>
                        <span class="text-sm font-bold text-math-dark-blue">Reading Materials</span>
                    </div>
                    <span class="text-sm font-black text-math-dark-blue">11</span>
                </div>
            </div>
        </div>

        <div class="border-t-2 border-gray-100 pt-6 flex flex-col gap-3">
            <button type="button" id="vpEditBtn"
                onclick="closeViewPanel(); openEditFromView();"
                class="w-full flex items-center justify-center gap-2 py-3.5 rounded-2xl bg-primary text-math-dark-blue font-black text-sm uppercase tracking-widest shadow-[0_4px_0_0_#c9a800] hover:shadow-[0_2px_0_0_#c9a800] hover:translate-y-[2px] active:shadow-none active:translate-y-[4px] transition-all">
                <span class="material-symbols-outlined text-xl">edit</span>
                Edit This Module
            </button>
            <button type="button" id="vpDeleteBtn"
                onclick="closeViewPanel(); openDeleteFromView();"
                class="w-full flex items-center justify-center gap-2 py-3.5 rounded-2xl border-2 border-red-200 text-red-500 font-black text-sm uppercase tracking-widest hover:bg-red-50 transition-colors">
                <span class="material-symbols-outlined text-xl">delete</span>
                Delete Module
            </button>
        </div>
    </div>

    <div id="deleteOverlay" class="fmv-overlay hidden">
        <div class="fmv-modal-card w-full max-w-sm text-center">
            <div class="p-8">
                <div class="size-16 bg-red-50 rounded-2xl flex items-center justify-center mx-auto mb-5">
                    <span class="material-symbols-outlined text-red-500 fill-icon" style="font-size:36px">delete_forever</span>
                </div>
                <h4 class="text-xl font-black text-math-dark-blue uppercase tracking-tight mb-2">Delete Module?</h4>
                <p class="text-gray-400 text-sm font-medium mb-2">You are about to permanently delete</p>
                <p class="font-black text-math-dark-blue text-base mb-6" id="deleteModuleName"></p>
                <div class="bg-red-50 rounded-2xl px-4 py-3 mb-8 flex items-center gap-2">
                    <span class="material-symbols-outlined text-red-400 text-lg">warning</span>
                    <p class="text-xs font-bold text-red-500 text-left">All content items inside this module will also be deleted. This cannot be undone.</p>
                </div>
                <div class="flex gap-3">
                    <button type="button" onclick="closeDeleteModal()" class="fmv-btn-cancel flex-1">Cancel</button>
                    <asp:Button ID="btnConfirmDelete" runat="server" Text="Yes, Delete"
                        OnClick="btnConfirmDelete_Click"
                        CssClass="flex-1 py-3 rounded-2xl bg-red-500 text-white font-black text-xs uppercase tracking-widest hover:bg-red-600 transition-colors border-0 cursor-pointer shadow-[0_4px_0_0_#b91c1c] active:shadow-none" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    var _currentModuleId = '';
    var _currentModuleName = '';

    function showModal(id) {
        var el = document.getElementById(id);
        el.classList.remove('hidden');
        requestAnimationFrame(function () { el.classList.add('fmv-overlay-open'); });
    }

    function hideModal(id) {
        var el = document.getElementById(id);
        el.classList.remove('fmv-overlay-open');
        setTimeout(function () { el.classList.add('hidden'); }, 220);
    }

    function openAddModuleModal() {
        hideModal('editModuleOverlay');
        hideModal('deleteOverlay');
        showModal('addModuleOverlay');
    }
    function closeAddModuleModal() { hideModal('addModuleOverlay'); }

    function viewModule(moduleId) {
        window.location.href = 'moduleBuilder.aspx?id=' + encodeURIComponent(moduleId);
    }
    function closeViewPanel() {
        document.getElementById('viewPanel').classList.remove('open');
        document.getElementById('viewPanelBackdrop').classList.add('hidden');
    }
    function openEditFromView() {
        openEditModuleModal(_currentModuleId, _currentModuleName, '');
    }
    function openDeleteFromView() {
        openDeleteModal(_currentModuleId, _currentModuleName);
    }

    function openEditModuleModal(moduleId, title, status) {
        _currentModuleId = moduleId;
        _currentModuleName = title;

        document.getElementById('<%= hdnEditModuleId.ClientID %>').value = moduleId;
        document.getElementById('<%= txtEditModuleTitle.ClientID %>').value = title;

        var ddl = document.getElementById('<%= ddlEditModuleStatus.ClientID %>');
        for (var i = 0; i < ddl.options.length; i++) {
            if (ddl.options[i].value === status) { ddl.selectedIndex = i; break; }
        }

        hideModal('addModuleOverlay');
        hideModal('deleteOverlay');
        showModal('editModuleOverlay');
    }
    function closeEditModuleModal() { hideModal('editModuleOverlay'); }

    function openDeleteModal(moduleId, moduleName) {
        _currentModuleId = moduleId;
        _currentModuleName = moduleName;

        document.getElementById('<%= hdnDeleteModuleId.ClientID %>').value = moduleId;
        document.getElementById('deleteModuleName').textContent = '"' + moduleName + '"';

        hideModal('addModuleOverlay');
        hideModal('editModuleOverlay');
        showModal('deleteOverlay');
    }
    function closeDeleteModal() { hideModal('deleteOverlay'); }

    function showToast(msg, type) {
        var el = document.getElementById('fmvToast');
        el.textContent = msg;
        el.className = 'fmv-toast' + (type === 'error' ? ' fmv-toast-error' : '');
        el.classList.add('visible');
        setTimeout(function () { el.classList.remove('visible'); }, 3200);
    }

    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        closeAddModuleModal();
        closeEditModuleModal();
        closeDeleteModal();
        closeViewPanel();
    });
</script>
</asp:Content>