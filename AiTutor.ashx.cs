using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.SessionState;

namespace Assignment
{
    public class AiTutor : IHttpHandler, IRequiresSessionState
    {
        private static readonly HttpClient Http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(25)
        };

        public bool IsReusable => false;

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var sw = Stopwatch.StartNew();
            int responseStatus = 500;
            string responseCode = "INTERNAL_ERROR";
            string userIdForLog = "";
            string modelForLog = "";
            int promptCharsForLog = 0;

            try
            {
                if (!string.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
                {
                    responseStatus = 405;
                    responseCode = "METHOD_NOT_ALLOWED";
                    WriteJson(context, responseStatus, new { ok = false, error = "POST only.", code = responseCode });
                    return;
                }

                string body;
                using (var sr = new StreamReader(context.Request.InputStream))
                    body = sr.ReadToEnd();

                JObject req = string.IsNullOrWhiteSpace(body) ? new JObject() : JObject.Parse(body);
                string action = ((string)req["action"] ?? "").Trim();
                string message = Truncate(((string)req["message"] ?? "").Trim(), 1200);
                string moduleId = Truncate(((string)req["moduleId"] ?? "").Trim(), 100);
                string pagePath = Truncate(((string)req["pagePath"] ?? "").Trim(), 120);
                var history = ParseHistory(req["history"]);

                if (action.Equals("ping", StringComparison.OrdinalIgnoreCase))
                {
                    responseStatus = 200;
                    responseCode = "OK";
                    WriteJson(context, responseStatus, new { ok = true, msg = "pong" });
                    return;
                }

                string userId = ((context.Session["UserID"] ?? context.Session["userID"]) ?? "").ToString().Trim();
                string role = (context.Session["RoleName"] ?? "").ToString().Trim();
                userIdForLog = userId;

                if (string.IsNullOrWhiteSpace(userId))
                {
                    responseStatus = 401;
                    responseCode = "UNAUTHORIZED";
                    WriteJson(context, responseStatus, new { ok = false, error = "Please log in first.", code = responseCode });
                    return;
                }

                if (!role.Equals("Student", StringComparison.OrdinalIgnoreCase))
                {
                    responseStatus = 403;
                    responseCode = "FORBIDDEN_ROLE";
                    WriteJson(context, responseStatus, new { ok = false, error = "Tutor is for students only.", code = responseCode });
                    return;
                }

                if (string.IsNullOrWhiteSpace(message))
                {
                    responseStatus = 400;
                    responseCode = "INVALID_MESSAGE";
                    WriteJson(context, responseStatus, new { ok = false, error = "Please type a question.", code = responseCode });
                    return;
                }

                string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
                string model = ConfigurationManager.AppSettings["GeminiModel"] ?? "gemini-3-flash-preview";
                string fallbackModel = ConfigurationManager.AppSettings["GeminiFallbackModel"] ?? "gemini-3.1-flash-lite-preview";
                modelForLog = model;

                if (string.IsNullOrWhiteSpace(apiKey))
                {
                    responseStatus = 500;
                    responseCode = "MISSING_API_KEY";
                    WriteJson(context, responseStatus, new { ok = false, error = "GeminiApiKey missing in Web.config.", code = responseCode });
                    return;
                }

                string pageContext = BuildPageContext(moduleId, pagePath);
                string prompt = BuildPrompt(pageContext, message, history);
                promptCharsForLog = prompt.Length;

                GeminiCallResult call = CallGeminiWithResilience(apiKey, model, fallbackModel, prompt);
                modelForLog = call.ModelUsed;

                if (!call.Success)
                {
                    responseStatus = call.ClientStatus;
                    responseCode = call.ErrorCode;
                    WriteJson(context, responseStatus, new { ok = false, error = call.ErrorMessage, code = responseCode, model = call.ModelUsed });
                    return;
                }

                responseStatus = 200;
                responseCode = "OK";
                WriteJson(context, responseStatus, new { ok = true, answer = call.Answer, model = call.ModelUsed });
            }
            catch (JsonReaderException)
            {
                responseStatus = 400;
                responseCode = "INVALID_JSON";
                WriteJson(context, responseStatus, new { ok = false, error = "Invalid JSON payload.", code = responseCode });
            }
            catch (Exception ex)
            {
                responseStatus = 500;
                responseCode = "INTERNAL_ERROR";
                WriteJson(context, responseStatus, new { ok = false, error = "Tutor failed. Please try again.", code = responseCode });
                Debug.WriteLine("[AiTutor] Unhandled exception: " + ex.Message);
            }
            finally
            {
                sw.Stop();
                Debug.WriteLine(
                    $"[AiTutor] user={SafeLog(userIdForLog)} model={SafeLog(modelForLog)} status={responseStatus} code={responseCode} promptChars={promptCharsForLog} ms={sw.ElapsedMilliseconds}"
                );
            }
        }

        private static GeminiCallResult CallGeminiWithResilience(string apiKey, string model, string fallbackModel, string prompt)
        {
            GeminiCallResult first = CallGemini(apiKey, model, prompt);
            if (first.Success) return first;

            bool canUseFallback =
                !string.IsNullOrWhiteSpace(fallbackModel) &&
                !fallbackModel.Equals(model, StringComparison.OrdinalIgnoreCase);

            // If primary model is unavailable (404) or rate-limited (429), try fallback model.
            if ((first.ProviderStatus == 404 || first.ProviderStatus == 429) && canUseFallback)
            {
                var fallback = CallGemini(apiKey, fallbackModel, prompt);
                if (fallback.Success) return fallback;
                return fallback;
            }

            if (IsTransient(first.ProviderStatus))
            {
                Thread.Sleep(700);
                var retry = CallGemini(apiKey, model, prompt);
                if (retry.Success) return retry;
                return retry;
            }

            return first;
        }

        private static GeminiCallResult CallGemini(string apiKey, string model, string prompt)
        {
            string url =
                "https://generativelanguage.googleapis.com/v1beta/models/" +
                model + ":generateContent?key=" + apiKey;

            var reqBody = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[] { new { text = prompt } }
                    }
                }
            };

            var request = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(JsonConvert.SerializeObject(reqBody), Encoding.UTF8, "application/json")
            };

            using (var response = Http.SendAsync(request).GetAwaiter().GetResult())
            {
                string raw = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

                if (response.IsSuccessStatusCode)
                {
                    string answer = (string)JObject.Parse(raw)["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";
                    if (string.IsNullOrWhiteSpace(answer))
                    {
                        return new GeminiCallResult
                        {
                            Success = false,
                            ProviderStatus = 502,
                            ClientStatus = 502,
                            ErrorCode = "PROVIDER_ERROR",
                            ErrorMessage = "No response generated. Please try again.",
                            ModelUsed = model
                        };
                    }

                    return new GeminiCallResult
                    {
                        Success = true,
                        Answer = answer.Trim(),
                        ProviderStatus = 200,
                        ClientStatus = 200,
                        ModelUsed = model
                    };
                }

                int providerStatus = (int)response.StatusCode;
                string providerMessage = ExtractProviderMessage(raw);

                if (providerStatus == 429)
                {
                    return new GeminiCallResult
                    {
                        Success = false,
                        ProviderStatus = providerStatus,
                        ClientStatus = 429,
                        ErrorCode = "RATE_LIMIT",
                        ErrorMessage = "Tutor is busy right now. Please wait a moment and try again.",
                        ModelUsed = model
                    };
                }


                if (providerStatus == (int)HttpStatusCode.NotFound)
                {
                    return new GeminiCallResult
                    {
                        Success = false,
                        ProviderStatus = providerStatus,
                        ClientStatus = 500,
                        ErrorCode = "INVALID_MODEL",
                        ErrorMessage = "Configured model is unavailable for this API key/project.",
                        ModelUsed = model
                    };
                }

                if (providerStatus >= 500)
                {
                    return new GeminiCallResult
                    {
                        Success = false,
                        ProviderStatus = providerStatus,
                        ClientStatus = 502,
                        ErrorCode = "PROVIDER_ERROR",
                        ErrorMessage = "Tutor provider is temporarily unavailable. Please retry shortly.",
                        ModelUsed = model
                    };
                }

                return new GeminiCallResult
                {
                    Success = false,
                    ProviderStatus = providerStatus,
                    ClientStatus = 502,
                    ErrorCode = "PROVIDER_ERROR",
                    ErrorMessage = "Tutor request failed (" + providerStatus + "). " + providerMessage,
                    ModelUsed = model
                };
            }
        }

        private static List<ChatTurn> ParseHistory(JToken token)
        {
            var turns = new List<ChatTurn>();
            if (!(token is JArray arr)) return turns;

            foreach (var item in arr)
            {
                if (!(item is JObject o)) continue;
                string role = ((string)o["role"] ?? "").Trim().ToLowerInvariant();
                string text = Truncate(((string)o["text"] ?? "").Trim(), 500);
                if (string.IsNullOrWhiteSpace(text)) continue;
                if (role != "user" && role != "assistant") continue;
                turns.Add(new ChatTurn { Role = role, Text = text });
                if (turns.Count >= 6) break;
            }
            return turns;
        }

        private static string BuildPageContext(string moduleId, string pagePath)
        {
            var sb = new StringBuilder();
            if (!string.IsNullOrWhiteSpace(pagePath))
                sb.AppendLine("Page: " + pagePath);
            if (!string.IsNullOrWhiteSpace(moduleId))
                sb.AppendLine("Current module ID: " + moduleId);
            if (sb.Length == 0)
                sb.AppendLine("General math tutoring mode (no module context available).");
            return Truncate(sb.ToString().Trim(), 800);
        }

        private static string BuildPrompt(string pageContext, string message, List<ChatTurn> history)
        {
            var sb = new StringBuilder();
            sb.AppendLine("You are MathSphere Tutor for students.");
            sb.AppendLine("Rules:");
            sb.AppendLine("- Teach step-by-step with a hint-first approach.");
            sb.AppendLine("- Explain concepts before giving final answers.");
            sb.AppendLine("- Keep responses concise, clear, and age-appropriate.");
            sb.AppendLine("- If student asks for direct answer, still include short method.");
            sb.AppendLine("- Use plain text and short markdown headings/bold only.");
            sb.AppendLine("- If question is not math-related, politely refuse and ask for a math question.");
            sb.AppendLine("- If unsure, say you are not sure and ask a clarifying question.");
            sb.AppendLine("- Do not provide harmful, illegal, sexual, or self-harm guidance; give a brief safety refusal.");
            sb.AppendLine("- For calculation results, include a quick check step to verify the answer.");
            sb.AppendLine("- Keep answers under 180 words unless the student asks for full detail.");
            sb.AppendLine("- Do not use LaTeX delimiters ($$, \\(...\\), \\[...\\]); write math in plain text (example: sigma, n, x^2).");
            sb.AppendLine("- Use only plain keyboard math notation. Avoid LaTeX commands and escaped symbols. Prefer: *, /, <=, >=, !=, sqrt(x), pi, x^2.");
            sb.AppendLine();
            sb.AppendLine("Context:");
            sb.AppendLine(pageContext);

            if (history != null && history.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Recent chat history:");
                foreach (var turn in history)
                    sb.AppendLine(turn.Role + ": " + turn.Text);
            }

            sb.AppendLine();
            sb.AppendLine("Student question:");
            sb.AppendLine(message);
            return Truncate(sb.ToString(), 3500);
        }

        private static string ExtractProviderMessage(string raw)
        {
            try
            {
                var root = JObject.Parse(raw);
                return (string)root["error"]?["message"] ?? "";
            }
            catch
            {
                return "";
            }
        }

        private static bool IsTransient(int status)
        {
            return status == 429 || status == 500 || status == 502 || status == 503 || status == 504;
        }

        private static string Truncate(string text, int max)
        {
            if (string.IsNullOrEmpty(text)) return "";
            return text.Length <= max ? text : text.Substring(0, max);
        }

        private static string SafeLog(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "-" : value.Replace("\n", " ").Replace("\r", " ");
        }

        private static void WriteJson(HttpContext ctx, int statusCode, object payload)
        {
            ctx.Response.StatusCode = statusCode;
            ctx.Response.Write(JsonConvert.SerializeObject(payload));
        }

        private sealed class ChatTurn
        {
            public string Role { get; set; }
            public string Text { get; set; }
        }

        private sealed class GeminiCallResult
        {
            public bool Success { get; set; }
            public string Answer { get; set; }
            public int ProviderStatus { get; set; }
            public int ClientStatus { get; set; }
            public string ErrorCode { get; set; }
            public string ErrorMessage { get; set; }
            public string ModelUsed { get; set; }
        }
    }
}
