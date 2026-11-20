namespace Redux.Metadata {

    // Reads the metadata of an image that the user can choose to keep or
    // remove.
    public class MetadataReaderService : Object
    {

        public const string COMMENT_KEY = "Comment";

        // Tags handled automatically: the orientation is applied to the pixels,
        // the thumbnail would be outdated and the pointers only give structure
        // to the EXIF data.
        private const string[] AUTOMATIC_TAGS = {
            "Exif.Image.Orientation",
            "Xmp.tiff.Orientation",
            "Exif.Image.ExifTag",
            "Exif.Image.GPSTag",
            "Exif.Photo.InteroperabilityTag",
        };
        private const string THUMBNAIL_TAG_PREFIX = "Exif.Thumbnail.";

        // Returns every user-visible tag of the image, all of them kept.
        public MetadataSelection read(File file) throws Error
        {
            var metadata = new GExiv2.Metadata();
            metadata.open_path(file.get_path());

            var selection = new MetadataSelection();
            add_tags(selection, metadata, metadata.get_exif_tags(), MetadataCategory.EXIF);
            add_tags(selection, metadata, metadata.get_xmp_tags(), MetadataCategory.XMP);
            add_tags(selection, metadata, metadata.get_iptc_tags(), MetadataCategory.IPTC);

            var comment = file_comment(file);
            if (comment != null) {
                selection.tags.append(new MetadataTag(COMMENT_KEY, _("Comment"), comment, MetadataCategory.COMMENT));
            }
            return selection;
        }

        public bool is_automatic(string key)
        {
            return key in AUTOMATIC_TAGS || key.has_prefix(THUMBNAIL_TAG_PREFIX);
        }

        private void add_tags(MetadataSelection selection, GExiv2.Metadata metadata, string[] keys,
            MetadataCategory category) throws Error
        {
            foreach (var key in keys) {
                if (is_automatic(key)) {
                    continue;
                }
                var label = GExiv2.Metadata.get_tag_label(key) ?? key;
                var description = metadata.get_tag_interpreted_string(key) ?? "";
                selection.tags.append(new MetadataTag(key, label, description, category));
            }
        }

        // Returns the comment stored in the file itself, or null. GExiv2 falls
        // back to the EXIF, IPTC and XMP descriptions when the file has no
        // comment, so those are cleared from a separate copy first.
        private string? file_comment(File file) throws Error
        {
            var metadata = new GExiv2.Metadata();
            metadata.open_path(file.get_path());
            metadata.clear_exif();
            metadata.clear_xmp();
            metadata.clear_iptc();

            var comment = metadata.get_comment();
            return comment != null && comment.strip() != "" ? comment : null;
        }
    }
}
