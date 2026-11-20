namespace Redux.Conversion {

    // Image formats the images can be converted to. The nicks match the
    // GSettings enum and the order matches the format selector.
    public enum OutputFormat {
        WEBP,
        JPEG,
        PNG;

        public string extension()
        {
            switch (this) {
            case JPEG:
                return "jpg";

            case PNG:
                return "png";

            default:
                return "webp";
            }
        }

        // Whether the format is encoded with a quality factor (lossy) instead
        // of a compression level (lossless).
        public bool uses_quality()
        {
            return this != PNG;
        }
    }
}
