<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="flashCardCfg.aspx.cs" Inherits="MathSphere.flashCardCfg" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere - Configure Flashcard Set</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="Styles/flashCardCfg.css" rel="stylesheet" type="text/css"/>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f9d006",
                        "primary-dark": "#d4b105",
                        "math-blue": "#2563eb",
                        "math-blue-light": "#eff6ff",
                        "math-dark-blue": "#1e3a8a",
                        "math-green": "#84cc16",
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    },
                    borderRadius: {
                        "DEFAULT": "1rem",
                        "2xl": "1rem",
                        "3xl": "1.5rem",
                        "4xl": "2rem",
                    }
                },
            },
        }
    </script>
</head>
<body class="m-0 p-0 overflow-hidden" style="font-family: 'Space Grotesk', sans-serif; background: transparent;">

    <form id="form1" runat="server">

        <!-- Hidden fields for state -->
        <asp:HiddenField ID="hdnBlockId"   runat="server" />
        <asp:HiddenField ID="hdnModuleId"  runat="server" />
        <asp:HiddenField ID="hdnCardsJson" runat="server" />
        <asp:HiddenField ID="hdnFlashcardSetId" runat="server" />

        <!-- Full-viewport modal — no outer wrapper frame -->
        <div class="modal-window bg-white/95 w-full flex flex-col overflow-hidden rounded-[2rem] border border-white/70 shadow-[0_24px_60px_rgba(30,58,138,0.18)] backdrop-blur-md" style="height:100vh; max-width:100%">

            <!-- HEADER -->
            <header class="bg-gradient-to-r from-math-dark-blue via-math-blue to-blue-500 px-8 py-5 flex items-center justify-between shrink-0">
                <div class="flex items-center gap-4">
                    <div class="bg-white/20 text-white p-2.5 rounded-2xl flex items-center justify-center shadow-sm">
                        <span class="material-symbols-outlined text-2xl" style="font-variation-settings: 'FILL' 1;">style</span>
                    </div>
                    <div><h1 class="text-white text-xl font-black tracking-tight uppercase">Configure Flashcard Set</h1><p class="text-blue-100 text-xs font-semibold mt-1 uppercase tracking-[0.18em]">Teacher content setup</p></div>
                </div>
                <button type="button" onclick="closeWindow()"
                    class="size-10 rounded-2xl bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors">
                    <span class="material-symbols-outlined text-3xl text-white">close</span>
                </button>
            </header>

            <!-- SCROLLABLE BODY -->
            <main class="flex-1 overflow-y-auto custom-scrollbar px-8 py-7 space-y-6 bg-white">

                <!-- SET TITLE -->
                <div>
                    <label class="block text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 mb-2 ml-1">
                        Set Title
                    </label>
                    <asp:TextBox ID="txtSetTitle" runat="server"
                        CssClass="set-title-input w-full px-4 py-3 rounded-2xl border-2 border-slate-100 bg-[#f9fafb] font-bold text-slate-800 focus:border-math-blue focus:bg-white focus:ring-0 outline-none transition-all text-lg"
                        placeholder="Domain and Range Terminology" />
                </div>

                <!-- SHUFFLE TOGGLE -->
                <div class="flex items-center justify-between bg-math-blue-light border-2 border-math-blue px-6 py-5 rounded-2xl">
                    <div class="flex items-center gap-4">
                        <div class="bg-math-blue text-white p-2 rounded-xl">
                            <span class="material-symbols-outlined text-xl">shuffle</span>
                        </div>
                        <div>
                            <p class="font-black text-slate-900 uppercase tracking-wide text-sm leading-tight">Set Shuffle Mode</p>
                            <p class="text-xs text-slate-500 font-medium mt-0.5">Randomize order for students</p>
                        </div>
                    </div>
                    <label class="relative inline-flex items-center cursor-pointer select-none">
                        <asp:CheckBox ID="chkShuffle" runat="server" Checked="true" CssClass="sr-only peer" />
                        <div class="toggle-track w-14 h-8 bg-slate-300 rounded-full peer-checked:bg-math-blue transition-colors relative">
                            <div class="toggle-thumb absolute top-[4px] left-[4px] size-6 bg-white rounded-full shadow transition-transform"></div>
                        </div>
                    </label>
                </div>

                <!-- ACTIVE CARDS SECTION -->
                <div class="space-y-4">
                    <div class="flex items-center justify-between">
                        <h2 class="text-xs font-black text-slate-400 uppercase tracking-[0.2em]">
                            Active Cards (<span id="cardCount">0</span>)
                        </h2>
                    </div>

                    <!-- Cards container — filled by JS from server data -->
                    <div id="cardsContainer" class="space-y-4">
                        <!-- Server-rendered cards injected here on load -->
                        <asp:Repeater ID="rptCards" runat="server" OnItemDataBound="rptCards_ItemDataBound">
                            <ItemTemplate>
                                <asp:Literal ID="litCard" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <!-- Add New Card button -->
                    <button type="button" id="btnAddCard" onclick="addNewCard()"
                        class="add-card-btn w-full group flex flex-col items-center justify-center gap-3 py-10 border-4 border-dashed border-slate-200 rounded-3xl hover:border-math-blue hover:bg-blue-50/50 transition-all">
                        <div class="bg-math-blue text-white size-12 rounded-2xl flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                            <span class="material-symbols-outlined text-3xl" style="font-variation-settings:'FILL' 1;">add</span>
                        </div>
                        <span class="text-base font-black text-slate-400 group-hover:text-math-blue uppercase tracking-widest">Add New Card</span>
                    </button>
                </div>

            </main>

            <!-- FOOTER -->
            <footer class="bg-white border-t border-gray-100 px-8 py-6 flex flex-col md:flex-row items-center justify-between gap-4 shrink-0">
                <div class="text-slate-400 flex items-center gap-2">
                    <span class="material-symbols-outlined text-math-blue text-xl">info</span>
                    <span class="text-xs font-black uppercase tracking-widest">Autosaved to drafts</span>
                </div>
                <div class="flex items-center gap-6 w-full md:w-auto">
                    <button type="button" onclick="closeWindow()"
                        class="flex-1 md:flex-none rounded-2xl border border-gray-200 bg-white px-8 py-4 text-sm font-black uppercase tracking-[0.18em] text-slate-500 transition-all hover:border-blue-100 hover:bg-blue-50/60 hover:text-slate-900">
                        Cancel
                    </button>
                    <asp:Button ID="btnSave" runat="server"
                        Text="Save to Module"
                        CssClass="save-btn flex-1 md:flex-none px-8 py-4 bg-primary text-math-dark-blue font-black uppercase tracking-wider rounded-2xl shadow-[0_16px_30px_rgba(249,208,6,0.18)] hover:-translate-y-0.5 transition-all text-sm border-0"
                        OnClick="btnSave_Click"
                        OnClientClick="return collectCardsBeforeSave()" />
                </div>
            </footer>

        </div>

    </form>

    <script>
        // ============================
        // STATE
        // ============================
        let cardIdCounter = 1000;
        let newCardCounter = 0;

        // ============================
        // TOGGLE SYNC
        // ============================
        document.addEventListener('DOMContentLoaded', function () {
            syncToggle();
            updateCardCount();
            initDragHandles();

            // Sync toggle on checkbox change
            const cb = document.querySelector('#<%= chkShuffle.ClientID %>');
            if (cb) {
                cb.addEventListener('change', syncToggle);
            }
        });

        function syncToggle() {
            const cb = document.querySelector('#<%= chkShuffle.ClientID %>');
        const track = document.querySelector('.toggle-track');
        const thumb = document.querySelector('.toggle-thumb');
        if (!cb || !track || !thumb) return;
        if (cb.checked) {
            track.style.backgroundColor = '#2563eb';
            thumb.style.transform = 'translateX(24px)';
        } else {
            track.style.backgroundColor = '';
            thumb.style.transform = 'translateX(0)';
        }
    }

    // ============================
    // CARD COUNT
    // ============================
    function updateCardCount() {
        const count = document.querySelectorAll('#cardsContainer .flashcard-item').length;
        const el = document.getElementById('cardCount');
        if (el) el.textContent = count;
    }

    // ============================
    // ADD NEW CARD
    // ============================
        function addNewCard() {
            newCardCounter++;
            const container = document.getElementById('cardsContainer'); // adjust selector to match your container ID
            const cardId = 'new-' + newCardCounter;

            const div = document.createElement('div');
            div.className = 'flashcard-item group relative bg-white border-2 border-slate-100 rounded-3xl p-6 flex gap-5 items-start shadow-sm hover:shadow-md transition-shadow';
            div.dataset.cardId = cardId;
            div.innerHTML = `
        <div class="drag-handle cursor-grab active:cursor-grabbing text-slate-300 hover:text-math-blue transition-colors mt-2 shrink-0 select-none">
            <span class="material-symbols-outlined text-3xl">drag_indicator</span>
        </div>
        <div class="flex-1 grid grid-cols-1 md:grid-cols-2 gap-5">
            <div class="space-y-2">
                <label class="block text-[10px] font-black text-slate-800 uppercase tracking-widest">Front (Question)</label>
                <textarea class="card-front card-textarea w-full rounded-2xl p-4 min-h-[110px] resize-none border-2 border-slate-100 bg-[#f9fafb] font-medium text-sm text-slate-700 placeholder:text-slate-300 focus:border-math-blue focus:bg-white focus:ring-0 outline-none transition-all"
                    placeholder="Enter the math problem or question..."></textarea>
            </div>
            <div class="space-y-2">
                <label class="block text-[10px] font-black text-slate-800 uppercase tracking-widest">Back (Answer)</label>
                <textarea class="card-back card-textarea w-full rounded-2xl p-4 min-h-[110px] resize-none border-2 border-slate-100 bg-[#f9fafb] font-medium text-sm text-slate-700 placeholder:text-slate-300 focus:border-math-blue focus:bg-white focus:ring-0 outline-none transition-all"
                    placeholder="Enter the solution or final answer..."></textarea>
            </div>
        </div>
        <button type="button" onclick="deleteCard(this)"
            class="delete-card-btn shrink-0 bg-red-50 text-red-400 hover:bg-red-500 hover:text-white p-3 rounded-2xl transition-all mt-2 border border-red-100">
            <span class="material-symbols-outlined text-xl">delete</span>
        </button>`;

            container.appendChild(div);

            // Animate in
            div.style.opacity = '0';
            div.style.transform = 'translateY(-8px)';
            requestAnimationFrame(() => {
                div.style.transition = 'opacity 0.25s, transform 0.25s';
                div.style.opacity = '1';
                div.style.transform = 'translateY(0)';
            });
        }

    // ============================
    // DELETE CARD
    // ============================
        function deleteCard(btn) {
            const card = btn.closest('.flashcard-item');
            if (!card) return;
            card.style.transition = 'opacity 0.2s, transform 0.2s';
            card.style.opacity = '0';
            card.style.transform = 'scale(0.95)';
            setTimeout(() => card.remove(), 200);
        }

    // ============================
    // COLLECT CARDS ? hidden field
    // ============================
    function collectCards() {
        const cards = [];
        document.querySelectorAll('#cardsContainer .flashcard-item').forEach((card, i) => {
            cards.push({
                id:    card.dataset.cardId || ('card-' + i),
                front: card.querySelector('.card-front')?.value || '',
                back:  card.querySelector('.card-back')?.value  || '',
                order: i + 1
            });
        });
        return cards;
    }

    function collectCardsBeforeSave() {
        const cards = collectCards();
        document.getElementById('<%= hdnCardsJson.ClientID %>').value = JSON.stringify(cards);
            return true;
        }

        // ============================
        // AUTO-SAVE DRAFT
        // ============================
        let autoSaveTimer = null;
        function autoSaveDraft() {
            clearTimeout(autoSaveTimer);
            autoSaveTimer = setTimeout(() => {
                collectCardsBeforeSave();
                // Silently update the hidden field — actual DB save on btnSave click
            }, 1200);
        }

        // Trigger auto-save when any textarea changes
        document.addEventListener('input', function (e) {
            if (e.target.classList.contains('card-textarea')) autoSaveDraft();
        });

        // ============================
        // DRAG-TO-REORDER (pointer events)
        // ============================
        let dragSrc = null;

        function initDragHandles() {
            document.querySelectorAll('#cardsContainer .flashcard-item').forEach(card => initDragHandle(card));
        }

        function initDragHandle(card) {
            const handle = card.querySelector('.drag-handle');
            if (!handle || handle._bound) return;
            handle._bound = true;

            let startY = 0;
            let clone = null;
            let origIdx = -1;

            handle.addEventListener('pointerdown', function (e) {
                if (e.button !== 0) return;
                e.preventDefault();
                handle.setPointerCapture(e.pointerId);

                dragSrc = card;
                startY = e.clientY;
                origIdx = getCardIndex(card);

                card.classList.add('card-dragging');

                // Create floating clone
                const rect = card.getBoundingClientRect();
                clone = card.cloneNode(true);
                clone.id = 'drag-clone';
                clone.style.cssText = `
                position: fixed; z-index: 9999; pointer-events: none;
                left: ${rect.left}px; top: ${rect.top}px;
                width: ${rect.width}px; opacity: 0.92;
                border: 2px solid #2563eb; border-radius: 1.5rem;
                box-shadow: 0 20px 40px rgba(0,0,0,0.15);
                transform: rotate(-1deg) scale(1.01);
                transition: transform 0.1s;
            `;
                document.body.appendChild(clone);

                document.addEventListener('pointermove', onDragMove);
                document.addEventListener('pointerup', onDragEnd);
            });

            function onDragMove(e) {
                if (!clone) return;
                const dy = e.clientY - startY;
                const rect = card.getBoundingClientRect();
                clone.style.top = (rect.top + dy) + 'px';

                // Find card to swap with
                const cards = getCards();
                const srcIdx = cards.indexOf(dragSrc);
                for (let i = 0; i < cards.length; i++) {
                    if (cards[i] === dragSrc) continue;
                    const r = cards[i].getBoundingClientRect();
                    if (e.clientY > r.top && e.clientY < r.bottom) {
                        clearDropIndicators();
                        if (i < srcIdx) cards[i].classList.add('drop-above');
                        else cards[i].classList.add('drop-below');
                        break;
                    }
                }
            }

            function onDragEnd(e) {
                document.removeEventListener('pointermove', onDragMove);
                document.removeEventListener('pointerup', onDragEnd);
                clearDropIndicators();
                if (clone) { clone.remove(); clone = null; }
                if (!dragSrc) return;
                dragSrc.classList.remove('card-dragging');

                // Find final target
                const cards = getCards();
                const srcIdx = cards.indexOf(dragSrc);
                let targetIdx = srcIdx;
                for (let i = 0; i < cards.length; i++) {
                    if (cards[i] === dragSrc) continue;
                    const r = cards[i].getBoundingClientRect();
                    if (e.clientY > r.top && e.clientY < r.bottom) { targetIdx = i; break; }
                }

                if (targetIdx !== srcIdx) {
                    const container = document.getElementById('cardsContainer');
                    const addBtn = document.getElementById('btnAddCard');
                    if (targetIdx < srcIdx) {
                        container.insertBefore(dragSrc, cards[targetIdx]);
                    } else {
                        const next = cards[targetIdx].nextSibling;
                        if (next && next !== addBtn) container.insertBefore(dragSrc, next);
                        else container.insertBefore(dragSrc, addBtn);
                    }
                }

                dragSrc = null;
                autoSaveDraft();
            }
        }

        function getCards() {
            return Array.from(document.querySelectorAll('#cardsContainer .flashcard-item'));
        }

        function getCardIndex(card) {
            return getCards().indexOf(card);
        }

        function saveCardsState() {
            const cards = [];
            document.querySelectorAll('.flashcard-item').forEach((el, i) => {
                cards.push({
                    id: el.dataset.cardId || ('new-' + i),
                    front: el.querySelector('.card-front')?.value ?? '',
                    back: el.querySelector('.card-back')?.value ?? ''
                });
            });
            const hdn = document.getElementById('<%= hdnCardsJson.ClientID %>');
            if (hdn) hdn.value = JSON.stringify(cards);
        }

        function clearDropIndicators() {
            document.querySelectorAll('.drop-above, .drop-below').forEach(el => {
                el.classList.remove('drop-above', 'drop-below');
            });
        }

        // ============================
        // CLOSE — sends message to parent overlay
        // ============================
        function closeWindow() {
            if (window.parent && window.parent !== window) {
                window.parent.postMessage('closeOverlay', window.location.origin);
            } else if (window.opener) {
                window.close();
            } else {
                window.history.back();
            }
        }

        // ============================
        // UTILS
        // ============================
        function escapeHtml(str) {
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }
    </script>

</body>
</html>
