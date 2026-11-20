namespace Redux.Images {

    // An image file the user picked as input for a conversion.
    public class SourceImage : Object
    {

        public File file { get; construct; }
        public string name { get; construct; }
        public string content_type { get; construct; }
        public int64 size { get; construct; }
        // Where the user knows the file to be, for display only.
        public string display_path { get; construct; }
        public bool selected { get; set; default = true; }
        // The metadata chosen to keep for this image; null until the user
        // edits it, which means all of it is kept when editing per image.
        public Metadata.MetadataSelection? metadata_selection { get; set; default = null; }

        public SourceImage (File file, string name, string content_type, int64 size, string display_path)
        {
            Object(file: file, name: name, content_type: content_type, size: size, display_path: display_path);
        }
    }
}
