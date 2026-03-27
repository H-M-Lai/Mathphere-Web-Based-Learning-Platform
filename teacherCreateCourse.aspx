<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="teacherCreateCourse.aspx.cs" Inherits="MathSphere.teacherCreateCourse" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <title>MathSphere - Create New Course</title>
    <link href="https://fonts.googleapis.com" rel="preconnect" />
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect" />
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet" />
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="Styles/teacherCreateCourse.css" rel="stylesheet" type="text/css" />
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: "#2563eb",
                        secondary: "#facc15",
                        accent: "#84cc16",
                        "math-dark-blue": "#1e3a8a",
                        "background-light": "#f8fafc"
                    },
                    fontFamily: {
                        display: ["Space Grotesk", "sans-serif"],
                        body: ["Space Grotesk", "sans-serif"]
                    }
                }
            }
        };
    </script>
</head>
<body class="min-h-screen bg-background-light font-body text-slate-800">
<form id="form1" runat="server">

    <asp:HiddenField ID="hdnStartDate" runat="server" />
    <asp:HiddenField ID="hdnEndDate" runat="server" />
    <asp:HiddenField ID="hdnAutoArchive" runat="server" Value="true" />
    <asp:HiddenField ID="hdnStatus" runat="server" Value="Draft" />

    <div class="relative min-h-screen overflow-hidden">
        <div class="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_rgba(59,130,246,0.12),_transparent_28%),radial-gradient(circle_at_bottom_left,_rgba(250,204,21,0.16),_transparent_24%),linear-gradient(to_bottom,_rgba(255,255,255,0.96),_rgba(248,250,252,1))]"></div>
        <div class="pointer-events-none absolute inset-0 math-grid opacity-40"></div>

        <div class="relative mx-auto flex min-h-screen max-w-7xl items-center px-4 py-8 lg:px-8">
            <div class="grid w-full gap-8 xl:grid-cols-[1.05fr_0.95fr]">

                <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 p-8 shadow-[0_24px_60px_rgba(30,58,138,0.08)] lg:p-10">
                    <div class="absolute -right-12 -top-12 size-44 rounded-full bg-blue-100/70 blur-3xl"></div>
                    <div class="absolute bottom-0 left-0 h-36 w-40 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
                    <div class="relative flex h-full flex-col justify-between gap-10">
                        <div class="space-y-8">
                            <div class="flex items-center justify-between gap-4">
                                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                                    <span class="material-symbols-outlined text-sm fill-icon">library_books</span>
                                    Course builder
                                </div>
                                <button type="button"
                                    onclick="window.location.href='courselistDashboard.aspx'"
                                    class="inline-flex items-center gap-2 rounded-full border border-gray-200 bg-white px-4 py-2 text-[11px] font-black uppercase tracking-[0.2em] text-gray-500 transition-all hover:border-blue-100 hover:text-blue-600">
                                    <span class="material-symbols-outlined text-base">arrow_back</span>
                                    Back to courses
                                </button>
                            </div>

                            <div class="space-y-4">
                                <h1 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">
                                    Create a course shell your students can grow into.
                                </h1>
                                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                                    Set up the course identity, define its schedule, and launch it with a structure that matches the newer teacher workspace.
                                </p>
                            </div>

                            <div class="grid gap-4 sm:grid-cols-3">
                                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Step 1</p>
                                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Name and describe the course</p>
                                </div>
                                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Step 2</p>
                                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Set the validity window</p>
                                </div>
                                <div class="rounded-[1.75rem] border border-white/70 bg-gray-50/90 px-5 py-4 shadow-sm">
                                    <p class="text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Step 3</p>
                                    <p class="mt-2 text-sm font-bold text-math-dark-blue">Launch and continue building</p>
                                </div>
                            </div>
                        </div>

                        <div class="grid gap-4 sm:grid-cols-2">
                            <div class="rounded-[2rem] border border-blue-100 bg-blue-50/80 p-6 shadow-sm">
                                <div class="flex items-center gap-3">
                                    <div class="flex size-12 items-center justify-center rounded-2xl bg-white text-blue-600 shadow-sm">
                                        <span class="material-symbols-outlined text-2xl">menu_book</span>
                                    </div>
                                    <div>
                                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-blue-500">Preview ID</p>
                                        <p id="previewIdCard" class="text-sm font-bold text-math-dark-blue">Ready to assign</p>
                                    </div>
                                </div>
                            </div>
                            <div class="rounded-[2rem] border border-yellow-100 bg-yellow-50/80 p-6 shadow-sm">
                                <div class="flex items-center gap-3">
                                    <div class="flex size-12 items-center justify-center rounded-2xl bg-white text-yellow-500 shadow-sm">
                                        <span class="material-symbols-outlined text-2xl">calendar_month</span>
                                    </div>
                                    <div>
                                        <p class="text-[11px] font-black uppercase tracking-[0.24em] text-yellow-600">Schedule</p>
                                        <p class="text-sm font-bold text-math-dark-blue">Launch now, then manage visibility with validity dates.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="rounded-[2.75rem] border border-white/70 bg-white/95 p-8 shadow-[0_24px_60px_rgba(15,23,42,0.10)] lg:p-10">
                    <div class="space-y-8">
                        <div class="space-y-3">
                            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                                <span class="material-symbols-outlined text-sm fill-icon">edit_square</span>
                                New course setup
                            </div>
                            <h2 class="text-3xl font-black tracking-tight text-math-dark-blue">Build the essentials first</h2>
                            <p class="text-sm font-bold leading-6 text-gray-500">
                                This form creates the course record first. You can add modules, assessments, and settings right after launch.
                            </p>
                        </div>

                        <asp:Panel ID="pnlError" runat="server" Visible="false"
                            CssClass="rounded-[1.75rem] border border-red-200 bg-red-50/90 px-5 py-4 shadow-sm">
                            <div class="flex items-start gap-3">
                                <span class="material-symbols-outlined text-red-500 text-xl">error</span>
                                <asp:Label ID="lblError" runat="server" CssClass="text-sm font-bold leading-6 text-red-600"></asp:Label>
                            </div>
                        </asp:Panel>

                        <div class="space-y-5">
                            <div>
                                <label class="mb-2 ml-1 block text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Course Name</label>
                                <asp:TextBox ID="txtCourseName" runat="server"
                                    CssClass="w-full rounded-[1.75rem] border border-gray-200 bg-gray-50 px-5 py-4 font-bold text-math-dark-blue transition-all placeholder:text-gray-400 focus:border-blue-300 focus:bg-white focus:ring-4 focus:ring-blue-100"
                                    placeholder="e.g. Advanced Calculus II"
                                    MaxLength="100"></asp:TextBox>
                            </div>

                            <div>
                                <label class="mb-2 ml-1 block text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">
                                    Course ID
                                    <span class="ml-1 normal-case tracking-normal font-medium text-gray-400">(auto-generated)</span>
                                </label>
                                <div class="flex items-center gap-3 rounded-[1.75rem] border border-dashed border-blue-200 bg-blue-50/60 px-5 py-4 text-sm font-bold text-blue-700">
                                    <span class="material-symbols-outlined text-lg text-blue-500">auto_awesome</span>
                                    <asp:Literal ID="litPreviewId" runat="server" Text="Will be assigned on creation (e.g. C003)"></asp:Literal>
                                </div>
                            </div>

                            <div>
                                <label class="mb-2 ml-1 block text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Course Description</label>
                                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4"
                                    CssClass="w-full resize-none rounded-[1.75rem] border border-gray-200 bg-gray-50 px-5 py-4 font-bold text-math-dark-blue transition-all placeholder:text-gray-400 focus:border-blue-300 focus:bg-white focus:ring-4 focus:ring-blue-100"
                                    placeholder="Describe the course objectives and curriculum highlights..."
                                    MaxLength="500"></asp:TextBox>
                            </div>

                            <div class="rounded-[1.75rem] border border-gray-100 bg-gray-50/70 p-4">
                                <button type="button" onclick="openValidityModal()"
                                    class="flex w-full items-center gap-3 rounded-[1.5rem] border border-blue-100 bg-white px-5 py-4 text-left text-sm font-black uppercase tracking-[0.22em] text-math-dark-blue transition-all hover:border-blue-200 hover:bg-blue-50/60">
                                    <span class="material-symbols-outlined text-blue-600 text-xl" style="font-variation-settings:'FILL' 1">calendar_month</span>
                                    <span>Set Course Validity</span>
                                    <span id="validityBadge"
                                        class="ml-auto hidden rounded-full border border-green-200 bg-green-50 px-3 py-1 text-[10px] font-black uppercase tracking-[0.18em] text-green-600 whitespace-nowrap">Dates set</span>
                                </button>
                            </div>

                            <div class="space-y-3 pt-2">
                                <asp:Button ID="btnLaunchCourse" runat="server" Text="Launch Course"
                                    OnClick="btnLaunchCourse_Click"
                                    OnClientClick="return clientValidate();"
                                    CssClass="w-full rounded-full border border-blue-100 bg-blue-50 px-6 py-4 text-sm font-black uppercase tracking-[0.24em] text-blue-600 transition-all hover:border-blue-200 hover:bg-blue-100 cursor-pointer" />

                                <div class="relative flex items-center py-1">
                                    <div class="flex-grow border-t border-gray-200"></div>
                                    <span class="mx-4 flex-shrink text-[10px] font-black uppercase tracking-[0.24em] text-gray-400">Or</span>
                                    <div class="flex-grow border-t border-gray-200"></div>
                                </div>

                                <asp:Button ID="btnDiscard" runat="server" Text="Discard Draft"
                                    OnClientClick="window.location.href='courselistDashboard.aspx'; return false;"
                                    CssClass="w-full rounded-full border border-gray-200 bg-gray-50 px-6 py-4 text-xs font-black uppercase tracking-[0.24em] text-gray-500 transition-all hover:bg-white cursor-pointer" />
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>

    <div id="validityModalOverlay"
         class="fixed inset-0 z-[200] hidden items-center justify-center p-4 bg-[#1e3a8a]/20 backdrop-blur-md">
        <div class="w-full max-w-lg overflow-hidden rounded-[2.5rem] border border-white/70 bg-white/95 shadow-[0_24px_60px_rgba(15,23,42,0.14)]">
            <div class="p-8 pb-0 text-center">
                <div class="mx-auto mb-4 flex size-16 items-center justify-center rounded-2xl bg-yellow-50">
                    <span class="material-symbols-outlined text-4xl text-yellow-500" style="font-variation-settings:'FILL' 1">event_available</span>
                </div>
                <h3 class="text-3xl font-black tracking-tight text-math-dark-blue">Set Course Validity</h3>
                <p id="modalCourseName" class="mt-1 text-xs font-bold uppercase tracking-[0.24em] text-gray-400">New Course</p>
            </div>

            <div class="space-y-6 p-8">
                <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div class="space-y-2">
                        <label class="ml-1 block text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">Start Date</label>
                        <div class="relative">
                            <span class="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-blue-600 text-xl">calendar_today</span>
                            <input type="date" id="modalStartDate"
                                class="w-full rounded-[1.5rem] border border-gray-200 bg-gray-50 py-4 pl-12 pr-4 font-bold text-math-dark-blue transition-all focus:border-blue-300 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-100" />
                        </div>
                    </div>
                    <div class="space-y-2">
                        <label class="ml-1 block text-[11px] font-black uppercase tracking-[0.24em] text-gray-400">End Date</label>
                        <div class="relative">
                            <span class="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-blue-600 text-xl">calendar_month</span>
                            <input type="date" id="modalEndDate"
                                class="w-full rounded-[1.5rem] border border-gray-200 bg-gray-50 py-4 pl-12 pr-4 font-bold text-math-dark-blue transition-all focus:border-blue-300 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-100" />
                        </div>
                    </div>
                </div>

                <div class="flex items-center justify-between rounded-[1.5rem] border border-gray-100 bg-gray-50 p-4">
                    <div>
                        <p class="text-sm font-black uppercase tracking-[0.16em] text-math-dark-blue">Automatic Archiving</p>
                        <p class="text-[10px] font-bold uppercase tracking-[0.24em] text-gray-400">Archive the course after the end date</p>
                    </div>
                    <div onclick="toggleModalArchive()" class="cursor-pointer select-none">
                        <div id="modalToggleTrack"
                             class="relative h-[28px] w-[52px] rounded-full transition-colors duration-200"
                             style="background:#84cc16;">
                            <div id="modalToggleThumb"
                                 class="absolute top-[3px] left-[3px] h-[22px] w-[22px] rounded-full bg-white shadow transition-transform duration-200"
                                 style="transform:translateX(24px);"></div>
                        </div>
                    </div>
                </div>

                <div id="modalDateError"
                     class="hidden rounded-xl bg-red-50 p-3 text-center text-xs font-bold uppercase tracking-[0.22em] text-red-500">
                    End date must be after start date.
                </div>
            </div>

            <div class="flex flex-col gap-3 p-8 pt-0">
                <button type="button" onclick="saveValidityModal()"
                    class="w-full rounded-full border border-blue-100 bg-blue-50 px-6 py-4 text-sm font-black uppercase tracking-[0.24em] text-blue-600 transition-all hover:border-blue-200 hover:bg-blue-100">
                    Save Validity
                </button>
                <button type="button" onclick="closeValidityModal()"
                    class="w-full rounded-full border border-gray-200 bg-gray-50 px-6 py-4 text-xs font-black uppercase tracking-[0.24em] text-gray-500 transition-all hover:bg-white">
                    Cancel
                </button>
            </div>
        </div>
    </div>

</form>

<script type="text/javascript">
    var modalArchiveOn = true;

    function openValidityModal() {
        var nameInput = document.getElementById('<%= txtCourseName.ClientID %>');
        var label = document.getElementById('modalCourseName');
        label.textContent = (nameInput && nameInput.value.trim())
            ? nameInput.value.trim() : 'New Course';

        var sd = document.getElementById('<%= hdnStartDate.ClientID %>').value;
        var ed = document.getElementById('<%= hdnEndDate.ClientID %>').value;
        var arch = document.getElementById('<%= hdnAutoArchive.ClientID %>').value;

        document.getElementById('modalStartDate').value =
            sd || new Date().toISOString().split('T')[0];
        document.getElementById('modalEndDate').value = ed || '';

        modalArchiveOn = (arch !== 'false');
        renderModalToggle();

        document.getElementById('modalDateError').classList.add('hidden');

        var overlay = document.getElementById('validityModalOverlay');
        overlay.classList.remove('hidden');
        overlay.classList.add('flex');
    }

    function closeValidityModal() {
        var overlay = document.getElementById('validityModalOverlay');
        overlay.classList.add('hidden');
        overlay.classList.remove('flex');
    }

    function toggleModalArchive() {
        modalArchiveOn = !modalArchiveOn;
        renderModalToggle();
    }

    function renderModalToggle() {
        var track = document.getElementById('modalToggleTrack');
        var thumb = document.getElementById('modalToggleThumb');
        if (modalArchiveOn) {
            track.style.background = '#84cc16';
            thumb.style.transform = 'translateX(24px)';
        } else {
            track.style.background = '#d1d5db';
            thumb.style.transform = 'translateX(0)';
        }
    }

    function saveValidityModal() {
        var start = document.getElementById('modalStartDate').value;
        var end = document.getElementById('modalEndDate').value;
        var errEl = document.getElementById('modalDateError');

        if (start && end && new Date(end) <= new Date(start)) {
            errEl.classList.remove('hidden');
            return;
        }
        errEl.classList.add('hidden');

        var status = 'Draft';
        if (start) {
            var sd = new Date(start);
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            if (sd <= today) status = 'Active';
        }

        document.getElementById('<%= hdnStartDate.ClientID %>').value = start;
        document.getElementById('<%= hdnEndDate.ClientID %>').value = end;
        document.getElementById('<%= hdnAutoArchive.ClientID %>').value = modalArchiveOn ? 'true' : 'false';
        document.getElementById('<%= hdnStatus.ClientID %>').value = status;

        var badge = document.getElementById('validityBadge');
        if (start || end) {
            var label = start || 'Start pending';
            if (end) label += ' to ' + end;
            badge.textContent = label;
            badge.classList.remove('hidden');
        } else {
            badge.classList.add('hidden');
        }

        closeValidityModal();
    }

    document.getElementById('validityModalOverlay').addEventListener('click', function (e) {
        if (e.target === this) closeValidityModal();
    });

    function clientValidate() {
        var name = document.getElementById('<%= txtCourseName.ClientID %>').value.trim();
        if (!name) {
            alert('Please enter a Course Name.');
            return false;
        }
        var ed = document.getElementById('<%= hdnEndDate.ClientID %>').value;
        if (!ed) {
            alert('Please set the Course Validity (end date) before launching.');
            return false;
        }
        return true;
    }

    document.addEventListener('DOMContentLoaded', function () {
        var preview = document.getElementById('<%= litPreviewId.ClientID %>');
        var previewCard = document.getElementById('previewIdCard');
        if (preview && previewCard) {
            previewCard.textContent = preview.textContent;
        }

        var existingStart = document.getElementById('<%= hdnStartDate.ClientID %>').value;
        var existingEnd = document.getElementById('<%= hdnEndDate.ClientID %>').value;
        if (existingStart || existingEnd) {
            var badge = document.getElementById('validityBadge');
            var label = existingStart || 'Start pending';
            if (existingEnd) label += ' to ' + existingEnd;
            badge.textContent = label;
            badge.classList.remove('hidden');
        }
    });
</script>
</body>
</html>