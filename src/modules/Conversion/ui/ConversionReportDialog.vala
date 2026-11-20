namespace Redux.Conversion {

    // Shows the statistics of a finished conversion: how many images were
    // converted, how much space was saved and the result of every image.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/conversion-report-dialog.ui")]
    public class ConversionReportDialog : Adw.Dialog
    {

        [GtkChild]
        private unowned Gtk.Button open_folder_button;
        [GtkChild]
        private unowned Gtk.Image status_icon;
        [GtkChild]
        private unowned Gtk.Label headline_label;
        [GtkChild]
        private unowned Gtk.Label description_label;
        [GtkChild]
        private unowned Adw.ActionRow failed_row;
        [GtkChild]
        private unowned Adw.ActionRow saved_row;
        [GtkChild]
        private unowned Gtk.Label converted_label;
        [GtkChild]
        private unowned Gtk.Label failed_label;
        [GtkChild]
        private unowned Gtk.Label original_size_label;
        [GtkChild]
        private unowned Gtk.Label output_size_label;
        [GtkChild]
        private unowned Gtk.Label saved_label;
        [GtkChild]
        private unowned Gtk.Label reduction_label;
        [GtkChild]
        private unowned Gtk.ListBox results_list;

        public signal void open_folder_requested(File directory);

        public ConversionReportDialog (ConversionReport report)
        {
            show_headline(report);
            show_summary(report);
            results_list.bind_model(report.results, (item) => new ConversionResultRow((ConversionResult) item));

            open_folder_button.visible = report.output_directory != null && report.converted_count > 0;
            open_folder_button.clicked.connect(() => open_folder_requested(report.output_directory));
        }

        private void show_headline(ConversionReport report)
        {
            if (report.cancelled) {
                status_icon.icon_name = "process-stop-symbolic";
                headline_label.label = _("Conversion Cancelled");
            } else if (report.converted_count == 0) {
                status_icon.icon_name = "dialog-error-symbolic";
                headline_label.label = _("No Images Converted");
            } else if (report.failed_count > 0) {
                status_icon.icon_name = "dialog-warning-symbolic";
                headline_label.label = _("Conversion Finished with Errors");
            } else {
                status_icon.icon_name = "emblem-ok-symbolic";
                headline_label.label = _("Conversion Finished");
            }

            description_label.label = report.saved_size >= 0
                ? _("The converted images take up %s less space.").printf(format_size(report.saved_size))
                : _("The converted images take up %s more space.").printf(format_size(-report.saved_size));
            description_label.visible = report.converted_count > 0;
        }

        private void show_summary(ConversionReport report)
        {
            converted_label.label = report.converted_count.to_string();
            failed_label.label = report.failed_count.to_string();
            failed_row.visible = report.failed_count > 0;
            original_size_label.label = format_size(report.original_total_size);
            output_size_label.label = format_size(report.output_total_size);

            if (report.saved_size >= 0) {
                saved_row.title = _("Space Saved");
                saved_label.label = format_size(report.saved_size);
            } else {
                saved_row.title = _("Size Increase");
                saved_label.label = format_size(-report.saved_size);
            }
            reduction_label.label = ReportFormatter.signed_percentage(-report.reduction_percentage);
        }
    }
}
