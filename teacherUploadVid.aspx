<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="teacherUploadVid.aspx.cs" Inherits="MathSphere.teacherUploadVid" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere - Configure Video Block</title>

    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>

    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f9d006",
                        "math-blue": "#2563eb",
                        "math-green": "#84cc16",
                        "math-dark-blue": "#1e3a8a"
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    }
                }
            }
        }
    </script>

    <style>
        body {
            font-family: 'Space Grotesk', sans-serif;
            background: transparent;
        }

        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }

        .video-shell-scroll::-webkit-scrollbar {
            width: 6px;
        }

        .video-shell-scroll::-webkit-scrollbar-track {
            background: #f8fafc;
            border-radius: 9999px;
        }

        .video-shell-scroll::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 9999px;
        }

        .video-shell-scroll::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }
    </style>
</head>

<body class="m-0 p-0 overflow-hidden">
<form id="form1" runat="server">

    <asp:HiddenField ID="hdnActiveTab" runat="server" Value="link" />
    <asp:HiddenField ID="hdnBlockId" runat="server" />

    <div class="h-screen w-full overflow-hidden rounded-[2rem] border border-white/70 bg-white/95 shadow-[0_24px_60px_rgba(30,58,138,0.18)] backdrop-blur-md flex flex-col">

        <header class="shrink-0 bg-gradient-to-r from-math-dark-blue via-math-blue to-blue-500 px-7 py-5 flex items-center gap-4">
            <div class="size-11 rounded-2xl bg-white/20 flex items-center justify-center shadow-sm">
                <span class="material-symbols-outlined text-white text-[28px]" style="font-variation-settings:'FILL' 1">play_circle</span>
            </div>
            <div>
                <h1 class="text-white text-lg font-black uppercase tracking-tight leading-none">Configure Video Block</h1>
                <p class="text-blue-100 text-[11px] font-semibold uppercase tracking-[0.18em] mt-1">Teacher content setup</p>
            </div>
            <button type="button" id="btnClose" onclick="closeModal()"
                class="ml-auto size-10 rounded-2xl bg-white/15 hover:bg-white/20 flex items-center justify-center transition-colors">
                <span class="material-symbols-outlined text-white text-xl">close</span>
            </button>
        </header>

        <main class="flex-1 overflow-y-auto video-shell-scroll bg-white px-7 py-7">
            <div class="max-w-4xl mx-auto grid gap-6 lg:grid-cols-[minmax(0,1.1fr)_320px]">

                <section class="rounded-[2rem] border border-gray-100 bg-white shadow-[0_18px_40px_rgba(30,58,138,0.06)] p-6 sm:p-7 space-y-6">
                    <div>
                        <p class="text-[10px] font-black uppercase tracking-[0.22em] text-gray-400 mb-2">Video Source</p>
                        <label class="block text-xs font-black uppercase tracking-widest text-math-dark-blue mb-3">YouTube URL</label>
                        <div class="relative">
                            <span class="material-symbols-outlined pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-300 text-lg">link</span>
                            <asp:TextBox ID="txtVideoUrl" runat="server"
                                CssClass="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 py-4 pl-12 pr-4 text-sm font-bold text-math-dark-blue outline-none transition-all focus:border-math-blue focus:bg-white focus:ring-0"
                                placeholder="https://youtube.com/watch?v=..."
                                onkeyup="handleUrlInput(this.value)">
                            </asp:TextBox>
                        </div>
                        <p class="mt-3 text-xs font-medium text-gray-400">Only YouTube links are supported for this video block.</p>
                    </div>

                    <div class="rounded-[1.75rem] border-2 border-dashed border-gray-200 bg-gray-50 p-4 sm:p-5">
                        <div id="previewContainer" class="relative aspect-video overflow-hidden rounded-[1.4rem] border border-gray-200 bg-white">
                            <div id="previewEmpty" class="absolute inset-0 flex flex-col items-center justify-center text-center text-gray-300">
                                <span class="material-symbols-outlined text-5xl mb-2">smart_display</span>
                                <p class="text-[11px] font-black uppercase tracking-[0.22em]">Preview will appear here</p>
                            </div>
                            <iframe id="previewIframe"
                                class="hidden absolute inset-0 h-full w-full"
                                frameborder="0"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen>
                            </iframe>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-black uppercase tracking-widest text-math-dark-blue mb-3">Video Caption / Title</label>
                        <asp:TextBox ID="txtCaption" runat="server"
                            CssClass="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 px-4 py-4 text-sm font-bold text-math-dark-blue outline-none transition-all focus:border-math-blue focus:bg-white focus:ring-0"
                            placeholder="Introduction to Algebra Concepts">
                        </asp:TextBox>
                    </div>
                </section>

                <aside class="rounded-[2rem] bg-gradient-to-br from-math-dark-blue via-math-blue to-blue-500 p-6 text-white overflow-hidden relative shadow-[0_18px_40px_rgba(37,99,235,0.18)]">
                    <div class="absolute -top-8 -right-8 size-28 rounded-full bg-white/10"></div>
                    <div class="absolute -bottom-10 -left-10 size-32 rounded-full bg-white/5"></div>
                    <div class="relative z-10 space-y-6">
                        <div>
                            <p class="text-[10px] font-black uppercase tracking-[0.22em] text-blue-100">Best Practice</p>
                            <h2 class="mt-2 text-2xl font-black leading-tight">Keep the video short, focused, and easy to revisit.</h2>
                        </div>

                        <div class="space-y-3">
                            <div class="flex items-center gap-3 rounded-2xl border border-white/20 bg-white/10 px-4 py-3">
                                <span class="material-symbols-outlined text-primary" style="font-variation-settings:'FILL' 1">play_lesson</span>
                                <span class="text-sm font-bold">Use one clear concept per video</span>
                            </div>
                            <div class="flex items-center gap-3 rounded-2xl border border-white/20 bg-white/10 px-4 py-3">
                                <span class="material-symbols-outlined text-primary" style="font-variation-settings:'FILL' 1">subtitles</span>
                                <span class="text-sm font-bold">Add a caption students can recognise</span>
                            </div>
                            <div class="flex items-center gap-3 rounded-2xl border border-white/20 bg-white/10 px-4 py-3">
                                <span class="material-symbols-outlined text-primary" style="font-variation-settings:'FILL' 1">lightbulb</span>
                                <span class="text-sm font-bold">Pair the video with a quick follow-up activity</span>
                            </div>
                        </div>
                    </div>
                </aside>
            </div>
        </main>

        <footer class="shrink-0 border-t border-gray-100 bg-white px-7 py-5">
            <div class="max-w-4xl mx-auto flex flex-col-reverse gap-3 sm:flex-row sm:items-center sm:justify-between">
                <button type="button" onclick="closeModal()"
                    class="inline-flex items-center justify-center rounded-2xl border border-gray-200 bg-white px-6 py-3 text-xs font-black uppercase tracking-[0.18em] text-gray-500 transition-all hover:border-blue-100 hover:bg-blue-50/60 hover:text-math-dark-blue">
                    Cancel
                </button>

                <asp:Button ID="btnAttach" runat="server"
                    Text="Attach to Module"
                    CssClass="inline-flex items-center justify-center rounded-2xl bg-primary px-7 py-3.5 text-sm font-black uppercase tracking-[0.18em] text-math-dark-blue border-0 shadow-[0_16px_30px_rgba(249,208,6,0.18)] transition-all hover:-translate-y-0.5"
                    OnClick="btnAttach_Click"
                    OnClientClick="return validateForm();" />
            </div>
        </footer>

    </div>

</form>

<script>
    function handleUrlInput(url) {
        const iframe = document.getElementById('previewIframe');
        const empty = document.getElementById('previewEmpty');
        const youtubeId = extractYouTubeId(url);

        if (youtubeId) {
            iframe.src = `https://www.youtube.com/embed/${youtubeId}`;
            iframe.classList.remove('hidden');
            empty.classList.add('hidden');
        } else {
            iframe.src = '';
            iframe.classList.add('hidden');
            empty.classList.remove('hidden');
        }
    }

    function extractYouTubeId(url) {
        const m = (url || '').match(/(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)/);
        return m ? m[1] : null;
    }

    function validateForm() {
        const url = document.getElementById('<%= txtVideoUrl.ClientID %>').value.trim();
        if (!url) {
            alert('Please enter a YouTube URL.');
            return false;
        }
        if (!extractYouTubeId(url)) {
            alert('Only YouTube URLs are supported.\nExample: https://youtube.com/watch?v=...');
            return false;
        }
        return true;
    }

    function closeModal() {
        if (window.parent && window.parent !== window) {
            window.parent.postMessage('closeOverlay', window.location.origin);
        } else if (window.opener) {
            window.close();
        } else {
            window.location.href = 'moduleBuilder.aspx';
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        const url = document.getElementById('<%= txtVideoUrl.ClientID %>').value || '';
        if (url.trim()) handleUrlInput(url);
    });
</script>

</body>
</html>
