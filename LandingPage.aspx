<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LandingPage.aspx.cs" Inherits="Guest.LandingPage" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <title>MathSphere - Learn Smarter, Practice Better</title>

    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet" />

    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f9d006",
                        "background-light": "#f8f8f5",
                        "math-blue": "#2563eb",
                        "math-green": "#84cc16",
                        "math-dark-blue": "#1e3a8a"
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    },
                    borderRadius: {
                        "DEFAULT": "1rem",
                        "lg": "2rem",
                        "xl": "3rem",
                        "full": "9999px"
                    }
                }
            }
        }
    </script>

    <style type="text/tailwindcss">
        @layer base {
            body {
                @apply bg-background-light font-display text-math-dark-blue;
                background-image:
                    linear-gradient(rgba(0,0,0,0.03) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(0,0,0,0.03) 1px, transparent 1px);
                background-size: 40px 40px;
            }
        }

        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 500, 'GRAD' 0, 'opsz' 24; }
        .fill-icon { font-variation-settings: 'FILL' 1, 'wght' 500, 'GRAD' 0, 'opsz' 24; }

        @keyframes floaty {
            0%, 100% { transform: translate3d(0,0,0) rotate(var(--r)); }
            50%      { transform: translate3d(var(--x), var(--y), 0) rotate(var(--r)); }
        }

        .bg-float {
            animation: floaty var(--d, 18s) ease-in-out infinite;
            will-change: transform;
        }

        .surface-card {
            @apply bg-white/75 backdrop-blur-md border border-gray-100 rounded-[2rem] shadow-[0_12px_30px_rgba(0,0,0,0.06)];
        }

        @keyframes fade-up {
            from { opacity: 0; transform: translateY(26px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes soft-pop {
            from { opacity: 0; transform: translateY(18px) scale(.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        @keyframes gentle-pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 10px 24px rgba(249,208,6,0.35); }
            50% { transform: scale(1.02); box-shadow: 0 14px 30px rgba(249,208,6,0.45); }
        }

        .fade-up {
            animation: fade-up .65s cubic-bezier(.22,.61,.36,1) both;
        }

        .soft-pop {
            animation: soft-pop .55s cubic-bezier(.22,.61,.36,1) both;
        }

        .hero-delay-1 { animation-delay: .08s; }
        .hero-delay-2 { animation-delay: .16s; }
        .hero-delay-3 { animation-delay: .24s; }
        .hero-delay-4 { animation-delay: .32s; }
        .hero-delay-5 { animation-delay: .40s; }
        .hero-delay-6 { animation-delay: .48s; }

        .feature-card {
            transition: transform .22s ease, box-shadow .22s ease, border-color .22s ease;
        }

        .feature-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 18px 36px rgba(0,0,0,0.10);
            border-color: rgba(37,99,235,0.15);
        }

        .pulse-cta {
            animation: gentle-pulse 2.8s ease-in-out infinite;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="relative min-h-screen overflow-x-hidden">

            <div class="fixed inset-0 pointer-events-none overflow-hidden opacity-[0.05] -z-10">
                <span class="material-symbols-outlined absolute text-[140px] top-28 left-[7%] text-primary bg-float" style="--r:17deg; --x:18px; --y:-12px; --d:22s;">add</span>
                <span class="material-symbols-outlined absolute text-[160px] top-96 right-[10%] text-primary bg-float" style="--r:-23deg; --x:-14px; --y:16px; --d:26s;">percent</span>
                <span class="material-symbols-outlined absolute text-[150px] bottom-72 left-[14%] text-primary bg-float" style="--r:41deg; --x:12px; --y:10px; --d:24s;">equal</span>
                <span class="material-symbols-outlined absolute text-[170px] bottom-24 right-[12%] text-primary bg-float" style="--r:-31deg; --x:-16px; --y:-10px; --d:28s;">function</span>
            </div>

            <header class="sticky top-0 z-50 bg-white/90 backdrop-blur-md shadow-sm px-6 md:px-8 py-3 fade-up">
                <div class="max-w-[1440px] mx-auto flex items-center justify-between gap-4">
                    <a class="flex items-center gap-3" href="LandingPage.aspx">
                        <img src="Image/white themed MathSphere logo transparent 2.png"
                             class="h-10 lg:h-12 w-auto object-contain"
                             alt="MathSphere Logo" />
                        <span class="text-2xl lg:text-3xl font-extrabold tracking-tight uppercase text-math-dark-blue">
                            MATHSPHERE
                        </span>
                    </a>

                    <div class="flex items-center gap-3">
                        <asp:Button
                            ID="btnLogin"
                            runat="server"
                            Text="Login"
                            OnClick="btnLogin_Click"
                            CssClass="px-6 py-2.5 bg-white text-math-dark-blue font-black text-sm rounded-full border-2 border-gray-200 hover:border-math-blue/30 hover:text-math-blue transition-colors shadow-sm" />
                    </div>
                </div>
            </header>

            <main>
                <section class="px-6 md:px-8 pt-14 md:pt-20 pb-16">
                    <div class="max-w-[1440px] mx-auto grid grid-cols-1 lg:grid-cols-[1.1fr_0.9fr] gap-12 items-center">
                        <div>
                            <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-primary/25 border border-primary/40 text-math-dark-blue mb-6 fade-up hero-delay-1">
                                <span class="material-symbols-outlined text-sm fill-icon">auto_awesome</span>
                                <span class="text-[11px] font-black uppercase tracking-[0.2em]">Gamified Math Learning Platform</span>
                            </div>

                            <h1 class="text-5xl md:text-7xl font-black leading-[0.95] tracking-tight text-math-dark-blue mb-6 fade-up hero-delay-2">
                                Learn Math with
                                <span class="text-math-blue">missions</span>,
                                practice, and
                                <span class="text-primary">momentum</span>.
                            </h1>

                            <p class="text-lg md:text-xl text-gray-500 font-semibold leading-relaxed max-w-2xl mb-10 fade-up hero-delay-3">
                                MathSphere helps students build confidence through guided modules, assessments, streaks, community discussion, and an AI tutor designed to support step-by-step math learning.
                            </p>

                            <div class="flex flex-col sm:flex-row gap-4 mb-10 fade-up hero-delay-4">
                                <asp:Button
                                    ID="btnTryGuest"
                                    runat="server"
                                    Text="Try as Guest"
                                    OnClick="btnTryGuest_Click"
                                    CssClass="w-full sm:w-auto px-9 py-4 bg-primary text-math-dark-blue font-black text-base rounded-2xl border-2 border-primary shadow-[0_10px_24px_rgba(249,208,6,0.35)] hover:brightness-95 transition-all pulse-cta" />

                                <asp:Button
                                    ID="btnRegister"
                                    runat="server"
                                    Text="Create Account"
                                    OnClick="btnRegister_Click"
                                    CssClass="w-full sm:w-auto px-9 py-4 bg-math-blue text-white font-black text-base rounded-2xl shadow-[0_10px_24px_rgba(37,99,235,0.25)] hover:bg-math-dark-blue transition-all" />
                            </div>

                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 max-w-3xl fade-up hero-delay-5">
                                <div class="surface-card p-5 feature-card soft-pop hero-delay-6">
                                    <p class="text-[11px] font-black uppercase tracking-[0.2em] text-gray-400 mb-2">Modules</p>
                                    <p class="text-sm font-bold text-gray-600">Structured lessons with guided learning flow and progress tracking.</p>
                                </div>
                                <div class="surface-card p-5 feature-card soft-pop hero-delay-6">
                                    <p class="text-[11px] font-black uppercase tracking-[0.2em] text-gray-400 mb-2">AI Tutor</p>
                                    <p class="text-sm font-bold text-gray-600">Hints-first support to help students understand math step by step.</p>
                                </div>
                                <div class="surface-card p-5 feature-card soft-pop hero-delay-6">
                                    <p class="text-[11px] font-black uppercase tracking-[0.2em] text-gray-400 mb-2">Progress</p>
                                    <p class="text-sm font-bold text-gray-600">XP, streaks, and missions that keep practice consistent and visible.</p>
                                </div>
                            </div>
                        </div>

                        <div class="relative">
                            <div class="surface-card p-6 md:p-8 rounded-[2.75rem] overflow-hidden soft-pop hero-delay-4">
                                <div class="flex items-center justify-between mb-6">
                                    <div>
                                        <p class="text-[11px] font-black uppercase tracking-[0.2em] text-gray-400">Student Snapshot</p>
                                        <h2 class="text-2xl font-black text-math-dark-blue mt-1">A clearer way to learn</h2>
                                    </div>
                                    <div class="size-12 rounded-2xl bg-primary/25 border border-primary/40 flex items-center justify-center">
                                        <span class="material-symbols-outlined text-math-dark-blue fill-icon">school</span>
                                    </div>
                                </div>

                                <div class="space-y-4">
                                    <div class="bg-white rounded-[1.5rem] border border-gray-100 p-5 shadow-sm">
                                        <div class="flex items-center justify-between mb-3">
                                            <span class="text-sm font-black text-math-dark-blue">Current Mission</span>
                                            <span class="px-3 py-1 rounded-full bg-math-blue/10 text-math-blue text-[10px] font-black uppercase tracking-widest">In Progress</span>
                                        </div>
                                        <p class="text-lg font-black text-math-dark-blue mb-2">Quadratic Equations</p>
                                        <div class="h-3 w-full bg-gray-100 rounded-full overflow-hidden border border-gray-200">
                                            <div class="h-full w-[68%] bg-math-blue rounded-full"></div>
                                        </div>
                                        <div class="flex justify-between mt-2 text-xs font-bold text-gray-400">
                                            <span>68% complete</span>
                                            <span>Assessment unlocked next</span>
                                        </div>
                                    </div>

                                    <div class="grid grid-cols-2 gap-4">
                                        <div class="bg-primary/20 rounded-[1.5rem] border border-primary/30 p-5">
                                            <p class="text-[10px] font-black uppercase tracking-widest text-math-dark-blue/60 mb-1">Day Streak</p>
                                            <p class="text-3xl font-black text-math-dark-blue">7</p>
                                        </div>
                                        <div class="bg-white rounded-[1.5rem] border border-gray-100 p-5 shadow-sm">
                                            <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Math XP</p>
                                            <p class="text-3xl font-black text-math-blue">305</p>
                                        </div>
                                    </div>

                                    <div class="bg-math-dark-blue text-white rounded-[1.75rem] p-5 shadow-[0_16px_35px_rgba(30,58,138,0.2)]">
                                        <div class="flex items-center gap-3 mb-2">
                                            <span class="material-symbols-outlined fill-icon text-primary">forum</span>
                                            <p class="font-black">Community + support</p>
                                        </div>
                                        <p class="text-sm text-blue-100 font-semibold leading-relaxed">
                                            Students can ask questions, review past attempts, compare progress on the leaderboard, and continue learning beyond the classroom.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="px-6 md:px-8 py-16">
                    <div class="max-w-[1440px] mx-auto">
                        <div class="text-center max-w-3xl mx-auto mb-12">
                            <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 mb-3">Why MathSphere</p>
                            <h2 class="text-4xl md:text-5xl font-black tracking-tight text-math-dark-blue mb-4">
                                Built for real student learning, not just content delivery.
                            </h2>
                            <p class="text-lg text-gray-500 font-semibold">
                                The platform combines learning structure, motivation, and support so students can keep moving instead of getting stuck.
                            </p>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
                            <div class="surface-card p-7 feature-card soft-pop">
                                <div class="size-12 rounded-2xl bg-math-blue/10 text-math-blue flex items-center justify-center mb-5">
                                    <span class="material-symbols-outlined fill-icon">menu_book</span>
                                </div>
                                <h3 class="text-xl font-black text-math-dark-blue mb-3">Guided Modules</h3>
                                <p class="text-sm font-semibold text-gray-500 leading-relaxed">Students follow structured blocks, unlock progress in sequence, and build understanding step by step.</p>
                            </div>

                            <div class="surface-card p-7 feature-card soft-pop">
                                <div class="size-12 rounded-2xl bg-primary/25 text-math-dark-blue flex items-center justify-center mb-5">
                                    <span class="material-symbols-outlined fill-icon">smart_toy</span>
                                </div>
                                <h3 class="text-xl font-black text-math-dark-blue mb-3">AI Tutor Help</h3>
                                <p class="text-sm font-semibold text-gray-500 leading-relaxed">A built-in tutor can explain concepts, offer hints, and support students when they need extra help.</p>
                            </div>

                            <div class="surface-card p-7 feature-card soft-pop">
                                <div class="size-12 rounded-2xl bg-math-green/10 text-math-green flex items-center justify-center mb-5">
                                    <span class="material-symbols-outlined fill-icon">emoji_events</span>
                                </div>
                                <h3 class="text-xl font-black text-math-dark-blue mb-3">Motivation System</h3>
                                <p class="text-sm font-semibold text-gray-500 leading-relaxed">XP, streaks, missions, and leaderboards turn steady practice into something visible and rewarding.</p>
                            </div>

                            <div class="surface-card p-7 feature-card soft-pop">
                                <div class="size-12 rounded-2xl bg-math-dark-blue/10 text-math-dark-blue flex items-center justify-center mb-5">
                                    <span class="material-symbols-outlined fill-icon">groups</span>
                                </div>
                                <h3 class="text-xl font-black text-math-dark-blue mb-3">Teacher + Forum Support</h3>
                                <p class="text-sm font-semibold text-gray-500 leading-relaxed">Students can learn with teacher-created content and discuss questions with the wider MathSphere community.</p>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="px-6 md:px-8 py-16">
                    <div class="max-w-[1440px] mx-auto surface-card rounded-[2.75rem] p-8 md:p-12">
                        <div class="grid grid-cols-1 lg:grid-cols-[0.95fr_1.05fr] gap-10 items-center">
                            <div>
                                <p class="text-[11px] font-black uppercase tracking-[0.25em] text-gray-400 mb-3">How It Works</p>
                                <h2 class="text-4xl font-black tracking-tight text-math-dark-blue mb-5">From first visit to confident practice.</h2>
                                <p class="text-lg font-semibold text-gray-500 leading-relaxed">
                                    Whether students join with an account or try the platform as a guest, MathSphere gives a clear path into learning and improvement.
                                </p>
                            </div>

                            <div class="space-y-4">
                                <div class="flex gap-4 items-start bg-white rounded-[1.6rem] border border-gray-100 p-5 shadow-sm feature-card soft-pop">
                                    <div class="size-10 rounded-2xl bg-primary text-math-dark-blue flex items-center justify-center font-black shrink-0">1</div>
                                    <div>
                                        <h3 class="font-black text-math-dark-blue mb-1">Explore modules</h3>
                                        <p class="text-sm font-semibold text-gray-500">Browse learning content, preview topics, and discover what to study next.</p>
                                    </div>
                                </div>
                                <div class="flex gap-4 items-start bg-white rounded-[1.6rem] border border-gray-100 p-5 shadow-sm feature-card soft-pop">
                                    <div class="size-10 rounded-2xl bg-math-blue text-white flex items-center justify-center font-black shrink-0">2</div>
                                    <div>
                                        <h3 class="font-black text-math-dark-blue mb-1">Practice and complete assessments</h3>
                                        <p class="text-sm font-semibold text-gray-500">Progress through learning blocks, answer quizzes, and review past attempts.</p>
                                    </div>
                                </div>
                                <div class="flex gap-4 items-start bg-white rounded-[1.6rem] border border-gray-100 p-5 shadow-sm feature-card soft-pop">
                                    <div class="size-10 rounded-2xl bg-math-green text-white flex items-center justify-center font-black shrink-0">3</div>
                                    <div>
                                        <h3 class="font-black text-math-dark-blue mb-1">Build consistency</h3>
                                        <p class="text-sm font-semibold text-gray-500">Earn XP, keep streaks alive, ask the AI tutor for help, and stay motivated over time.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="px-6 md:px-8 pt-4 pb-20">
                    <div class="max-w-5xl mx-auto text-center bg-math-dark-blue text-white rounded-[2.75rem] px-8 py-12 shadow-[0_22px_55px_rgba(30,58,138,0.25)] relative overflow-hidden soft-pop">
                        <div class="absolute -top-20 -right-20 size-64 rounded-full bg-primary/20 blur-3xl"></div>
                        <div class="absolute -bottom-24 -left-24 size-72 rounded-full bg-white/10 blur-3xl"></div>
                        <div class="relative z-10">
                            <p class="text-[11px] font-black uppercase tracking-[0.25em] text-blue-100 mb-3">Get Started</p>
                            <h2 class="text-4xl md:text-5xl font-black tracking-tight mb-4">Start learning with MathSphere today.</h2>
                            <p class="text-lg font-semibold text-blue-100 max-w-2xl mx-auto mb-8">
                                Explore as a guest first, or create an account to track your learning progress, join discussions, and unlock the full student experience.
                            </p>
                            <div class="flex flex-col sm:flex-row gap-4 justify-center">
                                <asp:Button
                                    ID="btnContinueQuest"
                                    runat="server"
                                    Text="Login to Continue"
                                    OnClick="btnContinueQuest_Click"
                                    CssClass="w-full sm:w-auto px-9 py-4 bg-primary text-math-dark-blue font-black text-base rounded-2xl shadow-[0_10px_24px_rgba(249,208,6,0.35)] hover:brightness-95 transition-all" />
                                <asp:Button
                                    ID="btnRegisterFooter"
                                    runat="server"
                                    Text="Register Now"
                                    OnClick="btnRegister_Click"
                                    CssClass="w-full sm:w-auto px-9 py-4 bg-white text-math-dark-blue font-black text-base rounded-2xl border border-white/20 hover:bg-blue-50 transition-all" />
                            </div>
                        </div>
                    </div>
                </section>
            </main>

            <footer class="bg-white border-t border-gray-200 px-6 md:px-8 py-8">
                <div class="max-w-[1440px] mx-auto flex flex-col md:flex-row justify-between items-center gap-5">
                    <div class="flex items-center gap-3">
                        <img src="Image/white themed MathSphere logo transparent 2.png"
                             class="h-8 w-auto object-contain"
                             alt="MathSphere Logo" />
                        <span class="font-extrabold text-math-dark-blue tracking-tight text-lg uppercase">MathSphere</span>
                    </div>

                    <p class="text-xs font-bold text-gray-400 text-center">A gamified learning platform for stronger math practice and progress.</p>

                    <div class="flex gap-6 text-xs font-black text-gray-400 uppercase tracking-widest">
                        <a class="hover:text-math-blue transition-colors" href="Contact.aspx">Contact Support</a>
                    </div>
                </div>
            </footer>
        </div>
    </form>

    <script>
        (function () {
            var btn = document.getElementById('<%= btnTryGuest.ClientID %>');
            if (btn && !btn.dataset.iconified) {
                btn.dataset.iconified = '1';
                btn.innerHTML = 'Try as Guest <span class="material-symbols-outlined" style="font-size:18px;vertical-align:middle;">explore</span>';
            }
        })();
    </script>
</body>
</html>

