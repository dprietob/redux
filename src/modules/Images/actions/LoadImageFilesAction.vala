namespace Redux.Images {

    // Turns the files picked by the user into source images, skipping the ones
    // that are not supported images or cannot be read.
    public class LoadImageFilesAction : Object
    {

        private ImageFileService image_file_service;

        public LoadImageFilesAction (ImageFileService image_file_service)
        {
            this.image_file_service = image_file_service;
        }

        public SourceImage[] execute(File[] files)
        {
            SourceImage[] images = {};
            foreach (var file in files) {
                try {
                    var info = file.query_info(ImageFileService.QUERY_ATTRIBUTES, FileQueryInfoFlags.NONE);
                    var image = image_file_service.from_file_info(file, info);
                    if (image != null) {
                        images += image;
                    }
                } catch (Error error) {
                    // An unreadable file is left out like any other unsupported
                    // file: the caller reports how many files were skipped.
                    debug("Skipping %s: %s", file.get_uri(), error.message);
                }
            }
            return images;
        }
    }
}
