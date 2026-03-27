<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="Assignment.StudentProfile" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Profile • MathSphere
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    @keyframes cardIn {
        from { opacity: 0; transform: translateY(20px) scale(.98); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }
    .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }
</style>
</asp:Content>
<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <asp:FileUpload ID="fuAvatar" runat="server"
        Style="position:absolute;left:-9999px;width:1px;height:1px;opacity:0;"
        onchange="MS.onAvatarFileChosen(this)" />

    <asp:HiddenField ID="hfAvatarOriginal" runat="server" />

    <div class="page-enter">
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative space-y-3 max-w-3xl">
            <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                <span class="material-symbols-outlined text-sm fill-icon">badge</span>
                Identity & progress
            </div>
            <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Student Profile</h2>
            <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">Manage your account details, update your profile, and keep track of your learning journey in one place.</p>
        </div>
    </section>

    <asp:ValidationSummary ID="vsProfile" runat="server"
        ValidationGroup="ProfileGroup" DisplayMode="BulletList"
        CssClass="mb-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-red-700 font-semibold text-sm"
        HeaderText="Please fix the following:" />

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">

        <div class="lg:col-span-8 space-y-8">
            <section class="bg-white/70 backdrop-blur-md rounded-[2.25rem] p-8 border border-gray-100 shadow-[0_12px_30px_rgba(0,0,0,0.06)] hover:shadow-[0_18px_45px_rgba(0,0,0,0.08)] hover:-translate-y-[1px] transition-all">
                <div class="flex flex-col md:flex-row gap-10 items-center md:items-start">

                    <%-- Avatar --%>
                    <div class="flex flex-col items-center gap-4 shrink-0">
                        <div class="size-44 rounded-[2.25rem] border border-gray-100 p-2 shadow-inner bg-white/60 relative group overflow-hidden"
                             title="Click to change avatar"
                             onclick="document.getElementById('<%= fuAvatar.ClientID %>').click();"
                             style="cursor:pointer">
                            <asp:Image ID="imgMainAvatar" runat="server"
                                CssClass="w-full h-full object-cover rounded-[2rem]"
                                ImageUrl="~/Image/default-avatar.png" AlternateText="Profile Avatar" />
                            <div class="absolute inset-0 bg-math-dark-blue/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity rounded-[2rem]">
                                <span class="material-symbols-outlined text-white text-4xl">photo_camera</span>
                            </div>
                        </div>

                        <asp:Label ID="lblAvatarHint" runat="server" Visible="false"
                            CssClass="text-[10px] font-black uppercase tracking-widest text-amber-500 text-center">
                            Preview ready - click Save to upload.
                        </asp:Label>

                        <div class="flex gap-3 w-full max-w-[260px]">
                            <asp:LinkButton ID="btnChangeAvatar" runat="server"
                                CssClass="flex-1 inline-flex items-center justify-center gap-2 bg-math-blue text-white font-black px-3 py-3 rounded-2xl shadow-lg shadow-math-blue/20 hover:bg-math-dark-blue transition-all active:scale-[0.99] uppercase tracking-widest text-xs opacity-40 pointer-events-none select-none"
                                OnClick="btnChangeAvatar_Click" CausesValidation="false">
                                <span class="material-symbols-outlined text-base">save</span>Save
                            </asp:LinkButton>
                            <button type="button" id="btnCancelAvatarEl" onclick="MS.cancelAvatarPreview()"
                                class="flex-1 inline-flex items-center justify-center gap-2 bg-white/80 border border-gray-200 text-gray-500 font-black px-3 py-3 rounded-2xl shadow-sm hover:bg-white hover:text-math-dark-blue transition-all active:scale-[0.99] uppercase tracking-widest text-xs opacity-40 pointer-events-none select-none cursor-not-allowed">
                                <span class="material-symbols-outlined text-base">close</span>Cancel
                            </button>
                        </div>
                    </div>

                    <%-- Form fields --%>
                    <div class="flex-1 w-full space-y-10">
                        <div>
                            <div class="flex items-center gap-3 mb-6">
                                <div class="size-11 rounded-2xl bg-math-blue/10 border border-math-blue/10 flex items-center justify-center">
                                    <span class="material-symbols-outlined text-math-blue fill-icon">badge</span>
                                </div>
                                <div>
                                    <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Account</p>
                                    <h3 class="text-2xl font-black tracking-tight text-math-dark-blue">Profile Details</h3>
                                </div>
                            </div>

                            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="block mb-4 text-math-green font-black text-sm" />

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div class="space-y-2">
                                    <label class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 ml-1">Full Name</label>
                                    <asp:TextBox ID="txtFullName" runat="server" CssClass="w-full bg-white/70 border border-gray-200 rounded-2xl px-4 py-3 font-semibold text-math-dark-blue placeholder:text-gray-400 shadow-sm transition-all focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10" />
                                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ValidationGroup="ProfileGroup" ErrorMessage="Full Name is required." CssClass="block text-red-500 text-sm font-semibold" Display="Dynamic" />
                                </div>
                                <div class="space-y-2">
                                    <label class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 ml-1">School Email</label>
                                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="w-full bg-white/70 border border-gray-200 rounded-2xl px-4 py-3 font-semibold text-math-dark-blue placeholder:text-gray-400 shadow-sm transition-all focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10" />
                                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="ProfileGroup" ErrorMessage="Email is required." CssClass="block text-red-500 text-sm font-semibold" Display="Dynamic" />
                                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="ProfileGroup" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Please enter a valid email address." CssClass="block text-red-500 text-sm font-semibold" Display="Dynamic" />
                                </div>
                                <div class="space-y-2 md:col-span-2">
                                    <label class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 ml-1">School Name</label>
                                    <asp:TextBox ID="txtSchoolName" runat="server" placeholder="e.g., SMK Puchong Utama" CssClass="w-full bg-white/70 border border-gray-200 rounded-2xl px-4 py-3 font-semibold text-math-dark-blue placeholder:text-gray-400 shadow-sm transition-all focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10" />
                                    <asp:RequiredFieldValidator ID="rfvSchool" runat="server" ControlToValidate="txtSchoolName" ValidationGroup="ProfileGroup" ErrorMessage="School Name is required." CssClass="block text-red-500 text-sm font-semibold" Display="Dynamic" />
                                </div>
                                <div class="md:col-span-2 pt-2">
                                    <asp:Button ID="btnSaveChanges" runat="server" Text="Save Changes" OnClick="btnSaveChanges_Click" ValidationGroup="ProfileGroup" CssClass="bg-math-blue text-white font-black px-8 py-3 rounded-2xl hover:bg-math-dark-blue transition-all shadow-lg shadow-math-blue/20 active:scale-[0.99] uppercase tracking-widest text-sm" />
                                </div>
                            </div>
                        </div>

                        <div class="border-t border-gray-100"></div>

                        <div>
                            <div class="flex items-center gap-3 mb-5">
                                <div class="size-11 rounded-2xl bg-math-green/10 border border-math-green/10 flex items-center justify-center">
                                    <span class="material-symbols-outlined text-math-green fill-icon">security</span>
                                </div>
                                <div>
                                    <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Security</p>
                                    <h3 class="text-2xl font-black tracking-tight text-math-dark-blue">Account Protection</h3>
                                </div>
                            </div>
                            <p class="text-sm font-semibold text-gray-500 mb-4">Keep your account secure by updating your password when needed.</p>
                            <div class="flex flex-col md:flex-row gap-3">
                                <asp:LinkButton ID="btnResetPassword" runat="server" OnClick="btnResetPassword_Click" CausesValidation="false"
                                    CssClass="w-full md:w-auto inline-flex items-center justify-center gap-2 bg-math-green text-white font-black px-8 py-3 rounded-2xl uppercase tracking-widest text-sm shadow-lg shadow-math-green/20 hover:brightness-95 transition-all active:scale-[0.99]">
                                    <span class="material-symbols-outlined text-[20px] fill-icon">lock_reset</span>Reset Password
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CausesValidation="false"
                                    CssClass="w-full md:w-auto inline-flex items-center justify-center gap-2 bg-red-500 text-white font-black px-8 py-3 rounded-2xl uppercase tracking-widest text-sm shadow-lg shadow-red-500/20 hover:bg-red-600 transition-all active:scale-[0.99]">
                                    <span class="material-symbols-outlined text-[20px] fill-icon">logout</span>Logout
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <%-- RIGHT COLUMN --%>
        <div class="lg:col-span-4 space-y-8">
            <section class="bg-white/70 backdrop-blur-md rounded-[2.25rem] p-6 border border-gray-100 shadow-[0_12px_30px_rgba(0,0,0,0.06)] hover:shadow-[0_18px_45px_rgba(0,0,0,0.08)] hover:-translate-y-[1px] transition-all">
                <div class="flex items-center gap-3 mb-6">
                    <div class="size-11 rounded-2xl bg-primary/25 border border-primary/30 flex items-center justify-center">
                        <span class="material-symbols-outlined text-math-dark-blue fill-icon">insights</span>
                    </div>
                    <div>
                        <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400">Progress</p>
                        <h3 class="text-xl font-black tracking-tight text-math-dark-blue">Progress Summary</h3>
                    </div>
                </div>

                <div class="grid grid-cols-1 gap-4">
                    <div class="bg-white/60 border border-gray-100 rounded-[2rem] p-5 flex items-center gap-4 shadow-sm hover:-translate-y-[1px] transition-all">
                        <div class="size-14 rounded-2xl bg-math-blue/10 border border-math-blue/10 text-math-blue flex items-center justify-center">
                            <span class="material-symbols-outlined text-3xl fill-icon">stars</span>
                        </div>
                        <div>
                            <div class="text-3xl font-black text-math-dark-blue"><asp:Literal ID="litStatXP" runat="server" /></div>
                            <div class="text-[10px] font-black uppercase tracking-[0.25em] text-gray-400">Total XP</div>
                        </div>
                    </div>
                    <div class="bg-white/60 border border-gray-100 rounded-[2rem] p-5 flex items-center gap-4 shadow-sm hover:-translate-y-[1px] transition-all">
                        <div class="size-14 rounded-2xl bg-primary/25 border border-primary/30 text-math-dark-blue flex items-center justify-center">
                            <span class="material-symbols-outlined text-3xl fill-icon">local_fire_department</span>
                        </div>
                        <div>
                            <div class="text-3xl font-black text-math-dark-blue"><asp:Literal ID="litStatStreak" runat="server" /></div>
                            <div class="text-[10px] font-black uppercase tracking-[0.25em] text-gray-400">Current Streak</div>
                        </div>
                    </div>
                    <div class="bg-white/60 border border-gray-100 rounded-[2rem] p-5 flex items-center gap-4 shadow-sm hover:-translate-y-[1px] transition-all">
                        <div class="size-14 rounded-2xl bg-math-green/10 border border-math-green/10 text-math-green flex items-center justify-center">
                            <span class="material-symbols-outlined text-3xl fill-icon">check_circle</span>
                        </div>
                        <div>
                            <div class="text-3xl font-black text-math-dark-blue"><asp:Literal ID="litStatCourses" runat="server" /></div>
                            <div class="text-[10px] font-black uppercase tracking-[0.25em] text-gray-400">Courses Completed</div>
                        </div>
                    </div>
                    <div class="bg-white/60 border border-gray-100 rounded-[2rem] p-5 flex items-center gap-4 shadow-sm hover:-translate-y-[1px] transition-all">
                        <div class="size-14 rounded-2xl bg-math-dark-blue/10 border border-math-dark-blue/10 text-math-dark-blue flex items-center justify-center">
                            <span class="material-symbols-outlined text-3xl fill-icon">schedule</span>
                        </div>
                        <div>
                            <div class="text-3xl font-black text-math-dark-blue"><asp:Literal ID="litStatTime" runat="server" /></div>
                            <div class="text-[10px] font-black uppercase tracking-[0.25em] text-gray-400">Study Time</div>
                        </div>
                    </div>
                </div>

                <div class="mt-8 relative overflow-hidden rounded-[2.25rem] bg-gradient-to-br from-math-dark-blue via-math-blue to-math-blue text-white p-6 shadow-[0_16px_45px_rgba(37,99,235,0.25)]">
                    <div class="absolute -top-24 -right-24 size-72 rounded-full bg-primary/20 blur-3xl"></div>
                    <div class="absolute -bottom-28 -left-28 size-72 rounded-full bg-white/10 blur-3xl"></div>
                    <div class="relative z-10">
                        <div class="text-[11px] font-black uppercase tracking-[0.25em] text-white/70 mb-1">Weekly Goal</div>
                        <div class="text-xl font-black mb-4"><asp:Literal ID="litGoalName" runat="server" /></div>
                        <div class="h-3 bg-white/20 rounded-full overflow-hidden mb-2">
                            <asp:Panel ID="pnlProgressBar" runat="server" CssClass="h-full bg-primary rounded-full transition-all" Style="width:0%"></asp:Panel>
                        </div>
                        <div class="flex justify-between text-[10px] font-black uppercase tracking-widest text-white/70">
                            <span><asp:Literal ID="litGoalProgressText" runat="server" /></span>
                            <span class="text-primary"><asp:Literal ID="litGoalPercent" runat="server" /></span>
                        </div>
                    </div>
                    <span class="material-symbols-outlined absolute -bottom-4 -right-4 text-8xl opacity-10 rotate-12">trending_up</span>
                </div>
            </section>
        </div>
    </div>

    <script>
        var MS = (function () {
            var avatarImgId = '<%= imgMainAvatar.ClientID %>';
            var fuId = '<%= fuAvatar.ClientID %>';
            var hfOriginalId = '<%= hfAvatarOriginal.ClientID %>';
            var btnSaveId    = '<%= btnChangeAvatar.ClientID %>';
            var btnCancelId  = 'btnCancelAvatarEl';
            var hintId       = '<%= lblAvatarHint.ClientID %>';

            function setButtons(enabled) {
                [btnSaveId, btnCancelId].forEach(function (id) {
                    var el = document.getElementById(id);
                    if (!el) return;
                    if (enabled) {
                        el.classList.remove('opacity-40', 'pointer-events-none', 'select-none', 'cursor-not-allowed');
                        el.classList.add('opacity-100');
                    } else {
                        el.classList.add('opacity-40', 'pointer-events-none', 'select-none');
                        el.classList.remove('opacity-100');
                        if (id === btnCancelId) el.classList.add('cursor-not-allowed');
                    }
                });
            }

            function onAvatarFileChosen(input) {
                var file = input.files && input.files[0];
                if (!file) return;
                var allowed = ['image/png', 'image/jpeg', 'image/gif', 'image/webp'];
                if (allowed.indexOf(file.type) === -1) { alert('Please choose a PNG, JPG, GIF or WEBP image.'); input.value = ''; return; }
                if (file.size > 2 * 1024 * 1024) { alert('Image too large — maximum 2 MB.'); input.value = ''; return; }
                var reader = new FileReader();
                reader.onload = function (e) { var img = document.getElementById(avatarImgId); if (img) img.src = e.target.result; };
                reader.readAsDataURL(file);
                setButtons(true);
                var hint = document.getElementById(hintId); if (hint) hint.style.display = 'block';
            }

            function cancelAvatarPreview() {
                var hf = document.getElementById(hfOriginalId), img = document.getElementById(avatarImgId), fu = document.getElementById(fuId);
                if (img && hf) img.src = hf.value;
                if (fu) fu.value = '';
                setButtons(false);
                var hint = document.getElementById(hintId); if (hint) hint.style.display = 'none';
            }

            setButtons(false);
            return { onAvatarFileChosen: onAvatarFileChosen, cancelAvatarPreview: cancelAvatarPreview };
        })();
    </script>

    </div>
</asp:Content>


