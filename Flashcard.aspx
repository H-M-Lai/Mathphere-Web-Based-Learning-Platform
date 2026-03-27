<%@ Page Language="C#" MasterPageFile="~/Student.master" AutoEventWireup="true"
         CodeBehind="Flashcard.aspx.cs" Inherits="MathSphere.Flashcard" %>

<asp:Content ID="TitleBlock" ContentPlaceHolderID="TitleContent" runat="server">
    Flashcards — MathSphere
</asp:Content>

<asp:Content ID="HeadBlock" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .fc-scene {
        perspective: 1200px;
        width: 100%;
        height: 320px;
    }
    .fc-card {
        width: 100%; height: 100%;
        position: relative;
        transform-style: preserve-3d;
        transition: transform .55s cubic-bezier(.4,0,.2,1);
        cursor: pointer;
    }
    .fc-card.flipped { transform: rotateY(180deg); }

    .fc-face {
        position: absolute; inset: 0;
        backface-visibility: hidden;
        -webkit-backface-visibility: hidden;
        border-radius: 2rem;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 2.5rem;
        text-align: center;
        user-select: none;
    }
    .fc-front {
        background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 60%, #3b82f6 100%);
        box-shadow: 0 20px 60px rgba(37,99,235,.35);
    }
    .fc-back {
        background: linear-gradient(135deg, #14532d 0%, #16a34a 60%, #84cc16 100%);
        box-shadow: 0 20px 60px rgba(22,163,74,.35);
        transform: rotateY(180deg);
    }

    .dot { transition: all .25s ease; }
    .dot.active { background: #2563eb; transform: scale(1.35); }
    .dot.seen   { background: #84cc16; }

    @keyframes slideInRight {
        from { opacity:0; transform:translateX(40px); }
        to   { opacity:1; transform:translateX(0); }
    }
    .slide-right { animation: slideInRight .3s ease forwards; }

    /* Complete banner */
    @keyframes popIn {
        0%   { opacity:0; transform:scale(.85) translateY(16px); }
        70%  { transform:scale(1.04) translateY(-3px); }
        100% { opacity:1; transform:scale(1) translateY(0); }
    }
    .pop-in { animation: popIn .5s cubic-bezier(.34,1.56,.64,1) forwards; }
    /* Progress bar fill */
    #fcProgressFill { transition: width .4s cubic-bezier(.4,0,.2,1); }

    @keyframes cardIn {
        from { opacity: 0; transform: translateY(18px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .page-enter { animation: cardIn .45s ease-out; }
</style>
</asp:Content>

<asp:Content ID="MainBlock" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-enter space-y-8">

    <%-- Hidden fields --%>
    <asp:HiddenField ID="hfDeckId"       runat="server" />
    <asp:HiddenField ID="hfReturnModule" runat="server" />

    <%-- Hidden form fields for completion POST --%>
    <input type="hidden" name="hdnCompleteFlashcard" id="hdnCompleteFlashcard" value="0" />
    <input type="hidden" name="hdnCompleteDeckId"    id="hdnCompleteDeckId"    value="" />
    <input type="hidden" name="hdnCompleteModuleId"  id="hdnCompleteModuleId"  value="" />

    <%-- DECK PICKER VIEW --%>
    <asp:Panel ID="pnlDeckPicker" runat="server">
        <div class="max-w-5xl mx-auto mb-10 space-y-8">
            <section class="relative overflow-hidden rounded-[2.75rem] border border-white/70 bg-white/90 px-8 py-9 lg:px-10 lg:py-10 shadow-[0_20px_48px_rgba(30,58,138,0.08)]">
                <div class="absolute -right-20 -top-20 size-56 rounded-full bg-blue-100/70 blur-3xl"></div>
                <div class="absolute bottom-0 left-0 h-32 w-44 rounded-tr-[4rem] bg-yellow-100/70 blur-2xl"></div>
                <div class="relative space-y-3 max-w-3xl mx-auto text-center">
                    <div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-4 py-2 text-[11px] font-black uppercase tracking-[0.28em] text-blue-600">
                        <span class="material-symbols-outlined text-sm fill-icon">style</span>
                        Recall practice
                    </div>
                    <h2 class="text-4xl font-black tracking-tight text-math-dark-blue lg:text-5xl">Flashcard <span class="text-math-blue">Decks</span></h2>
                    <p class="max-w-2xl mx-auto text-base font-medium leading-7 text-gray-500 lg:text-lg">Pick a deck, review key concepts quickly, and reinforce what you just learned through active recall.</p>
                </div>
            </section>

            <div class="surface-card p-5 max-w-2xl mx-auto">
                <div class="relative flex items-center gap-3">
                    <span class="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none">search</span>
                    <asp:TextBox ID="txtDeckSearch" runat="server"
                        placeholder="Search decks or modules…"
                        CssClass="w-full pl-14 pr-28 py-4 rounded-2xl border border-gray-200 bg-white/80 font-semibold text-math-dark-blue placeholder-gray-400 focus:outline-none focus:border-math-blue/40 focus:ring-4 focus:ring-math-blue/10 transition-all shadow-sm" />
                    <asp:Button ID="btnDeckSearch" runat="server" Text="Search"
                        CssClass="absolute right-2 top-1/2 -translate-y-1/2 px-5 py-2.5 bg-math-dark-blue text-white rounded-xl font-black text-xs uppercase tracking-widest hover:bg-math-blue transition-colors border-0 cursor-pointer"
                        OnClick="btnDeckSearch_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 max-w-5xl mx-auto">
            <asp:Repeater ID="rptDecks" runat="server" OnItemCommand="rptDecks_ItemCommand">
                <ItemTemplate>
                    <div class="group surface-card rounded-[2rem] p-7 hover:-translate-y-[2px] hover:shadow-[0_18px_40px_rgba(37,99,235,0.10)] transition-all duration-300">

                        <div class='<%# GetDeckAccentClass(Container.ItemIndex) %> h-2 w-16 rounded-full mb-5'></div>

                        <p class="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400 mb-1">
                            <%# Eval("ModuleName") %>
                        </p>
                        <h3 class="text-xl font-black text-blue-900 leading-tight mb-4 group-hover:text-blue-600 transition-colors">
                            <%# Eval("DeckTitle") %>
                        </h3>
                        <div class="flex items-center gap-3 text-sm text-gray-500 font-bold mb-5">
                            <span class="flex items-center gap-1.5">
                                <span class="material-symbols-outlined text-base text-blue-400">style</span>
                                <%# Eval("CardCount") %> cards
                            </span>
                            <%-- Completion badge --%>
                            <asp:Panel runat="server" Visible='<%# (bool)Eval("IsCompleted") %>'>
                                <span class="flex items-center gap-1 text-math-green font-black text-xs">
                                    <span class="material-symbols-outlined text-sm fill-icon">check_circle</span>
                                    Done
                                </span>
                            </asp:Panel>
                        </div>

                        <asp:LinkButton ID="btnOpenDeck" runat="server"
                            CommandName="OpenDeck"
                            CommandArgument='<%# Eval("DeckID") %>'
                            CssClass="w-full flex items-center justify-center gap-2 px-5 py-3
                                      rounded-2xl bg-blue-600 text-white font-black text-sm
                                      uppercase tracking-widest shadow-lg shadow-blue-200
                                      hover:bg-blue-700 transition-all active:scale-[0.98]">
                            <span class="material-symbols-outlined text-base">play_arrow</span>
                            <%# (bool)Eval("IsCompleted") ? "Review Again" : "Study Now" %>
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Panel ID="pnlNoDecks" runat="server" Visible="false">
            <div class="max-w-md mx-auto text-center py-20">
                <span class="material-symbols-outlined text-7xl text-gray-200 block mb-4">style</span>
                <p class="text-gray-400 font-black uppercase tracking-widest text-sm">No decks found</p>
            </div>
        </asp:Panel>

    </asp:Panel>

    <%-- STUDY VIEW --%>
    <asp:Panel ID="pnlStudy" runat="server" Visible="false">

        <%-- -- Top bar -- --%>
        <div class="max-w-2xl mx-auto mb-6 flex items-center justify-between gap-4">

            <asp:HyperLink ID="lnkBackToCourse" runat="server"
                CssClass="inline-flex items-center gap-2 px-4 py-2.5 rounded-2xl bg-white
                          border-2 border-gray-200 text-gray-600 font-black text-xs
                          uppercase tracking-widest hover:border-blue-300 hover:text-blue-600 transition-all">
                <span class="material-symbols-outlined text-base">arrow_back</span>
                Course Content
            </asp:HyperLink>

            <div class="text-center flex-1 min-w-0">
                <p class="text-[10px] font-black uppercase tracking-widest text-gray-400">
                    <asp:Literal ID="litStudyModule" runat="server" />
                </p>
                <h3 class="text-xl font-black text-blue-900 truncate">
                    <asp:Literal ID="litStudyTitle" runat="server" />
                </h3>
            </div>

            <div class="shrink-0 size-14 rounded-2xl bg-blue-50 border border-blue-100
                        flex flex-col items-center justify-center">
                <span id="progText" class="text-lg font-black text-blue-900 leading-none">0</span>
                <span class="text-[9px] font-black uppercase tracking-widest text-blue-400 mt-0.5">cards</span>
            </div>
        </div>

        <%-- -- Progress bar (cards seen) -- --%>
        <div class="max-w-2xl mx-auto mb-4 space-y-1">
            <div class="flex justify-between text-[10px] font-black uppercase tracking-widest text-gray-400">
                <span>Progress</span>
                <span><span id="seenCount">0</span> / <span id="totalCount">0</span> seen</span>
            </div>
            <div class="h-2 w-full bg-gray-100 rounded-full overflow-hidden border border-gray-200">
                <div id="fcProgressFill" class="h-full bg-math-green rounded-full" style="width:0%"></div>
            </div>
        </div>

        <%-- -- Card counter + shuffle -- --%>
        <div class="max-w-2xl mx-auto mb-4 flex items-center justify-between px-1">
            <p class="text-sm font-bold text-gray-400">
                Card <span id="spanCurrent" class="text-blue-600 font-black">1</span>
                of <span id="spanTotal" class="font-black text-blue-900">0</span>
            </p>
            <button type="button" onclick="shuffleCards()"
                class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-white
                       border-2 border-gray-200 text-gray-500 hover:border-blue-300
                       hover:text-blue-600 font-black text-xs uppercase tracking-widest transition-all">
                <span class="material-symbols-outlined text-base">shuffle</span>
                Shuffle
            </button>
        </div>

        <%-- -- THE FLASHCARD -- --%>
        <div class="max-w-2xl mx-auto mb-8">
            <div class="fc-scene" id="fcScene" onclick="flipCard()">
                <div class="fc-card" id="fcCard">
                    <div class="fc-face fc-front">
                        <span class="material-symbols-outlined text-white/30 text-6xl mb-4"
                              style="font-variation-settings:'FILL' 1">help</span>
                        <p class="text-white/60 font-black text-[10px] uppercase tracking-[0.2em] mb-3">Question</p>
                        <p id="cardQuestion" class="text-white font-black text-2xl leading-snug max-w-md">Loading…</p>
                        <p class="absolute bottom-5 text-white/40 text-xs font-semibold tracking-wide">Tap to reveal answer</p>
                    </div>
                    <div class="fc-face fc-back">
                        <span class="material-symbols-outlined text-white/30 text-6xl mb-4"
                              style="font-variation-settings:'FILL' 1">lightbulb</span>
                        <p class="text-white/60 font-black text-[10px] uppercase tracking-[0.2em] mb-3">Answer</p>
                        <p id="cardAnswer" class="text-white font-black text-2xl leading-snug max-w-md"></p>
                        <p class="absolute bottom-5 text-white/40 text-xs font-semibold tracking-wide">Tap to see question</p>
                    </div>
                </div>
            </div>
        </div>

        <%-- -- Navigation -- --%>
        <div class="max-w-2xl mx-auto flex items-center justify-between gap-4 mb-8">
            <button type="button" id="btnPrev" onclick="prevCard()"
                class="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-white border-2
                       border-gray-200 text-gray-600 font-black text-sm uppercase tracking-widest
                       hover:border-blue-300 hover:text-blue-600 transition-all disabled:opacity-40">
                <span class="material-symbols-outlined text-base">arrow_back</span> Prev
            </button>

            <div id="dotNav" class="flex gap-1.5 flex-wrap justify-center max-w-[200px]"></div>

            <button type="button" id="btnNext" onclick="nextCard()"
                class="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-blue-600
                       text-white font-black text-sm uppercase tracking-widest shadow-lg
                       shadow-blue-200 hover:bg-blue-700 transition-all disabled:opacity-40">
                Next <span class="material-symbols-outlined text-base">arrow_forward</span>
            </button>
        </div>

        <%-- -- COMPLETION BANNER (hidden until all cards seen) -- --%>
        <div id="completionBanner" class="hidden max-w-2xl mx-auto mb-8">
            <div class="bg-white/70 backdrop-blur-md rounded-[2.5rem] border border-gray-100
                        shadow-[0_12px_30px_rgba(0,0,0,0.06)] p-8 text-center pop-in">

                <div class="size-20 rounded-3xl bg-math-green/10 border border-math-green/20
                            flex items-center justify-center mx-auto mb-5">
                    <span class="material-symbols-outlined text-math-green fill-icon text-4xl">auto_awesome</span>
                </div>

                <h3 class="text-2xl font-black text-math-dark-blue mb-1">All cards reviewed!</h3>
                <p class="text-gray-400 font-semibold mb-6">
                    You've seen all <span id="bannerTotal">0</span> cards in this deck.
                </p>

                <%-- XP awarded notice — shown by JS if first attempt --%>
                <div id="xpNotice" class="hidden flex items-center justify-center gap-2 mb-6
                                          p-3 rounded-2xl bg-primary/10 border border-primary/20">
                    <span class="material-symbols-outlined text-primary fill-icon">stars</span>
                    <span class="text-sm font-black text-math-dark-blue" id="xpNoticeText"></span>
                </div>

                <div class="flex flex-col sm:flex-row gap-3 justify-center">
                    <%-- Mark complete button — posts to server --%>
                    <button type="button" id="btnMarkComplete"
                        onclick="submitCompletion()"
                        class="inline-flex items-center justify-center gap-2 px-7 py-3.5
                               rounded-2xl bg-math-green text-white font-black text-sm
                               uppercase tracking-widest shadow-lg shadow-green-200
                               hover:bg-green-600 transition-all">
                        <span class="material-symbols-outlined text-base fill-icon">check_circle</span>
                        Mark as Complete
                    </button>

                    <button type="button" onclick="restartDeck()"
                        class="inline-flex items-center justify-center gap-2 px-7 py-3.5
                               rounded-2xl bg-gray-100 text-gray-700 font-black text-sm
                               uppercase tracking-widest hover:bg-gray-200 transition-all">
                        <span class="material-symbols-outlined text-base">replay</span>
                        Review Again
                    </button>

                    <asp:HyperLink ID="lnkBackToCourse2" runat="server"
                        CssClass="inline-flex items-center justify-center gap-2 px-7 py-3.5
                                  rounded-2xl bg-math-blue text-white font-black text-sm
                                  uppercase tracking-widest shadow-lg shadow-math-blue/20
                                  hover:bg-math-dark-blue transition-all">
                        <span class="material-symbols-outlined text-base fill-icon">arrow_back</span>
                        Back to Module
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <%-- -- Already completed notice (server-rendered) -- --%>
        <asp:Panel ID="pnlAlreadyComplete" runat="server" Visible="false">
            <div class="max-w-2xl mx-auto mb-6">
                <div class="flex items-center gap-3 px-5 py-3.5 rounded-2xl
                            bg-math-green/10 border border-math-green/20">
                    <span class="material-symbols-outlined text-math-green fill-icon">check_circle</span>
                    <span class="text-sm font-black text-math-dark-blue">
                        You've already completed this deck — reviewing again won't award additional XP.
                    </span>
                </div>
            </div>
        </asp:Panel>

        <%-- Hidden card data from server --%>
        <asp:HiddenField ID="hfCardsJson"      runat="server" />
        <asp:HiddenField ID="hfKnownJson"      runat="server" />
        <asp:HiddenField ID="hfCurrentDeck"    runat="server" />
        <asp:HiddenField ID="hfIsFirstAttempt" runat="server" />
        <asp:HiddenField ID="hfFlashcardXP"    runat="server" />

    </asp:Panel>

    <%-- SCRIPT --%>
    <script>
    (function () {
        'use strict';

        var cardsJsonEl = document.getElementById('<%= hfCardsJson.ClientID %>');
        if (!cardsJsonEl || cardsJsonEl.value === '') return;

        var allCards      = [];
        var viewCards     = [];
        var idx           = 0;
        var isFlipped     = false;
        var seenSet       = {};   // tracks which indices have been viewed
        var isFirstAttempt = document.getElementById('<%= hfIsFirstAttempt.ClientID %>')?.value === '1';
        var xpAmount       = parseInt(document.getElementById('<%= hfFlashcardXP.ClientID %>')?.value || '0', 10);

        try { allCards = JSON.parse(cardsJsonEl.value || '[]'); } catch (e) { allCards = []; }
        viewCards = allCards.slice();

        var progText = document.getElementById('progText');
        if (progText) progText.textContent = allCards.length;

        document.getElementById('totalCount').textContent  = viewCards.length;
        document.getElementById('spanTotal').textContent   = viewCards.length;
        document.getElementById('bannerTotal').textContent = viewCards.length;

        buildDots();
        showCard(0);

        // Show card
        function showCard(i) {
            if (viewCards.length === 0) return;
            i = Math.max(0, Math.min(i, viewCards.length - 1));
            idx = i;
            isFlipped = false;

            // Mark as seen
            seenSet[i] = true;
            updateProgress();

            var fc = document.getElementById('fcCard');
            if (fc) fc.classList.remove('flipped');

            var card = viewCards[idx];
            document.getElementById('cardQuestion').textContent = card.Question || '';
            document.getElementById('cardAnswer').textContent   = card.Answer   || '';
            document.getElementById('spanCurrent').textContent  = idx + 1;

            document.querySelectorAll('.dot').forEach(function (d, di) {
                d.classList.toggle('active', di === idx);
                d.classList.toggle('seen',   seenSet[di] && di !== idx);
            });

            document.getElementById('btnPrev').disabled = (idx === 0);
            document.getElementById('btnNext').disabled = (idx === viewCards.length - 1);

            var scene = document.getElementById('fcScene');
            if (scene) {
                scene.classList.remove('slide-right');
                void scene.offsetWidth;
                scene.classList.add('slide-right');
            }

            // Show completion banner once ALL cards have been seen
            checkAllSeen();
        }

        // Track progress bar
        function updateProgress() {
            var seen  = Object.keys(seenSet).length;
            var total = viewCards.length;
            document.getElementById('seenCount').textContent   = seen;
            document.getElementById('fcProgressFill').style.width =
                (total > 0 ? (seen / total * 100) : 0) + '%';
        }

        // Show completion banner when all cards seen
        function checkAllSeen() {
            var seen  = Object.keys(seenSet).length;
            var total = viewCards.length;
            if (seen < total) return;

            var banner = document.getElementById('completionBanner');
            if (!banner || !banner.classList.contains('hidden')) return;

            banner.classList.remove('hidden');

            // Show XP notice only on first attempt
            if (isFirstAttempt && xpAmount > 0) {
                var notice = document.getElementById('xpNotice');
                var noticeText = document.getElementById('xpNoticeText');
                if (notice && noticeText) {
                    noticeText.textContent = '+' + xpAmount + ' XP awarded for completing this deck!';
                    notice.classList.remove('hidden');
                    notice.style.display = 'flex';
                }
            }
        }

        // Submit completion to server
        window.submitCompletion = function () {
            document.getElementById('hdnCompleteFlashcard').value = '1';
            document.getElementById('hdnCompleteDeckId').value    =
                document.getElementById('<%= hfCurrentDeck.ClientID %>').value;
            document.getElementById('hdnCompleteModuleId').value  =
                document.getElementById('<%= hfReturnModule.ClientID %>').value;

                var btn = document.getElementById('btnMarkComplete');
                if (btn) {
                    btn.disabled = true;
                    btn.innerHTML = '<span class="material-symbols-outlined text-base fill-icon animate-spin">progress_activity</span> Saving…';
                }

                var masterForm = document.getElementById('form1') || document.forms[0];
                if (masterForm) masterForm.submit();
            };

            // Restart deck
            window.restartDeck = function () {
                seenSet = {};
                document.getElementById('completionBanner').classList.add('hidden');
                updateProgress();
                buildDots();
                showCard(0);
            };

            window.flipCard = function () {
                isFlipped = !isFlipped;
                document.getElementById('fcCard').classList.toggle('flipped', isFlipped);
            };

            window.nextCard = function () {
                if (idx < viewCards.length - 1) showCard(idx + 1);
            };
            window.prevCard = function () {
                if (idx > 0) showCard(idx - 1);
            };

            window.shuffleCards = function () {
                for (var i = viewCards.length - 1; i > 0; i--) {
                    var j = Math.floor(Math.random() * (i + 1));
                    var tmp = viewCards[i]; viewCards[i] = viewCards[j]; viewCards[j] = tmp;
                }
                seenSet = {};
                document.getElementById('completionBanner').classList.add('hidden');
                updateProgress();
                buildDots();
                showCard(0);
            };

            function buildDots() {
                var nav = document.getElementById('dotNav');
                if (!nav) return;
                nav.innerHTML = '';
                var max = Math.min(viewCards.length, 20);
                for (var i = 0; i < max; i++) {
                    var d = document.createElement('button');
                    d.type = 'button';
                    d.className = 'dot size-2 rounded-full bg-gray-300';
                    (function (ii) { d.addEventListener('click', function () { showCard(ii); }); })(i);
                    nav.appendChild(d);
                }
                if (viewCards.length > 20) {
                    var more = document.createElement('span');
                    more.className = 'text-[10px] text-gray-400 font-bold';
                    more.textContent = '+' + (viewCards.length - 20);
                    nav.appendChild(more);
                }
            }

            document.addEventListener('keydown', function (e) {
                if (e.key === 'ArrowRight' || e.key === 'l') window.nextCard();
                if (e.key === 'ArrowLeft' || e.key === 'h') window.prevCard();
                if (e.key === ' ' || e.key === 'f') { e.preventDefault(); window.flipCard(); }
            });

            var touchStartX = 0;
            var scene = document.getElementById('fcScene');
            if (scene) {
                scene.addEventListener('touchstart', function (e) {
                    touchStartX = e.touches[0].clientX;
                }, { passive: true });
                scene.addEventListener('touchend', function (e) {
                    var dx = e.changedTouches[0].clientX - touchStartX;
                    if (Math.abs(dx) > 50) {
                        if (dx < 0) window.nextCard(); else window.prevCard();
                    } else {
                        window.flipCard();
                    }
                });
            }

        })();
    </script>

    </div>
</asp:Content>





