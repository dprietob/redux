namespace Redux.Images {

    // Presents the input images and turns user gestures into controller calls.
    // Shows an empty state when there are no images and a status bar with the
    // selection summary.
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

        private ImageListController controller;

        // Whether each image shows a button to choose the metadata it keeps.
        public bool metadata_editable { get; set; default = false; }

        public signal void metadata_requested(SourceImage image);
        // Set while the check reflects the selection, so that change is not
        // mistaken for a user click.
        private bool reflecting_selection = false;

        public ImageListPanel (ImageListController controller)
        {
            this.controller = controller;
            list_box.bind_model(controller.images, build_row);
            controller.images.items_changed.connect(() => refresh());
            select_all_button.toggled.connect(on_select_all_toggled);

            refresh();
        }

        private void refresh()
        {
            var has_images = controller.images.get_n_items() > 0;
            stack.visible_child_name = has_images ? "images" : "empty";
            status_bar.visible = has_images;
            refresh_selection();
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

        private Gtk.Widget build_row(Object item)
        {
            var image = (SourceImage) item;
            var row = new ImageRow(image);
            image.notify["selected"].connect(() => refresh_selection());
            row.remove_requested.connect((target) => controller.remove(target));
            row.metadata_requested.connect((target) => metadata_requested(target));
            bind_property("metadata-editable", row, "metadata-editable", BindingFlags.SYNC_CREATE);
            return row;
        }
    }
}
