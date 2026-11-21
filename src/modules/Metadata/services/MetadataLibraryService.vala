namespace Redux.Metadata {

    // Calls the GExiv2 functions whose names differ between GExiv2 0.14 and
    // 0.16, so the rest of the code works with both. Distributions such as
    // Ubuntu 26.04 still ship 0.14, where the current names are the "try_"
    // ones and the plain names are deprecated; 0.16 renamed them the other way
    // round. Meson defines GEXIV2_0_16 when it builds against 0.16.
    public class MetadataLibraryService : Object
    {

        public static unowned string? tag_label(string key) throws Error
        {
#if GEXIV2_0_16
            return GExiv2.Metadata.get_tag_label(key);
#else
            return GExiv2.Metadata.try_get_tag_label(key);
#endif
        }

        public static bool has_tag(GExiv2.Metadata metadata, string key) throws Error
        {
#if GEXIV2_0_16
            return metadata.has_tag(key);
#else
            return metadata.try_has_tag(key);
#endif
        }

        public static string? tag_string(GExiv2.Metadata metadata, string key) throws Error
        {
#if GEXIV2_0_16
            return metadata.get_tag_string(key);
#else
            return metadata.try_get_tag_string(key);
#endif
        }

        public static string? tag_interpreted_string(GExiv2.Metadata metadata, string key) throws Error
        {
#if GEXIV2_0_16
            return metadata.get_tag_interpreted_string(key);
#else
            return metadata.try_get_tag_interpreted_string(key);
#endif
        }

        public static long tag_long(GExiv2.Metadata metadata, string key) throws Error
        {
#if GEXIV2_0_16
            return metadata.get_tag_long(key);
#else
            return metadata.try_get_tag_long(key);
#endif
        }

        public static void set_tag_string(GExiv2.Metadata metadata, string key, string text) throws Error
        {
#if GEXIV2_0_16
            metadata.set_tag_string(key, text);
#else
            metadata.try_set_tag_string(key, text);
#endif
        }

        public static void clear_tag(GExiv2.Metadata metadata, string key) throws Error
        {
#if GEXIV2_0_16
            metadata.clear_tag(key);
#else
            metadata.try_clear_tag(key);
#endif
        }

        public static string? comment(GExiv2.Metadata metadata) throws Error
        {
#if GEXIV2_0_16
            return metadata.get_comment();
#else
            return metadata.try_get_comment();
#endif
        }

        public static void set_comment(GExiv2.Metadata metadata, string comment) throws Error
        {
#if GEXIV2_0_16
            metadata.set_comment(comment);
#else
            metadata.try_set_comment(comment);
#endif
        }

        public static void erase_exif_thumbnail(GExiv2.Metadata metadata) throws Error
        {
#if GEXIV2_0_16
            metadata.erase_exif_thumbnail();
#else
            metadata.try_erase_exif_thumbnail();
#endif
        }

        public static void set_exif_thumbnail(GExiv2.Metadata metadata, uint8[] thumbnail) throws Error
        {
#if GEXIV2_0_16
            metadata.set_exif_thumbnail_from_buffer(thumbnail);
#else
            metadata.try_set_exif_thumbnail_from_buffer(thumbnail);
#endif
        }
    }
}
