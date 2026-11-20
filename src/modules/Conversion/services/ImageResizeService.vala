namespace Redux.Conversion {

    // Computes and applies the new size of an image according to the resize
    // options.
    public class ImageResizeService : Object
    {

        public Gdk.Pixbuf resize(Gdk.Pixbuf image, ConversionSettings settings)
        {
            int target_width;
            int target_height;
            target_size(image.width, image.height, settings, out target_width, out target_height);

            if (target_width == image.width && target_height == image.height) {
                return image;
            }
            return image.scale_simple(target_width, target_height, Gdk.InterpType.BILINEAR);
        }

        // Calculates the size of the output image. Pixel sizes are a bounding
        // box when the aspect ratio is kept (a zero side adapts to the other);
        // otherwise they are the exact size. With percentages and the aspect
        // ratio kept, the width percentage scales both sides.
        public void target_size(int original_width, int original_height, ConversionSettings settings,
            out int target_width, out int target_height)
        {
            target_width = original_width;
            target_height = original_height;
            if (!settings.resize_enabled) {
                return;
            }

            if (settings.resize_mode == ResizeMode.PERCENTAGE) {
                var height_percentage = settings.keep_aspect_ratio
                    ? settings.width_percentage : settings.height_percentage;
                target_width = scale(original_width, settings.width_percentage / 100.0);
                target_height = scale(original_height, height_percentage / 100.0);
            } else if (settings.keep_aspect_ratio) {
                var factor = bounding_box_factor(original_width, original_height, settings.width, settings.height);
                target_width = scale(original_width, factor);
                target_height = scale(original_height, factor);
            } else {
                target_width = settings.width;
                target_height = settings.height;
            }
        }

        // Returns the scale factor that fits the image inside the box, ignoring
        // the sides of the box that are zero.
        private double bounding_box_factor(int original_width, int original_height, int box_width, int box_height)
        {
            var width_factor = (double) box_width / original_width;
            var height_factor = (double) box_height / original_height;

            if (box_width > 0 && box_height > 0) {
                return double.min(width_factor, height_factor);
            }
            return box_width > 0 ? width_factor : height_factor;
        }

        private int scale(int length, double factor)
        {
            return int.max(1, (int) Math.round(length * factor));
        }
    }
}
