using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net.Http;
using System.Text;
using System.Threading;
using System;

namespace Assignment
{
    public static class GeminiHelper
    {
        private static readonly HttpClient Http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        public static GeminiResult Call(string apiKey, string model, string fallbackModel, string prompt)
        {
            var first = CallOnce(apiKey, model, prompt);
            if (first.Success) return first;

            bool hasFallback = !string.IsNullOrWhiteSpace(fallbackModel) &&
                               !fallbackModel.Equals(model, StringComparison.OrdinalIgnoreCase);

            if ((first.ProviderStatus == 404 || first.ProviderStatus == 429) && hasFallback)
                return CallOnce(apiKey, fallbackModel, prompt);

            if (IsTransient(first.ProviderStatus))
            {
                Thread.Sleep(700);
                return CallOnce(apiKey, model, prompt);
            }

            return first;
        }

        private static GeminiResult CallOnce(string apiKey, string model, string prompt)
        {
            string url = "https://generativelanguage.googleapis.com/v1beta/models/"
                       + model + ":generateContent?key=" + apiKey;

            var body = new
            {
                contents = new[] { new { parts = new[] { new { text = prompt } } } }
            };

            var request = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(JsonConvert.SerializeObject(body), Encoding.UTF8, "application/json")
            };

            using (var response = Http.SendAsync(request).GetAwaiter().GetResult())
            {
                string raw = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                int status = (int)response.StatusCode;

                if (response.IsSuccessStatusCode)
                {
                    string text = (string)JObject.Parse(raw)["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";
                    if (string.IsNullOrWhiteSpace(text))
                        return Fail(502, "PROVIDER_ERROR", "No content returned. Please retry.", model);

                    return new GeminiResult { Success = true, Text = text.Trim(), ModelUsed = model };
                }

                if (status == 429) return Fail(429, "RATE_LIMIT", "AI is busy. Please wait and retry.", model);
                if (status == 404) return Fail(404, "INVALID_MODEL", "Model unavailable for this API key.", model);
                if (status >= 500) return Fail(502, "PROVIDER_ERROR", "AI provider temporarily unavailable.", model);

                string msg = (string)JObject.Parse(raw)?["error"]?["message"] ?? "";
                return Fail(502, "PROVIDER_ERROR", "Request failed (" + status + "). " + msg, model);
            }
        }

        private static bool IsTransient(int s) => s == 429 || s == 500 || s == 502 || s == 503 || s == 504;

        private static GeminiResult Fail(int status, string code, string message, string model) =>
            new GeminiResult { Success = false, ProviderStatus = status, ErrorCode = code, ErrorMessage = message, ModelUsed = model };
    }

    public class GeminiResult
    {
        public bool Success { get; set; }
        public string Text { get; set; }
        public string ModelUsed { get; set; }
        public int ProviderStatus { get; set; }
        public string ErrorCode { get; set; }
        public string ErrorMessage { get; set; }
    }
}