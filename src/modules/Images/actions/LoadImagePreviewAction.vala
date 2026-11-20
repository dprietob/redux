namespace Redux.Images {

    // Loads a small, upright version of an image to preview it. Images that
    // already fit are loaded at their own size instead of being enlarged.
    public class LoadImagePreviewAction : Object
    {

        // Size given to the loader to keep the image dimensions unchanged.
        private const int ORIGINAL_SIZE = -1;

        public async Gdk.Pixbuf execute(File file, int maximum_size, Cancellable? cancellable) throws Error
        {
            int width;
            int height;
            yield Gdk.Pixbuf.get_file_info_async(file.get_path(), cancellable, out width, out height);
            var size = int.max(width, height) > maximum_size ? maximum_size : ORIGINAL_SIZE;

            var stream = yield file.read_async(Priority.DEFAULT, cancellable);
            var preview = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, size, size, true, cancellable);
            stream.close();
            return preview.apply_embedded_orientation() ?? preview;
        }
    }
}
