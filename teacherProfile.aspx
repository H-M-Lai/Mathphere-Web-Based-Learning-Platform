<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
         CodeBehind="teacherProfile.aspx.cs" Inherits="MathSphere.teacherProfile" %>

<%-- Title --%>
<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    Teacher Profile — MathSphere
</asp:Content>

<%-- Head (page-specific styles) --%>
<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Styles/teacherProfile.css") %>" rel="stylesheet" />
    <style>
        .btn-3d-green {
            background: #84cc16;
            box-shadow: 0 10px 24px rgba(132,204,22,.22);
            transition: transform .18s ease, box-shadow .18s ease, filter .18s ease;
        }
        .btn-3d-green:hover  { transform: translateY(-2px); box-shadow: 0 14px 30px rgba(132,204,22,.28); filter: brightness(.98); }
        .btn-3d-green:active { transform: translateY(0); box-shadow: 0 8px 18px rgba(132,204,22,.22); }

        .btn-3d-blue {
            background: #2563eb;
            box-shadow: 0 10px 24px rgba(37,99,235,.22);
            transition: transform .18s ease, box-shadow .18s ease, filter .18s ease;
        }
        .btn-3d-blue:hover  { transform: translateY(-2px); box-shadow: 0 14px 30px rgba(37,99,235,.28); filter: brightness(.98); }
        .btn-3d-blue:active { transform: translateY(0); box-shadow: 0 8px 18px rgba(37,99,235,.22); }

        #avatarPreviewWrap {
            position: relative;
            width: 192px;
            height: 192px;
        }
        #avatarPreviewWrap img {
            width: 100%; height: 100%; object-fit: cover; border-radius: 9999px;
            border: 8px solid #ffffff;
            box-shadow: 0 16px 36px rgba(30,58,138,.12);
        }
        #avatarDropZone {
            position: absolute;
            inset: 0;
            border-radius: 9999px;
            background: rgba(30,58,138,0.55);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 11px;
            font-weight: 900;
            letter-spacing: .08em;
            text-transform: uppercase;
            opacity: 0;
            transition: opacity .2s;
            cursor: pointer;
        }
        #avatarPreviewWrap:hover #avatarDropZone { opacity: 1; }

        #avatarModalOverlay {
            position: fixed;
            inset: 0;
            z-index: 10000;
            align-items: center;
            justify-content: center;
            padding: 1rem;
            background: rgba(15,34,87,0.55);
            backdrop-filter: blur(6px);
        }
        #avatarModalOverlay.hidden { display: none !important; }
        #avatarModalOverlay:not(.hidden) { display: flex; }

        #avatarModalCard {
            background: #fff;
            border-radius: 2rem;
            border: 1px solid rgba(255,255,255,.72);
            box-shadow: 0 28px 60px rgba(30,58,138,.18);
            width: 100%;
            max-width: 430px;
            overflow: hidden;
        }
    </style>
</asp:Content>

<%-- Main content --%>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- AVATAR UPLOAD MODAL  (pure client-side show/hide + postback) --%>
    <div id="avatarModalOverlay" class="hidden">
        <div id="avatarModalCard">

            <%-- Header --%>
            <div class="bg-math-dark-blue px-6 py-5 border-b-4 border-math-dark-blue flex items-center gap-3">
                <div class="w-11 h-11 bg-primary rounded-2xl flex items-center justify-center border-2 border-white shadow-[3px_3px_0px_0px_#d4b105] flex-shrink-0">
                    <span class="material-symbols-outlined text-math-dark-blue text-2xl fill-icon">photo_camera</span>
                </div>
                <h2 class="text-lg font-black tracking-tight text-white uppercase">Change Avatar</h2>
            </div>

            <div class="p-6 space-y-5">

                <%-- Preview area --%>
                <div class="flex justify-center">
                    <div class="relative w-36 h-36 rounded-full overflow-hidden border-4 border-primary shadow-lg bg-slate-100">
                        <img id="avatarLocalPreview"
                             src="<%= ResolveUrl("~/Image/default-avatar.png") %>"
                             class="w-full h-full object-cover" alt="Preview" />
                        <div class="absolute inset-0 flex items-center justify-center bg-slate-900/40 opacity-0 hover:opacity-100 transition-opacity cursor-pointer rounded-full"
                             onclick="document.getElementById('hiddenFileInput').click()">
                            <span class="material-symbols-outlined text-white text-3xl fill-icon">add_a_photo</span>
                        </div>
                    </div>
                </div>

                <%-- Drop zone / file picker --%>
                <div id="avatarDropArea"
                     class="border-2 border-dashed border-slate-300 rounded-2xl p-6 text-center cursor-pointer hover:border-math-blue hover:bg-blue-50 transition-all"
                     onclick="document.getElementById('hiddenFileInput').click()"
                     ondragover="event.preventDefault(); this.classList.add('border-math-blue','bg-blue-50')"
                     ondragleave="this.classList.remove('border-math-blue','bg-blue-50')"
                     ondrop="handleAvatarDrop(event)">
                    <span class="material-symbols-outlined text-slate-400 text-4xl fill-icon mb-2 block">cloud_upload</span>
                    <p class="text-xs font-black text-slate-500 uppercase tracking-widest">Click or drag &amp; drop</p>
                    <p class="text-[10px] font-bold text-slate-400 mt-1">JPG, PNG, GIF — max 2 MB</p>
                    <p id="avatarFileName" class="text-[10px] font-bold text-math-blue mt-2 hidden"></p>
                </div>

                <%-- Hidden real file input --%>
                <input type="file" id="hiddenFileInput" accept=".jpg,.jpeg,.png,.gif,.webp"

                       style="display:none"
                       onchange="previewAvatarFile(this)" />

                <%-- Hidden ASP file upload (submitted via JS) --%>
                <asp:FileUpload ID="fuAvatar" runat="server" style="display:none" accept=".jpg,.jpeg,.png,.gif,.webp" />

                <%-- Error strip --%>
                <div id="avatarUploadError" class="hidden bg-red-50 border-2 border-red-200 rounded-2xl p-3 text-xs font-bold text-red-600"></div>

                <div class="flex flex-col gap-3">
                    <asp:Button ID="btnSaveAvatar" runat="server" Text="Save Avatar"
                        OnClick="btnSaveAvatar_Click"
                        OnClientClick="return prepareAvatarUpload();"
                        CssClass="btn-3d-blue w-full text-white font-black py-4 rounded-2xl text-sm tracking-widest uppercase border-0 cursor-pointer" />
                    <button type="button" onclick="closeAvatarModal()"
                        class="w-full bg-white border-2 border-slate-200 hover:bg-slate-50 text-slate-500 font-black py-3 rounded-2xl text-xs tracking-widest uppercase transition-colors cursor-pointer">
                        Cancel
                    </button>
                </div>

            </div>
        </div>
    </div>
    <%-- PAGE HEADER --%>
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">badge</span>
                    Teacher identity
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">
                    Teacher Profile
                </h2>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Manage your MathSphere identity, update your account details, and keep track of your classroom impact in one place.
                </p>
            </div>
        </div>
    </section>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">

        <%-- LEFT: Profile card --%>
        <div class="lg:col-span-8 space-y-8">
            <div class="relative overflow-hidden rounded-[2.5rem] border border-white/70 bg-white/90 p-8 md:p-10 shadow-[0_22px_52px_rgba(30,58,138,0.10)]">
                <div class="absolute -right-14 -top-14 size-40 rounded-full bg-blue-100/70 blur-3xl pointer-events-none"></div><div class="absolute -left-10 bottom-0 size-32 rounded-full bg-yellow-100/60 blur-2xl pointer-events-none"></div>

                <div class="relative z-10 flex flex-col gap-10 xl:flex-row xl:items-start">

                    <%-- Avatar column --%>
                    <div class="flex flex-col items-center gap-6 xl:w-[220px] xl:pt-2">
                        <div id="avatarPreviewWrap">
                            <asp:Image ID="imgProfileLarge" runat="server"
                                ImageUrl="~/Image/default-avatar.png"
                                AlternateText="Profile Photo"
                                CssClass="w-full h-full object-cover" />
                            <div id="avatarDropZone" onclick="openAvatarModal()">
                                <span class="material-symbols-outlined text-3xl fill-icon mb-1">add_a_photo</span>
                                <span>Change</span>
                            </div>
                        </div>
                        <asp:Button ID="btnChangeAvatar" runat="server" Text="Change Avatar"
                            OnClientClick="openAvatarModal(); return false;"
                            CssClass="btn-3d-blue text-white font-black py-4 px-8 rounded-2xl text-sm tracking-widest uppercase border-0 cursor-pointer" />
                    </div>

                    <%-- Details column --%>
                    <div class="flex-1 space-y-10">

                        <div>
                            <div class="flex items-center gap-3 mb-8">
                                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-math-blue shadow-sm">
                                    <span class="material-symbols-outlined text-2xl fill-icon">school</span>
                                </div>
                                <h3 class="text-2xl font-black tracking-tight text-math-dark-blue uppercase">Account Details</h3>
                            </div>

                            <asp:Panel ID="pnlSaveResult" runat="server" Visible="false"
                                CssClass="mb-6 rounded-2xl px-4 py-3 flex items-center gap-2">
                                <asp:Label ID="lblSaveResult" runat="server" CssClass="font-bold text-sm"></asp:Label>
                            </asp:Panel>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                                <div class="space-y-2">
                                    <label class="text-xs font-black text-math-dark-blue uppercase tracking-widest ml-1">Full Name</label>
                                    <asp:TextBox ID="txtFullName" runat="server"
                                        CssClass="w-full rounded-2xl border border-gray-200 bg-gray-50/90 px-5 py-4 font-bold text-math-dark-blue transition-all focus:outline-none focus:border-math-blue focus:bg-white"
                                        placeholder="e.g. Dr. Sarah Mitchell" MaxLength="100"></asp:TextBox>
                                </div>

                                <div class="space-y-2">
                                    <label class="text-xs font-black text-math-dark-blue uppercase tracking-widest ml-1">School Email</label>
                                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                                        CssClass="w-full rounded-2xl border border-gray-200 bg-gray-50/90 px-5 py-4 font-bold text-math-dark-blue transition-all focus:outline-none focus:border-math-blue focus:bg-white"
                                        placeholder="e.g. teacher@school.edu" MaxLength="150"></asp:TextBox>
                                </div>

                                <div class="md:col-span-2 space-y-2">
                                    <label class="text-xs font-black text-math-dark-blue uppercase tracking-widest ml-1">School Name</label>
                                    <asp:TextBox ID="txtSchoolName" runat="server"
                                        CssClass="w-full rounded-2xl border border-gray-200 bg-gray-50/90 px-5 py-4 font-bold text-math-dark-blue transition-all focus:outline-none focus:border-math-blue focus:bg-white"
                                        placeholder="e.g. West Valley High School" MaxLength="150"></asp:TextBox>
                                </div>

                                <div class="md:col-span-2 pt-4">
                                    <asp:Button ID="btnSaveChanges" runat="server" Text="Save Changes"
                                        OnClick="btnSaveChanges_Click"
                                        CssClass="inline-flex items-center justify-center rounded-2xl bg-primary px-10 py-4 text-sm font-black uppercase tracking-widest text-math-dark-blue shadow-[0_10px_22px_rgba(249,208,6,0.28)] transition-all hover:-translate-y-0.5 hover:shadow-[0_14px_28px_rgba(249,208,6,0.34)] border-0 cursor-pointer" />
                                </div>

                            </div>
                        </div>

                        <%-- Security section --%>
                        <div class="pt-10 border-t border-gray-100">
                            <div class="flex items-center gap-3 mb-6">
                                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-green-50 text-math-green shadow-sm">
                                    <span class="material-symbols-outlined text-2xl fill-icon">security</span>
                                </div>
                                <h3 class="text-2xl font-black tracking-tight text-math-dark-blue uppercase">Security</h3>
                            </div>
                            <p class="text-slate-500 font-medium mb-8 max-w-md">
                                Protect your educator account by regularly updating your credentials.
                                A secure reset link will be sent to your registered email.
                            </p>
                            <div class="flex flex-wrap gap-4">
                                <asp:Button ID="btnResetPassword" runat="server" Text="Reset Password"
                                    OnClick="btnResetPassword_Click"
                                    CssClass="btn-3d-green text-white font-black py-4 px-10 rounded-2xl text-sm tracking-widest uppercase border-0 cursor-pointer" />
                                <asp:Button ID="btnLogout" runat="server" Text="Logout"
                                    OnClick="btnLogout_Click"
                                    CssClass="btn-3d-blue text-white font-black py-4 px-10 rounded-2xl text-sm tracking-widest uppercase border-0 cursor-pointer" />
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <%-- RIGHT: Teaching Impact --%>
        <div class="lg:col-span-4 space-y-5">
            <div class="mb-2 flex items-center gap-3 rounded-[1.75rem] border border-white/70 bg-white/90 px-5 py-4 shadow-[0_16px_34px_rgba(30,58,138,0.06)]">
                <span class="material-symbols-outlined text-math-blue text-2xl fill-icon">insights</span>
                <h3 class="text-xl font-black tracking-tight text-math-dark-blue uppercase">Teaching Impact</h3>
            </div>
            <div class="space-y-4">
                <asp:Repeater ID="rptImpactCards" runat="server" OnItemDataBound="rptImpactCards_ItemDataBound">
                    <ItemTemplate>
                        <asp:Literal ID="litImpactCard" runat="server"></asp:Literal>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

    </div>

</asp:Content>

<%-- Scripts --%>
<asp:Content ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    // Avatar modal
    function openAvatarModal() {
        document.getElementById('avatarModalOverlay').classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }

    function closeAvatarModal() {
        document.getElementById('avatarModalOverlay').classList.add('hidden');
        document.body.style.overflow = '';
        document.getElementById('avatarFileName').classList.add('hidden');
        document.getElementById('avatarFileName').textContent = '';
        document.getElementById('avatarUploadError').classList.add('hidden');
        var localPrev = document.getElementById('avatarLocalPreview');
        if (localPrev) localPrev.src = '<%= ResolveUrl("~/Image/default-avatar.png") %>';
    }

    function previewAvatarFile(input) {
        var file = input.files[0];
        if (!file) return;

        var err = document.getElementById('avatarUploadError');
        if (file.size > 2 * 1024 * 1024) {
            err.textContent = 'File is too large. Maximum size is 2 MB.';
            err.classList.remove('hidden');
            input.value = '';
            return;
        }
        var allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        if (!allowedTypes.includes(file.type)) {
            err.textContent = 'Invalid file type. Please upload JPG, PNG, GIF, or WEBP only.';
            err.classList.remove('hidden');
            input.value = '';
            return;
        }
        err.classList.add('hidden');

        var fn = document.getElementById('avatarFileName');
        fn.textContent = file.name;
        fn.classList.remove('hidden');

        var reader = new FileReader();
        reader.onload = function (e) {
            document.getElementById('avatarLocalPreview').src = e.target.result;
        };
        reader.readAsDataURL(file);
    }

    function handleAvatarDrop(event) {
        event.preventDefault();
        var zone = document.getElementById('avatarDropArea');
        zone.classList.remove('border-math-blue', 'bg-blue-50');
        var files = event.dataTransfer.files;
        if (files.length) {
            var dt = new DataTransfer();
            dt.items.add(files[0]);
            var inp = document.getElementById('hiddenFileInput');
            inp.files = dt.files;
            previewAvatarFile(inp);
        }
    }

    function prepareAvatarUpload() {
        var hiddenInput = document.getElementById('hiddenFileInput');
        if (!hiddenInput || !hiddenInput.files.length) {
            var err = document.getElementById('avatarUploadError');
            err.textContent = 'Please choose an image first.';
            err.classList.remove('hidden');
            return false;
        }
        var aspUpload = document.getElementById('<%= fuAvatar.ClientID %>');
        var dt = new DataTransfer();
        dt.items.add(hiddenInput.files[0]);
        aspUpload.files = dt.files;
        return true;
    }
</script>
</asp:Content>
