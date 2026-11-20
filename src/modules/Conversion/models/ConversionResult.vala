namespace Redux.Conversion {

    // Outcome of converting a single image.
    public class ConversionResult : Object
    {

        public string source_name { get; set; default = ""; }
        public string output_name { get; set; default = ""; }
        public bool succeeded { get; set; default = false; }
        public string error_message { get; set; default = ""; }
        public int64 original_size { get; set; default = 0; }
        public int64 output_size { get; set; default = 0; }
        public int original_width { get; set; default = 0; }
        public int original_height { get; set; default = 0; }
        public int output_width { get; set; default = 0; }
        public int output_height { get; set; default = 0; }
        // Share of the original size that was saved; negative when the output
        // file is larger than the original.
        public double reduction_percentage { get; set; default = 0; }
    }
}
