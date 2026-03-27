<%@ Page Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="helpCenter.aspx.cs" Inherits="MathSphere.helpCenter" %>

<%-- Title --%>
<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere Admin — Create / Edit Help Article
</asp:Content>

<%-- Head (page-specific styles) --%>
<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/AdminUI/Styles/helpCenter.css") %>" rel="stylesheet" />
    <style>
        /* -- Rich-text toolbar buttons -- */
        .hc-tool-btn {
            background: #fff; border: 2px solid #e2e8f0; border-radius: .6rem;
            width: 2.25rem; height: 2.25rem;
            display: flex; align-items: center; justify-content: center;
            color: #1e3a8a; cursor: pointer; transition: all .15s;
        }
        .hc-tool-btn:hover { background: #eff6ff; border-color: #2563eb; }

        /* -- Publication status pills -- */
        .hc-pill { display: block; cursor: pointer; }
        .hc-pill-input { position: absolute; opacity: 0; width: 0; height: 0; }
        .hc-pill-card {
            border: 2px solid #e2e8f0; border-radius: 1rem;
            padding: .75rem; text-align: center; transition: all .15s;
            background: #f8fafc;
        }
        .hc-pill-input:checked + .hc-pill-card {
            border-color: #2563eb; background: #eff6ff;
        }
        .hc-pill-card-green.hc-pill-input:checked + .hc-pill-card,
        .hc-pill-input:checked + .hc-pill-card-green {
            border-color: #84cc16; background: #f7fee7;
        }
        .hc-pill-text {
            font-size: .75rem; font-weight: 900;
            text-transform: uppercase; letter-spacing: .1em; color: #1e3a8a;
        }
        .hc-pill-text-green { color: #3f6212; }

        /* -- Toggle switch -- */
        .hc-toggle { position: relative; display: inline-block; width: 44px; height: 24px; }
        .hc-toggle-checkbox input[type="checkbox"] { opacity: 0; width: 0; height: 0; }
        .hc-toggle-track {
            position: absolute; inset: 0; background: #e2e8f0;
            border-radius: 9999px; cursor: pointer; transition: background .2s;
        }
        .hc-toggle-track::before {
            content: ''; position: absolute;
            width: 18px; height: 18px; left: 3px; top: 3px;
            background: #fff; border-radius: 50%; transition: transform .2s;
            box-shadow: 0 1px 3px rgba(0,0,0,.2);
        }
        input:checked ~ .hc-toggle-track { background: #2563eb; }
        input:checked ~ .hc-toggle-track::before { transform: translateX(20px); }

        /* -- Action buttons -- */
        .hc-action {
            display: flex; align-items: center; justify-content: center; gap: .75rem;
            font-weight: 900; font-size: .85rem; text-transform: uppercase;
            letter-spacing: .08em; border-radius: 1.5rem; padding: 1.1rem 1.5rem;
            cursor: pointer; transition: all .15s; text-decoration: none;
        }
        .hc-action-primary {
            background: #f9d006; color: #1e3a8a;
            box-shadow: 0 5px 0 #c49a08;
            border: none;
        }
        .hc-action-primary:hover  { background: #f0c800; }
        .hc-action-primary:active { transform: translateY(3px); box-shadow: 0 2px 0 #c49a08; }
        .hc-action-outline {
            background: #fff; color: #2563eb;
            border: 2px solid #2563eb;
        }
        .hc-action-outline:hover  { background: #eff6ff; }

        /* -- Message panel colours -- */
        .msg-ok  { color: #166534; }
        .msg-err { color: #991b1b; }
        .msg-warn { color: #92400e; }

        /* -- Toast -- */
        #hcToast {
            position: fixed; bottom: 2rem; right: 2rem; z-index: 9999;
            background: #1e3a8a; color: #fff;
            padding: .9rem 1.6rem; border-radius: 1rem;
            font-weight: 900; font-size: .8rem; letter-spacing: .05em; text-transform: uppercase;
            box-shadow: 0 8px 32px rgba(30,58,138,.25);
            opacity: 0; transform: translateY(1rem);
            transition: opacity .3s, transform .3s; pointer-events: none;
        }
        #hcToast.visible { opacity: 1; transform: translateY(0); }
    </style>
</asp:Content>

<%-- Main content --%>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Hidden fields --%>
    <asp:HiddenField ID="hfArticleId" runat="server" />
    <asp:HiddenField ID="hfFeatured"  runat="server" />

    <%-- PAGE HEADER --%>
    <header class="mb-10">
        <a href="helpCenterHub.aspx"
           class="text-math-blue font-black uppercase tracking-widest text-xs flex items-center gap-2 hover:underline mb-3 w-fit">
            <span class="material-symbols-outlined text-base">arrow_back</span>
            Back to Hub
        </a>
        <h2 class="text-4xl font-black text-math-dark-blue mb-2 italic uppercase tracking-tighter">
            <asp:Literal ID="litModeTitle" runat="server" Text="Create New Entry" />
        </h2>
        <p class="text-lg text-gray-500 font-medium italic">
            <asp:Literal ID="litModeDesc" runat="server"
                Text="Compose a new knowledge base article or FAQ for your users." />
        </p>
    </header>

    <%-- MESSAGE PANEL --%>
    <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="mb-8">
        <div class="bg-white rounded-2xl border-2 border-gray-100 px-6 py-4 shadow-sm text-sm font-semibold">
            <asp:Literal ID="litMsg" runat="server"></asp:Literal>
        </div>
    </asp:Panel>

    <%-- EDITOR + SETTINGS --%>
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

        <%-- Left: Editor --%>
        <div class="lg:col-span-2 space-y-8">
            <div class="bg-white rounded-[2.5rem] p-8 shadow-xl border-2 border-gray-100">

                <div class="mb-8">
                    <label class="block text-xs font-black text-gray-400 uppercase tracking-widest mb-3 ml-2">Entry Title</label>
                    <asp:TextBox ID="txtTitle" runat="server"
                        CssClass="w-full bg-gray-50 border-2 border-gray-100 rounded-2xl px-6 py-4 text-xl font-bold text-math-dark-blue placeholder-gray-300 focus:border-math-blue focus:ring-0 transition-all outline-none"
                        placeholder="e.g., How to solve quadratic equations in MathSphere" />
                </div>

                <div>
                    <label class="block text-xs font-black text-gray-400 uppercase tracking-widest mb-3 ml-2">Article Body</label>
                    <div class="border-2 border-gray-100 rounded-3xl overflow-hidden">

                        <%-- Toolbar --%>
                        <div class="bg-gray-50 border-b-2 border-gray-100 p-4 flex flex-wrap gap-2">
                            <button type="button" class="hc-tool-btn" onclick="hcFormat('bold')" title="Bold">
                                <span class="material-symbols-outlined">format_bold</span>
                            </button>
                            <button type="button" class="hc-tool-btn" onclick="hcFormat('italic')" title="Italic">
                                <span class="material-symbols-outlined">format_italic</span>
                            </button>
                            <button type="button" class="hc-tool-btn" onclick="hcFormat('underline')" title="Underline">
                                <span class="material-symbols-outlined">format_underlined</span>
                            </button>
                            <div class="w-px h-6 bg-gray-200 self-center mx-1"></div>
                            <button type="button" class="hc-tool-btn" onclick="hcInsertList('ul')" title="Bullet list">
                                <span class="material-symbols-outlined">format_list_bulleted</span>
                            </button>
                            <button type="button" class="hc-tool-btn" onclick="hcInsertList('ol')" title="Numbered list">
                                <span class="material-symbols-outlined">format_list_numbered</span>
                            </button>
                            <div class="w-px h-6 bg-gray-200 self-center mx-1"></div>
                            <button type="button" class="hc-tool-btn" onclick="hcInsertLink()" title="Insert link">
                                <span class="material-symbols-outlined">link</span>
                            </button>
                        </div>

                        <asp:TextBox ID="txtBody" runat="server"
                            TextMode="MultiLine" Rows="12"
                            CssClass="w-full bg-white border-none focus:ring-0 p-8 text-math-dark-blue font-medium leading-relaxed resize-none outline-none"
                            placeholder="Start writing your article here..." />
                    </div>
                </div>
            </div>
        </div>

        <%-- Right: Settings + Actions --%>
        <div class="lg:col-span-1 space-y-8">

            <div class="bg-white rounded-[2.5rem] p-8 shadow-xl border-2 border-math-blue/10">
                <h3 class="text-xl font-black text-math-dark-blue uppercase tracking-tight flex items-center gap-2 mb-8">
                    <span class="material-symbols-outlined text-math-blue">settings</span>
                    Entry Settings
                </h3>

                <div class="space-y-8">

                    <%-- Category --%>
                    <div>
                        <label class="block text-xs font-black text-gray-400 uppercase tracking-widest mb-3">Category Selection</label>
                        <div class="relative">
                            <asp:DropDownList ID="ddlCategory" runat="server"
                                CssClass="w-full appearance-none bg-gray-50 border-2 border-gray-100 rounded-2xl px-5 py-4 font-bold text-math-dark-blue focus:border-math-blue focus:ring-0 transition-all cursor-pointer">
                                <asp:ListItem Text="Account Management"       Value="account" />
                                <asp:ListItem Text="Courses &amp; Curriculum" Value="courses" />
                                <asp:ListItem Text="Technical Support"        Value="technical" />
                                <asp:ListItem Text="Billing &amp; Payments"   Value="payments" />
                            </asp:DropDownList>
                            <span class="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400">expand_more</span>
                        </div>
                    </div>

                    <%-- Publication status pills --%>
                    <div>
                        <label class="block text-xs font-black text-gray-400 uppercase tracking-widest mb-3">Publication Status</label>
                        <div class="flex gap-4">
                            <label class="hc-pill flex-1">
                                <input id="rbDraft" runat="server" type="radio" name="hcStatus" class="hc-pill-input" />
                                <div class="hc-pill-card">
                                    <span class="hc-pill-text">Draft</span>
                                </div>
                            </label>
                            <label class="hc-pill flex-1">
                                <input id="rbPublished" runat="server" type="radio" name="hcStatus" class="hc-pill-input" />
                                <div class="hc-pill-card">
                                    <span class="hc-pill-text" style="color:#3f6212">Published</span>
                                </div>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Action buttons --%>
            <div class="flex flex-col gap-4">
                <asp:LinkButton ID="btnPublish" runat="server"
                    OnClick="btnPublish_Click"
                    CssClass="hc-action hc-action-primary">
                    <span class="material-symbols-outlined" style="font-size:22px;font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">save</span>
                    <span>Save Article</span>
                </asp:LinkButton>
            </div>
        </div>
    </div>

    <%-- STAT CARDS --%>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mt-16">
        <div class="bg-blue-50 border-4 border-math-blue/10 rounded-3xl p-6 flex items-center gap-6 hover:border-math-blue/30 transition-all">
            <div class="size-14 bg-white rounded-2xl flex items-center justify-center text-math-blue shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">person_celebrate</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-math-blue uppercase tracking-widest">Growth</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    +<asp:Literal ID="litGrowth" runat="server" Text="0" />
                    <span class="text-sm font-bold opacity-60">This Week</span>
                </div>
            </div>
        </div>

        <div class="bg-green-50 border-4 border-math-green/10 rounded-3xl p-6 flex items-center gap-6 hover:border-math-green/30 transition-all">
            <div class="size-14 bg-white rounded-2xl flex items-center justify-center text-math-green shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">how_to_reg</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-math-green uppercase tracking-widest">Active Rate</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litActiveRate" runat="server" Text="0%" />
                    <span class="text-sm font-bold opacity-60">Verified</span>
                </div>
            </div>
        </div>

        <div class="bg-yellow-50 border-4 border-primary/10 rounded-3xl p-6 flex items-center gap-6 hover:border-primary/30 transition-all">
            <div class="size-14 bg-white rounded-2xl flex items-center justify-center text-primary shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">shield_person</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-primary uppercase tracking-widest">Staff Count</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litStaffCount" runat="server" Text="0" />
                    <span class="text-sm font-bold opacity-60">Privileged</span>
                </div>
            </div>
        </div>
    </div>

    <%-- TOAST --%>
    <div id="hcToast"></div>

    <script>
        // Toolbar helpers
        function hcFormat(cmd) {
            var ta = document.getElementById('<%= txtBody.ClientID %>');
            var start = ta.selectionStart, end = ta.selectionEnd;
            var sel = ta.value.substring(start, end);
            var tag = { bold: '**', italic: '_', underline: '__' }[cmd] || '';
            if (!sel) return;
            ta.setRangeText(tag + sel + tag, start, end, 'select');
        }

        function hcInsertList(type) {
            var ta = document.getElementById('<%= txtBody.ClientID %>');
            var bullet = type === 'ul' ? '- ' : '1. ';
            ta.setRangeText('\n' + bullet, ta.selectionStart, ta.selectionEnd, 'end');
        }

        function hcInsertLink() {
            var url = prompt('Enter URL:');
            if (!url) return;
            var ta  = document.getElementById('<%= txtBody.ClientID %>');
            var start = ta.selectionStart, end = ta.selectionEnd;
            var sel = ta.value.substring(start, end) || 'link text';
            ta.setRangeText('[' + sel + '](' + url + ')', start, end, 'end');
        }

        // Toast
        function showHcToast(msg) {
            var el = document.getElementById('hcToast');
            el.textContent = msg;
            el.classList.add('visible');
            setTimeout(function () { el.classList.remove('visible'); }, 3200);
        }
    </script>

</asp:Content>

