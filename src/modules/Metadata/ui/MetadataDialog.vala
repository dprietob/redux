namespace Redux.Metadata {

    // Lets the user choose which metadata of one image is kept in its
    // converted version, grouped by category.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/metadata-dialog.ui")]
    public class MetadataDialog : Adw.Dialog
    {

        private const MetadataCategory[] CATEGORIES = {
            MetadataCategory.EXIF,
            MetadataCategory.XMP,
            MetadataCategory.IPTC,
            MetadataCategory.COMMENT,
        };

        [GtkChild]
        private unowned Adw.WindowTitle window_title;
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Adw.PreferencesGroup categories_group;

        private MetadataController controller;
        private MetadataSelection selection;

        public MetadataDialog (MetadataController controller, string image_name, MetadataSelection selection)
        {
            this.controller = controller;
            this.selection = selection;
            window_title.subtitle = image_name;

            foreach (var category in CATEGORIES) {
                var tags = tags_of(selection, category);
                if (tags.length == 0) {
                    continue;
                }
                var row = new MetadataCategoryRow(category, category_title(category), tags);
                row.category_toggled.connect(on_category_toggled);
                categories_group.add(row);
            }

            stack.visible_child_name = selection.tags.get_n_items() > 0 ? "categories" : "empty";
        }

        // A method rather than a lambda capturing the dialog, so the rows do not
        // keep the dialog alive once it is closed.
        private void on_category_toggled(MetadataCategory category, bool kept)
        {
            controller.set_category_kept(selection, category, kept);
        }

        private MetadataTag[] tags_of(MetadataSelection selection, MetadataCategory category)
        {
            MetadataTag[] tags = {};
            for (uint index = 0; index < selection.tags.get_n_items(); index++) {
                var tag = (MetadataTag) selection.tags.get_item(index);
                if (tag.category == category) {
                    tags += tag;
                }
            }
            return tags;
        }

        private string category_title(MetadataCategory category)
        {
            switch (category) {
            case MetadataCategory.EXIF:
                return "EXIF";

            case MetadataCategory.XMP:
                return "XMP";

            case MetadataCategory.IPTC:
                return "IPTC";

            default:
                return _("Comment");
            }
        }
    }
}
