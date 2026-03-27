<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="setTextContent.aspx.cs" Inherits="MathSphere.setTextContent" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere - Text Content Configuration</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="Styles/setTextContent.css" rel="stylesheet" type="text/css"/>
    <script id="tailwind-config">
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        "navy": "#1e3a8a",
                        "navy-light": "#e8edf8",
                    },
                    fontFamily: { "display": ["Space Grotesk", "sans-serif"] }
                }
            }
        }
    </script>
</head>
<%-- enctype="multipart/form-data" required for file upload to work --%>
<body class="m-0 p-0 overflow-hidden" style="font-family:'Space Grotesk',sans-serif;">
<form id="form1" runat="server" enctype="multipart/form-data">

    <!-- Hidden state -->
    <asp:HiddenField ID="hdnBlockId"     runat="server" />
    <asp:HiddenField ID="hdnModuleId"    runat="server" />
    <asp:HiddenField ID="hdnBodyHtml"    runat="server" />
    <asp:HiddenField ID="hdnPdfFileName" runat="server" />
    <asp:HiddenField ID="hdnPdfPath"     runat="server" />  <%-- stores existing saved path --%>

    <div class="tc-shell flex flex-col bg-white" style="height:100vh;">

        <!-- HEADER -->
        <header class="tc-header flex-shrink-0 flex items-center justify-between px-8 py-5">
            <div class="flex items-center gap-4">
                <div class="size-11 bg-white/20 rounded-2xl flex items-center justify-center">
                    <span class="material-symbols-outlined text-white text-2xl"
                          style="font-variation-settings:'FILL' 1;">description</span>
                </div>
                <h1 class="text-white text-lg font-black uppercase tracking-tight">
                    Text Content Configuration
                </h1>
            </div>
            <button type="button" onclick="closePanel()"
                class="size-9 bg-white/10 hover:bg-white/20 rounded-full flex items-center justify-center transition-colors">
                <span class="material-symbols-outlined text-white/90 text-xl">close</span>
            </button>
        </header>

        <!-- SCROLLABLE BODY -->
        <main class="flex-1 overflow-y-auto tc-scroll px-8 py-7 space-y-7 bg-white">

            <!-- CONTENT TITLE -->
            <div class="space-y-2">
                <label class="tc-label">Content Title</label>
                <asp:TextBox ID="txtTitle" runat="server"
                    CssClass="tc-input w-full"
                    placeholder="e.g., Introduction to Quadratic Equations" />
            </div>

            <!-- PDF ATTACHMENT -->
            <div class="space-y-3">
                <label class="tc-label">PDF Attachment</label>

                <%--
                    ONE upload control. The drop zone clicks this directly.
                    No separate hidden <input type="file"> � that's what broke uploads.
                    onchange calls handlePdfSelect(this) to show file info in UI.
                --%>
                <asp:FileUpload ID="fileUploadPdf" runat="server"
                    CssClass="hidden"
                    onchange="handlePdfSelect(this)" />

                <!-- Drop zone -->
                <div id="pdfDropZone"
                    class="pdf-drop-zone w-full border-4 border-dashed border-slate-300
                           rounded-2xl p-10 flex flex-col items-center justify-center gap-4
                           cursor-pointer hover:border-navy transition-all"
                    onclick="document.getElementById('<%= fileUploadPdf.ClientID %>').click()"
                    ondragover="handlePdfDragOver(event)"
                    ondragleave="handlePdfDragLeave(event)"
                    ondrop="handlePdfDrop(event)">
                    <span class="material-symbols-outlined text-6xl text-navy"
                          style="font-variation-settings:'FILL' 1;">picture_as_pdf</span>
                    <div class="text-center">
                        <p class="text-base font-black text-slate-800 uppercase tracking-tight">
                            Drag &amp; Drop PDF or Browse
                        </p>
                        <p class="text-sm text-slate-400 font-medium mt-1">
                            Supported file types: .pdf &nbsp;�&nbsp; Max 10MB
                        </p>
                    </div>
                </div>

                <!-- File info row (shown after selection or if PDF already saved) -->
                <div id="pdfFileInfo"
                     class="hidden items-center gap-4 p-4 bg-navy-light
                            border-2 border-navy/20 rounded-2xl">
                    <span class="material-symbols-outlined text-navy text-3xl"
                          style="font-variation-settings:'FILL' 1;">picture_as_pdf</span>
                    <div class="flex-1 min-w-0">
                        <p id="pdfFileName"
                           class="font-black text-slate-800 text-sm truncate"></p>
                        <p id="pdfFileSize"
                           class="text-xs text-slate-400 font-medium mt-0.5"></p>
                    </div>
                    <button type="button" onclick="clearPdf()"
                        class="size-8 bg-white border-2 border-slate-200
                               hover:border-red-300 hover:bg-red-50 rounded-xl
                               flex items-center justify-center transition-colors">
                        <span class="material-symbols-outlined
                                     text-slate-400 hover:text-red-500 text-base">close</span>
                    </button>
                </div>

                <p class="text-xs text-slate-400 flex items-center gap-1.5 font-medium">
                    <span class="material-symbols-outlined text-sm">info</span>
                    Attached PDFs will be viewable by students within the lesson viewer.
                </p>
            </div>

            <!-- BODY TEXT / RICH EDITOR -->
            <div class="space-y-2">
                <label class="tc-label">Body Text Content</label>
                <div class="editor-wrapper rounded-2xl overflow-hidden shadow-[0_10px_24px_rgba(15,23,42,0.05)]">

                    <!-- Toolbar -->
                    <div class="editor-toolbar bg-slate-100 border-b-2 border-slate-200
                                px-3 py-2.5 flex flex-wrap items-center gap-2">
                        <div class="toolbar-group">
                            <button type="button" onclick="execCmd('bold')"
                                    title="Bold" class="tbtn"><b>B</b></button>
                            <button type="button" onclick="execCmd('italic')"
                                    title="Italic" class="tbtn"><i>I</i></button>
                            <button type="button" onclick="execCmd('underline')"
                                    title="Underline" class="tbtn"><u>U</u></button>
                        </div>
                        <div class="toolbar-group">
                            <button type="button" onclick="execCmd('insertUnorderedList')"
                                    title="Bullet list" class="tbtn">
                                <span class="material-symbols-outlined"
                                      style="font-size:1.1rem;">format_list_bulleted</span>
                            </button>
                            <button type="button" onclick="execCmd('insertOrderedList')"
                                    title="Numbered list" class="tbtn">
                                <span class="material-symbols-outlined"
                                      style="font-size:1.1rem;">format_list_numbered</span>
                            </button>
                        </div>
                        <div class="toolbar-group">
                            <button type="button" onclick="insertMath()"
                                    title="Math formula" class="tbtn font-mono text-sm">fx</button>
                            <button type="button" onclick="insertLink()"
                                    title="Insert link" class="tbtn">
                                <span class="material-symbols-outlined"
                                      style="font-size:1.1rem;">link</span>
                            </button>
                            <button type="button" onclick="triggerImageInsert()"
                                    title="Insert image" class="tbtn">
                                <span class="material-symbols-outlined"
                                      style="font-size:1.1rem;">image</span>
                            </button>
                            <input type="file" id="editorImageInput" accept="image/*"
                                   class="hidden" onchange="insertImageFile(this)" />
                        </div>
                        <div class="ml-auto">
                            <button type="button" onclick="toggleFullscreen()"
                                    title="Fullscreen" class="tbtn">
                                <span class="material-symbols-outlined" id="fsIcon"
                                      style="font-size:1.1rem;">fullscreen</span>
                            </button>
                        </div>
                    </div>

                    <%--
                        editor starts EMPTY � no hardcoded placeholder HTML.
                        DOMContentLoaded fills it from hdnBodyHtml (loaded from DB).
                        If DB is empty, editor stays blank (correct behaviour).
                    --%>
                    <div id="editorBody"
                         class="editor-body p-6 min-h-[220px] text-slate-800 text-base
                                leading-relaxed focus:outline-none"
                         contenteditable="true"
                         spellcheck="true"
                         oninput="syncEditorToHidden(); updateToolbarState()">
                    </div>

                </div>
            </div>

            <!-- PREVIEW -->
            <div class="flex items-center justify-between bg-slate-50 border-2
                        border-dashed border-slate-300 rounded-2xl px-6 py-5">
                <div class="flex items-center gap-4">
                    <span class="material-symbols-outlined text-slate-400 text-3xl">visibility</span>
                    <div>
                        <p class="font-black text-slate-800 uppercase tracking-wider text-sm">
                            Preview Mode
                        </p>
                        <p class="text-xs text-slate-400 font-medium mt-0.5">
                            Check how this content looks to students
                        </p>
                    </div>
                </div>
                <button type="button" onclick="openPreview()"
                    class="rounded-2xl border border-gray-200 bg-white px-5 py-2.5 text-xs font-black uppercase tracking-[0.18em] text-gray-500 transition-all hover:border-blue-100 hover:bg-blue-50/60 hover:text-math-dark-blue">
                    Open Preview
                </button>
            </div>

        </main>

        <!-- FOOTER -->
        <footer class="tc-footer flex-shrink-0 bg-white px-8 py-5 flex items-center justify-between">
            <div class="flex items-center gap-2 text-slate-400">
                <span class="material-symbols-outlined text-base">history</span>
                <span class="text-xs font-medium italic" id="lastEditedLabel">
                    Last edited just now
                </span>
            </div>
            <div class="flex items-center gap-4">
                <button type="button" onclick="closePanel()"
                    class="inline-flex items-center justify-center rounded-2xl border border-gray-200 bg-white px-6 py-3 text-xs font-black uppercase tracking-[0.18em] text-gray-500 transition-all hover:border-blue-100 hover:bg-blue-50/60 hover:text-math-dark-blue">
                    Discard
                </button>
                <asp:Button ID="btnSave" runat="server"
                    Text="Save to Module"
                    CssClass="tc-save-btn"
                    OnClick="btnSave_Click"
                    OnClientClick="return collectBeforeSave()" />
            </div>
        </footer>
    </div>

    <!-- Preview overlay -->
    <div id="previewOverlay"
         class="fixed inset-0 z-50 hidden bg-slate-900/70 backdrop-blur-sm
                items-center justify-center p-8">
        <div class="bg-white w-full max-w-3xl max-h-[90vh] flex flex-col
                    rounded-2xl overflow-hidden shadow-2xl">
            <div class="flex items-center justify-between bg-slate-100
                        border-b-2 border-slate-200 px-6 py-4">
                <p class="font-black text-slate-700 uppercase tracking-wider text-sm">
                    Student Preview
                </p>
                <button type="button" onclick="closePreview()"
                        class="text-slate-400 hover:text-slate-700 transition-colors">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            <div id="previewContent"
                 class="flex-1 overflow-y-auto p-8 prose max-w-none
                        text-base leading-relaxed text-slate-800"></div>
        </div>
    </div>

</form>

<script>
    // -
    //  INIT
    // -
    document.addEventListener('DOMContentLoaded', function () {

        // Pre-fill editor from DB content (via server hidden field)
        // hdnBodyHtml is set by LoadTextContent() from blockContentTable.textContent
        const savedHtml = document.getElementById('<%= hdnBodyHtml.ClientID %>').value;
        const editor = document.getElementById('editorBody');

        if (savedHtml && savedHtml.trim() !== '') {
            editor.innerHTML = savedHtml;   // real content from DB
        }
        // else: leave blank � user will type fresh content

        // Show PDF info row if a PDF was already saved in DB
        const savedPdfName = document.getElementById('<%= hdnPdfFileName.ClientID %>').value;
        if (savedPdfName && savedPdfName.trim() !== '') {
            showPdfInfo(savedPdfName, 'Previously attached');
        }

        // Attach editor event listeners AFTER DOMContentLoaded
        editor.addEventListener('keyup', updateToolbarState);
        editor.addEventListener('mouseup', updateToolbarState);

        startAutoSave();
    });

    // -
    //  RICH EDITOR
    // -
    function execCmd(cmd, value) {
        document.getElementById('editorBody').focus();
        document.execCommand(cmd, false, value || null);
        syncEditorToHidden();
        updateToolbarState();
    }

    function syncEditorToHidden() {
        // Store raw HTML � we base64-encode only right before postback
        document.getElementById('<%= hdnBodyHtml.ClientID %>').value =
            document.getElementById('editorBody').innerHTML;
    }

    function updateToolbarState() {
        ['bold', 'italic', 'underline'].forEach(cmd => {
            const btn = document.querySelector(`.tbtn[onclick*="${cmd}"]`);
            if (btn) btn.classList.toggle('tbtn-active',
                !!document.queryCommandState(cmd));
        });
    }

    // -
    //  TOOLBAR ACTIONS
    // -
    function insertMath() {
        const expr = prompt('Enter a math expression (e.g. x� + y� = z�):');
        if (!expr) return;
        const span = `<span class="bg-blue-50 px-1.5 rounded font-mono text-sm">${escHtml(expr)}</span>`;
        document.getElementById('editorBody').focus();
        document.execCommand('insertHTML', false, span);
        syncEditorToHidden();
    }

    function insertLink() {
        const url = prompt('Enter URL:');
        if (!url) return;
        document.getElementById('editorBody').focus();
        document.execCommand('createLink', false, url);
        syncEditorToHidden();
    }

    function triggerImageInsert() {
        document.getElementById('editorImageInput').click();
    }

    function insertImageFile(input) {
        if (!input.files || !input.files[0]) return;
        const reader = new FileReader();
        reader.onload = function (e) {
            const img = `<img src="${e.target.result}"
            style="max-width:100%;border-radius:0.5rem;margin:0.5rem 0;" alt="" />`;
            document.getElementById('editorBody').focus();
            document.execCommand('insertHTML', false, img);
            syncEditorToHidden();
        };
        reader.readAsDataURL(input.files[0]);
        input.value = '';
    }

    // -
    //  FULLSCREEN
    // -
    let isFullscreen = false;
    function toggleFullscreen() {
        const wrapper = document.querySelector('.editor-wrapper');
        const icon = document.getElementById('fsIcon');
        isFullscreen = !isFullscreen;
        if (isFullscreen) {
            wrapper.style.cssText =
                'position:fixed;inset:0;z-index:9999;border-radius:0;' +
                'border:none;display:flex;flex-direction:column;';
            icon.textContent = 'fullscreen_exit';
        } else {
            wrapper.style.cssText = '';
            icon.textContent = 'fullscreen';
        }
    }

    // -
    //  PDF � drag & drop + browse
    // -
    function handlePdfDragOver(e) {
        e.preventDefault();
        document.getElementById('pdfDropZone').classList.add('dragover');
    }
    function handlePdfDragLeave(e) {
        e.preventDefault();
        document.getElementById('pdfDropZone').classList.remove('dragover');
    }
    function handlePdfDrop(e) {
        e.preventDefault();
        document.getElementById('pdfDropZone').classList.remove('dragover');
        const file = e.dataTransfer?.files[0];
        if (!file) return;

        // ? Assign dropped file to the ASP FileUpload using DataTransfer API
        try {
            const dt = new DataTransfer();
            dt.items.add(file);
            document.getElementById('<%= fileUploadPdf.ClientID %>').files = dt.files;
    } catch (err) {
        // DataTransfer not supported in very old browsers � alert user
        alert('Please use the Browse button to select a file in this browser.');
        return;
    }
    processPdfFile(file);
}

// ? Called by onchange on the ASP FileUpload control
function handlePdfSelect(input) {
    if (input.files && input.files[0]) processPdfFile(input.files[0]);
}

function processPdfFile(file) {
    if (file.type !== 'application/pdf') {
        alert('Only PDF files are supported.'); return;
    }
    if (file.size > 10 * 1024 * 1024) {
        alert('File exceeds the 10MB limit.'); return;
    }
    document.getElementById('<%= hdnPdfFileName.ClientID %>').value = file.name;
    showPdfInfo(file.name, formatFileSize(file.size));
    updateLastEdited();
}

function showPdfInfo(name, sizeLabel) {
    document.getElementById('pdfDropZone').classList.add('hidden');
    document.getElementById('pdfFileName').textContent = name;
    document.getElementById('pdfFileSize').textContent = sizeLabel;
    const info = document.getElementById('pdfFileInfo');
    info.classList.remove('hidden');
    info.classList.add('flex');
}

function clearPdf() {
    // Hide file info, show drop zone again
    document.getElementById('pdfDropZone').classList.remove('hidden');
    const info = document.getElementById('pdfFileInfo');
    info.classList.add('hidden');
    info.classList.remove('flex');

    // Clear the ASP FileUpload control
    document.getElementById('<%= fileUploadPdf.ClientID %>').value = '';
    // Clear the saved PDF path so server knows to remove it
    document.getElementById('<%= hdnPdfPath.ClientID %>').value     = '';
    document.getElementById('<%= hdnPdfFileName.ClientID %>').value = '';
}

function formatFileSize(bytes) {
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

// -
//  PREVIEW
// -
function openPreview() {
    const overlay = document.getElementById('previewOverlay');
    document.getElementById('previewContent').innerHTML =
        document.getElementById('editorBody').innerHTML;
    overlay.classList.remove('hidden');
    overlay.classList.add('flex');
}
function closePreview() {
    const overlay = document.getElementById('previewOverlay');
    overlay.classList.add('hidden');
    overlay.classList.remove('flex');
}

// -
//  AUTO-SAVE + LAST EDITED
// -
let autoSaveTimer;
function startAutoSave() {
    document.getElementById('editorBody').addEventListener('input', () => {
        clearTimeout(autoSaveTimer);
        autoSaveTimer = setTimeout(() => {
            syncEditorToHidden();
            updateLastEdited();
        }, 800);
    });
}
function updateLastEdited() {
    document.getElementById('lastEditedLabel').textContent = 'Last edited just now';
}

// -
//  COLLECT BEFORE SAVE
//  Sync editor ? hidden field, then base64-encode so ASP.NET
//  request validation doesn't reject the HTML tags
// -
function collectBeforeSave() {
    syncEditorToHidden();  // ensure latest content in hidden field

    const hdnEl = document.getElementById('<%= hdnBodyHtml.ClientID %>');
        const html = hdnEl.value;

        try {
            // btoa requires Latin-1; encodeURIComponent + unescape handles Unicode
            hdnEl.value = btoa(unescape(encodeURIComponent(html)));
        } catch (e) {
            // If encoding fails, send plain � server has a fallback try/catch
            console.warn('Base64 encoding failed, sending plain HTML:', e);
        }
        return true;
    }

    // -
    //  CLOSE
    // -
    function closePanel() {
        if (window.parent && window.parent !== window)
            window.parent.postMessage('closeOverlay', window.location.origin);
        else window.history.back();
    }

    // -
    //  UTIL
    // -
    function escHtml(s) {
        return String(s)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;')
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
</script>

</body>
</html>

