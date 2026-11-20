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

        public MetadataDialog (MetadataController controller, string image_name, MetadataSelection selection)
        {
            window_title.subtitle = image_name;

            foreach (var category in CATEGORIES) {
                var tags = tags_of(selection, category);
                if (tags.length == 0) {
                    continue;
                }
                var row_category = category;
                var row = new MetadataCategoryRow(category_title(row_category), tags);
                row.category_toggled.connect((kept) => controller.set_category_kept(selection, row_category, kept));
                categories_group.add(row);
            }

            stack.visible_child_name = selection.tags.get_n_items() > 0 ? "categories" : "empty";
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
