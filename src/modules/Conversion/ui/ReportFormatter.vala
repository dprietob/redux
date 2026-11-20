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

        // The one-line outcome of a conversion, shared by the report and the
        // notification.
        public static string headline(ConversionReport report)
        {
            if (report.cancelled) {
                return _("Conversion Cancelled");
            }
            if (report.converted_count == 0) {
                return _("No Images Converted");
            }
            if (report.failed_count > 0) {
                return _("Conversion Finished with Errors");
            }
            return _("Conversion Finished");
        }

        public static string space_change(ConversionReport report)
        {
            return report.saved_size >= 0
                ? _("The converted images take up %s less space.").printf(format_size(report.saved_size))
                : _("The converted images take up %s more space.").printf(format_size(-report.saved_size));
        }
    }
}
