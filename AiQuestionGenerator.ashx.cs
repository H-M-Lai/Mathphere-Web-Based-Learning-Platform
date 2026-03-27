using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Configuration;
using System.IO;
using System.Text;
using System.Web;
using System.Web.SessionState;

namespace Assignment
{
    public class AiQuestionGenerator : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable => false;

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            try
            {
                if (!context.Request.HttpMethod.Equals("POST", StringComparison.OrdinalIgnoreCase))
                { Write(context, 405, new { ok = false, error = "POST only." }); return; }

                // Auth: teachers only
                string userId = (context.Session["UserID"] ?? context.Session["userID"] ?? "").ToString().Trim();
                string role = (context.Session["RoleName"] ?? "").ToString().Trim();

                if (string.IsNullOrWhiteSpace(userId))
                { Write(context, 401, new { ok = false, error = "Not logged in." }); return; }

                if (!role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
                { Write(context, 403, new { ok = false, error = "Teachers only." }); return; }

                // Parse request
                string body;
                using (var sr = new StreamReader(context.Request.InputStream))
                    body = sr.ReadToEnd();

                JObject req;
                try { req = JObject.Parse(body); }
                catch { Write(context, 400, new { ok = false, error = "Invalid JSON body." }); return; }

                string topic = ((string)req["topic"] ?? "").Trim();
                string level = ((string)req["level"] ?? "Medium").Trim();
                string type = ((string)req["type"] ?? "mcq").Trim();
                int count = Math.Min(Math.Max((int?)req["count"] ?? 5, 1), 10);

                if (string.IsNullOrWhiteSpace(topic))
                { Write(context, 400, new { ok = false, error = "Topic is required." }); return; }

                // Build prompt
                string prompt = BuildPrompt(topic, level, type, count);

                string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
                string model = ConfigurationManager.AppSettings["GeminiModel"] ?? "gemini-2.0-flash";
                string fallback = ConfigurationManager.AppSettings["GeminiFallbackModel"] ?? "gemini-1.5-flash";

                // Call Gemini
                GeminiResult result = GeminiHelper.Call(apiKey, model, fallback, prompt);

                if (!result.Success)
                {
                    Write(context, result.ProviderStatus, new
                    {
                        ok = false,
                        error = result.ErrorMessage,
                        code = result.ErrorCode
                    });
                    return;
                }

                // Parse returned JSON
                JArray questions;
                string parseError;
                if (!TryExtractQuestionsJson(result.Text, out questions, out parseError))
                {
                    // Return the raw text in debug so you can see exactly what Gemini sent
                    Write(context, 500, new
                    {
                        ok = false,
                        error = "AI returned malformed JSON. Please retry.",
                        parseError = parseError,
                        rawPreview = result.Text?.Length > 400
                                         ? result.Text.Substring(0, 400) + "…"
                                         : result.Text
                    });
                    return;
                }

                Write(context, 200, new { ok = true, questions, model = result.ModelUsed });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[AiQuestionGenerator] " + ex);
                Write(context, 500, new { ok = false, error = "Generation failed: " + ex.Message });
            }
        }

        // Prompt builder
        private static string BuildPrompt(string topic, string level, string type, int count)
        {
            var sb = new StringBuilder();
            sb.AppendLine("You are a math assessment question generator for a school platform.");
            sb.AppendLine($"Generate exactly {count} {level}-difficulty {FormatType(type)} questions on the topic: \"{topic}\".");
            sb.AppendLine();
            sb.AppendLine("Rules:");
            sb.AppendLine("- Questions must be math-focused and age-appropriate for secondary/high school.");
            sb.AppendLine("- Write math in plain text only (e.g. x^2, sqrt(x), pi). No LaTeX, no markdown.");
            sb.AppendLine("- IMPORTANT: Respond with ONLY a raw JSON array. No markdown code fences, no prose, no commentary.");
            sb.AppendLine("- The very first character of your response must be '[' and the very last must be ']'.");

            if (type == "mcq")
            {
                sb.AppendLine("- Each question must have exactly 4 options labeled A, B, C, D.");
                sb.AppendLine("- Exactly one option must be correct.");
            }

            sb.AppendLine();
            sb.AppendLine("Required JSON schema (follow exactly):");

            if (type == "mcq")
            {
                sb.AppendLine(@"[
  {
    ""question"": ""What is 3x + 5 = 11? Solve for x."",
    ""options"": { ""A"": ""1"", ""B"": ""2"", ""C"": ""3"", ""D"": ""4"" },
    ""answer"": ""B"",
    ""explanation"": ""3(2) + 5 = 11, so x = 2.""
  }
]");
            }
            else // true_false
            {
                sb.AppendLine(@"[
  {
    ""question"": ""The square of any negative number is always positive."",
    ""answer"": ""True"",
    ""explanation"": ""(-3)^2 = 9, which is positive. This holds for all real negatives.""
  }
]");
            }

            return sb.ToString();
        }

        private static string FormatType(string type)
        {
            if (type == "mcq") return "multiple-choice (MCQ)";
            if (type == "true_false") return "true/false";
            return type;
        }

        // Robust JSON extractor
        // Handles: clean array, ```json fences, prose before/after the array
        private static bool TryExtractQuestionsJson(string raw, out JArray result, out string error)
        {
            result = null;
            error = null;

            if (string.IsNullOrWhiteSpace(raw))
            { error = "Empty response from AI."; return false; }

            string cleaned = raw.Trim();

            // 1. Strip ```json ... ``` or ``` ... ``` fences
            if (cleaned.StartsWith("```"))
            {
                int newline = cleaned.IndexOf('\n');
                if (newline >= 0) cleaned = cleaned.Substring(newline + 1).Trim();
                if (cleaned.EndsWith("```"))
                    cleaned = cleaned.Substring(0, cleaned.Length - 3).Trim();
            }

            // 2. If still not starting with '[', find the first '[' and last ']'
            if (!cleaned.StartsWith("["))
            {
                int start = cleaned.IndexOf('[');
                int end = cleaned.LastIndexOf(']');
                if (start >= 0 && end > start)
                    cleaned = cleaned.Substring(start, end - start + 1).Trim();
            }

            // 3. Try parsing
            try
            {
                result = JArray.Parse(cleaned);
                return true;
            }
            catch (Exception ex)
            {
                error = ex.Message;
                return false;
            }
        }

        private static void Write(HttpContext ctx, int status, object payload)
        {
            ctx.Response.StatusCode = status;
            ctx.Response.Write(JsonConvert.SerializeObject(payload));
        }
    }
}
