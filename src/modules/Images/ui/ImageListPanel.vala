namespace Redux.Images {

    // Presents the input images and turns user gestures into controller calls.
    // Shows an empty state when there are no images and a status bar with the
    // selection summary. Image files can be dropped anywhere on the panel.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/image-list-panel.ui")]
    public class ImageListPanel : Adw.NavigationPage
    {

        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.ListBox list_box;
        [GtkChild]
        private unowned Gtk.Box status_bar;
        [GtkChild]
        private unowned Gtk.CheckButton select_all_button;
        [GtkChild]
        private unowned Gtk.Label summary_label;
        [GtkChild]
        private unowned Gtk.Button options_button;

        private ImageListController controller;
        // Set while the check reflects the selection, so that change is not
        // mistaken for a user click.
        private bool reflecting_selection = false;

        // Whether each image shows a button to choose the metadata it keeps.
        public bool metadata_editable { get; set; default = false; }
        // Whether the panel is shown alone, on a narrow screen, and needs a
        // button to reach the conversion options.
        public bool narrow { get; set; default = false; }

        public signal void metadata_requested(SourceImage image);
        public signal void files_dropped(File[] files);

        public ImageListPanel (ImageListController controller)
        {
            this.controller = controller;
            list_box.bind_model(controller.images, build_row);
            controller.images.items_changed.connect(() => refresh());
            controller.selection_changed.connect(() => refresh_selection());
            select_all_button.toggled.connect(on_select_all_toggled);
            accept_dropped_files();
            bind_property("narrow", options_button, "visible", BindingFlags.SYNC_CREATE);

            refresh();
        }

        // Lets the user drop image files from the file manager onto the panel.
        private void accept_dropped_files()
        {
            var target = new Gtk.DropTarget(typeof (Gdk.FileList), Gdk.DragAction.COPY);
            target.drop.connect((value, x, y) => {
                var file_list = (Gdk.FileList) value.get_boxed();
                File[] files = {};
                foreach (var file in file_list.get_files()) {
                    files += file;
                }
                files_dropped(files);
                return true;
            });
            add_controller(target);
        }

        private void refresh()
        {
            var has_images = controller.images.get_n_items() > 0;
            stack.visible_child_name = has_images ? "images" : "empty";
            status_bar.visible = has_images;
            refresh_selection();
            refresh_move_buttons();
        }

        // The first image cannot move up and the last one cannot move down.
        private void refresh_move_buttons()
        {
            var last_index = (int) controller.images.get_n_items() - 1;
            for (int index = 0; index <= last_index; index++) {
                var row = (ImageRow) list_box.get_row_at_index(index);
                row.can_move_up = index > 0;
                row.can_move_down = index < last_index;
            }
        }

        // Updates the selection summary and the state of the select-all check.
        private void refresh_selection()
        {
            uint total = controller.images.get_n_items();
            uint selected = 0;
            int64 selected_size = 0;
            for (uint index = 0; index < total; index++) {
                var image = (SourceImage) controller.images.get_item(index);
                if (image.selected) {
                    selected++;
                    selected_size += image.size;
                }
            }

            summary_label.label = _("%u of %u selected · %s").printf(selected, total, format_size(selected_size));

            reflecting_selection = true;
            select_all_button.inconsistent = selected > 0 && selected < total;
            select_all_button.active = total > 0 && selected == total;
            reflecting_selection = false;
        }

        private void on_select_all_toggled()
        {
            if (reflecting_selection) {
                return;
            }
            controller.select_all(select_all_button.active);
        }

        // The handlers only use the panel, never the row: a closure keeping the
        // row would be stored in the row itself and it would never be freed.
        private Gtk.Widget build_row(Object item)
        {
            var row = new ImageRow((SourceImage) item);
            row.remove_requested.connect((image) => controller.remove(image));
            row.metadata_requested.connect((image) => metadata_requested(image));
            row.move_requested.connect((dragged, target, after) => controller.move(dragged, target, after));
            row.move_by_requested.connect((image, offset) => controller.move_by(image, offset));
            row.preview_requested.connect(on_preview_requested);
            bind_property("metadata-editable", row, "metadata-editable", BindingFlags.SYNC_CREATE);
            bind_property("narrow", row, "narrow", BindingFlags.SYNC_CREATE);
            return row;
        }

        private void on_preview_requested(ImageRow row, SourceImage image)
        {
            controller.load_preview.begin(image, (object, result) => {
                var preview = controller.load_preview.end(result);
                if (preview != null) {
                    row.show_preview(preview);
                }
            });
        }
    }
}
