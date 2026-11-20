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

        public SourceImage image { get; private set; }
        public bool metadata_editable { get; set; default = false; }

        public signal void remove_requested(SourceImage image);
        public signal void metadata_requested(SourceImage image);

        public ImageRow (SourceImage image)
        {
            this.image = image;

            title = image.name;
            subtitle = "%s · %s".printf(format_size(image.size), ContentType.get_description(image.content_type));
            tooltip_text = image.path();

            image.bind_property("selected", check_button, "active",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            bind_property("metadata-editable", metadata_button, "visible", BindingFlags.SYNC_CREATE);
            metadata_button.clicked.connect(() => metadata_requested(image));
            remove_button.clicked.connect(() => remove_requested(image));
        }
    }
}
