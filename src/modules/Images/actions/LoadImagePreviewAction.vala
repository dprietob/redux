namespace Redux.Images {

    // Loads a small, upright version of an image to preview it. Images that
    // already fit are kept at their own size instead of being enlarged.
    public class LoadImagePreviewAction : Object
    {

        private ImageLoaderService image_loader_service;

        public LoadImagePreviewAction ()
        {
            image_loader_service = new ImageLoaderService();
        }

        public async Gdk.Pixbuf execute(File file, int maximum_size, Cancellable? cancellable) throws Error
        {
            var image = yield image_loader_service.load_async(file, cancellable);
            var longest_side = int.max(image.width, image.height);
            if (longest_side <= maximum_size) {
                return image;
            }

            var factor = (double) maximum_size / longest_side;
            return image.scale_simple(scaled(image.width, factor), scaled(image.height, factor),
                       Gdk.InterpType.BILINEAR);
        }

        private int scaled(int length, double factor)
        {
            return int.max(1, (int) Math.round(length * factor));
        }
    }
}
