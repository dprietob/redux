namespace Redux.Images {

    // A row of the input list: the image name, its size and type, a check to
    // include it in the conversion and buttons to edit its metadata and to
    // remove it. On wide screens the row is dragged to reorder it and its
    // preview appears when hovering it; on narrow screens it shows buttons to
    // move it and to preview it instead.
    //
    // Handlers are methods rather than lambdas that capture the row, so the
    // signals connected to the row's own children never keep it alive.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/image-row.ui")]
    public class ImageRow : Adw.ActionRow
    {

        [GtkChild]
        private unowned Gtk.Image drag_handle;
        [GtkChild]
        private unowned Gtk.CheckButton check_button;
        [GtkChild]
        private unowned Gtk.Button move_up_button;
        [GtkChild]
        private unowned Gtk.Button move_down_button;
        [GtkChild]
        private unowned Gtk.MenuButton preview_button;
        [GtkChild]
        private unowned Gtk.Popover preview_popover;
        [GtkChild]
        private unowned Gtk.Button metadata_button;
        [GtkChild]
        private unowned Gtk.Button remove_button;

        private ImagePreview tooltip_preview;
        private ImagePreview popover_preview;
        private bool preview_requested_once = false;

        public SourceImage image { get; private set; }
        public bool metadata_editable { get; set; default = false; }
        // Whether the row is shown on a narrow, usually touch, screen.
        public bool narrow { get; set; default = false; }
        public bool can_move_up { get; set; default = false; }
        public bool can_move_down { get; set; default = false; }

        public signal void remove_requested(SourceImage image);
        public signal void metadata_requested(SourceImage image);
        // Emitted the first time a preview is needed, to load it.
        public signal void preview_requested(SourceImage image);
        // Emitted when another image is dropped on this row: it goes after this
        // row's image when after is true, before it otherwise.
        public signal void move_requested(SourceImage dragged, SourceImage target, bool after);
        // Emitted by the move buttons: -1 moves the image up, 1 moves it down.
        public signal void move_by_requested(SourceImage image, int offset);

        public ImageRow (SourceImage image)
        {
            this.image = image;

            title = image.name;
            subtitle = "%s · %s".printf(format_size(image.size), ContentType.get_description(image.content_type));

            image.bind_property("selected", check_button, "active",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            bind_visibility();
            connect_buttons();
            set_up_previews();
            enable_reordering();
        }

        public void show_preview(Gdk.Pixbuf image_preview)
        {
            tooltip_preview.show_image(image_preview);
            popover_preview.show_image(image_preview);
            trigger_tooltip_query();
        }

        private void bind_visibility()
        {
            bind_property("metadata-editable", metadata_button, "visible", BindingFlags.SYNC_CREATE);
            bind_property("narrow", drag_handle, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);
            bind_property("narrow", move_up_button, "visible", BindingFlags.SYNC_CREATE);
            bind_property("narrow", move_down_button, "visible", BindingFlags.SYNC_CREATE);
            bind_property("narrow", preview_button, "visible", BindingFlags.SYNC_CREATE);
            bind_property("can-move-up", move_up_button, "sensitive", BindingFlags.SYNC_CREATE);
            bind_property("can-move-down", move_down_button, "sensitive", BindingFlags.SYNC_CREATE);
        }

        private void connect_buttons()
        {
            metadata_button.clicked.connect(on_metadata_clicked);
            remove_button.clicked.connect(on_remove_clicked);
            move_up_button.clicked.connect(on_move_up_clicked);
            move_down_button.clicked.connect(on_move_down_clicked);
        }

        private void on_metadata_clicked()
        {
            metadata_requested(image);
        }

        private void on_remove_clicked()
        {
            remove_requested(image);
        }

        private void on_move_up_clicked()
        {
            move_by_requested(image, -1);
        }

        private void on_move_down_clicked()
        {
            move_by_requested(image, 1);
        }

        // The preview shows in a tooltip when hovering the row, and in a
        // popover from the preview button on narrow screens.
        private void set_up_previews()
        {
            tooltip_preview = new ImagePreview(image.display_path);
            popover_preview = new ImagePreview(image.display_path);
            preview_popover.child = popover_preview;
            preview_popover.show.connect(request_preview);

            has_tooltip = true;
            query_tooltip.connect(on_query_tooltip);
        }

        private bool on_query_tooltip(int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip)
        {
            request_preview();
            tooltip.set_custom(tooltip_preview);
            return true;
        }

        private void request_preview()
        {
            if (!preview_requested_once) {
                preview_requested_once = true;
                preview_requested(image);
            }
        }

        // Lets the user reorder images by dragging a row onto another one.
        private void enable_reordering()
        {
            var source = new Gtk.DragSource() {
                actions = Gdk.DragAction.MOVE
            };
            source.prepare.connect(on_drag_prepare);
            source.drag_begin.connect(on_drag_begin);
            add_controller(source);

            var target = new Gtk.DropTarget(typeof (SourceImage), Gdk.DragAction.MOVE);
            target.drop.connect(on_drop);
            add_controller(target);
        }

        private Gdk.ContentProvider? on_drag_prepare(Gtk.DragSource source, double x, double y)
        {
            var dragged = Value(typeof (SourceImage));
            dragged.set_object(image);
            return new Gdk.ContentProvider.for_value(dragged);
        }

        private void on_drag_begin(Gtk.DragSource source, Gdk.Drag drag)
        {
            source.set_icon(new Gtk.WidgetPaintable(this), 0, 0);
        }

        private bool on_drop(Gtk.DropTarget target, Value value, double x, double y)
        {
            var dragged = value.get_object() as SourceImage;
            if (dragged == null) {
                return false;
            }
            move_requested(dragged, image, y > get_height() / 2);
            return true;
        }
    }
}
