namespace Redux.Conversion {

    // Formats the figures of a conversion report for display.
    public class ReportFormatter : Object
    {

        // Formats a size change as a signed percentage, e.g. "−42.5 %" for a
        // file that became smaller.
        public static string signed_percentage(double change)
        {
            var sign = change > 0 ? "+" : (change < 0 ? "−" : "");
            return "%s%.1f %%".printf(sign, change.abs());
        }

        public static string percentage(double value)
        {
            return "%.1f %%".printf(value);
        }
    }
}
