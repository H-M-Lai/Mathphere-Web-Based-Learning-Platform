<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="teacherForgetPassword.aspx.cs" Inherits="MathLab.teacherForgetPassword" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>MathSphere - Forgot Password</title>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700;800;900&family=Outfit:wght@400;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <link href="Styles/teacherForgetPassword.css" rel="stylesheet" />
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        "electric-blue": "#2563eb",
                        "bright-yellow": "#facc15",
                        "lime-green": "#84cc16",
                        "bg-light": "#f8fafc",
                        "ui-dark": "#1e293b",
                    },
                    fontFamily: {
                        "display": ["Lexend", "sans-serif"],
                        "body": ["Outfit", "sans-serif"]
                    }
                },
            },
        }
    </script>
</head>
<body class="bg-bg-light font-display text-ui-dark overflow-hidden">
    <form id="form1" runat="server">
        <div class="fixed inset-0 math-bg blur-md scale-105 pointer-events-none opacity-40"></div>
        
        <div class="fixed inset-0 bg-ui-dark/40 backdrop-blur-sm z-50 flex items-center justify-center p-6">
            <div class="zoom-container w-full max-w-5xl">
                <div class="bg-white rounded-[3rem] shadow-2xl flex flex-col md:flex-row overflow-hidden border-4 border-white">
                    
                    <div class="w-full md:w-2/5 bg-electric-blue p-12 flex flex-col justify-center items-center text-center relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-full h-full opacity-10">
                            <div class="absolute top-10 left-10 text-6xl font-black text-white">8</div>
                            <div class="absolute bottom-20 right-10 text-6xl font-black text-white">+</div>
                            <div class="absolute top-1/2 right-1/4 text-4xl font-black text-white">#</div>
                        </div>
                        <div class="relative z-10 flex flex-col items-center gap-6">
                            <div class="relative flex items-center justify-center h-48 w-48">
                                <div class="absolute bg-lime-green size-36 rounded-full border-8 border-white/20 flex items-center justify-center rotate-45 floating-3d">
                                    <span class="material-symbols-outlined text-white text-8xl font-bold">all_inclusive</span>
                                </div>
                                <div class="absolute bg-bright-yellow size-28 rounded-3xl -rotate-12 flex items-center justify-center shadow-[10px_10px_0px_#2563eb] floating-3d">
                                    <span class="material-symbols-outlined text-electric-blue text-6xl font-black">key</span>
                                </div>
                            </div>
                        </div>
                        <div class="mt-16 z-10">
                            <h3 class="text-white text-4xl font-black uppercase tracking-tight leading-tight">
                                NO STRESS,<br/>
                                <span class="text-bright-yellow">WE'LL FIND IT.</span>
                            </h3>
                        </div>
                    </div>

                    <div class="w-full md:w-3/5 bg-white p-8 md:p-16 flex flex-col">
                        <div class="flex-1">
                            <h1 class="text-4xl font-black text-electric-blue mb-4 uppercase tracking-tighter">FORGOT PASSWORD?</h1>
                            <p class="text-ui-dark font-medium text-lg mb-10 leading-relaxed">
                                Enter your email and we'll send you a reset link so you can get back into your teacher account.
                            </p>
                            
                            <div class="space-y-8">
                                <div class="space-y-2">
                                    <label class="text-xs font-black text-electric-blue uppercase tracking-widest ml-1">Email</label>
                                    <asp:TextBox ID="txtRecoveryEmail" runat="server" TextMode="Email" 
                                        CssClass="w-full px-6 py-4 rounded-2xl border-4 border-electric-blue focus:ring-0 focus:border-lime-green text-lg font-bold placeholder:text-gray-300" 
                                        placeholder="alex@school.edu"></asp:TextBox>
                                </div>

                                <asp:Button ID="btnRecover" runat="server" Text="Send Recovery Link" 
                                    OnClick="btnRecover_Click"
                                    CssClass="w-full bg-bright-yellow text-electric-blue py-5 rounded-[24px] font-black text-xl uppercase tracking-widest shadow-[8px_8px_0px_#2563eb] hover:translate-y-1 hover:shadow-[4px_4px_0px_#2563eb] transition-all cursor-pointer" />
                                
                                <asp:Label ID="lblStatus" runat="server" CssClass="block text-center font-bold text-sm mt-4"></asp:Label>
                            </div>
                        </div>

                        <div class="mt-12 text-center">
                            <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/Login.aspx" 
                                CssClass="text-electric-blue font-black uppercase tracking-widest text-sm hover:underline flex items-center justify-center gap-2 group">
                                <span class="material-symbols-outlined text-sm transition-transform group-hover:-translate-x-1">arrow_back</span>
                                Back to Login
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>