namespace Redux.Images {

    // A row of the input list: the image name, its size and type, a check to
    // include it in the conversion and a button to remove it.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/image-row.ui")]
    public class ImageRow : Adw.ActionRow
    {

        [GtkChild]
        private unowned Gtk.CheckButton check_button;
        [GtkChild]
        private unowned Gtk.Button metadata_button;
        [GtkChild]
        private unowned Gtk.Button remove_button;

        private ImagePreview preview;
        private bool preview_requested_once = false;

        public SourceImage image { get; private set; }
        public bool metadata_editable { get; set; default = false; }

        public signal void remove_requested(SourceImage image);
        public signal void metadata_requested(SourceImage image);
        // Emitted the first time the tooltip is shown, to load the preview.
        public signal void preview_requested(SourceImage image);

        public ImageRow (SourceImage image)
        {
            this.image = image;

            title = image.name;
            subtitle = "%s · %s".printf(format_size(image.size), ContentType.get_description(image.content_type));
            preview = new ImagePreview(image.display_path);
            has_tooltip = true;
            query_tooltip.connect(on_query_tooltip);

            image.bind_property("selected", check_button, "active",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            bind_property("metadata-editable", metadata_button, "visible", BindingFlags.SYNC_CREATE);
            metadata_button.clicked.connect(() => metadata_requested(image));
            remove_button.clicked.connect(() => remove_requested(image));
        }

        public void show_preview(Gdk.Pixbuf image_preview)
        {
            preview.show_image(image_preview);
            trigger_tooltip_query();
        }

        private bool on_query_tooltip(int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip)
        {
            if (!preview_requested_once) {
                preview_requested_once = true;
                preview_requested(image);
            }
            tooltip.set_custom(preview);
            return true;
        }
    }
}
