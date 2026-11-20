namespace Redux.Conversion {

    // A row of the report: the converted image with its size change, or the
    // reason why it could not be converted.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/conversion-result-row.ui")]
    public class ConversionResultRow : Adw.ActionRow
    {

        [GtkChild]
        private unowned Gtk.Image status_icon;
        [GtkChild]
        private unowned Gtk.Label reduction_label;

        public ConversionResultRow (ConversionResult result)
        {
            title = result.source_name;
            if (result.succeeded) {
                show_success(result);
            } else {
                show_failure(result);
            }
        }

        private void show_success(ConversionResult result)
        {
            status_icon.icon_name = "emblem-ok-symbolic";
            status_icon.add_css_class("success");

            subtitle = _("Saved as %s").printf(result.output_name) + "\n"
                + _("%s → %s · %d × %d → %d × %d").printf(
                format_size(result.original_size), format_size(result.output_size),
                result.original_width, result.original_height, result.output_width, result.output_height);

            reduction_label.label = ReportFormatter.signed_percentage(-result.reduction_percentage);
            reduction_label.add_css_class(result.reduction_percentage >= 0 ? "success" : "warning");
            reduction_label.tooltip_text = result.reduction_percentage >= 0
                ? _("Size reduction") : _("Size increase");
        }

        private void show_failure(ConversionResult result)
        {
            status_icon.icon_name = "dialog-error-symbolic";
            status_icon.add_css_class("error");
            subtitle = result.error_message;
            reduction_label.visible = false;
        }
    }
}
