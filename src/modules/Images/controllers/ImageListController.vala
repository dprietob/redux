namespace Redux.Images {

    // Coordinates the list of input images: it runs the validator and actions
    // that load images and keeps the bound list model up to date.
    public class ImageListController : Object
    {

        private ImageFileService image_file_service;
        private ListImagesInDirectoryAction list_images_action;
        private LoadImageFilesAction load_image_files_action;

        public GLib.ListStore images { get; private set; }
        public File? input_directory { get; private set; default = null; }

        public ImageListController ()
        {
            image_file_service = new ImageFileService();
            list_images_action = new ListImagesInDirectoryAction(image_file_service);
            load_image_files_action = new LoadImageFilesAction(image_file_service);

            images = new GLib.ListStore(typeof (SourceImage));
        }

        public string[] supported_content_types()
        {
            return image_file_service.supported_content_types();
        }

        // Replaces the list with the images found in the folder. Returns an
        // error message, or null on success.
        public string? open_directory(File? directory)
        {
            var error = new ImageDirectoryValidator(directory).validate();
            if (error != null) {
                return error;
            }

            SourceImage[] found;
            try {
                found = list_images_action.execute(directory);
            } catch (Error list_error) {
                return list_error.message;
            }

            input_directory = directory;
            images.splice(0, images.get_n_items(), (Object[]) found);
            return null;
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
            input_directory = null;
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
