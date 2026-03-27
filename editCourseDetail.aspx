<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="editCourseDetail.aspx.cs" Inherits="MathSphere.editCourseDetail" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    Edit Course — MathSphere
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .ecd-input {
            width: 100%;
            background: #f8fafc;
            border: 2px solid #e2e8f0;
            border-radius: 1rem;
            padding: 0.9rem 1.25rem;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 600;
            font-size: 0.9rem;
            color: #1e3a8a;
            outline: none;
            transition: border-color 0.15s;
        }
        .ecd-input:focus { border-color: #2563eb; background: #fff; }
        .ecd-input.readonly {
            background: #f1f5f9;
            color: #94a3b8;
            cursor: not-allowed;
        }
        .ecd-label {
            display: block;
            font-size: 10px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.2em;
            color: #64748b;
            margin-bottom: 0.4rem;
            margin-left: 0.25rem;
        }
        .ecd-error {
            color: #ef4444;
            font-size: 11px;
            font-weight: 700;
            margin-top: 0.3rem;
            margin-left: 0.25rem;
            display: none;
        }
        .ecd-error.visible { display: block; }

        /* -- Validity button -- */
        .ecd-validity-btn {
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #f8fafc;
            border: 2px solid #e2e8f0;
            border-radius: 1rem;
            padding: 0.9rem 1.25rem;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 700;
            font-size: 0.9rem;
            color: #1e3a8a;
            cursor: pointer;
            transition: border-color 0.15s, background 0.15s;
        }
        .ecd-validity-btn:hover,
        .ecd-validity-btn.open { border-color: #2563eb; background: #fff; }

        /* -- Date popover -- */
        .ecd-date-popover {
            display: none;
            margin-top: 0.5rem;
            background: #fff;
            border: 2px solid #e2e8f0;
            border-radius: 1.25rem;
            padding: 1.25rem;
            box-shadow: 0 8px 32px rgba(30,58,138,0.10);
        }
        .ecd-date-popover.open { display: block; }

        .ecd-date-row {
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: end;
            gap: 0.75rem;
        }
        .ecd-date-field label {
            display: block;
            font-size: 10px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.18em;
            color: #94a3b8;
            margin-bottom: 0.35rem;
        }
        .ecd-date-arrow {
            display: flex;
            align-items: center;
            padding-bottom: 0.5rem;
            color: #cbd5e1;
            font-weight: 900;
            font-size: 1.25rem;
        }

        /* -- Left panel -- */
        .ecd-left-panel {
            background: linear-gradient(160deg, #1e3a8a 0%, #2563eb 65%, #3b82f6 100%);
            position: relative;
            overflow: hidden;
        }
        .ecd-icon-circle {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: rgba(255,255,255,0.15);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
            border: 3px solid rgba(255,255,255,0.25);
        }

        /* -- Buttons -- */
        .ecd-update-btn {
            flex: 1;
            background: #f9d006;
            color: #1e3a8a;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 900;
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.12em;
            padding: 1.1rem 1.5rem;
            border-radius: 1rem;
            border: none;
            cursor: pointer;
            box-shadow: 0 16px 30px rgba(249,208,6,0.18);
            transition: box-shadow 0.15s, transform 0.15s;
        }
        .ecd-update-btn:hover  { filter: brightness(1.02); transform: translateY(-1px); }
        .ecd-update-btn:active { transform: translateY(0); box-shadow: 0 10px 18px rgba(249,208,6,0.16); }

        .ecd-discard-btn {
            flex: 1;
            background: #fff;
            color: #64748b;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 900;
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.12em;
            padding: 1.1rem 1.5rem;
            border-radius: 1rem;
            border: 2px solid #e2e8f0;
            cursor: pointer;
            transition: background 0.15s, color 0.15s, border-color 0.15s;
        }
        .ecd-discard-btn:hover { background: #fff; color: #1e3a8a; border-color: #cbd5e1; }

        /* -- Toast -- */
        .ecd-toast {
            position: fixed;
            bottom: 2rem;
            left: 50%;
            transform: translateX(-50%) translateY(1rem);
            background: #1e3a8a;
            color: white;
            font-weight: 800;
            font-size: 0.875rem;
            padding: 0.75rem 1.5rem;
            border-radius: 1rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            z-index: 9999;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s ease, transform 0.3s ease;
            white-space: nowrap;
        }
        .ecd-toast.visible {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hdnCourseId" runat="server" />

    <%-- Back breadcrumb --%>
    <nav class="flex items-center gap-2 text-[10px] font-black uppercase tracking-[0.18em] text-gray-400 mb-8">
        <a href="courselistDashboard.aspx"
           class="hover:text-math-blue transition-colors flex items-center gap-1">
            <span class="material-symbols-outlined text-sm">arrow_back</span>
            Courses
        </a>
        <span class="material-symbols-outlined text-sm">chevron_right</span>
        <span class="text-math-blue">Edit Course</span>
    </nav>

    <%-- Two-panel card --%>
    <section class="relative max-w-5xl mx-auto overflow-hidden rounded-[2.5rem] border border-white/80 bg-white/95 shadow-[0_24px_60px_rgba(30,58,138,0.12)] backdrop-blur-md>
        <div class="flex flex-col md:flex-row min-h-[580px]">

        <%-- Left blue panel --%>
        <div class="ecd-left-panel md:w-[35%] p-10 lg:p-12 flex flex-col items-center justify-center text-center">
            <%-- Decorative floating symbols --%>
            <div class="absolute opacity-10 pointer-events-none">
                <span class="material-symbols-outlined text-8xl text-white absolute -top-8 -left-8 rotate-12">functions</span>
                <span class="material-symbols-outlined text-8xl text-white absolute -bottom-8 -right-8 -rotate-12">change_history</span>
            </div>
            <div class="ecd-icon-circle">
                <span class="material-symbols-outlined text-white fill-icon" style="font-size:2.8rem">edit_note</span>
            </div>
            <h2 class="text-white text-3xl font-black uppercase leading-tight tracking-tight mb-4">
                Revise Your<br/>Curriculum
            </h2>
            <p class="text-blue-100/70 text-sm font-medium leading-relaxed max-w-[200px]">
                Keep your course materials up-to-date and tailored for your students' success.
            </p>

            <%-- Stats pills --%>
            <div class="mt-8 flex flex-col gap-3 w-full">
                <div class="flex items-center gap-3 bg-white/10 border border-white/20 rounded-2xl px-4 py-3">
                    <span class="material-symbols-outlined text-primary fill-icon text-xl">edit</span>
                    <span class="text-white font-black text-xs uppercase tracking-wider">Edit Course Name</span>
                </div>
                <div class="flex items-center gap-3 bg-white/10 border border-white/20 rounded-2xl px-4 py-3">
                    <span class="material-symbols-outlined text-primary fill-icon text-xl">description</span>
                    <span class="text-white font-black text-xs uppercase tracking-wider">Edit Description</span>
                </div>
                <div class="flex items-center gap-3 bg-white/10 border border-white/20 rounded-2xl px-4 py-3">
                    <span class="material-symbols-outlined text-primary fill-icon text-xl">calendar_month</span>
                    <span class="text-white font-black text-xs uppercase tracking-wider">Set Course Validity</span>
                </div>
            </div>
        </div>

        <%-- Right white form panel --%>
        <div class="flex-1 p-10 md:p-12 lg:p-14 flex flex-col justify-between bg-white/90">
            <div>
                <%-- Heading --%>
                <div class="mb-8">
                    <p class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400 mb-1">Update Curriculum</p>
                    <h1 class="text-3xl font-black text-math-dark-blue tracking-tight">Edit Course Details</h1>
                </div>

                <%-- Validation summary --%>
                <asp:Panel ID="pnlValidation" runat="server" Visible="false"
                    CssClass="mb-6 bg-red-50 border-2 border-red-200 rounded-2xl px-5 py-4 flex items-center gap-3">
                    <span class="material-symbols-outlined text-red-500 fill-icon">error</span>
                    <asp:Label ID="lblValidation" runat="server" CssClass="text-red-600 font-bold text-sm"></asp:Label>
                </asp:Panel>

                <%-- Success panel --%>
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false"
                    CssClass="mb-6 bg-green-50 border-2 border-green-200 rounded-2xl px-5 py-4 flex items-center gap-3">
                    <span class="material-symbols-outlined text-green-500 fill-icon">check_circle</span>
                    <asp:Label ID="lblSuccess" runat="server" CssClass="text-green-700 font-bold text-sm"></asp:Label>
                </asp:Panel>

                <div class="space-y-5">

                    <%-- Course Name --%>
                    <div>
                        <label class="ecd-label">Course Name <span class="text-red-500">*</span></label>
                        <asp:TextBox ID="txtCourseName" runat="server"
                            CssClass="ecd-input"
                            placeholder="e.g. Advanced Algebra II"
                            MaxLength="150"></asp:TextBox>
                        <div id="errCourseName" class="ecd-error">Course name is required.</div>
                    </div>

                    <%-- Course ID (read-only) --%>
                    <div>
                        <label class="ecd-label">Course ID (read-only)</label>
                        <asp:TextBox ID="txtCourseId" runat="server"
                            CssClass="ecd-input readonly"
                            ReadOnly="true"></asp:TextBox>
                    </div>

                    <%-- Description --%>
                    <div>
                        <label class="ecd-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server"
                            TextMode="MultiLine" Rows="3"
                            CssClass="ecd-input"
                            placeholder="Describe what students will learn in this course…"></asp:TextBox>
                    </div>

                    <%-- Course Validity -- improved UI --%>
                    <div>
                        <label class="ecd-label">Set Course Validity</label>

                        <%-- Toggle button --%>
                        <button type="button" class="ecd-validity-btn" onclick="toggleDatePicker()" id="btnDateDisplay">
                            <span class="flex items-center gap-3">
                                <span class="material-symbols-outlined text-math-blue text-xl fill-icon">calendar_month</span>
                                <span id="dateDisplayText" class="text-math-dark-blue font-bold">Select date range…</span>
                            </span>
                            <span class="material-symbols-outlined text-math-blue text-xl" id="dateChevron">expand_more</span>
                        </button>

                        <%-- Inline date popover --%>
                        <div class="ecd-date-popover" id="datePickerPopover">

                            <div class="ecd-date-row">
                                <%-- Start Date (read-only display) --%>
                                <div class="ecd-date-field">
                                    <label>Start Date (read-only)</label>
                                    <asp:TextBox ID="txtStartDate" runat="server"
                                        TextMode="Date"
                                        ReadOnly="true"
                                        CssClass="ecd-input readonly"
                                        style="padding:0.7rem 1rem;"></asp:TextBox>
                                </div>

                                <div class="ecd-date-arrow"><span class="material-symbols-outlined text-2xl">east</span></div>

                                <%-- End Date (editable) --%>
                                <div class="ecd-date-field">
                                    <label>End Date</label>
                                    <asp:TextBox ID="txtEndDate" runat="server"
                                        TextMode="Date"
                                        CssClass="ecd-input"
                                        style="padding:0.7rem 1rem;"
                                        onchange="updateDateDisplay()"></asp:TextBox>
                                </div>
                            </div>

                            <%-- Popover footer --%>
                            <div class="flex items-center justify-between mt-4 pt-4 border-t-2 border-gray-100">
                                <p class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">
                                    Only the end date can be changed
                                </p>
                                <button type="button" onclick="toggleDatePicker()"
                                    class="px-6 py-2.5 bg-math-blue text-white rounded-xl font-black text-xs uppercase tracking-widest hover:bg-math-dark-blue transition-colors shadow-[0_4px_0_0_#1e3a8a] hover:shadow-[0_2px_0_0_#1e3a8a] hover:translate-y-[2px] active:shadow-none active:translate-y-[4px]">
                                    Done
                                </button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>

            <%-- Action buttons --%>
            <div class="flex flex-col sm:flex-row gap-4 mt-10">
                <button type="button" onclick="discardChanges()" class="ecd-discard-btn">Discard Changes</button>
                <asp:Button ID="btnUpdate" runat="server"
                    Text="Update Course"
                    OnClick="btnUpdate_Click"
                    CssClass="ecd-update-btn"
                    OnClientClick="return validateForm();"/>
            </div>

        </div>
    </section>

    <div id="ecdToast" class="ecd-toast"></div>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    var dateOpen = false;

    function toggleDatePicker() {
        dateOpen = !dateOpen;
        var pop = document.getElementById('datePickerPopover');
        var btn = document.getElementById('btnDateDisplay');
        var chev = document.getElementById('dateChevron');
        if (dateOpen) {
            pop.classList.add('open');
            btn.classList.add('open');
            chev.textContent = 'expand_less';
        } else {
            pop.classList.remove('open');
            btn.classList.remove('open');
            chev.textContent = 'expand_more';
        }
    }

    function updateDateDisplay() {
        var s = document.getElementById('<%= txtStartDate.ClientID %>').value;
        var e = document.getElementById('<%= txtEndDate.ClientID %>').value;
        var el = document.getElementById('dateDisplayText');
        if (s && e) {
            el.textContent = formatDate(s) + ' to ' + formatDate(e);
        } else if (s) {
            el.textContent = formatDate(s) + '  ?  End Date…';
        } else {
            el.textContent = 'Select date range…';
        }
    }

    function formatDate(val) {
        if (!val) return '';
        var d = new Date(val + 'T00:00:00');
        return d.toLocaleDateString('en-US', { month: 'short', day: '2-digit', year: 'numeric' });
    }

    function validateForm() {
        var name = document.getElementById('<%= txtCourseName.ClientID %>').value.trim();
        var err  = document.getElementById('errCourseName');
        var inp  = document.getElementById('<%= txtCourseName.ClientID %>');
        if (!name) {
            err.classList.add('visible');
            inp.style.borderColor = '#ef4444';
            inp.focus();
            return false;
        }
        err.classList.remove('visible');
        inp.style.borderColor = '';
        return true;
    }

    function discardChanges() {
        window.location.href = 'courselistDashboard.aspx';
    }

    function showToast(msg) {
        var el = document.getElementById('ecdToast');
        if (!el) return;
        el.textContent = msg;
        el.classList.add('visible');
        setTimeout(function () { el.classList.remove('visible'); }, 3200);
    }

    // Close date picker on outside click
    document.addEventListener('click', function (e) {
        var pop = document.getElementById('datePickerPopover');
        var btn = document.getElementById('btnDateDisplay');
        if (dateOpen && !pop.contains(e.target) && !btn.contains(e.target)) {
            toggleDatePicker();
        }
    });

    // Init display from server values on load
    window.addEventListener('DOMContentLoaded', function () {
        updateDateDisplay();
    });
</script>
</asp:Content>
