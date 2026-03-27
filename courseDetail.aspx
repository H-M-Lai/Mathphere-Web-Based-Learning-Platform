<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="courseDetail.aspx.cs" Inherits="MathSphere.courseDetail" %>

<%-- Title --%>
<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere — <asp:Literal ID="litPageTitle" runat="server" Text="Course Detail" />
</asp:Content>

<%-- Head (page-specific styles) --%>
<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/courseDetail.css") %>" rel="stylesheet" />
    <style>
        .cd-bg-icon { position: fixed; pointer-events: none; opacity: 0.1; }
    </style>
</asp:Content>

<%-- Main content --%>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hdnDeleteAssessmentId" runat="server" />
    <asp:Button ID="btnDeleteAssessment" runat="server"
                CssClass="hidden"
                CausesValidation="false"
                OnClick="btnDeleteAssessment_Click" />

    <%-- Decorative background icons --%>
    <div class="fixed inset-0 pointer-events-none opacity-10 overflow-hidden -z-10">
        <span class="material-symbols-outlined absolute text-7xl top-20 left-[10%] rotate-12 text-math-blue">functions</span>
        <span class="material-symbols-outlined absolute text-8xl top-60 right-[5%] -rotate-12 text-math-green">change_history</span>
        <span class="material-symbols-outlined absolute text-6xl bottom-40 left-[15%] rotate-45 text-primary">pie_chart</span>
        <span class="material-symbols-outlined absolute text-9xl bottom-10 right-[20%] -rotate-45 text-math-blue">architecture</span>
    </div>

    <%-- COURSE HERO --%>
    <div class="mb-12">
        <div class="flex flex-col xl:flex-row justify-between items-start gap-8 mb-8">

            <%-- Course title + back link --%>
            <div class="flex items-center gap-6">
                <div class="size-20 bg-math-blue text-white rounded-[2rem] flex items-center justify-center shadow-xl shadow-math-blue/20 rotate-3">
                    <span class="material-symbols-outlined text-5xl fill-icon">
                        <asp:Literal ID="litCourseIcon" runat="server" Text="functions" />
                    </span>
                </div>
                <div>
                    <a href="<%= ResolveUrl("~/courselistDashboard.aspx") %>"
                       class="text-math-blue font-bold text-sm uppercase tracking-widest hover:underline flex items-center gap-1 mb-1">
                        <span class="material-symbols-outlined text-sm">arrow_back</span> Back to Courses
                    </a>
                    <h2 class="text-4xl md:text-5xl font-black text-math-dark-blue tracking-tight">
                        <asp:Literal ID="litCourseName" runat="server" Text="Course Name" />
                    </h2>
                    <p class="text-lg text-gray-500 font-medium italic mt-1">
                        <asp:Literal ID="litCourseInfo" runat="server" Text="Section • Semester" />
                    </p>
                </div>
            </div>

            <%-- Stat mini-cards --%>
            <div class="flex flex-wrap gap-4 w-full xl:w-auto">

                <div class="flex-1 min-w-[160px] bg-white p-5 rounded-2xl border-2 border-gray-100 shadow-sm">
                    <span class="text-[10px] font-black text-gray-400 uppercase tracking-widest block mb-1">Enrolled</span>
                    <div class="flex items-end gap-1">
                        <span class="text-4xl font-black text-math-dark-blue">
                            <asp:Literal ID="litEnrolledCount" runat="server" Text="0" />
                        </span>
                        <span class="text-math-green font-bold text-sm mb-1 pb-0.5">Students</span>
                    </div>
                </div>

           
            </div>
        </div>
    </div>

    <%-- CURRICULUM TIMELINE --%>
    <section class="bg-white rounded-[2.5rem] p-10 shadow-xl border-2 border-gray-100 mb-10">
        <div class="flex justify-between items-center mb-12">
            <h3 class="text-2xl font-black flex items-center gap-4 uppercase tracking-tighter">
                <span class="size-10 bg-math-blue/10 rounded-xl flex items-center justify-center">
                    <span class="material-symbols-outlined text-math-blue text-2xl">timeline</span>
                </span>
                Curriculum Timeline
            </h3>
            <asp:HyperLink ID="lnkFullSyllabus" runat="server"
                CssClass="bg-math-blue text-white font-black text-xs uppercase tracking-widest px-5 py-2.5 rounded-2xl hover:bg-blue-700 transition-colors flex items-center gap-2 shadow-md">
                <span class="material-symbols-outlined text-sm">list_alt</span>
                Full Syllabus
            </asp:HyperLink>
        </div>

        <div class="relative px-4">
            <div class="absolute top-[22px] left-8 right-8 h-1 bg-gray-200 rounded-full opacity-40"></div>
            <div class="flex justify-between items-start relative z-10 gap-4 overflow-x-auto pb-6">
                <asp:Repeater ID="rptModules" runat="server" OnItemDataBound="rptModules_ItemDataBound">
                    <ItemTemplate>
                        <asp:Literal ID="litModuleCard" runat="server"></asp:Literal>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Repeater ID="Repeater1" runat="server" OnItemDataBound="rptModules_ItemDataBound">
                    <ItemTemplate>
                        <asp:Literal ID="litModuleCard" runat="server"></asp:Literal>
                    </ItemTemplate>
                </asp:Repeater>

                <%-- Empty state --%>
                <asp:Panel ID="pnlNoModules" runat="server" Visible="false">
                    <div class="flex flex-col items-center py-12 text-center">
                        <div class="size-16 rounded-3xl bg-gray-50 border-2 border-dashed border-gray-200 
                                    flex items-center justify-center mx-auto mb-4">
                            <span class="material-symbols-outlined text-3xl text-gray-300"
                                  style="font-variation-settings:'FILL' 1">timeline</span>
                        </div>
                        <p class="text-sm font-black text-gray-400 uppercase tracking-widest mb-1">No Modules Yet</p>
                        <p class="text-xs font-semibold text-gray-300 mb-4">Add modules via the Full Syllabus page</p>
                        <a href='<%# "fullModuleView.aspx?courseId=" + Request.QueryString["courseId"] %>'
                           class="inline-flex items-center gap-2 px-5 py-2.5 bg-math-blue text-white 
                                  font-black text-xs uppercase tracking-widest rounded-2xl 
                                  hover:bg-math-dark-blue transition-all shadow-md">
                            <span class="material-symbols-outlined text-sm">add_circle</span>
                            Go to Full Syllabus
                        </a>
                    </div>
                </asp:Panel>

            </div>
        </div>
    </section>

    <%-- COURSE ASSESSMENTS --%>
    <section class="bg-white rounded-[2.5rem] p-10 shadow-xl border-2 border-gray-100">
        <div class="flex items-center justify-between mb-8">
            <div class="flex items-center gap-4">
                <span class="size-11 bg-math-green/10 rounded-xl flex items-center justify-center">
                    <span class="material-symbols-outlined text-math-green text-2xl">assignment</span>
                </span>
                <h3 class="text-2xl font-black uppercase tracking-tight">Course Assessments</h3>
            </div>
            <asp:HyperLink ID="lnkNewAssessment" runat="server"
                CssClass="flex items-center gap-2 bg-math-green/10 text-green-700 border-2 border-math-green/30 font-black text-xs uppercase tracking-widest px-5 py-2.5 rounded-2xl hover:bg-math-green/20 transition-colors">
                <span class="material-symbols-outlined text-lg">add_circle</span>
                New Assessment
            </asp:HyperLink>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <asp:Repeater ID="rptAssessments" runat="server" OnItemDataBound="rptAssessments_ItemDataBound">
                <ItemTemplate>
                    <asp:Literal ID="litAssessmentCard" runat="server"></asp:Literal>
                </ItemTemplate>
            </asp:Repeater>

                    <asp:Repeater ID="Repeater2" runat="server" OnItemDataBound="rptAssessments_ItemDataBound">
            <ItemTemplate>
                <asp:Literal ID="litAssessmentCard" runat="server"></asp:Literal>
            </ItemTemplate>
        </asp:Repeater>

        <%-- Empty state --%>
        <asp:Panel ID="pnlNoAssessments" runat="server" Visible="false">
            <div class="col-span-2 flex flex-col items-center py-12 text-center">
                <div class="size-16 rounded-3xl bg-gray-50 border-2 border-dashed border-gray-200 
                            flex items-center justify-center mx-auto mb-4">
                    <span class="material-symbols-outlined text-3xl text-gray-300"
                          style="font-variation-settings:'FILL' 1">assignment</span>
                </div>
                <p class="text-sm font-black text-gray-400 uppercase tracking-widest mb-1">No Assessments Yet</p>
                <p class="text-xs font-semibold text-gray-300 mb-4">Create your first assessment for this course</p>
            </div>
        </asp:Panel>

        </div>
    </section>

    <%-- DELETE CONFIRMATION MODAL --%>
    <div id="deleteAssessmentModal"
         class="fixed inset-0 z-50 hidden items-center justify-center p-4
                bg-math-dark-blue/40 backdrop-blur-sm">
        <div class="bg-white rounded-[2rem] p-10 text-center max-w-md w-full shadow-2xl">
            <div class="size-16 rounded-3xl bg-red-100 flex items-center justify-center mx-auto mb-5">
                <span class="material-symbols-outlined text-red-400 text-3xl fill-icon">delete_forever</span>
            </div>
            <h3 class="text-2xl font-black text-math-dark-blue mb-2">Delete Assessment?</h3>
            <p class="text-gray-500 font-semibold mb-1">
                You are about to delete:
            </p>
            <p id="deleteAssessmentName"
               class="text-math-dark-blue font-black text-lg mb-6 truncate"></p>
            <p class="text-red-400 text-xs font-bold uppercase tracking-widest mb-8">
                This will also delete all questions, options and student attempts. This cannot be undone.
            </p>
            <div class="flex gap-4">
                <button type="button" onclick="closeDeleteAssessmentModal()"
                    class="flex-1 py-3.5 rounded-2xl bg-white border-2 border-gray-200
                           text-gray-600 font-black text-sm uppercase tracking-widest
                           hover:bg-gray-50 transition-all">
                    Cancel
                </button>
                <button type="button" onclick="confirmDeleteAssessment()"
                    class="flex-1 py-3.5 rounded-2xl bg-red-500 text-white font-black
                           text-sm uppercase tracking-widest shadow-lg shadow-red-200
                           hover:bg-red-600 transition-all">
                    Yes, Delete
                </button>
            </div>
        </div>
    </div>

</asp:Content>

<%-- Script --%>
<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    // Delete assessment modal
    function showDeleteAssessmentModal(aid, title) {
        document.getElementById('<%= hdnDeleteAssessmentId.ClientID %>').value = aid;
        document.getElementById('deleteAssessmentName').textContent = title;
        var m = document.getElementById('deleteAssessmentModal');
        m.classList.remove('hidden');
        m.classList.add('flex');
    }

    function closeDeleteAssessmentModal() {
        var m = document.getElementById('deleteAssessmentModal');
        m.classList.add('hidden');
        m.classList.remove('flex');
    }

    function confirmDeleteAssessment() {
        // Trigger the hidden server button ? btnDeleteAssessment_Click
        document.getElementById('<%= btnDeleteAssessment.ClientID %>').click();
    }

    // Close on backdrop click
    document.getElementById('deleteAssessmentModal')
        .addEventListener('click', function (e) {
            if (e.target === this) closeDeleteAssessmentModal();
        });
</script>
</asp:Content>

