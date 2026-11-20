using Redux.Images;

namespace Redux.Metadata {

    // Coordinates the per-image metadata editor: it loads the metadata of an
    // image once and applies the user's choices to it.
    public class MetadataController : Object
    {

        private LoadImageMetadataAction load_metadata_action;
        private SetMetadataCategoryKeptAction set_category_kept_action;

        public MetadataController ()
        {
            load_metadata_action = new LoadImageMetadataAction(new MetadataReaderService());
            set_category_kept_action = new SetMetadataCategoryKeptAction();
        }

        // Returns the metadata selection of the image, reading it the first
        // time. Returns an error message, or null on success.
        public string? load(SourceImage image, out MetadataSelection? selection)
        {
            selection = image.metadata_selection;
            if (selection != null) {
                return null;
            }

            try {
                selection = load_metadata_action.execute(image.file);
            } catch (Error error) {
                return error.message;
            }
            image.metadata_selection = selection;
            return null;
        }

        public void set_category_kept(MetadataSelection selection, MetadataCategory category, bool kept)
        {
            set_category_kept_action.execute(selection, category, kept);
        }
    }
}
