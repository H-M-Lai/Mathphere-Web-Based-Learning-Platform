<%@ Page Language="C#" MasterPageFile="~/Teacher.master" AutoEventWireup="true"
    CodeBehind="moduleBuilder.aspx.cs" Inherits="MathSphere.moduleBuilder" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere — Module Builder
</asp:Content>

<asp:Content ID="HeadBlock" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/moduleBuilder.css" rel="stylesheet" type="text/css" />

    <style>
        .tab-active-green {
            background: rgba(255,255,255,0.98);
            border-color: #84cc16;
            box-shadow: 0 14px 32px rgba(15,23,42,0.08);
        }

        .tab-inactive {
            background: rgba(255,255,255,0.82);
            border-color: rgba(226,232,240,0.85);
            transition: all 0.2s ease;
        }

        .tab-inactive:hover {
            background: rgba(255,255,255,0.96);
            transform: translateY(-1px);
            box-shadow: 0 10px 24px rgba(15,23,42,0.05);
        }
    </style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Toast notification --%>
    <div id="toastNotif"
         class="fixed bottom-6 right-6 z-[9999999] flex items-center gap-3
                bg-math-dark-blue text-white font-black text-sm px-6 py-4
                rounded-2xl shadow-2xl pointer-events-none
                transition-all duration-300 ease-out"
         style="transform: translateY(1rem); opacity: 0;"
         aria-live="polite">
        <span class="material-symbols-outlined text-math-green text-xl">check_circle</span>
        <span id="toastText">Saved!</span>
    </div>

    <div class="mb-8 rounded-[2.25rem] border border-white/80 bg-white/85 shadow-[0_18px_40px_rgba(15,23,42,0.06)] backdrop-blur-sm sticky top-[88px] z-40">
        <div class="max-w-7xl mx-auto px-6 py-4">
            <div class="flex flex-wrap gap-4 md:gap-8 justify-center md:justify-start">
                <button type="button" onclick="window.location.href='courselistDashboard.aspx'"
                    class="flex items-center gap-3 px-6 py-3.5 rounded-[1.5rem] border tab-inactive group border-math-blue/20">
                    <div class="size-10 rounded-xl bg-math-blue/10 flex items-center justify-center group-hover:scale-110 transition-transform">
                        <span class="material-symbols-outlined text-math-blue fill-icon">layers</span>
                    </div>
                    <span class="font-black text-sm uppercase tracking-widest">Courses</span>
                </button>

                <button type="button"
                    class="flex items-center gap-3 px-6 py-3.5 rounded-[1.5rem] border tab-active-green group">
                    <div class="size-10 rounded-xl bg-math-green/10 flex items-center justify-center group-hover:scale-110 transition-transform">
                        <span class="material-symbols-outlined text-math-green fill-icon">grid_view</span>
                    </div>
                    <span class="font-black text-sm uppercase tracking-widest">Module Builder</span>
                </button>

                <button type="button" onclick="window.location.href='assessmentTemplates.aspx'"
                    class="flex items-center gap-3 px-6 py-3.5 rounded-[1.5rem] border tab-inactive group border-primary/20">
                    <div class="size-10 rounded-xl bg-primary/10 flex items-center justify-center group-hover:scale-110 transition-transform">
                        <span class="material-symbols-outlined text-primary fill-icon">assignment</span>
                    </div>
                    <span class="font-black text-sm uppercase tracking-widest">Assessment Templates</span>
                </button>
            </div>
        </div>
    </div>

    <main class="relative z-10 flex flex-1 overflow-hidden rounded-[2.5rem] border border-white/75 bg-white/65 shadow-[0_20px_48px_rgba(15,23,42,0.08)] backdrop-blur-sm">
        <%-- Left Sidebar: Content Library --%>
        <aside class="hidden w-80 overflow-y-auto rounded-l-[2.5rem] border-r border-white/75 bg-white/96 p-6 xl:block">
            <h3 class="text-xs font-black uppercase tracking-[0.2em] text-gray-400 mb-6">Content Library</h3>
            <div class="space-y-4" id="contentLibrary">
                <asp:Repeater ID="rptContentLibrary" runat="server" OnItemDataBound="rptContentLibrary_ItemDataBound">
                    <ItemTemplate>
                        <asp:Literal ID="litContentBlock" runat="server"></asp:Literal>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="mt-12 p-6 rounded-3xl bg-math-dark-blue text-white relative overflow-hidden">
                <div class="relative z-10">
                    <div class="font-black text-lg mb-2 italic">Pro Tip!</div>
                    <p class="text-xs text-blue-200 font-medium leading-relaxed">
                        Drag and drop blocks directly into your module sequence to build the learning flow.
                    </p>
                </div>
                <span class="material-symbols-outlined absolute -bottom-4 -right-4 text-7xl opacity-20 rotate-12">lightbulb</span>
            </div>
        </aside>

        <%-- Center: Module Builder --%>
        <div class="flex-1 p-8 overflow-y-auto">
            <div class="max-w-4xl mx-auto">
                <div class="flex justify-between items-end mb-8">
                    <div>
                        <span class="text-math-green font-black tracking-widest text-xs uppercase block mb-1">Current Workspace</span>
                        <h2 class="text-3xl font-black text-math-dark-blue">
                            <asp:Literal ID="litModuleTitle" runat="server" Text="Module 1: Introduction to Functions" />
                        </h2>
                    </div>
                    <div class="flex gap-2">
                        <asp:Button ID="btnSaveChanges" runat="server" Text="Save Changes"
                            CssClass="rounded-2xl bg-primary px-5 py-3 text-xs font-black uppercase tracking-[0.18em] text-math-dark-blue shadow-[0_10px_22px_rgba(249,208,6,0.24)] transition-all hover:-translate-y-0.5 cursor-pointer border-0"
                            OnClick="btnSaveChanges_Click" />
                    </div>
                </div>

                <div class="flex flex-col gap-4 w-full" id="moduleBlocksContainer">
                    <asp:Repeater ID="rptModuleBlocks" runat="server" OnItemDataBound="rptModuleBlocks_ItemDataBound">
                        <ItemTemplate>
                            <asp:Literal ID="litModuleBlock" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div id="dropZone" class="drop-zone border-4 border-dashed border-gray-200 rounded-[2.5rem] p-12 flex flex-col items-center justify-center text-gray-400 group hover:border-math-green/30 hover:bg-math-green/5 transition-all mt-4">
                    <div class="size-16 rounded-full bg-gray-100 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                        <span class="material-symbols-outlined text-4xl">add</span>
                    </div>
                    <p class="font-black uppercase tracking-widest text-sm">Drop content blocks here</p>
                </div>
            </div>
        </div>

        <%-- Right Sidebar: Module Settings --%>
        <aside class="hidden w-80 overflow-y-auto rounded-r-[2.5rem] border-l border-white/75 bg-white/96 p-8 lg:block">
            <h3 class="text-xs font-black uppercase tracking-[0.2em] text-gray-400 mb-8">Module Settings</h3>

            <div class="space-y-8">
                <div>
                    <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2">Module Title</label>
                    <asp:TextBox ID="txtModuleTitle" runat="server"
                        CssClass="w-full bg-gray-50 border-2 border-gray-100 rounded-2xl px-4 py-3 font-bold text-math-dark-blue focus:border-math-green focus:ring-0 transition-colors"
                        Text="Introduction to Functions"></asp:TextBox>
                </div>

                <div>
                    <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2">Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4"
                        CssClass="w-full bg-gray-50 border-2 border-gray-100 rounded-2xl px-4 py-3 font-medium text-sm text-gray-600 focus:border-math-green focus:ring-0 transition-colors"
                        Text="A comprehensive look at the basics of algebraic functions, focusing on vertical line tests, domain, and range identification."></asp:TextBox>
                </div>

                <div class="pt-8 border-t-2 border-gray-100">
                    <asp:Button ID="btnSaveConfiguration" runat="server" Text="Save Configuration"
                        OnClick="btnSaveConfiguration_Click"
                        CssClass="w-full rounded-2xl bg-primary py-4 text-sm font-black uppercase tracking-[0.18em] text-math-dark-blue shadow-[0_12px_24px_rgba(249,208,6,0.22)] transition-all hover:-translate-y-0.5 cursor-pointer border-0" />
                </div>
            </div>
        </aside>
    </main>

    <asp:HiddenField ID="hdnModuleId" runat="server" />
    <asp:HiddenField ID="hdnBlocksJson" runat="server" />

    <%-- DRAG GHOST ELEMENT --%>
    <div id="dragGhost" class="drag-ghost hidden fixed pointer-events-none z-[9999] bg-white rounded-2xl border-2 border-math-green shadow-2xl px-6 py-4 flex items-center gap-4 opacity-90">
        <div id="dragGhostIcon" class="size-10 rounded-xl flex items-center justify-center">
            <span class="material-symbols-outlined text-2xl fill-icon"></span>
        </div>
        <div>
            <div id="dragGhostType" class="text-[10px] font-black uppercase text-math-green"></div>
            <div id="dragGhostTitle" class="font-black text-math-dark-blue text-sm"></div>
        </div>
    </div>

    <%-- INLINE CONFIG MODAL  (video / flashcard / quiz / text) --%>
    <div id="configModal" class="fixed inset-0 z-[99999] hidden items-center justify-center p-4">
        <div id="configBackdrop" class="absolute inset-0 bg-slate-900/50 backdrop-blur-sm" onclick="closeConfigModal()"></div>
        <div id="configPanel" class="relative w-full max-w-xl bg-white rounded-[2rem] shadow-2xl overflow-hidden flex flex-col max-h-[90vh] modal-enter">

            <%-- Header — the × here is the ONLY close button --%>
            <div id="configHeader" class="bg-math-blue p-6 flex items-center gap-4 flex-shrink-0">
                <div id="configHeaderIcon" class="size-12 bg-white/20 rounded-xl flex items-center justify-center text-white">
                    <span class="material-symbols-outlined fill-icon text-3xl">play_circle</span>
                </div>
                <div>
                    <h2 id="configHeaderTitle" class="text-white text-lg font-black tracking-tight uppercase">Configure Video Block</h2>
                    <p class="text-white/70 text-xs font-bold uppercase tracking-wider">Module Content Setup</p>
                </div>
                <button type="button" onclick="closeConfigModal()" class="ml-auto size-9 rounded-xl bg-white/20 hover:bg-white/30 flex items-center justify-center text-white transition-colors">
                    <span class="material-symbols-outlined text-xl">close</span>
                </button>
            </div>

            <div class="flex-1 overflow-y-auto p-8 space-y-6 config-scroll">
                <div id="videoTabSwitcher" class="hidden">
                    <div class="flex p-1 bg-gray-100 rounded-2xl gap-1">
                        <button type="button" id="tabLinkBtn" onclick="switchVideoTab('link')"
                            class="flex-1 py-3 px-4 rounded-xl font-black text-xs flex items-center justify-center gap-2 transition-all uppercase tracking-widest bg-math-blue text-white shadow-md">
                            <span class="material-symbols-outlined text-base">link</span>Link from Web
                        </button>
                        <button type="button" id="tabUploadBtn" onclick="switchVideoTab('upload')"
                            class="flex-1 py-3 px-4 rounded-xl font-black text-xs flex items-center justify-center gap-2 transition-all uppercase tracking-widest text-gray-400 hover:bg-white hover:text-math-dark-blue">
                            <span class="material-symbols-outlined text-base">cloud_upload</span>Upload File
                        </button>
                    </div>
                </div>

                <div id="videoLinkContent" class="hidden space-y-4">
                    <div>
                        <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">YouTube or Vimeo URL</label>
                        <div class="flex items-center gap-2 border-2 border-gray-200 rounded-xl px-4 py-3 bg-gray-50 focus-within:border-math-blue transition-colors">
                            <span class="material-symbols-outlined text-gray-400 text-base">link</span>
                            <input id="videoUrlInput" type="text" placeholder="https://youtube.com/watch?v=..."
                                class="flex-1 bg-transparent text-math-dark-blue font-medium text-sm outline-none placeholder:text-gray-300"
                                oninput="updateVideoPreview(this.value)" />
                        </div>
                    </div>
                    <div id="videoPreviewArea" class="aspect-video bg-gray-50 border-2 border-dashed border-gray-200 rounded-2xl flex flex-col items-center justify-center text-gray-300 overflow-hidden transition-all">
                        <span class="material-symbols-outlined text-5xl mb-2">image</span>
                        <p class="text-[10px] font-black uppercase tracking-widest">Preview Loading...</p>
                    </div>
                </div>

                <div id="videoUploadContent" class="hidden space-y-3">
                    <div id="videoDropZone"
                        class="aspect-video bg-math-blue/5 border-2 border-dashed border-math-blue rounded-2xl flex flex-col items-center justify-center cursor-pointer hover:bg-math-blue/10 transition-all group"
                        onclick="document.getElementById('videoFileInput').click()"
                        ondragover="event.preventDefault(); this.classList.add('bg-math-blue/10')"
                        ondragleave="this.classList.remove('bg-math-blue/10')"
                        ondrop="handleVideoDrop(event)">
                        <div class="size-20 bg-white shadow-[0_4px_0_0_#bfdbfe] rounded-2xl flex items-center justify-center mb-5 group-hover:scale-110 transition-transform">
                            <span class="material-symbols-outlined fill-icon text-math-blue text-5xl">cloud_upload</span>
                        </div>
                        <h3 class="font-black text-math-dark-blue text-base uppercase tracking-tight mb-3">Drag &amp; Drop your MP4 file here</h3>
                        <button type="button" class="bg-math-blue text-white font-black py-2.5 px-6 rounded-xl text-xs uppercase tracking-widest shadow-[0_4px_0_0_#1d4ed8] hover:shadow-[0_2px_0_0_#1d4ed8] hover:translate-y-0.5 active:translate-y-1 active:shadow-none transition-all">
                            Or Browse Files
                        </button>
                        <input id="videoFileInput" type="file" accept=".mp4,.mov" class="hidden" onchange="handleVideoFileSelect(this)" />
                    </div>
                    <div id="videoFileInfo" class="hidden items-center gap-3 bg-math-green/10 border border-math-green/30 rounded-xl px-4 py-3">
                        <span class="material-symbols-outlined fill-icon text-math-green">check_circle</span>
                        <span id="videoFileName" class="text-sm font-bold text-math-dark-blue flex-1 truncate"></span>
                        <button type="button" onclick="clearVideoFile()" class="text-gray-400 hover:text-red-500 transition-colors">
                            <span class="material-symbols-outlined text-base">close</span>
                        </button>
                    </div>
                    <div class="flex items-center gap-2 px-1">
                        <span class="material-symbols-outlined text-gray-400 text-sm">info</span>
                        <p class="text-gray-400 text-[10px] font-bold">Max file size: 500MB · Supported: .mp4, .mov</p>
                    </div>
                </div>

                <div id="flashcardFields" class="hidden space-y-4">
                    <div>
                        <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">Set Title</label>
                        <input type="text" placeholder="Domain and Range Terminology"
                            class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 font-bold text-math-dark-blue text-sm bg-gray-50 focus:border-math-blue outline-none transition-colors" />
                    </div>
                    <div>
                        <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">Number of Cards</label>
                        <input type="number" min="1" max="100" placeholder="12"
                            class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 font-bold text-math-dark-blue text-sm bg-gray-50 focus:border-math-blue outline-none transition-colors" />
                    </div>
                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-xl border-2 border-gray-100">
                        <div>
                            <p class="font-black text-sm text-math-dark-blue">Shuffle Cards</p>
                            <p class="text-[10px] text-gray-400 font-bold">Randomise order each session</p>
                        </div>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" class="sr-only peer" checked />
                            <div class="w-11 h-6 bg-gray-200 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border after:border-gray-300 after:rounded-full after:size-5 after:transition-all peer-checked:bg-math-green"></div>
                        </label>
                    </div>
                </div>

                <div id="quizFields" class="hidden space-y-4">
                    <div>
                        <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">Quiz Title</label>
                        <input type="text" placeholder="Functions &amp; Relations Quiz"
                            class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 font-bold text-math-dark-blue text-sm bg-gray-50 focus:border-math-blue outline-none transition-colors" />
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">Time Limit (mins)</label>
                            <input type="number" min="1" placeholder="30"
                                class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 font-bold text-math-dark-blue text-sm bg-gray-50 focus:border-math-blue outline-none transition-colors" />
                        </div>
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">Passing Score (%)</label>
                            <input type="number" min="1" max="100" placeholder="70"
                                class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 font-bold text-math-dark-blue text-sm bg-gray-50 focus:border-math-blue outline-none transition-colors" />
                        </div>
                    </div>
                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-xl border-2 border-gray-100">
                        <div>
                            <p class="font-black text-sm text-math-dark-blue">Allow Retakes</p>
                            <p class="text-[10px] text-gray-400 font-bold">Students can retry the quiz</p>
                        </div>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" class="sr-only peer" checked />
                            <div class="w-11 h-6 bg-gray-200 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border after:border-gray-300 after:rounded-full after:size-5 after:transition-all peer-checked:bg-math-green"></div>
                        </label>
                    </div>
                </div>

                <div id="textFields" class="hidden space-y-4">
                    <div>
                        <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">Content Title</label>
                        <input type="text" placeholder="Reading: Algebraic Expressions"
                            class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 font-bold text-math-dark-blue text-sm bg-gray-50 focus:border-math-blue outline-none transition-colors" />
                    </div>
                    <div>
                        <label class="block text-[10px] font-black uppercase tracking-widest text-math-blue mb-2 ml-1">Content Body</label>
                        <div class="border-2 border-gray-200 rounded-2xl overflow-hidden focus-within:border-math-blue transition-colors">
                            <div class="flex flex-wrap items-center gap-1 p-2 border-b border-gray-100 bg-gray-50/50">
                                <button type="button" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors"><span class="material-symbols-outlined text-lg">format_bold</span></button>
                                <button type="button" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors"><span class="material-symbols-outlined text-lg">format_italic</span></button>
                                <button type="button" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors"><span class="material-symbols-outlined text-lg">format_underlined</span></button>
                                <div class="w-px h-5 bg-gray-200 mx-1"></div>
                                <button type="button" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors"><span class="material-symbols-outlined text-lg">format_list_bulleted</span></button>
                                <button type="button" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors"><span class="material-symbols-outlined text-lg">format_list_numbered</span></button>
                                <div class="w-px h-5 bg-gray-200 mx-1"></div>
                                <button type="button" class="p-2 rounded-lg bg-math-blue/10 text-math-blue transition-colors"><span class="material-symbols-outlined text-lg">functions</span></button>
                            </div>
                            <textarea rows="5" placeholder="Write your lesson content here..."
                                class="w-full p-4 bg-white text-math-dark-blue font-medium text-sm placeholder:text-gray-300 outline-none resize-none border-none focus:ring-0"></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <div class="p-6 border-t-2 border-gray-100 bg-white flex flex-col sm:flex-row-reverse gap-3 flex-shrink-0">
                <button type="button" onclick="attachToModule()"
                    class="flex-1 bg-primary text-math-dark-blue font-black py-4 px-8 rounded-2xl shadow-[0_5px_0_0_#d4b105] hover:shadow-[0_3px_0_0_#d4b105] hover:translate-y-0.5 active:translate-y-1 active:shadow-none transition-all flex items-center justify-center gap-2 text-sm uppercase tracking-widest">
                    <span class="material-symbols-outlined fill-icon">add_link</span>
                    Attach to Module
                </button>
                <button type="button" onclick="closeConfigModal()"
                    class="px-6 py-4 font-black text-gray-400 hover:text-math-dark-blue transition-colors uppercase tracking-widest text-xs">
                    Cancel
                </button>
            </div>
        </div>
    </div>

    <%-- IFRAME OVERLAY — no extra close bar; iframe handles its own close --%>
    <div id="iframeOverlay" class="fixed inset-0 z-[999999] hidden items-start justify-center bg-slate-900/60 backdrop-blur-sm"
         style="padding-top: 150px; padding-bottom: 20px; padding-left: 16px; padding-right: 16px;">
        <div class="absolute inset-0" onclick="closeIframeOverlay()"></div>
        <div id="iframePanel" class="relative z-10 overflow-hidden iframe-panel-enter bg-white rounded-[2rem] shadow-2xl flex flex-col"
             style="width:100%; height:100%; max-height:calc(100vh - 170px);">

            <iframe id="configIframe" src="" frameborder="0"
                style="width:100%; flex:1; border:none; display:block; border-radius:2rem; min-height:0;"
                allow="autoplay">
            </iframe>
        </div>
    </div>

    <style>
        .iframe-panel-enter { animation: iframePanelIn 0.28s cubic-bezier(0.34,1.3,0.64,1); }
        @keyframes iframePanelIn {
            from { opacity:0; transform:scale(0.97) translateY(12px); }
            to   { opacity:1; transform:scale(1)    translateY(0); }
        }
        #iframeOverlay.open { display:flex !important; }
    </style>

</asp:Content>

<%-- SCRIPTS --%>
<asp:Content ID="ScriptBlock" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        var _toastTimer = null;

        function showToast(msg, duration) {
            duration = duration || 3000;
            var toast = document.getElementById('toastNotif');
            var text = document.getElementById('toastText');
            if (!toast || !text) return;
            text.textContent = msg;
            toast.style.transform = 'translateY(0)';
            toast.style.opacity = '1';
            if (_toastTimer) clearTimeout(_toastTimer);
            _toastTimer = setTimeout(function () {
                toast.style.transform = 'translateY(1rem)';
                toast.style.opacity = '0';
            }, duration);
        }

        window.showToast = showToast;
    </script>

    <%-- SCRIPT 2 — DRAG & DROP MANAGER --%>
    <script>
        (function () {
            // State
            let dragSource = null;
            let dragData = null;
            let dragBlockEl = null;
            let dragOverEl = null;
            let blockIdCounter = 100;

            // Ghost element
            const ghost = document.getElementById('dragGhost');
            const ghostIcon = document.getElementById('dragGhostIcon');
            const ghostType = document.getElementById('dragGhostType');
            const ghostTitle = document.getElementById('dragGhostTitle');

            function showGhost(x, y, icon, colorClass, type, title) {
                ghostIcon.className = `size-10 rounded-xl bg-${colorClass}/10 flex items-center justify-center`;
                ghostIcon.querySelector('span').className = `material-symbols-outlined text-2xl fill-icon text-${colorClass}`;
                ghostIcon.querySelector('span').textContent = icon;
                ghostType.textContent = type;
                ghostTitle.textContent = title;
                ghost.classList.remove('hidden');
                ghost.classList.add('flex');
                moveGhost(x, y);
            }

            function moveGhost(x, y) {
                ghost.style.left = (x + 16) + 'px';
                ghost.style.top = (y - 20) + 'px';
            }

            function hideGhost() {
                ghost.classList.add('hidden');
                ghost.classList.remove('flex');
            }

            // Color mapping
            const colorMap = {
                'math-blue': { bg: '#eff6ff', text: '#2563eb', badge: '#dbeafe' },
                'primary': { bg: '#fffbeb', text: '#b45309', badge: '#fef3c7' },
                'math-green': { bg: '#f0fdf4', text: '#65a30d', badge: '#dcfce7' },
                'gray-500': { bg: '#f9fafb', text: '#6b7280', badge: '#f3f4f6' }
            };

            function getColors(colorClass) {
                return colorMap[colorClass] || colorMap['gray-500'];
            }

            // Library item drag setup
            function setupLibraryItem(el) {
                el.setAttribute('draggable', 'false');
                el.addEventListener('pointerdown', function (e) {
                    if (e.button !== 0) return;
                    e.preventDefault();
                    dragSource = 'library';
                    dragData = {
                        contentType: el.dataset.contentType,
                        displayName: el.dataset.displayName,
                        subtitle: el.dataset.subtitle,
                        icon: el.dataset.icon,
                        colorClass: el.dataset.colorClass
                    };
                    showGhost(e.clientX, e.clientY, dragData.icon, dragData.colorClass, dragData.displayName, dragData.displayName);
                    document.addEventListener('pointermove', onPointerMove);
                    document.addEventListener('pointerup', onPointerUp);
                });
            }

            // Block drag handle setup
            function setupBlockHandle(blockEl) {
                const handle = blockEl.querySelector('.drag-handle');
                if (!handle) return;
                handle.addEventListener('pointerdown', function (e) {
                    if (e.button !== 0) return;
                    e.preventDefault();
                    dragSource = 'block';
                    dragBlockEl = blockEl;
                    const title = blockEl.querySelector('h4')?.textContent || '';
                    const icon = blockEl.dataset.icon || 'article';
                    const colorClass = blockEl.dataset.colorClass || 'gray-500';
                    const contentType = blockEl.dataset.contentType || '';
                    blockEl.classList.add('dragging-block');
                    showGhost(e.clientX, e.clientY, icon, colorClass, contentType, title);
                    document.addEventListener('pointermove', onPointerMove);
                    document.addEventListener('pointerup', onPointerUp);
                });
            }

            // Pointer move
            function onPointerMove(e) {
                moveGhost(e.clientX, e.clientY);
                const container = document.getElementById('moduleBlocksContainer');
                const dropZone = document.getElementById('dropZone');
                clearInsertIndicators();
                const dzRect = dropZone.getBoundingClientRect();
                const inDropZone = e.clientX >= dzRect.left && e.clientX <= dzRect.right &&
                    e.clientY >= dzRect.top && e.clientY <= dzRect.bottom;
                dropZone.classList.toggle('drop-zone-active', inDropZone);
                dragOverEl = computeInsertRef(e.clientX, e.clientY, container);
            }

            function computeInsertRef(x, y, container) {
                const blocks = Array.from(container.querySelectorAll(':scope > .module-block-item'));
                if (blocks.length === 0) return { position: 'append' };
                for (let i = 0; i < blocks.length; i++) {
                    const rect = blocks[i].getBoundingClientRect();
                    if (y < rect.top + rect.height / 2) {
                        blocks[i].classList.add('insert-before');
                        return { position: 'before', el: blocks[i] };
                    }
                }
                const last = blocks[blocks.length - 1];
                last.classList.add('insert-after');
                return { position: 'after', el: last };
            }

            // Pointer up
            function onPointerUp(e) {
                document.removeEventListener('pointermove', onPointerMove);
                document.removeEventListener('pointerup', onPointerUp);
                hideGhost();
                clearInsertIndicators();

                const dropZone = document.getElementById('dropZone');
                const container = document.getElementById('moduleBlocksContainer');
                dropZone.classList.remove('drop-zone-active');
                if (dragBlockEl) dragBlockEl.classList.remove('dragging-block');

                const dzRect = dropZone.getBoundingClientRect();
                const containerRect = container.getBoundingClientRect();
                const inValidArea =
                    (e.clientX >= containerRect.left && e.clientX <= containerRect.right &&
                        e.clientY >= containerRect.top && e.clientY <= containerRect.bottom) ||
                    (e.clientX >= dzRect.left && e.clientX <= dzRect.right &&
                        e.clientY >= dzRect.top && e.clientY <= dzRect.bottom);

                const dzHovered = e.clientX >= dzRect.left && e.clientX <= dzRect.right &&
                    e.clientY >= dzRect.top && e.clientY <= dzRect.bottom;
                const insertRef = dzHovered ? { position: 'append' } : dragOverEl;

                if (dragSource === 'library' && inValidArea) {
                    addBlockFromLibrary(dragData, insertRef);
                } else if (dragSource === 'block' && inValidArea && dragOverEl) {
                    reorderBlock(dragBlockEl, insertRef);
                }

                dragSource = null;
                dragData = null;
                dragBlockEl = null;
                dragOverEl = null;
                updateOrderNumbers();
                saveBlocksState();
            }

            function clearInsertIndicators() {
                document.querySelectorAll('.insert-before, .insert-after').forEach(el => {
                    el.classList.remove('insert-before', 'insert-after');
                });
            }

            // Add block from library
            function addBlockFromLibrary(data, insertRef) {
                const container = document.getElementById('moduleBlocksContainer');
                const newBlockEl = createBlockElement({
                    id: 'new-' + (++blockIdCounter),
                    contentType: data.displayName,
                    title: data.displayName,
                    metadata: data.subtitle,
                    icon: data.icon,
                    colorClass: data.colorClass
                });

                setupBlockHandle(newBlockEl);
                setupDeleteButton(newBlockEl);
                setupSettingsButton(newBlockEl);

                if (!insertRef || insertRef.position === 'append') {
                    container.appendChild(newBlockEl);
                } else if (insertRef.position === 'before' && insertRef.el) {
                    container.insertBefore(newBlockEl, insertRef.el);
                } else if (insertRef.position === 'after' && insertRef.el) {
                    const next = insertRef.el.nextSibling;
                    if (next) container.insertBefore(newBlockEl, next);
                    else container.appendChild(newBlockEl);
                } else {
                    container.appendChild(newBlockEl);
                }

                newBlockEl.style.opacity = '0';
                newBlockEl.style.transform = 'translateY(-8px)';
                requestAnimationFrame(() => {
                    newBlockEl.style.transition = 'opacity 0.25s ease, transform 0.25s ease';
                    newBlockEl.style.opacity = '1';
                    newBlockEl.style.transform = 'translateY(0)';
                });
            }

            // Reorder block
            function reorderBlock(blockEl, insertRef) {
                if (!insertRef) return;
                const container = document.getElementById('moduleBlocksContainer');
                if (insertRef.position === 'append') { container.appendChild(blockEl); return; }
                if (!insertRef.el || insertRef.el === blockEl) return;
                if (insertRef.position === 'before') {
                    if (insertRef.el.previousSibling !== blockEl)
                        container.insertBefore(blockEl, insertRef.el);
                } else if (insertRef.position === 'after') {
                    const next = insertRef.el.nextSibling;
                    if (next === null) container.appendChild(blockEl);
                    else if (next !== blockEl) container.insertBefore(blockEl, next);
                }
            }

            // Create block element
            function createBlockElement(data) {
                const colors = getColors(data.colorClass);
                const el = document.createElement('div');
                el.className = 'module-block-item block w-full bg-white rounded-3xl border-2 border-math-green/30 p-1 shadow-sm hover:shadow-md transition-all relative';
                el.style.display = 'block';
                el.dataset.blockId = data.id;
                el.dataset.contentType = data.contentType;
                el.dataset.icon = data.icon;
                el.dataset.colorClass = data.colorClass;
                el.innerHTML = `
    <div class="bg-white border-l-8 border-math-green rounded-[1.25rem] p-6 flex items-center gap-6">
        <div class="drag-handle text-gray-300 hover:text-math-dark-blue transition-colors cursor-grab active:cursor-grabbing">
            <span class="material-symbols-outlined text-3xl">drag_indicator</span>
        </div>
        <div class="size-14 rounded-2xl flex items-center justify-center" style="background:${colors.bg}">
            <span class="material-symbols-outlined text-3xl fill-icon" style="color:${colors.text}">${data.icon}</span>
        </div>
        <div class="flex-1">
            <div class="flex items-center gap-2 mb-1">
                <span class="text-[10px] font-black px-2 py-0.5 rounded-full uppercase" style="background:${colors.badge};color:${colors.text}">${data.contentType}</span>
                <span class="text-[10px] font-bold text-gray-400">${data.metadata}</span>
            </div>
            <h4 class="font-black text-xl text-math-dark-blue">${data.title}</h4>
        </div>
        <div class="flex gap-2">
            <button type="button" class="settings-btn size-10 rounded-xl hover:bg-gray-100 flex items-center justify-center text-gray-400 hover:text-math-dark-blue transition-colors">
                <span class="material-symbols-outlined">settings</span>
            </button>
            <button type="button" class="delete-btn size-10 rounded-xl hover:bg-red-50 flex items-center justify-center text-gray-400 hover:text-red-500 transition-colors">
                <span class="material-symbols-outlined">delete</span>
            </button>
        </div>
    </div>`;
                return el;
            }

            // Delete block
            function setupDeleteButton(blockEl) {
                const btn = blockEl.querySelector('.delete-btn');
                if (!btn) return;
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    blockEl.style.transition = 'opacity 0.2s, transform 0.2s';
                    blockEl.style.opacity = '0';
                    blockEl.style.transform = 'scale(0.95)';
                    setTimeout(() => {
                        blockEl.remove();
                        updateOrderNumbers();
                        saveBlocksState();
                    }, 200);
                });
            }

            function updateOrderNumbers() { /* future: visual step numbers */ }

            // Save blocks state to hidden field
            window.saveBlocksState = function saveBlocksState() {
                const container = document.getElementById('moduleBlocksContainer');
                const blocks = Array.from(container.querySelectorAll('.module-block-item'));
                const state = blocks.map((el, i) => ({
                    id: el.dataset.blockId,
                    contentType: el.dataset.contentType,
                    icon: el.dataset.icon,
                    colorClass: el.dataset.colorClass,
                    title: el.querySelector('h4')?.textContent || '',
                    order: i + 1
                }));
                const hdn = document.getElementById('<%= hdnBlocksJson.ClientID %>');
                if (hdn) hdn.value = JSON.stringify(state);
            };

            // Settings button
            function setupSettingsButton(blockEl) {
                const btn = blockEl.querySelector('.settings-btn');
                if (!btn) return;
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    const blockId = blockEl.dataset.blockId || '';
                    const contentType = (blockEl.dataset.contentType || '').toLowerCase();
                    const moduleId = document.getElementById('<%= hdnModuleId.ClientID %>').value || '';

                    if (blockId.startsWith('new-')) {
                        alert('Please click "Save Changes" first to save the block before configuring it.');
                        return;
                    }

                    if (contentType.includes('video')) {
                        let url = 'teacherUploadVid.aspx?blockId=' + encodeURIComponent(blockId);
                        if (moduleId) url += '&moduleId=' + encodeURIComponent(moduleId);
                        openIframeOverlay(url, 'video');
                    } else if (contentType.includes('flashcard')) {
                        let url = 'flashCardCfg.aspx?blockId=' + encodeURIComponent(blockId);
                        if (moduleId) url += '&moduleId=' + encodeURIComponent(moduleId);
                        openIframeOverlay(url, 'flashcard');
                    } else if (contentType.includes('quiz')) {
                        let url = 'setQuiz.aspx?blockId=' + encodeURIComponent(blockId);
                        if (moduleId) url += '&moduleId=' + encodeURIComponent(moduleId);
                        openIframeOverlay(url, 'quiz');
                    } else if (contentType.includes('text')) {
                        let url = 'setTextContent.aspx?blockId=' + encodeURIComponent(blockId);
                        if (moduleId) url += '&moduleId=' + encodeURIComponent(moduleId);
                        openIframeOverlay(url, 'text');
                    } else {
                        const title = blockEl.querySelector('h4')?.textContent || contentType;
                        openConfigModal(blockEl.dataset.contentType || contentType, title, blockEl);
                    }
                });
            }

            // Init existing blocks from server-rendered HTML
            function initExistingBlocks() {
                const container = document.getElementById('moduleBlocksContainer');
                container.querySelectorAll('[data-block-id]').forEach(el => {
                    el.classList.add('module-block-item');
                    setupBlockHandle(el);
                    setupDeleteButton(el);
                    setupSettingsButton(el);
                });
            }

            // Init library items
            function initLibraryItems() {
                document.querySelectorAll('.library-item').forEach(el => setupLibraryItem(el));
            }

            document.addEventListener('DOMContentLoaded', function () {
                initLibraryItems();
                initExistingBlocks();
            });

            window._setupSettingsButton = setupSettingsButton;
        })();
    </script>

    <%-- SCRIPT 3 — APPLY BLOCK ID MAPPINGS --%>
    <script>
        window.applyBlockIdMappings = function (mappings) {
            if (!mappings) return;
            var container = document.getElementById('moduleBlocksContainer');
            if (!container) return;

            container.querySelectorAll('[data-block-id]').forEach(function (el) {
                var tempId = el.dataset.blockId;
                if (mappings[tempId]) {
                    el.dataset.blockId = mappings[tempId];
                    var settingsBtn = el.querySelector('.settings-btn[data-block-id]');
                    if (settingsBtn) settingsBtn.dataset.blockId = mappings[tempId];
                }
            });

            if (typeof window.saveBlocksState === 'function') window.saveBlocksState();
        };
    </script>

    <%-- SCRIPT 4 — CONFIG MODAL MANAGER --%>
    <script>
        let _currentBlockEl = null;

        const MODAL_CONFIGS = {
            'Video Lesson':     { headerBg: '#2563eb', icon: 'play_circle',  title: 'Configure Video Block',    show: ['videoTabSwitcher', 'videoLinkContent'], initFn: () => switchVideoTab('link') },
            'Flashcard Set':    { headerBg: '#f9d006', icon: 'style',        title: 'Configure Flashcard Set',  show: ['flashcardFields'] },
            'Interactive Quiz': { headerBg: '#84cc16', icon: 'quiz',         title: 'Configure Quiz Block',     show: ['quizFields'] },
            'Text Content':     { headerBg: '#64748b', icon: 'article',      title: 'Configure Text Block',     show: ['textFields'] }
        };

        function resolveConfig(contentType) {
            if (MODAL_CONFIGS[contentType]) return MODAL_CONFIGS[contentType];
            for (const key of Object.keys(MODAL_CONFIGS)) {
                if (contentType.toLowerCase().includes(key.split(' ')[0].toLowerCase()))
                    return MODAL_CONFIGS[key];
            }
            return MODAL_CONFIGS['Text Content'];
        }

        const ALL_SECTIONS = ['videoTabSwitcher', 'videoLinkContent', 'videoUploadContent', 'flashcardFields', 'quizFields', 'textFields'];

        function openConfigModal(contentType, title, blockEl) {
            _currentBlockEl = blockEl;
            const cfg = resolveConfig(contentType);
            document.getElementById('configHeader').style.backgroundColor = cfg.headerBg;
            document.getElementById('configHeaderIcon').querySelector('span').textContent = cfg.icon;
            document.getElementById('configHeaderTitle').textContent = cfg.title;
            ALL_SECTIONS.forEach(id => document.getElementById(id)?.classList.add('hidden'));
            (cfg.show || []).forEach(id => document.getElementById(id)?.classList.remove('hidden'));
            if (cfg.initFn) cfg.initFn();
            const modal = document.getElementById('configModal');
            const panel = document.getElementById('configPanel');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            requestAnimationFrame(() => panel.classList.add('modal-visible'));
            document.body.style.overflow = 'hidden';
        }

        function closeConfigModal() {
            const modal = document.getElementById('configModal');
            const panel = document.getElementById('configPanel');
            panel.classList.remove('modal-visible');
            setTimeout(() => {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                document.body.style.overflow = '';
                _currentBlockEl = null;
            }, 220);
        }

        function attachToModule() { closeConfigModal(); }

        function switchVideoTab(tab) {
            const linkBtn = document.getElementById('tabLinkBtn');
            const uploadBtn = document.getElementById('tabUploadBtn');
            const linkContent = document.getElementById('videoLinkContent');
            const uploadContent = document.getElementById('videoUploadContent');
            if (tab === 'link') {
                linkBtn.classList.add('bg-math-blue', 'text-white', 'shadow-md');
                linkBtn.classList.remove('text-gray-400', 'hover:bg-white', 'hover:text-math-dark-blue');
                uploadBtn.classList.remove('bg-math-blue', 'text-white', 'shadow-md');
                uploadBtn.classList.add('text-gray-400', 'hover:bg-white', 'hover:text-math-dark-blue');
                linkContent.classList.remove('hidden');
                uploadContent.classList.add('hidden');
            } else {
                uploadBtn.classList.add('bg-math-blue', 'text-white', 'shadow-md');
                uploadBtn.classList.remove('text-gray-400', 'hover:bg-white', 'hover:text-math-dark-blue');
                linkBtn.classList.remove('bg-math-blue', 'text-white', 'shadow-md');
                linkBtn.classList.add('text-gray-400', 'hover:bg-white', 'hover:text-math-dark-blue');
                uploadContent.classList.remove('hidden');
                linkContent.classList.add('hidden');
            }
        }

        function updateVideoPreview(url) {
            const area = document.getElementById('videoPreviewArea');
            const ytMatch = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)/);
            const vimeoMatch = url.match(/vimeo\.com\/(\d+)/);
            let embedUrl = null;
            if (ytMatch) embedUrl = `https://www.youtube.com/embed/${ytMatch[1]}`;
            else if (vimeoMatch) embedUrl = `https://player.vimeo.com/video/${vimeoMatch[1]}`;
            if (embedUrl) {
                area.innerHTML = `<iframe src="${embedUrl}" class="w-full h-full rounded-xl" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>`;
            } else {
                area.innerHTML = `<span class="material-symbols-outlined text-5xl mb-2 text-gray-300">image</span><p class="text-[10px] font-black uppercase tracking-widest text-gray-300">Preview Loading...</p>`;
            }
        }

        function handleVideoFileSelect(input) { if (input.files?.[0]) showVideoFile(input.files[0]); }
        function handleVideoDrop(e) {
            e.preventDefault();
            document.getElementById('videoDropZone').classList.remove('bg-math-blue/10');
            if (e.dataTransfer.files[0]) showVideoFile(e.dataTransfer.files[0]);
        }
        function showVideoFile(file) {
            document.getElementById('videoDropZone').classList.add('hidden');
            const info = document.getElementById('videoFileInfo');
            document.getElementById('videoFileName').textContent = file.name;
            info.classList.remove('hidden'); info.classList.add('flex');
        }
        function clearVideoFile() {
            document.getElementById('videoDropZone').classList.remove('hidden');
            const info = document.getElementById('videoFileInfo');
            info.classList.add('hidden'); info.classList.remove('flex');
            document.getElementById('videoFileInput').value = '';
        }

        window.openConfigModal = openConfigModal;
        window.closeConfigModal = closeConfigModal;
        window.switchVideoTab = switchVideoTab;
        window.updateVideoPreview = updateVideoPreview;
        window.handleVideoDrop = handleVideoDrop;
        window.handleVideoFileSelect = handleVideoFileSelect;
        window.clearVideoFile = clearVideoFile;
        window.attachToModule = attachToModule;
    </script>

    <%-- SCRIPT 5 — IFRAME OVERLAY MANAGER --%>
    <script>
        var _currentIframeType = '';

        function openIframeOverlay(url, type) {
            _currentIframeType = type; 
            const overlay = document.getElementById('iframeOverlay');
            const panel = document.getElementById('iframePanel');
            const iframe = document.getElementById('configIframe');

            // Width per block type
            if (type === 'flashcard') panel.style.maxWidth = '900px';
            else if (type === 'quiz') panel.style.maxWidth = '780px';
            else if (type === 'text') panel.style.maxWidth = '860px';
            else panel.style.maxWidth = '620px';

            iframe.src = url;
            overlay.classList.remove('hidden');
            overlay.classList.add('open', 'flex');
            document.body.style.overflow = 'hidden';

            panel.classList.remove('iframe-panel-enter');
            void panel.offsetWidth;
            panel.classList.add('iframe-panel-enter');

            window.addEventListener('message', onIframeMessage);
        }

        function closeIframeOverlay() {
            const overlay = document.getElementById('iframeOverlay');
            const iframe = document.getElementById('configIframe');
            overlay.classList.add('hidden')
            overlay.classList.remove('open', 'flex');
            document.body.style.overflow = '';
            iframe.src = '';
            window.removeEventListener('message', onIframeMessage);
        }

        function onIframeMessage(event) {
            if (event.origin !== window.location.origin) return;
            if (event.data === 'closeOverlay' || event.data?.action === 'closeOverlay') {
                closeIframeOverlay();

                var type = event.data?.type || _currentIframeType || '';
                var messages = {
                    'video': 'Video content saved successfully!',
                    'flashcard': 'Flashcard set saved successfully!',
                    'quiz': 'Quiz configured successfully!',
                    'text': 'Text content saved successfully!'
                };
                showToast(messages[type] || 'Block content saved!');

                setTimeout(function () {
                    var moduleId = document.getElementById('<%= hdnModuleId.ClientID %>').value;
                    if (moduleId) window.location.href = 'moduleBuilder.aspx?id=' + encodeURIComponent(moduleId);
                }, 1500);
            }
        }

        window.openIframeOverlay = openIframeOverlay;
        window.closeIframeOverlay = closeIframeOverlay;
    </script>
</asp:Content>


