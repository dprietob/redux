namespace Redux.Conversion {

    // Non-dismissable dialog that follows a running conversion and lets the
    // user cancel it.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/conversion-progress-dialog.ui")]
    public class ConversionProgressDialog : Adw.Dialog
    {

        [GtkChild]
        private unowned Gtk.Label current_label;
        [GtkChild]
        private unowned Gtk.ProgressBar progress_bar;
        [GtkChild]
        private unowned Gtk.Button cancel_button;

        public signal void cancel_requested();

        public ConversionProgressDialog ()
        {
            cancel_button.clicked.connect(() => {
                cancel_requested();
                cancel_button.sensitive = false;
                current_label.label = _("Cancelling after the current image…");
            });
        }

        public void update(uint completed, uint total, string current_name)
        {
            progress_bar.fraction = total > 0 ? (double) completed / total : 0;
            progress_bar.text = _("%u of %u").printf(completed, total);
            if (cancel_button.sensitive) {
                current_label.label = current_name;
            }
        }
    }
}
