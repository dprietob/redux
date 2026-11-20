namespace Redux.Metadata {

    // Copies the metadata the user keeps from an original image to its
    // converted version, adapted to the new image.
    public class MetadataWriterService : Object
    {

        private const long NORMAL_ORIENTATION = 1;
        private const string[] ORIENTATION_TAGS = { "Exif.Image.Orientation", "Xmp.tiff.Orientation" };
        private const string[] WIDTH_TAGS = { "Exif.Photo.PixelXDimension", "Exif.Image.ImageWidth" };
        private const string[] HEIGHT_TAGS = { "Exif.Photo.PixelYDimension", "Exif.Image.ImageLength" };

        // The encoders write images without metadata, so removing everything
        // needs no work; otherwise the kept metadata is written to the target.
        public void write(File source, File target, MetadataMode mode, MetadataSelection? selection,
            int output_width, int output_height) throws Error
        {
            if (mode == MetadataMode.REMOVE_ALL) {
                return;
            }

            var metadata = new GExiv2.Metadata();
            metadata.open_path(source.get_path());

            if (mode == MetadataMode.KEEP_EXIF) {
                metadata.clear_xmp();
                metadata.clear_iptc();
                metadata.clear_comment();
            } else if (selection != null) {
                remove_discarded_tags(metadata, selection);
            }

            adapt_to_output(metadata, output_width, output_height);
            metadata.save_file(target.get_path());
        }

        private void remove_discarded_tags(GExiv2.Metadata metadata, MetadataSelection selection) throws Error
        {
            for (uint index = 0; index < selection.tags.get_n_items(); index++) {
                var tag = (MetadataTag) selection.tags.get_item(index);
                if (tag.kept) {
                    continue;
                }
                if (tag.category == MetadataCategory.COMMENT) {
                    metadata.clear_comment();
                } else {
                    metadata.clear_tag(tag.key);
                }
            }
        }

        // The pixels are already upright and maybe resized, so the orientation
        // is reset, the old thumbnail is dropped and the stored size updated.
        private void adapt_to_output(GExiv2.Metadata metadata, int output_width, int output_height) throws Error
        {
            metadata.erase_exif_thumbnail();
            replace_existing_tags(metadata, ORIENTATION_TAGS, NORMAL_ORIENTATION);
            replace_existing_tags(metadata, WIDTH_TAGS, output_width);
            replace_existing_tags(metadata, HEIGHT_TAGS, output_height);
        }

        // Updates only the tags already present, so no metadata is added that
        // the user chose to remove. The value is set as text so each tag keeps
        // its standard type: a signed long orientation, for example, is
        // ignored by image viewers.
        private void replace_existing_tags(GExiv2.Metadata metadata, string[] keys, long new_value) throws Error
        {
            foreach (var key in keys) {
                if (metadata.has_tag(key)) {
                    metadata.set_tag_string(key, new_value.to_string());
                }
            }
        }
    }
}
