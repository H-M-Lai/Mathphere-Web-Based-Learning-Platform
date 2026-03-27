<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="setQuiz.aspx.cs" Inherits="MathSphere.setQuiz" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere - Configure Quiz</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        "math-blue": "#2563eb",
                        "math-green": "#10b981",
                        "math-amber": "#f59e0b",
                        "math-dark": "#0f172a",
                    },
                    fontFamily: { "display": ["Space Grotesk", "sans-serif"] }
                }
            }
        }
    </script>
    <style>
        * { font-family: 'Space Grotesk', sans-serif; box-sizing: border-box; }
        body { margin:0; padding:0; overflow:hidden; background:transparent; }

        /* -- Shell layout -- */
        .quiz-shell { display:flex; flex-direction:column; height:100vh; background:rgba(255,255,255,0.96); border:1px solid rgba(255,255,255,0.72); border-radius:2rem; overflow:hidden; box-shadow:0 24px 60px rgba(30,58,138,0.18); backdrop-filter:blur(12px); }
        .quiz-body  { flex:1; overflow-y:auto; background:#ffffff; padding:1.75rem 2rem; }
        .quiz-body::-webkit-scrollbar { width:4px; }
        .quiz-body::-webkit-scrollbar-thumb { background:#cbd5e1; border-radius:99px; }

        /* -- Question card -- */
        .q-card {
            background:#fff;
            border:2px solid #e2e8f0;
            border-radius:1.25rem;
            margin-bottom:1rem;
            overflow:hidden;
            transition:border-color .15s;
        }
        .q-card:focus-within { border-color:#2563eb; }
        .q-card-header {
            display:flex;
            align-items:center;
            gap:.75rem;
            padding:.875rem 1.25rem;
            background:#f8fafc;
            border-bottom:2px solid #e2e8f0;
        }
        .q-number {
            width:2rem; height:2rem;
            border-radius:.625rem;
            background:#f9d006;
            color:#fff;
            font-size:.75rem;
            font-weight:800;
            display:flex; align-items:center; justify-content:center;
            flex-shrink:0;
        }
        .q-card-body { padding:1rem 1.25rem; }

        /* -- Question textarea -- */
        .q-textarea {
            width:100%;
            border:none;
            outline:none;
            resize:none;
            background:transparent;
            font-size:.9375rem;
            font-weight:500;
            color:#0f172a;
            line-height:1.6;
            padding:0;
            min-height:56px;
        }
        .q-textarea::placeholder { color:#cbd5e1; }

        /* -- Options -- */
        .opt-row {
            display:flex;
            align-items:center;
            gap:.625rem;
            padding:.6rem .875rem;
            background:#f8fafc;
            border:1.5px solid #e2e8f0;
            border-radius:.75rem;
            margin-bottom:.5rem;
            transition:border-color .15s;
        }
        .opt-row:focus-within { border-color:#2563eb; background:#fff; }
        .opt-row.is-correct { border-color:#10b981; background:#f0fdf4; }
        .opt-letter {
            width:1.75rem; height:1.75rem;
            border-radius:.5rem;
            background:#e2e8f0;
            color:#64748b;
            font-size:.7rem;
            font-weight:800;
            display:flex; align-items:center; justify-content:center;
            flex-shrink:0;
        }
        .opt-row.is-correct .opt-letter { background:#2563eb; color:#fff; }
        .opt-input {
            flex:1;
            border:none;
            outline:none;
            background:transparent;
            font-size:.85rem;
            font-weight:500;
            color:#0f172a;
        }
        .opt-input::placeholder { color:#cbd5e1; }
        .correct-btn {
            flex-shrink:0;
            padding:.3rem .75rem;
            border-radius:99px;
            border:1.5px solid #e2e8f0;
            background:#fff;
            font-size:.65rem;
            font-weight:800;
            text-transform:uppercase;
            letter-spacing:.05em;
            color:#94a3b8;
            cursor:pointer;
            transition:all .15s;
            white-space:nowrap;
        }
        .correct-btn:hover { border-color:#10b981; color:#10b981; }
        .opt-row.is-correct .correct-btn {
            background:#f9d006;
            border-color:#10b981;
            color:#fff;
        }
        .del-opt-btn {
            flex-shrink:0;
            background:none;
            border:none;
            cursor:pointer;
            color:#cbd5e1;
            padding:.2rem;
            border-radius:.375rem;
            display:flex;
            transition:color .15s;
        }
        .del-opt-btn:hover { color:#ef4444; }

        /* -- Points pills -- */
        .pts-pill {
            padding:.35rem .875rem;
            border-radius:99px;
            border:1.5px solid #e2e8f0;
            background:#fff;
            font-size:.75rem;
            font-weight:800;
            color:#64748b;
            cursor:pointer;
            transition:all .15s;
        }
        .pts-pill.active { background:#2563eb; border-color:#2563eb; color:#fff; }
        .pts-pill:hover:not(.active) { border-color:#2563eb; color:#2563eb; }

        /* -- Add question button -- */
        .add-q-btn {
            display:flex;
            align-items:center;
            justify-content:center;
            gap:.5rem;
            width:100%;
            padding:.875rem;
            border:2px dashed #e2e8f0;
            border-radius:1rem;
            background:none;
            color:#94a3b8;
            font-size:.8rem;
            font-weight:800;
            text-transform:uppercase;
            letter-spacing:.08em;
            cursor:pointer;
            transition:all .15s;
        }
        .add-q-btn:hover { border-color:#2563eb; color:#2563eb; background:#eff6ff; }

        /* -- Save button -- */
        .save-btn {
            display:inline-flex !important;
            align-items:center;
            gap:.5rem;
            padding:.875rem 2rem;
            border-radius:1rem;
            background:#f9d006;
            color:#1e3a8a !important;
            font-weight:800;
            font-size:.8rem;
            text-transform:uppercase;
            letter-spacing:.1em;
            border:none !important;
            cursor:pointer;
            box-shadow:0 16px 30px rgba(249,208,6,.18);
            transition:background .15s, transform .15s, box-shadow .15s;
        }
        .save-btn:hover  { transform:translateY(-1px); box-shadow:0 18px 32px rgba(249,208,6,.28); filter:brightness(1.01); }
        .save-btn:active { transform:translateY(0); box-shadow:0 10px 18px rgba(249,208,6,.16); }

        /* -- Quiz title input -- */
        .quiz-title-input {
            width:100%;
            border:2px solid #e2e8f0;
            border-radius:.875rem;
            padding:.75rem 1rem;
            font-size:.9rem;
            font-weight:600;
            color:#0f172a;
            outline:none;
            transition:border-color .15s;
            background:#fff;
        }
        .quiz-title-input:focus { border-color:#2563eb; }

        /* -- Hint textarea -- */
        .hint-input {
            width:100%;
            border:1.5px solid #fde68a;
            border-radius:.75rem;
            padding:.625rem .875rem;
            font-size:.8rem;
            font-weight:500;
            color:#92400e;
            background:#fffbeb;
            outline:none;
            resize:none;
            transition:border-color .15s;
        }
        .hint-input:focus { border-color:#f59e0b; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <%-- Hidden state --%>
    <asp:HiddenField ID="hdnBlockId"    runat="server" />
    <asp:HiddenField ID="hdnModuleId"   runat="server" />
    <asp:HiddenField ID="hdnQuizId"     runat="server" />
    <asp:HiddenField ID="hdnQuizJson"   runat="server" />  <%-- full quiz state JSON --%>

    <div class="quiz-shell">

        <%-- HEADER --%>
        <header class="shrink-0 bg-gradient-to-r from-[#1e3a8a] via-[#2563eb] to-[#3b82f6] px-7 py-5 flex items-center justify-between">
            <div style="display:flex; align-items:center; gap:1rem;">
                <div class="size-11 rounded-2xl bg-white/20 flex items-center justify-center shadow-sm">
                    <span class="material-symbols-outlined" style="color:#fff; font-size:1.5rem;
                          font-variation-settings:'FILL' 1;">quiz</span>
                </div>
                <div>
                    <h1 class="text-white text-lg font-black uppercase tracking-tight leading-none">Configure Quiz</h1><p class="text-blue-100 text-[11px] font-semibold uppercase tracking-[0.18em] mt-1">Teacher content setup</p>
                </div>
            </div>
            <button type="button" onclick="closeQuiz()" class="size-10 rounded-2xl bg-white/15 hover:bg-white/20 flex items-center justify-center transition-colors border-0">
                <span class="material-symbols-outlined" style="color:#fff; font-size:1.25rem;">close</span>
            </button>
        </header>

        <%-- BODY --%>
        <div class="quiz-body">

            <%-- Quiz title --%>
            <div style="margin-bottom:1.25rem;">
                <label style="display:block; font-size:.65rem; font-weight:800;
                               text-transform:uppercase; letter-spacing:.12em;
                               color:#64748b; margin-bottom:.4rem;">
                    Quiz Title <span style="color:#94a3b8; font-weight:500;">(optional)</span>
                </label>
                <asp:TextBox ID="txtQuizTitle" runat="server"
                    CssClass="quiz-title-input"
                    placeholder="e.g. Domain & Range Check"></asp:TextBox>
            </div>

            <%-- Questions container � rendered by JS from hdnQuizJson on load --%>
            <div id="questionsContainer"></div>

            <%-- Add question button --%>
            <button type="button" class="add-q-btn" onclick="addQuestion()">
                <span class="material-symbols-outlined" style="font-size:1.25rem;
                      font-variation-settings:'FILL' 1;">add_circle</span>
                Add Another Question
            </button>

        </div>

        <%-- FOOTER --%>
        <footer style="flex-shrink:0; background:#fff; border-top:1px solid #e5e7eb;
                        padding:1rem 1.75rem; display:flex;
                        align-items:center; justify-content:space-between;">
            <button type="button" onclick="closeQuiz()" class="inline-flex items-center gap-2 rounded-2xl border border-gray-200 bg-white px-6 py-3 text-xs font-black uppercase tracking-[0.18em] text-gray-500 transition-all hover:border-blue-100 hover:bg-blue-50/60 hover:text-math-dark-blue">
                <span class="material-symbols-outlined" style="font-size:1rem;">cancel</span>
                Cancel
            </button>

            <asp:Button ID="btnSave" runat="server"
                Text="Save to Module"
                CssClass="save-btn"
                OnClick="btnSave_Click"
                OnClientClick="return collectBeforeSave()" />
        </footer>

    </div>
</form>

<script>
    // -
    //  STATE
    //  questions = [{
    //    questionId: 'QQ000001' | '',   // '' = new (not yet in DB)
    //    questionText: '',
    //    hint: '',
    //    points: 5,
    //    options: [{
    //      optionId: 'QO000001' | '',
    //      label: 'A',
    //      text: '',
    //      isCorrect: false
    //    }]
    //  }]
    // -
    let questions = [];
    const LETTERS = ['A', 'B', 'C', 'D', 'E', 'F'];

    // -
    //  INIT � load from server JSON or start fresh
    // -
    document.addEventListener('DOMContentLoaded', function () {
        const raw = document.getElementById('<%= hdnQuizJson.ClientID %>').value;
        if (raw) {
            try { questions = JSON.parse(raw); } catch (e) { questions = []; }
        }
        if (questions.length === 0) addQuestion();
        else renderAll();
    });

    // -
    //  RENDER
    // -
    function renderAll() {
        const c = document.getElementById('questionsContainer');
        c.innerHTML = '';
        questions.forEach((q, qi) => renderQuestion(q, qi));
    }

    function renderQuestion(q, qi) {
        const c = document.getElementById('questionsContainer');
        const card = document.createElement('div');
        card.className = 'q-card';
        card.dataset.qi = qi;

        // Header
        const canDelete = questions.length > 1;
        card.innerHTML = `
        <div class="q-card-header">
            <div class="q-number">${qi + 1}</div>
            <span style="font-size:.7rem; font-weight:800; text-transform:uppercase;
                          letter-spacing:.1em; color:#64748b; flex:1;">Question ${qi + 1}</span>
            ${canDelete ? `
            <button type="button" onclick="deleteQuestion(${qi})"
                style="background:none; border:none; cursor:pointer; color:#cbd5e1;
                       display:flex; align-items:center; border-radius:.375rem; padding:.2rem;"
                title="Remove question">
                <span class="material-symbols-outlined" style="font-size:1.1rem;">delete</span>
            </button>` : ''}
        </div>
        <div class="q-card-body">

            <%-- Question text --%>
            <textarea class="q-textarea"
                placeholder="Type your question here..."
                oninput="onQTextChange(${qi}, this.value)"
                rows="2">${escHtml(q.questionText)}</textarea>

            <%-- Options --%>
            <div style="margin-top:.75rem;" id="opts-${qi}">
                ${q.options.map((o, oi) => renderOptionHtml(qi, oi, o)).join('')}
            </div>

            <%-- Add option --%>
            <button type="button" onclick="addOption(${qi})"
                style="display:flex; align-items:center; gap:.375rem; margin-top:.5rem;
                       background:none; border:none; cursor:pointer;
                       color:#2563eb; font-size:.75rem; font-weight:800;
                       text-transform:uppercase; letter-spacing:.07em; padding:.25rem .125rem;">
                <span class="material-symbols-outlined"
                      style="font-size:1rem; font-variation-settings:'FILL' 1;">add_circle</span>
                Add Option
            </button>

            <%-- Bottom row: hint + points --%>
            <div style="display:grid; grid-template-columns:1fr auto;
                        gap:.875rem; margin-top:1rem; align-items:start;">

                <%-- Hint --%>
                <div>
                    <label style="font-size:.6rem; font-weight:800; text-transform:uppercase;
                                   letter-spacing:.1em; color:#f59e0b; display:block; margin-bottom:.3rem;">
                        <span class="material-symbols-outlined"
                              style="font-size:.85rem; vertical-align:middle;
                                     font-variation-settings:'FILL' 1;">lightbulb</span>
                        Hint / Explanation
                    </label>
                    <textarea class="hint-input" rows="2"
                        placeholder="Optional hint for wrong answers..."
                        oninput="onHintChange(${qi}, this.value)">${escHtml(q.hint || '')}</textarea>
                </div>

                <%-- Points --%>
                <div>
                    <label style="font-size:.6rem; font-weight:800; text-transform:uppercase;
                                   letter-spacing:.1em; color:#64748b; display:block; margin-bottom:.3rem;">
                        <span class="material-symbols-outlined"
                              style="font-size:.85rem; vertical-align:middle;
                                     font-variation-settings:'FILL' 1;">stars</span>
                        Points
                    </label>
                    <div style="display:flex; gap:.375rem;" id="pts-${qi}">
                        ${[5,10,20].map(v => `
                        <button type="button" class="pts-pill${q.points === v ? ' active' : ''}"
                            onclick="setPoints(${qi}, ${v}, this)">${v}</button>`).join('')}
                    </div>
                </div>
            </div>
        </div>`;

    c.appendChild(card);
}

function renderOptionHtml(qi, oi, o) {
    const isCorrect = o.isCorrect;
    return `
    <div class="opt-row${isCorrect ? ' is-correct' : ''}"
         data-qi="${qi}" data-oi="${oi}"
         data-option-id="${o.optionId || ''}">
        <div class="opt-letter">${LETTERS[oi] || String.fromCharCode(65+oi)}</div>
        <input class="opt-input" type="text"
               placeholder="Option text..."
               value="${escHtml(o.text)}"
               oninput="onOptTextChange(${qi}, ${oi}, this.value)" />
        <button type="button" class="correct-btn"
                onclick="markCorrect(${qi}, ${oi})">
            ${isCorrect ? 'Correct' : 'Mark Correct'}
        </button>
        <button type="button" class="del-opt-btn"
                onclick="deleteOption(${qi}, ${oi})">
            <span class="material-symbols-outlined" style="font-size:1.1rem;">delete</span>
        </button>
    </div>`;
}

// -
//  QUESTION MUTATIONS
// -
function addQuestion() {
    questions.push({
        questionId:   '',
        questionText: '',
        hint:         '',
        points:       5,
        options: [
            { optionId: '', label: 'A', text: '', isCorrect: true  },
            { optionId: '', label: 'B', text: '', isCorrect: false },
            { optionId: '', label: 'C', text: '', isCorrect: false },
        ]
    });
    renderAll();
    // Scroll to new card
    setTimeout(() => {
        const cards = document.querySelectorAll('.q-card');
        if (cards.length) cards[cards.length-1].scrollIntoView({ behavior:'smooth' });
    }, 50);
}

function deleteQuestion(qi) {
    if (questions.length <= 1) return;
    questions.splice(qi, 1);
    renderAll();
}

function onQTextChange(qi, val) {
    questions[qi].questionText = val;
}

function onHintChange(qi, val) {
    questions[qi].hint = val;
}

function setPoints(qi, val, btn) {
    questions[qi].points = val;
    const container = document.getElementById('pts-' + qi);
    container.querySelectorAll('.pts-pill').forEach(b => {
        b.classList.toggle('active', parseInt(b.textContent) === val);
    });
}

// -
//  OPTION MUTATIONS
// -
function addOption(qi) {
    const q = questions[qi];
    const oi = q.options.length;
    q.options.push({ optionId: '', label: LETTERS[oi] || String.fromCharCode(65+oi),
                     text: '', isCorrect: false });
    // Re-render just this card's options
    const container = document.getElementById('opts-' + qi);
    if (container) {
        container.innerHTML = q.options
            .map((o, i) => renderOptionHtml(qi, i, o)).join('');
    }
}

function onOptTextChange(qi, oi, val) {
    questions[qi].options[oi].text = val;
}

function markCorrect(qi, oi) {
    questions[qi].options.forEach((o, i) => { o.isCorrect = (i === oi); });
    // Re-render just this card's options
    const container = document.getElementById('opts-' + qi);
    if (container) {
        container.innerHTML = questions[qi].options
            .map((o, i) => renderOptionHtml(qi, i, o)).join('');
    }
}

function deleteOption(qi, oi) {
    const q = questions[qi];
    if (q.options.length <= 2) return; // minimum 2 options
    q.options.splice(oi, 1);
    // Re-label remaining
    q.options.forEach((o, i) => { o.label = LETTERS[i] || String.fromCharCode(65+i); });
    const container = document.getElementById('opts-' + qi);
    if (container) {
        container.innerHTML = q.options
            .map((o, i) => renderOptionHtml(qi, i, o)).join('');
    }
}

// -
//  COLLECT BEFORE SAVE
//  Reads current DOM values into questions[] then serialises to hidden field
// -
function collectBeforeSave() {
    // Sync all textarea/input values (in case oninput missed anything)
    document.querySelectorAll('.q-card').forEach(card => {
        const qi = parseInt(card.dataset.qi);
        if (isNaN(qi) || !questions[qi]) return;

        const ta = card.querySelector('.q-textarea');
        if (ta) questions[qi].questionText = ta.value;

        const hint = card.querySelector('.hint-input');
        if (hint) questions[qi].hint = hint.value;

        card.querySelectorAll('.opt-row').forEach((row, oi) => {
            if (!questions[qi].options[oi]) return;
            const inp = row.querySelector('.opt-input');
            if (inp) questions[qi].options[oi].text = inp.value;
            // Preserve existing optionId from data attribute
            const existingId = row.getAttribute('data-option-id');
            if (existingId) questions[qi].options[oi].optionId = existingId;
        });
    });

    // Validate
    for (let qi = 0; qi < questions.length; qi++) {
        const q = questions[qi];
        if (!q.questionText.trim()) {
            alert('Question ' + (qi+1) + ' needs question text.');
            return false;
        }
        const hasOption = q.options.some(o => o.text.trim());
        if (!hasOption) {
            alert('Question ' + (qi+1) + ' needs at least one option.');
            return false;
        }
        const hasCorrect = q.options.some(o => o.isCorrect);
        if (!hasCorrect) {
            alert('Question ' + (qi+1) + ' needs a correct answer selected.');
            return false;
        }
    }

    document.getElementById('<%= hdnQuizJson.ClientID %>').value =
            JSON.stringify(questions);
        return true;
    }

    // -
    //  CLOSE
    // -
    function closeQuiz() {
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
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }
</script>
</body>
</html>

