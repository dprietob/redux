namespace Redux.Metadata {

    // A metadata tag with its value and a check to keep it.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/metadata-tag-row.ui")]
    public class MetadataTagRow : Adw.ActionRow
    {

        // Long values, such as maker notes, are cut to keep the list readable.
        private const int MAXIMUM_VISIBLE_CHARACTERS = 160;

        [GtkChild]
        private unowned Gtk.CheckButton kept_button;

        public MetadataTagRow (MetadataTag tag)
        {
            title = tag.label;
            subtitle = shortened(tag.description);
            tooltip_text = tag.key;
            tag.bind_property("kept", kept_button, "active", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        }

        private string shortened(string text)
        {
            if (text.char_count() <= MAXIMUM_VISIBLE_CHARACTERS) {
                return text;
            }
            return text.substring(0, text.index_of_nth_char(MAXIMUM_VISIBLE_CHARACTERS)) + "…";
        }
    }
}
