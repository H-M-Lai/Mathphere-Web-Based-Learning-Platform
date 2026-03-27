<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="PostForum.aspx.cs" Inherits="Assignment.PostForum" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Start Discussion
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    @keyframes cardIn {
        from { opacity: 0; transform: translateY(20px) scale(.985); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }

    .page-enter { animation: cardIn .45s cubic-bezier(.22,.61,.36,1) both; }

    .compose-shell {
        background: rgba(255,255,255,.78);
        backdrop-filter: blur(16px);
        border: 1px solid rgba(229,231,235,.9);
        box-shadow: 0 18px 48px rgba(15,23,42,.08);
    }

    .compose-input {
        width: 100%;
        background: rgba(255,255,255,.92);
        border: 1.5px solid #e5e7eb;
        border-radius: 1.4rem;
        color: #1e3a8a;
        font-weight: 700;
        transition: border-color .18s ease, box-shadow .18s ease, background-color .18s ease, transform .18s ease;
    }

    .compose-input:focus {
        outline: none;
        border-color: rgba(37,99,235,.35);
        box-shadow: 0 0 0 4px rgba(37,99,235,.10);
        background: #fff;
    }

    .compose-textarea {
        min-height: 220px;
        resize: vertical;
    }

    .upload-zone {
        border: 2px dashed rgba(37,99,235,.28);
        background: linear-gradient(180deg, rgba(239,246,255,.78) 0%, rgba(255,255,255,.96) 100%);
        transition: border-color .18s ease, background-color .18s ease, transform .18s ease, box-shadow .18s ease;
        cursor: pointer;
    }

    .upload-zone:hover {
        border-color: rgba(30,58,138,.38);
        background: linear-gradient(180deg, rgba(239,246,255,.95) 0%, rgba(255,255,255,1) 100%);
        box-shadow: 0 14px 32px rgba(37,99,235,.08);
    }

    .upload-zone.drag-over {
        border-color: #1e3a8a;
        background: rgba(219,234,254,.9);
        transform: translateY(-1px);
    }

    .label-kicker {
        font-size: 11px;
        font-weight: 900;
        text-transform: uppercase;
        letter-spacing: .25em;
        color: #9ca3af;
        margin-bottom: .85rem;
        display: block;
    }

    .helper-card {
        background: rgba(255,255,255,.78);
        backdrop-filter: blur(14px);
        border: 1px solid rgba(229,231,235,.9);
        box-shadow: 0 12px 30px rgba(15,23,42,.06);
    }
</style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-enter space-y-8">

        <div>
            <a href="Forum.aspx"
               class="inline-flex items-center gap-2 text-math-blue font-black text-xs uppercase tracking-widest no-underline hover:no-underline hover:translate-x-[-4px] transition-transform">
                <span class="material-symbols-outlined text-lg leading-none">arrow_back</span>
                Back to Discussion Feed
            </a>
        </div>
        <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
            <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
            <div class="relative space-y-3 max-w-3xl mx-auto text-center">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">forum</span>
                    Community space
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Start a <span class="text-math-blue">New Discussion</span></h2>
                <p class="max-w-2xl mx-auto text-base font-medium leading-7 text-gray-500 lg:text-lg">Ask a smart question, share a neat shortcut, or start a mathematical conversation your classmates can build on.</p>
            </div>
        </section>

        <div class="grid grid-cols-1 xl:grid-cols-[1fr_320px] gap-8 items-start">

            <div class="compose-shell rounded-[2.5rem] p-8 lg:p-10">

                <asp:ValidationSummary ID="valSummary" runat="server"
                    CssClass="mb-6 p-4 rounded-2xl bg-red-50 border border-red-200 text-red-600 font-semibold text-sm"
                    HeaderText="Please fix the following:" />

                <asp:Label ID="lblError" runat="server" Visible="false"
                    CssClass="block mb-6 p-4 rounded-2xl bg-red-50 border border-red-200 text-red-600 font-semibold text-sm" />

                <div class="space-y-8">

                    <div>
                        <asp:Label runat="server" AssociatedControlID="txtTitle"
                            Text="Discussion Title"
                            CssClass="label-kicker" />
                        <asp:TextBox ID="txtTitle" runat="server"
                            CssClass="compose-input px-6 py-5 text-lg"
                            placeholder="e.g. Is there a fast way to solve simultaneous equations?"
                            MaxLength="200" />
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                            ControlToValidate="txtTitle"
                            ErrorMessage="Discussion title is required."
                            CssClass="text-red-500 text-xs font-bold mt-2 block"
                            Display="Dynamic" />
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-[1fr_220px] gap-6">
                        <div>
                            <asp:Label runat="server" AssociatedControlID="txtContent"
                                Text="Your Question or Idea"
                                CssClass="label-kicker" />
                            <asp:TextBox ID="txtContent" runat="server"
                                TextMode="MultiLine"
                                CssClass="compose-input compose-textarea px-6 py-5 text-base leading-relaxed"
                                placeholder="Give context, show your thinking, or explain what you're stuck on..." />
                            <asp:RequiredFieldValidator ID="rfvContent" runat="server"
                                ControlToValidate="txtContent"
                                ErrorMessage="Post content is required."
                                CssClass="text-red-500 text-xs font-bold mt-2 block"
                                Display="Dynamic" />
                        </div>

                        <div>
                            <asp:Label runat="server" AssociatedControlID="ddlModule"
                                Text="Related Module"
                                CssClass="label-kicker" />
                            <div class="relative">
                                <asp:DropDownList ID="ddlModule" runat="server"
                                    CssClass="compose-input px-5 py-4 text-sm appearance-none cursor-pointer pr-12">
                                </asp:DropDownList>
                                <span class="pointer-events-none material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 text-gray-400">expand_more</span>
                            </div>
                            <asp:RequiredFieldValidator ID="rfvModule" runat="server"
                                ControlToValidate="ddlModule"
                                InitialValue=""
                                ErrorMessage="Please select a module."
                                CssClass="text-red-500 text-xs font-bold mt-2 block"
                                Display="Dynamic" />
                        </div>
                    </div>

                    <div>
                        <p class="label-kicker">
                            Attach Image
                            <span class="text-gray-400 font-semibold normal-case text-[11px] tracking-normal ml-2">Optional · JPG, PNG, GIF, WebP · max 5 MB</span>
                        </p>

                        <asp:FileUpload ID="fuPhoto" runat="server"
                            CssClass="hidden"
                            accept="image/jpeg,image/png,image/gif,image/webp" />

                        <div id="uploadZone" class="upload-zone rounded-[2rem] p-8 text-center"
                             onclick="document.getElementById('<%= fuPhoto.ClientID %>').click()">

                            <div id="previewWrap" class="hidden mb-5">
                                <img id="previewImg"
                                     class="mx-auto max-h-56 rounded-[1.5rem] object-contain shadow-md border border-gray-100 bg-white" />
                            </div>

                            <div id="uploadPrompt">
                                <div class="size-20 rounded-[1.75rem] bg-white/90 border border-math-blue/10 flex items-center justify-center mx-auto mb-4 shadow-sm">
                                    <span class="material-symbols-outlined text-5xl text-math-blue">add_photo_alternate</span>
                                </div>
                                <p class="font-black text-math-dark-blue text-sm uppercase tracking-widest">Click or drag an image here</p>
                                <p class="text-gray-400 text-sm font-semibold mt-2">Use an image if it helps explain the question or working.</p>
                            </div>

                            <div id="fileBadge" class="hidden mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-math-blue/10 border border-math-blue/20 text-math-blue font-black text-xs uppercase tracking-wide">
                                <span class="material-symbols-outlined text-sm">image</span>
                                <span id="fileNameLabel"></span>
                                <button type="button" id="btnRemovePhoto"
                                        class="ml-1 text-red-400 hover:text-red-600 font-black"
                                        onclick="removePhoto(event)">&#x2715;</button>
                            </div>
                        </div>

                        <asp:Label ID="lblPhotoError" runat="server" Visible="false"
                            CssClass="block mt-2 text-red-500 text-xs font-bold" />
                    </div>

                    <div class="flex flex-col sm:flex-row gap-4 pt-2">
                        <asp:Button ID="btnPost" runat="server"
                            Text="Post to Community"
                            CssClass="bg-primary text-math-dark-blue px-8 py-4 rounded-2xl font-black text-sm uppercase tracking-widest border-0 shadow-lg shadow-primary/20 hover:brightness-95 transition-all active:scale-[0.98] cursor-pointer"
                            OnClick="btnPost_Click" />

                        <asp:Button ID="btnCancel" runat="server"
                            Text="Cancel"
                            CssClass="bg-white text-gray-500 px-8 py-4 rounded-2xl font-black text-sm uppercase tracking-widest border border-gray-200 hover:bg-gray-50 transition-all active:scale-[0.98] cursor-pointer"
                            CausesValidation="false"
                            OnClick="btnCancel_Click" />
                    </div>
                </div>
            </div>

            <aside class="space-y-6">
                <div class="helper-card rounded-[2.25rem] p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <p class="text-[10px] font-black uppercase tracking-[0.25em] text-gray-400 mb-1">Posting Tips</p>
                            <h3 class="text-lg font-black text-math-dark-blue">Make it easy to answer</h3>
                        </div>
                        <div class="size-11 rounded-2xl bg-math-blue/10 flex items-center justify-center border border-math-blue/10">
                            <span class="material-symbols-outlined text-math-blue fill-icon">forum</span>
                        </div>
                    </div>
                    <div class="space-y-3 text-sm font-semibold text-gray-500 leading-relaxed">
                        <div class="flex gap-3">
                            <span class="material-symbols-outlined text-math-blue text-base mt-0.5">title</span>
                            <p>Use a clear title so others know the exact concept you are asking about.</p>
                        </div>
                        <div class="flex gap-3">
                            <span class="material-symbols-outlined text-math-blue text-base mt-0.5">functions</span>
                            <p>Show your method or where you got stuck. People answer better when they can see your thinking.</p>
                        </div>
                        <div class="flex gap-3">
                            <span class="material-symbols-outlined text-math-blue text-base mt-0.5">image</span>
                            <p>Add a worksheet or working image only if it makes the explanation clearer.</p>
                        </div>
                    </div>
                </div>

                <div class="helper-card rounded-[2.25rem] p-6 bg-gradient-to-br from-math-dark-blue via-math-blue to-math-blue text-white shadow-[0_18px_42px_rgba(37,99,235,0.24)] border-0 overflow-hidden relative">
                    <div class="absolute -right-10 -bottom-10 size-40 rounded-full bg-white/10 blur-2xl"></div>
                    <div class="relative z-10">
                        <p class="text-[10px] font-black uppercase tracking-[0.25em] text-white/70 mb-2">Community Goal</p>
                        <h3 class="text-xl font-black tracking-tight mb-3">Start meaningful conversations</h3>
                        <p class="text-sm font-semibold text-white/80 leading-relaxed">
                            Strong forum posts help classmates revise faster and give teachers clearer insight into common misconceptions.
                        </p>
                    </div>
                </div>
            </aside>
        </div>
    </div>

    <script>
        (function () {
            var fu       = document.getElementById('<%= fuPhoto.ClientID %>');
            var zone     = document.getElementById('uploadZone');
            var preview  = document.getElementById('previewWrap');
            var img      = document.getElementById('previewImg');
            var prompt   = document.getElementById('uploadPrompt');
            var badge    = document.getElementById('fileBadge');
            var nameLabel= document.getElementById('fileNameLabel');
            var MAX_MB   = 5;

            fu.addEventListener('change', function () {
                var file = fu.files[0];
                if (!file) return;

                if (file.size > MAX_MB * 1024 * 1024) {
                    alert('Image is larger than 5 MB. Please choose a smaller file.');
                    fu.value = '';
                    return;
                }

                var reader = new FileReader();
                reader.onload = function (e) {
                    img.src = e.target.result;
                    preview.classList.remove('hidden');
                    prompt.classList.add('hidden');
                    nameLabel.textContent = file.name;
                    badge.classList.remove('hidden');
                };
                reader.readAsDataURL(file);
            });

            zone.addEventListener('dragover', function (e) {
                e.preventDefault();
                zone.classList.add('drag-over');
            });

            zone.addEventListener('dragleave', function () {
                zone.classList.remove('drag-over');
            });

            zone.addEventListener('drop', function (e) {
                e.preventDefault();
                zone.classList.remove('drag-over');
                if (e.dataTransfer.files.length) {
                    var dt = new DataTransfer();
                    dt.items.add(e.dataTransfer.files[0]);
                    fu.files = dt.files;
                    fu.dispatchEvent(new Event('change'));
                }
            });
        })();

        function removePhoto(e) {
            e.stopPropagation();
            var fu = document.getElementById('<%= fuPhoto.ClientID %>');
            fu.value = '';
            document.getElementById('previewWrap').classList.add('hidden');
            document.getElementById('uploadPrompt').classList.remove('hidden');
            document.getElementById('fileBadge').classList.add('hidden');
            document.getElementById('previewImg').src = '';
        }
    </script>

</asp:Content>
