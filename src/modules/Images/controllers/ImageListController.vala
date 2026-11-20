namespace Redux.Images {

    // Coordinates the list of input images: it runs the action that loads
    // the picked images and keeps the bound list model up to date.
    public class ImageListController : Object
    {

        private ImageFileService image_file_service;
        private LoadImageFilesAction load_image_files_action;
        private LoadImagePreviewAction load_image_preview_action;

        public const int PREVIEW_SIZE = 256;

        public GLib.ListStore images { get; private set; }

        // Emitted when any image is checked or unchecked.
        public signal void selection_changed();

        public ImageListController ()
        {
            image_file_service = new ImageFileService();
            load_image_files_action = new LoadImageFilesAction(image_file_service);
            load_image_preview_action = new LoadImagePreviewAction();

            images = new GLib.ListStore(typeof (SourceImage));
        }

        public string[] supported_content_types()
        {
            return image_file_service.supported_content_types();
        }

        // Appends the supported files that are not in the list yet and returns
        // how many of them were added.
        public uint add_files(File[] files)
        {
            uint added = 0;
            foreach (var image in load_image_files_action.execute(files)) {
                if (!contains(image.file)) {
                    image.notify["selected"].connect(on_image_selection_changed);
                    images.append(image);
                    added++;
                }
            }
            return added;
        }

        // Returns a small preview of the image, or null when it cannot be read.
        public async Gdk.Pixbuf? load_preview(SourceImage image)
        {
            try {
                return yield load_image_preview_action.execute(image.file, PREVIEW_SIZE, null);
            } catch (Error error) {
                // The preview is a convenience: without it the tooltip still
                // shows where the image is, and the conversion reports the
                // problem if the image is really unreadable.
                debug("No preview for %s: %s", image.file.get_uri(), error.message);
                return null;
            }
        }

        public void remove(SourceImage image)
        {
            uint position;
            if (images.find(image, out position)) {
                image.notify["selected"].disconnect(on_image_selection_changed);
                images.remove(position);
            }
        }

        // Moves an image next to another one: after it when after is true,
        // before it otherwise. The order decides the sequential numbers.
        public void move(SourceImage dragged, SourceImage target, bool after)
        {
            uint from;
            if (dragged == target) {
                return;
            }
            if (!images.find(dragged, out from)) {
                return;
            }
            images.remove(from);

            uint target_position;
            if (images.find(target, out target_position)) {
                images.insert(after ? target_position + 1 : target_position, dragged);
            } else {
                images.append(dragged);
            }
        }

        public void clear()
        {
            for (uint index = 0; index < images.get_n_items(); index++) {
                ((SourceImage) images.get_item(index)).notify["selected"].disconnect(on_image_selection_changed);
            }
            images.remove_all();
        }

        // Moves an image one place up (offset -1) or down (offset 1).
        public void move_by(SourceImage image, int offset)
        {
            uint position;
            if (!images.find(image, out position)) {
                return;
            }
            var neighbor_position = (int) position + offset;
            if (neighbor_position < 0 || neighbor_position >= images.get_n_items()) {
                return;
            }
            move(image, (SourceImage) images.get_item(neighbor_position), offset > 0);
        }

        private void on_image_selection_changed()
        {
            selection_changed();
        }

        public void select_all(bool selected)
        {
            for (uint index = 0; index < images.get_n_items(); index++) {
                ((SourceImage) images.get_item(index)).selected = selected;
            }
        }

        public SourceImage[] selected_images()
        {
            SourceImage[] selected = {};
            for (uint index = 0; index < images.get_n_items(); index++) {
                var image = (SourceImage) images.get_item(index);
                if (image.selected) {
                    selected += image;
                }
            }
            return selected;
        }

        private bool contains(File file)
        {
            for (uint index = 0; index < images.get_n_items(); index++) {
                if (((SourceImage) images.get_item(index)).file.equal(file)) {
                    return true;
                }
            }
            return false;
        }
    }
}
