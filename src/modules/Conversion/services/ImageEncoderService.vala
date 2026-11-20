namespace Redux.Conversion {

    // Encodes images in the chosen output format with its quality or
    // compression options.
    public class ImageEncoderService : Object
    {

        // JPEG has no transparency: transparent areas become white.
        private const uint32 JPEG_BACKGROUND_COLOR = (uint32) 0xffffffffU;

        public Bytes encode(Gdk.Pixbuf image, ConversionSettings settings) throws Error
        {
            switch (settings.output_format) {
            case OutputFormat.JPEG:
                return encode_jpeg(image, settings.quality);

            case OutputFormat.PNG:
                return encode_png(image, settings.compression_level);

            default:
                return encode_webp(image, settings.quality);
            }
        }

        private Bytes encode_jpeg(Gdk.Pixbuf image, int quality) throws Error
        {
            uint8[] buffer;
            without_transparency(image).save_to_bufferv(out buffer, "jpeg",
                { "quality" }, { quality.to_string() });
            return new Bytes.take((owned) buffer);
        }

        private Bytes encode_png(Gdk.Pixbuf image, int compression_level) throws Error
        {
            uint8[] buffer;
            image.save_to_bufferv(out buffer, "png", { "compression" }, { compression_level.to_string() });
            return new Bytes.take((owned) buffer);
        }

        // GdkPixbuf ignores the WebP quality option, so lossy WebP is encoded
        // with libwebp directly.
        private Bytes encode_webp(Gdk.Pixbuf image, int quality) throws Error
        {
            uint8 * output = null;
            size_t output_length;
            unowned uint8[] pixels = image.get_pixels_with_length();

            if (image.has_alpha) {
                output_length = WebP.encode_rgba(pixels, image.width, image.height, image.rowstride,
                        (float) quality, out output);
            } else {
                output_length = WebP.encode_rgb(pixels, image.width, image.height, image.rowstride,
                        (float) quality, out output);
            }

            if (output_length == 0) {
                WebP.free(output);
                throw new IOError.FAILED(_("The image could not be encoded as WebP."));
            }

            unowned uint8[] encoded = (uint8[]) output;
            encoded.length = (int) output_length;
            var bytes = new Bytes(encoded);
            WebP.free(output);
            return bytes;
        }

        private Gdk.Pixbuf without_transparency(Gdk.Pixbuf image)
        {
            if (!image.has_alpha) {
                return image;
            }
            var opaque = new Gdk.Pixbuf(Gdk.Colorspace.RGB, false, 8, image.width, image.height);
            opaque.fill(JPEG_BACKGROUND_COLOR);
            image.composite(opaque, 0, 0, image.width, image.height, 0, 0, 1, 1, Gdk.InterpType.NEAREST, 255);
            return opaque;
        }
    }
}
