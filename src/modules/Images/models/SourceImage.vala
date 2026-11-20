namespace Redux.Images {

    // An image file the user picked as input for a conversion.
    public class SourceImage : Object
    {

        public File file { get; construct; }
        public string name { get; construct; }
        public string content_type { get; construct; }
        public int64 size { get; construct; }
        public bool selected { get; set; default = true; }

        public SourceImage (File file, string name, string content_type, int64 size)
        {
            Object(file: file, name: name, content_type: content_type, size: size);
        }

        public string path()
        {
            return file.get_path();
        }
    }
}
