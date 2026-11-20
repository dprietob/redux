namespace Redux.Images {

    // Coordinates the list of input images: it runs the action that loads
    // the picked images and keeps the bound list model up to date.
    public class ImageListController : Object
    {

        private ImageFileService image_file_service;
        private LoadImageFilesAction load_image_files_action;

        public GLib.ListStore images { get; private set; }

        public ImageListController ()
        {
            image_file_service = new ImageFileService();
            load_image_files_action = new LoadImageFilesAction(image_file_service);

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
                    images.append(image);
                    added++;
                }
            }
            return added;
        }

        public void remove(SourceImage image)
        {
            uint position;
            if (images.find(image, out position)) {
                images.remove(position);
            }
        }

        public void clear()
        {
            images.remove_all();
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
