namespace Redux.Conversion {

    // Statistics of a finished conversion, together with the result of every
    // processed image.
    public class ConversionReport : Object
    {

        public GLib.ListStore results { get; construct; }
        public File? output_directory { get; set; default = null; }
        public bool cancelled { get; set; default = false; }
        public uint converted_count { get; set; default = 0; }
        public uint failed_count { get; set; default = 0; }
        public int64 original_total_size { get; set; default = 0; }
        public int64 output_total_size { get; set; default = 0; }
        // Bytes saved by the converted images; negative when they grew.
        public int64 saved_size { get; set; default = 0; }
        public double reduction_percentage { get; set; default = 0; }
        public double duration_seconds { get; set; default = 0; }

        public ConversionReport ()
        {
            Object(results: new GLib.ListStore(typeof (ConversionResult)));
        }
    }
}
