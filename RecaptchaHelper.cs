using System.Configuration;
using System.IO;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;

namespace MathSphere
{
    public static class RecaptchaHelper
    {
        public static bool Verify(HttpRequest request)
        {
            string response = request.Form["g-recaptcha-response"];
            if (string.IsNullOrWhiteSpace(response)) return false;

            string secretKey = ConfigurationManager.AppSettings["RecaptchaSecretKey"];
            string url = "https://www.google.com/recaptcha/api/siteverify";
            string postData = $"secret={secretKey}&response={response}";

            try
            {
                var webRequest = (HttpWebRequest)WebRequest.Create(url);
                webRequest.Method = "POST";
                webRequest.ContentType = "application/x-www-form-urlencoded";
                webRequest.Timeout = 5000;

                using (var writer = new StreamWriter(webRequest.GetRequestStream()))
                    writer.Write(postData);

                using (var webResponse = (HttpWebResponse)webRequest.GetResponse())
                using (var reader = new StreamReader(webResponse.GetResponseStream()))
                {
                    string json = reader.ReadToEnd();
                    dynamic result = new JavaScriptSerializer().DeserializeObject(json);
                    return result["success"] == true;
                }
            }
            catch { return false; }
        }
    }
}