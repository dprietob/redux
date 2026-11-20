namespace Redux.Metadata {

    // Keeps or removes every tag of a metadata category at once.
    public class SetMetadataCategoryKeptAction : Object
    {

        public void execute(MetadataSelection selection, MetadataCategory category, bool kept)
        {
            for (uint index = 0; index < selection.tags.get_n_items(); index++) {
                var tag = (MetadataTag) selection.tags.get_item(index);
                if (tag.category == category) {
                    tag.kept = kept;
                }
            }
        }
    }
}
