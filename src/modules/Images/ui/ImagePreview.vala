namespace Redux.Images {

    // Tooltip content of an image row: its location and, once loaded, a small
    // preview of the image.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/image-preview.ui")]
    public class ImagePreview : Gtk.Box
    {

        [GtkChild]
        private unowned Gtk.Picture picture;
        [GtkChild]
        private unowned Gtk.Label path_label;

        public ImagePreview (string display_path)
        {
            path_label.label = display_path;
        }

        public void show_image(Gdk.Pixbuf image)
        {
            var format = image.has_alpha ? Gdk.MemoryFormat.R8G8B8A8 : Gdk.MemoryFormat.R8G8B8;
            picture.paintable = new Gdk.MemoryTexture(image.width, image.height, format, image.read_pixel_bytes(),
                    image.rowstride);
            picture.visible = true;
        }
    }
}
