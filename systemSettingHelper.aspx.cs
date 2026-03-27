using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;

namespace MathSphere
{
    /// <summary>
    /// Shared helper for dbo.SystemSettings.
    /// Add this file once to your project — both admin and student pages use it.
    ///
    /// USAGE ON ANY STUDENT PAGE:
    ///
    ///   // Award points after flashcard completion:
    ///   int pts = SystemSettingsHelper.GetInt("FlashcardCompletion", 10);
    ///
    ///   // Award bonus after perfect quiz:
    ///   int quizBonus = SystemSettingsHelper.GetInt("QuizPerfectScore", 50);
    ///
    ///   // Award 7-day streak bonus:
    ///   int streakBonus = SystemSettingsHelper.GetInt("StreakBonus7Day", 100);
    ///
    ///   // Check inactivity threshold before sending notificationTable entry:
    ///   int days = SystemSettingsHelper.GetInt("InactivityThresholdDays", 3);
    ///
    ///   // Check streak window for StudentStreak update:
    ///   int hours = SystemSettingsHelper.GetInt("DailyActivityWindowHours", 24);
    /// </summary>
    public static class SystemSettingsHelper
    {
        private static string CS =>
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        // Read all settings as a dictionary
        public static Dictionary<string, string> GetAll()
        {
            var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(
                    "SELECT SettingKey, SettingValue FROM dbo.SystemSettings;", con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            dict[r["SettingKey"].ToString()] = r["SettingValue"].ToString();
                }
            }
            catch { }
            return dict;
        }

        // Read a single int
        public static int GetInt(string key, int fallback = 0)
        {
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(
                    "SELECT SettingValue FROM dbo.SystemSettings WHERE SettingKey = @k;", con))
                {
                    cmd.Parameters.AddWithValue("@k", key);
                    con.Open();
                    object val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value) return fallback;
                    return int.TryParse(val.ToString(), NumberStyles.Integer,
                        CultureInfo.InvariantCulture, out int p) ? p : fallback;
                }
            }
            catch { return fallback; }
        }

        // Read a single string
        public static string GetString(string key, string fallback = "")
        {
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(
                    "SELECT SettingValue FROM dbo.SystemSettings WHERE SettingKey = @k;", con))
                {
                    cmd.Parameters.AddWithValue("@k", key);
                    con.Open();
                    object val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value) return fallback;
                    string s = val.ToString();
                    return string.IsNullOrWhiteSpace(s) ? fallback : s;
                }
            }
            catch { return fallback; }
        }
    }
}

