namespace Redux.Images {

    // Knows which image files can be converted and turns file metadata into
    // source images.
    public class ImageFileService : Object
    {

        public const string QUERY_ATTRIBUTES = FileAttribute.STANDARD_NAME + ","
            + FileAttribute.STANDARD_DISPLAY_NAME + ","
            + FileAttribute.STANDARD_TYPE + ","
            + FileAttribute.STANDARD_SIZE + ","
            + FileAttribute.STANDARD_CONTENT_TYPE + ","
            + FileLocationService.HOST_PATH_ATTRIBUTE;

        private FileLocationService file_location_service = new FileLocationService();

        private const string[] CONVERTIBLE_CONTENT_TYPES = {
            "image/jpeg",
            "image/png",
            "image/webp",
            "image/bmp",
            "image/tiff",
            "image/gif",
            "image/avif",
            "image/heif",
        };

        // Returns the convertible content types that the installed image
        // loaders are able to read.
        public string[] supported_content_types()
        {
            string[] supported = {};
            foreach (var content_type in CONVERTIBLE_CONTENT_TYPES) {
                if (is_readable(content_type)) {
                    supported += content_type;
                }
            }
            return supported;
        }

        public bool is_supported(string content_type)
        {
            foreach (var supported in supported_content_types()) {
                if (ContentType.equals(content_type, supported)) {
                    return true;
                }
            }
            return false;
        }

        // Builds a source image from the metadata of a regular file, or returns
        // null when the file is not a supported image.
        public SourceImage? from_file_info(File file, FileInfo info)
        {
            if (info.get_file_type() != FileType.REGULAR) {
                return null;
            }
            var content_type = info.get_content_type();
            if (content_type == null || !is_supported(content_type)) {
                return null;
            }
            return new SourceImage(file, info.get_display_name(), content_type, info.get_size(),
                       file_location_service.display_path_from_info(file, info));
        }

        private bool is_readable(string content_type)
        {
            foreach (var format in Gdk.Pixbuf.get_formats()) {
                foreach (var mime_type in format.get_mime_types()) {
                    if (ContentType.equals(mime_type, content_type)) {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}
