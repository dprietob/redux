namespace Redux.Images {

    // Decodes image files into upright pixbufs.
    //
    // Images are read into memory and decoded from there, never from their
    // path. Inside Flatpak the picked files live in the document portal, and
    // the decoder (glycin) reopens a file through the path of its descriptor;
    // when the portal has meanwhile refreshed its entries, that path ends in
    // " (deleted)" and the image randomly fails to load.
    public class ImageLoaderService : Object
    {

        public Gdk.Pixbuf load(File file) throws Error
        {
            uint8[] contents;
            file.load_contents(null, out contents, null);
            var image = new Gdk.Pixbuf.from_stream(in_memory((owned) contents), null);
            return upright(image);
        }

        public async Gdk.Pixbuf load_async(File file, Cancellable? cancellable) throws Error
        {
            uint8[] contents;
            yield file.load_contents_async(cancellable, out contents, null);
            var image = yield new Gdk.Pixbuf.from_stream_async(in_memory((owned) contents), cancellable);
            return upright(image);
        }

        private InputStream in_memory(owned uint8[] contents)
        {
            return new MemoryInputStream.from_bytes(new Bytes.take((owned) contents));
        }

        // Follows the orientation stored by cameras.
        private Gdk.Pixbuf upright(Gdk.Pixbuf image)
        {
            return image.apply_embedded_orientation() ?? image;
        }
    }
}
