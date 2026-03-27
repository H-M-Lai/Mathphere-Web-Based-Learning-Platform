<%@ Page Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="forumModeration.aspx.cs" Inherits="MathSphere.forumModeration" %>

<asp:Content ContentPlaceHolderID="TitleContent" runat="server">
    MathSphere Admin — Forum Moderation
</asp:Content>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/AdminUI/Styles/forumModeration.css") %>" rel="stylesheet" />
    <style>
        /* -- Toast -- */
        #fmToast {
            position: fixed; bottom: 2rem; right: 2rem; z-index: 9999;
            background: #1e3a8a; color: #fff;
            padding: .9rem 1.6rem; border-radius: 1rem;
            font-weight: 900; font-size: .8rem; letter-spacing: .05em; text-transform: uppercase;
            box-shadow: 0 8px 32px rgba(30,58,138,.25);
            opacity: 0; transform: translateY(1rem);
            transition: opacity .3s, transform .3s;
            pointer-events: none;
        }
        #fmToast.show { opacity: 1; transform: translateY(0); pointer-events: auto; }

        /* -- Modal overlays -- */
        .fm-overlay {
            position: fixed; inset: 0; z-index: 200;
            background: rgba(30,58,138,.4); backdrop-filter: blur(4px);
            display: none; align-items: center; justify-content: center; padding: 1rem;
        }
        .fm-card {
            background: #fff; border-radius: 2rem; width: 100%; max-width: 480px;
            box-shadow: 0 24px 60px rgba(0,0,0,.18); overflow: hidden;
        }
        .fm-card-warn {
            background: #fff; border-radius: 2rem; width: 100%; max-width: 520px;
            box-shadow: 0 24px 60px rgba(0,0,0,.18); overflow: hidden;
        }
        .fm-close {
            position: absolute; top: 1rem; right: 1rem;
            background: #f1f5f9; border: none; border-radius: 50%;
            width: 2rem; height: 2rem; display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: #64748b;
        }
        .fm-close:hover { background: #e2e8f0; }

        /* Delete modal */
        .del-top { background: #fef2f2; padding: 2rem 2rem 1.5rem; text-align: center; position: relative; }
        .del-icon { margin-bottom: .5rem; }
        .del-title { font-size: 1.25rem; font-weight: 900; color: #1e3a8a; }
        .del-body { padding: 1.5rem 2rem 2rem; }
        .del-preview { background: #f8fafc; border-radius: 1rem; padding: 1rem 1.2rem; margin-bottom: 1.2rem; border: 2px solid #f1f5f9; }
        .del-badge { font-size: .65rem; font-weight: 900; text-transform: uppercase; letter-spacing: .12em; color: #ef4444; display: block; margin-bottom: .4rem; }
        .del-preview-txt { font-size: .85rem; color: #475569; font-style: italic; line-height: 1.5; margin: 0; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
        .del-sel-wrap { position: relative; margin-bottom: 1rem; }
        .del-sel { width: 100%; background: #f8fafc; border: 2px solid #e2e8f0; border-radius: .75rem; padding: .7rem 2.5rem .7rem 1rem; font-weight: 700; font-size: .85rem; color: #1e3a8a; appearance: none; cursor: pointer; }
        .del-chevron { position: absolute; right: .75rem; top: 50%; transform: translateY(-50%); font-size: 18px; color: #94a3b8; pointer-events: none; }
        .btn-del3d { display: flex; align-items: center; justify-content: center; gap: .5rem; width: 100%; background: #ef4444; color: #fff; border: none; border-radius: 1rem; padding: .9rem; font-weight: 900; font-size: .85rem; text-transform: uppercase; letter-spacing: .08em; cursor: pointer; box-shadow: 0 4px 0 #b91c1c; transition: all .15s; margin-bottom: .6rem; }
        .btn-del3d:hover { background: #dc2626; }
        .btn-del3d:active { transform: translateY(2px); box-shadow: 0 2px 0 #b91c1c; }
        .btn-mcancel { display: block; width: 100%; background: #f1f5f9; color: #64748b; border: none; border-radius: 1rem; padding: .75rem; font-weight: 900; font-size: .8rem; text-transform: uppercase; letter-spacing: .08em; cursor: pointer; transition: background .15s; }
        .btn-mcancel:hover { background: #e2e8f0; }
        .del-note { font-size: .72rem; color: #94a3b8; text-align: center; margin-top: .8rem; margin-bottom: 0; }
        .f-lbl { display: block; font-size: .75rem; font-weight: 900; color: #1e3a8a; text-transform: uppercase; letter-spacing: .08em; margin-bottom: .5rem; }

        /* Warn modal */
        .warn-top { display: flex; align-items: center; gap: 1rem; background: #fefce8; border-bottom: 2px solid #fef08a; padding: 1.5rem 2rem; }
        .warn-top-icon { background: #f9d006; border-radius: .75rem; width: 2.8rem; height: 2.8rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .warn-title { font-size: 1.15rem; font-weight: 900; color: #1e3a8a; }
        .warn-sub { font-size: .78rem; color: #64748b; font-weight: 600; margin: 0; }
        .warn-body { padding: 1.5rem 2rem; }
        .warn-reason-sel-wrap { position: relative; margin-bottom: 1.2rem; }
        .warn-reason-sel { width: 100%; background: #f8fafc; border: 2px solid #e2e8f0; border-radius: .75rem; padding: .7rem 2.5rem .7rem 1rem; font-weight: 700; font-size: .85rem; color: #1e3a8a; appearance: none; cursor: pointer; }
        .warn-reason-chevron { position: absolute; right: .75rem; top: 50%; transform: translateY(-50%); color: #94a3b8; pointer-events: none; }
        .warn-type-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: .6rem; margin-bottom: 1.2rem; }
        .wpill { background: #f8fafc; border: 2px solid #e2e8f0; border-radius: .75rem; padding: .6rem .5rem; cursor: pointer; display: flex; flex-direction: column; align-items: center; transition: all .15s; }
        .wpill:hover { border-color: #cbd5e1; }
        .wpill.wy { background: #fefce8; border-color: #f9d006; }
        .wpill.wr { background: #fef2f2; border-color: #ef4444; }
        .wpill-name { font-size: .8rem; font-weight: 900; color: #1e3a8a; }
        .wpill-sub  { font-size: .65rem; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: .06em; margin-top: .15rem; }
        .warn-msg-hdr { display: flex; justify-content: space-between; align-items: center; margin-bottom: .5rem; }
        .tpl-btn { font-size: .72rem; font-weight: 900; color: #2563eb; background: none; border: none; cursor: pointer; text-transform: uppercase; letter-spacing: .06em; }
        .tpl-btn:hover { color: #1d4ed8; }
        .warn-ta-wrap { background: #f8fafc; border: 2px solid #e2e8f0; border-radius: .75rem; overflow: hidden; margin-bottom: 1rem; }
        .warn-ta { width: 100%; background: transparent; border: none; padding: .9rem 1rem; font-size: .9rem; color: #334155; resize: none; outline: none; display: block; }
        .warn-toolbar { display: flex; gap: .3rem; padding: .4rem .8rem; border-top: 2px solid #f1f5f9; }
        .tb-btn { background: none; border: none; cursor: pointer; color: #94a3b8; padding: .2rem .4rem; border-radius: .3rem; font-size: .85rem; }
        .tb-btn:hover { background: #f1f5f9; color: #1e3a8a; }
        .btn-warn3d { display: flex; align-items: center; justify-content: center; gap: .5rem; width: 100%; background: #2563eb; color: #fff; border: none; border-radius: 1rem; padding: .9rem; font-weight: 900; font-size: .85rem; text-transform: uppercase; letter-spacing: .08em; cursor: pointer; box-shadow: 0 4px 0 #1d4ed8; transition: all .15s; margin-bottom: .6rem; }
        .btn-warn3d:hover { background: #1d4ed8; }
        .btn-warn3d:active { transform: translateY(2px); box-shadow: 0 2px 0 #1d4ed8; }
        .warn-footer { display: flex; justify-content: space-between; padding: .9rem 2rem; background: #f8fafc; border-top: 2px solid #f1f5f9; }
        .warn-fi { display: flex; align-items: center; gap: .35rem; font-size: .72rem; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: .06em; }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Hidden fields for modals --%>
    <asp:HiddenField ID="hfFlagId"   runat="server"/>
    <asp:HiddenField ID="hfPostUser" runat="server"/>
    <asp:HiddenField ID="hfWarnType" runat="server" Value="Major"/>

    <%-- Toast --%>
    <div id="fmToast"></div>

    <%-- Page header --%>
    <section class="relative mb-10 overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
        <div class="absolute -right-16 -top-16 size-52 rounded-full bg-blue-100/70 blur-3xl"></div>
        <div class="absolute bottom-0 left-0 h-32 w-48 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
        <div class="relative flex flex-col gap-8 xl:flex-row xl:items-end xl:justify-between">
            <div class="max-w-3xl space-y-3">
                <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                    <span class="material-symbols-outlined text-sm fill-icon">security</span>
                    Moderation queue
                </div>
                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Forum Moderation</h2>
                <p class="max-w-2xl text-base font-medium leading-7 text-gray-500 lg:text-lg">
                    Review flagged community posts, resolve violations, and guide forum behaviour from one shared admin workspace.
                </p>
            </div>
            <div class="flex flex-wrap gap-3">
                <div class="inline-flex items-center gap-3 rounded-[1.5rem] border border-white/70 bg-white/90 px-5 py-4 shadow-sm">
                    <span class="size-3 rounded-full bg-red-500 animate-pulse"></span>
                    <asp:Literal ID="litPendingReports" runat="server"/>
                </div>
                <div class="inline-flex items-center gap-2 rounded-[1.5rem] border border-white/70 bg-white/90 px-5 py-4 shadow-sm">
                    <div class="size-2 rounded-full bg-math-green animate-pulse"></div>
                    <span class="text-xs font-black uppercase tracking-[0.18em] text-math-dark-blue">Live DB Connected</span>
                </div>
            </div>
        </div>
    </section>

    <%-- Flagged posts repeater --%>
    <div class="space-y-6 mb-16">
        <asp:Repeater ID="rptFlaggedPosts" runat="server"
                      OnItemCommand="rptFlaggedPosts_ItemCommand">
            <ItemTemplate>
                <div class="rounded-[2.5rem] border border-white/70 bg-white/95 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)] transition-all hover:-translate-y-1 hover:shadow-[0_22px_48px_rgba(30,58,138,0.12)]">
                    <div class="flex items-start justify-between gap-6">

                        <%-- Left: post info --%>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="size-12 rounded-full border-2 border-primary overflow-hidden bg-yellow-100 flex-shrink-0">
                                    <img alt="avatar" class="w-full h-full object-cover" src='<%# Eval("StudentAvatar") %>'/>
                                </div>
                                <div>
                                    <div class="text-lg font-black text-math-dark-blue"><%# Eval("StudentName") %></div>
                                    <div class="flex items-center gap-2 mt-0.5 flex-wrap">
                                        <span class="bg-blue-100 text-math-blue text-[10px] font-black px-2 py-0.5 rounded-full uppercase">
                                            <%# (Eval("category") == DBNull.Value || string.IsNullOrEmpty(Eval("category")?.ToString())) ? "Forum" : Eval("category").ToString() %>
                                        </span>
                                        <span class="text-gray-400 text-[10px] font-bold uppercase tracking-widest">Flagged <%# Eval("TimeAgo") %></span>
                                    </div>
                                </div>
                            </div>

                            <div class="bg-gray-50 rounded-2xl p-6 mb-4 border-2 border-gray-100/50">
                                <h4 class="font-bold text-math-dark-blue mb-2 text-lg"><%# Eval("PostTitle") %></h4>

                                <p class="text-gray-600 leading-relaxed italic text-sm mb-3">
                                    <%# Eval("PostContent") %>
                                </p>

                                <asp:Panel runat="server"
                                    Visible='<%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("PostImageUrl"))) %>'>
                                    <img src='<%# ResolveUrl("~/" + Convert.ToString(Eval("PostImageUrl")).TrimStart('/')) %>'
                                         alt="Post image"
                                         class="mt-2 rounded-xl max-h-72 border-2 border-gray-100 bg-white object-contain" />
                                </asp:Panel>
                            </div>

                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="text-xs font-black text-gray-400 uppercase tracking-widest">Reason:</span>
                                <span class="bg-red-50 text-red-600 text-xs font-black px-3 py-1 rounded-lg uppercase border border-red-100"><%# Eval("FlagReason") %></span>
                                <span class="text-xs font-bold text-gray-300">•</span>
                                <span class="text-xs font-bold text-gray-400">Flagged by: <strong class="text-math-dark-blue"><%# Eval("FlaggedByName") %></strong></span>
                            </div>
                        </div>

                        <%-- Right: action buttons --%>
                        <div class="flex flex-col gap-3 min-w-[210px] flex-shrink-0">

                            <%-- ? KEEP POST — green --%>
                            <asp:LinkButton runat="server"
                                CommandName="KEEP"
                                CommandArgument='<%# Eval("flagID") %>'
                                CssClass="w-full flex items-center justify-center gap-2 bg-[#7dc142] hover:bg-[#6aad30] active:scale-[0.98] text-white font-black text-sm uppercase tracking-widest px-6 py-4 rounded-2xl shadow-lg shadow-green-200 transition-all border-b-4 border-[#5a9626]">
                                <span class="material-symbols-outlined text-xl" style="font-variation-settings:'FILL' 1">check_circle</span>
                                Keep Post
                            </asp:LinkButton>

                            <%-- ? DELETE POST — red --%>
                            <button type="button"
                                onclick='openDel(
                                    "<%# Eval("flagID") %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(Eval("StudentName")?.ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(Eval("PostContent")?.ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(Eval("FlagReason")?.ToString()) %>")'
                                class="w-full flex items-center justify-center gap-2 bg-[#e03e3e] hover:bg-[#cc2c2c] active:scale-[0.98] text-white font-black text-sm uppercase tracking-widest px-6 py-4 rounded-2xl shadow-lg shadow-red-200 transition-all border-b-4 border-[#b02222]">
                                <span class="material-symbols-outlined text-xl">cancel</span>
                                Delete Post
                            </button>

                            <%-- ?? WARN USER — yellow --%>
                            <button type="button"
                                onclick='openWarn(
                                    "<%# Eval("flagID") %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(Eval("StudentName")?.ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(Eval("FlagReason")?.ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(Eval("LastWarnText")?.ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(Eval("WarnCount")?.ToString()) %>")'
                                class="w-full flex items-center justify-center gap-2 bg-[#f5c518] hover:bg-[#e0b010] active:scale-[0.98] text-[#1e3a8a] font-black text-sm uppercase tracking-widest px-6 py-4 rounded-2xl shadow-lg shadow-yellow-200 transition-all border-b-4 border-[#c49a08]">
                                <span class="material-symbols-outlined text-xl">warning</span>
                                Warn User
                            </button>

                        </div>
                    </div>
                </div>
            </ItemTemplate>

            <%-- Empty state --%>
            <FooterTemplate>
                <%# rptFlaggedPosts_IsEmpty() ? @"
                <div class='rounded-[2.5rem] border border-dashed border-gray-200 bg-white/90 p-16 text-center shadow-[0_16px_32px_rgba(30,58,138,0.05)]'>
                    <span class=""material-symbols-outlined text-6xl text-gray-200 mb-4 block"" style=""font-variation-settings:'FILL' 1"">verified_user</span>
                    <h3 class=""text-2xl font-black text-gray-300 mb-2"">All Clear!</h3>
                    <p class=""text-gray-400 font-medium"">No flagged posts requiring attention right now.</p>
                </div>" : "" %>
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <%-- Live stats cards — fully DB connected --%>
    <div class="grid grid-cols-1 gap-6 pb-10 md:grid-cols-3">

        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex size-14 flex-shrink-0 items-center justify-center rounded-2xl bg-red-50 text-red-500 shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1">flag</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-red-500 uppercase tracking-widest">Open Flags</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litOpenFlags" runat="server" Text="0"/>
                    <span class="text-sm font-bold text-gray-400">Pending</span>
                </div>
            </div>
        </div>

        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex size-14 flex-shrink-0 items-center justify-center rounded-2xl bg-green-50 text-math-green shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1">how_to_reg</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-math-green uppercase tracking-widest">Resolved Today</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litResolvedToday" runat="server" Text="0"/>
                    <span class="text-sm font-bold text-gray-400">Actions</span>
                </div>
            </div>
        </div>

        <div class="rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]">
            <div class="flex size-14 flex-shrink-0 items-center justify-center rounded-2xl bg-yellow-50 text-primary shadow-sm">
                <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1">shield_person</span>
            </div>
            <div>
                <div class="text-[10px] font-black text-primary uppercase tracking-widest">Total Actions</div>
                <div class="text-2xl font-black text-math-dark-blue">
                    <asp:Literal ID="litTotalActions" runat="server" Text="0"/>
                    <span class="text-sm font-bold text-gray-400">All Time</span>
                </div>
            </div>
        </div>

    </div>

    <%-- DELETE MODAL --%>
    <div id="modalDelete" class="fm-overlay" onclick="bgClick(event,'modalDelete')">
        <div class="fm-card" onclick="event.stopPropagation()">
            <div class="del-top">
                <button type="button" class="fm-close" onclick="closeDel()">
                    <span class="material-symbols-outlined" style="font-size:17px">close</span>
                </button>
                <div class="del-icon">
                    <span class="material-symbols-outlined" style="font-size:2.6rem;color:#ef4444;font-variation-settings:'FILL' 1">delete_forever</span>
                </div>
                <h3 class="del-title">Permanently Delete Post?</h3>
            </div>
            <div class="del-body">
                <div class="del-preview">
                    <span class="del-badge">Flagged Post Content</span>
                    <p id="delTxt" class="del-preview-txt">…</p>
                </div>
                <label class="f-lbl">Reason for Action</label>
                <div class="del-sel-wrap">
                    <asp:DropDownList ID="ddlDeleteReason" runat="server" CssClass="del-sel">
                        <asp:ListItem Value="Harassment / Bullying"  Selected="True">Harassment / Bullying</asp:ListItem>
                        <asp:ListItem Value="Spam / Self-Promotion">Spam / Self-Promotion</asp:ListItem>
                        <asp:ListItem Value="Academic Dishonesty">Academic Dishonesty</asp:ListItem>
                        <asp:ListItem Value="Inappropriate Language">Inappropriate Language</asp:ListItem>
                    </asp:DropDownList>
                    <span class="del-chevron material-symbols-outlined">unfold_more</span>
                </div>
                <asp:LinkButton ID="btnConfirmDelete" runat="server"
                    OnClick="btnConfirmDelete_Click" CssClass="btn-del3d">
                    <span class="material-symbols-outlined">delete</span> Delete Post
                </asp:LinkButton>
                <button type="button" class="btn-mcancel" onclick="closeDel()">Cancel</button>
                <p class="del-note">This action is irreversible. The user will be notified of the deletion.</p>
            </div>
        </div>
    </div>

    <%-- WARN MODAL --%>
    <div id="modalWarn" class="fm-overlay" onclick="bgClick(event,'modalWarn')">
        <div class="fm-card-warn" onclick="event.stopPropagation()">
            <div class="warn-top">
                <div class="warn-top-icon">
                    <span class="material-symbols-outlined" style="font-size:1.5rem;color:#0f172a;font-variation-settings:'FILL' 1">warning</span>
                </div>
                <div>
                    <h2 class="warn-title">Issue User Warning</h2>
                    <p id="warnSub" class="warn-sub">Formal violation notice</p>
                </div>
            </div>

            <div class="warn-body">
                <label class="f-lbl">Reason for Flagging</label>
                <div class="warn-reason-sel-wrap">
                    <asp:DropDownList ID="ddlWarnReason" runat="server" CssClass="warn-reason-sel">
                        <asp:ListItem Value="Harassment / Bullying"  Selected="True">Harassment / Bullying</asp:ListItem>
                        <asp:ListItem Value="Academic Dishonesty">Academic Dishonesty</asp:ListItem>
                        <asp:ListItem Value="Spam / Self-Promotion">Spam / Self-Promotion</asp:ListItem>
                        <asp:ListItem Value="Inappropriate Language">Inappropriate Language</asp:ListItem>
                    </asp:DropDownList>
                    <span class="warn-reason-chevron material-symbols-outlined" style="font-size:22px">expand_more</span>
                </div>

                <label class="f-lbl">Warning Type</label>
                <div class="warn-type-grid">
                    <button type="button" id="pMinor" onclick="pickType('Minor')" class="wpill">
                        <span class="wpill-name">Minor</span><span class="wpill-sub">1st Offense</span>
                    </button>
                    <button type="button" id="pMajor" onclick="pickType('Major')" class="wpill wy">
                        <span class="wpill-name">Major</span><span class="wpill-sub">2nd Offense</span>
                    </button>
                    <button type="button" id="pFinal" onclick="pickType('Final')" class="wpill">
                        <span class="wpill-name">Final</span><span class="wpill-sub">Suspension</span>
                    </button>
                </div>

                <div class="warn-msg-hdr">
                    <label class="f-lbl" style="margin:0">Warning Message</label>
                    <button type="button" class="tpl-btn" onclick="useTpl()">Use Template</button>
                </div>
                <div class="warn-ta-wrap">
                    <asp:TextBox ID="txtWarnMsg" runat="server" TextMode="MultiLine" Rows="4"
                        CssClass="warn-ta" placeholder="Type warning message here…"></asp:TextBox>
                    <div class="warn-toolbar">
                        <button type="button" class="tb-btn"><strong>B</strong></button>
                        <button type="button" class="tb-btn"><em>I</em></button>
                        <button type="button" class="tb-btn">
                            <span class="material-symbols-outlined" style="font-size:14px;vertical-align:middle">link</span>
                        </button>
                    </div>
                </div>

                <asp:LinkButton ID="btnSendWarning" runat="server"
                    OnClick="btnSendWarning_Click" CssClass="btn-warn3d">
                    <span class="material-symbols-outlined" style="font-size:1.1rem">send</span> Send Warning
                </asp:LinkButton>
                <button type="button" class="btn-mcancel" onclick="closeWarn()">Cancel</button>
            </div>

            <%-- Real DB data injected from JS --%>
            <div class="warn-footer">
                <div class="warn-fi">
                    <span class="material-symbols-outlined" style="font-size:13px">history</span>
                    <span id="warnFooterLast">Last Warning: —</span>
                </div>
                <div class="warn-fi">
                    <span class="material-symbols-outlined" style="font-size:13px">warning_amber</span>
                    <span id="warnFooterCount">Total Warnings: 0</span>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openDel(flagId, username, content, reason) {
            _setHf('<%= hfFlagId.ClientID %>',   flagId);
            _setHf('<%= hfPostUser.ClientID %>', username);
            var p = document.getElementById('delTxt');
            if (p) p.textContent = content || '…';
            _setDDL('<%= ddlDeleteReason.ClientID %>', reason);
            _show('modalDelete');
        }

        function openWarn(flagId, username, reason, lastWarn, warnCount) {
            _setHf('<%= hfFlagId.ClientID %>',   flagId);
            _setHf('<%= hfPostUser.ClientID %>', username);
            var sub = document.getElementById('warnSub');
            if (sub) sub.textContent = 'Formal violation notice for ' + username;
            var fl = document.getElementById('warnFooterLast');
            var fc = document.getElementById('warnFooterCount');
            if (fl) fl.textContent = 'Last Warning: ' + (lastWarn && lastWarn !== '' ? lastWarn : 'Never');
            if (fc) fc.textContent = 'Total Warnings: ' + (warnCount || '0');
            _setDDL('<%= ddlWarnReason.ClientID %>', reason);
            pickType('Major');
            _show('modalWarn');
        }

        function closeDel()  { _hide('modalDelete'); }
        function closeWarn() { _hide('modalWarn');   }

        function pickType(t) {
            _setHf('<%= hfWarnType.ClientID %>', t);
            ['pMinor','pMajor','pFinal'].forEach(function(id) {
                var el = document.getElementById(id);
                if (el) el.classList.remove('wy','wr');
            });
            var map = { Minor:'pMinor', Major:'pMajor', Final:'pFinal' };
            var el = document.getElementById(map[t]);
            if (el) el.classList.add(t === 'Final' ? 'wr' : 'wy');
        }

        function useTpl() {
            var tb = document.getElementById('<%= txtWarnMsg.ClientID %>');
            if (tb) tb.value = 'Your post violates our community policy. Please review the MathSphere Community Guidelines before posting again.';
        }

        function bgClick(e, id) { if (e.target === document.getElementById(id)) _hide(id); }

        function showToast(msg) {
            var t = document.getElementById('fmToast');
            if (!t) return;
            t.textContent = msg; t.classList.add('show');
            setTimeout(function () { t.classList.remove('show'); }, 3500);
        }

        function _show(id) { var el=document.getElementById(id); if(!el)return; el.style.display='flex'; document.body.style.overflow='hidden'; }
        function _hide(id) { var el=document.getElementById(id); if(!el)return; el.style.display='none'; document.body.style.overflow=''; }
        function _setHf(id, val) { var el=document.getElementById(id); if(el) el.value=val||''; }
        function _setDDL(id, val) {
            var ddl=document.getElementById(id); if(!ddl||!val)return;
            for(var i=0;i<ddl.options.length;i++) {
                if(ddl.options[i].value.toLowerCase()===val.toLowerCase()){ddl.selectedIndex=i;break;}
            }
        }

        // Auto-show toast on postback (same pattern as systemSetting)
        (function () {
            var flag = '<%= toastFlag %>';
            var msg  = '<%= System.Web.HttpUtility.JavaScriptStringEncode(toastMessage) %>';
            if (flag === '1' && msg) showToast(msg);
        })();

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { closeDel(); closeWarn(); }
        });
    </script>

</asp:Content>


