namespace Redux.Conversion {

    // Options that describe how the images are converted.
    public class ConversionSettings : Object
    {

        public const int MINIMUM_QUALITY = 1;
        public const int MAXIMUM_QUALITY = 100;
        public const int MINIMUM_COMPRESSION_LEVEL = 0;
        public const int MAXIMUM_COMPRESSION_LEVEL = 9;
        public const int MAXIMUM_DIMENSION = 65535;
        public const int MINIMUM_PERCENTAGE = 1;
        public const int MAXIMUM_PERCENTAGE = 1000;

        public File? output_directory { get; set; default = null; }
        public OutputFormat output_format { get; set; default = OutputFormat.WEBP; }
        public int quality { get; set; default = 80; }
        public int compression_level { get; set; default = 6; }
        public bool resize_enabled { get; set; default = false; }
        public ResizeMode resize_mode { get; set; default = ResizeMode.PIXELS; }
        public int width { get; set; default = 1920; }
        public int height { get; set; default = 0; }
        public int width_percentage { get; set; default = 50; }
        public int height_percentage { get; set; default = 50; }
        public bool keep_aspect_ratio { get; set; default = true; }

        // Returns an independent snapshot, so a running conversion is not
        // affected by later changes made in the interface.
        public ConversionSettings copy()
        {
            return new ConversionSettings() {
                       output_directory = output_directory,
                       output_format = output_format,
                       quality = quality,
                       compression_level = compression_level,
                       resize_enabled = resize_enabled,
                       resize_mode = resize_mode,
                       width = width,
                       height = height,
                       width_percentage = width_percentage,
                       height_percentage = height_percentage,
                       keep_aspect_ratio = keep_aspect_ratio
            };
        }
    }
}
