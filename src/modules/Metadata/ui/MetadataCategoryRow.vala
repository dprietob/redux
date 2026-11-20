namespace Redux.Metadata {

    // A metadata category. Its switch keeps or removes the whole category and
    // expanding it lists the tags so single ones can be removed.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/metadata-category-row.ui")]
    public class MetadataCategoryRow : Adw.ExpanderRow
    {

        private MetadataTag[] tags;
        // Set while the switch reflects the tags, so that change is not
        // mistaken for the user toggling the category.
        private bool reflecting_tags = false;

        public MetadataCategory category { get; construct; }

        public signal void category_toggled(MetadataCategory category, bool kept);

        public MetadataCategoryRow (MetadataCategory category, string category_title, MetadataTag[] tags)
        {
            Object(category: category);
            this.tags = tags;
            title = category_title;

            foreach (var tag in tags) {
                add_row(new MetadataTagRow(tag));
                tag.notify["kept"].connect(() => refresh());
            }
            notify["enable-expansion"].connect(on_switch_toggled);
            refresh();
        }

        private void refresh()
        {
            uint kept = 0;
            foreach (var tag in tags) {
                if (tag.kept) {
                    kept++;
                }
            }
            subtitle = _("%u of %u kept").printf(kept, tags.length);

            reflecting_tags = true;
            enable_expansion = kept > 0;
            reflecting_tags = false;
        }

        private void on_switch_toggled()
        {
            if (!reflecting_tags) {
                category_toggled(category, enable_expansion);
            }
        }
    }
}
