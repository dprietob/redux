namespace Redux.Images {

    // Lists the supported images found directly inside a folder, sorted by name.
    public class ListImagesInDirectoryAction : Object
    {

        private ImageFileService image_file_service;

        public ListImagesInDirectoryAction (ImageFileService image_file_service)
        {
            this.image_file_service = image_file_service;
        }

        public SourceImage[] execute(File directory) throws Error
        {
            var images = new GenericArray<SourceImage> ();
            var enumerator = directory.enumerate_children(ImageFileService.QUERY_ATTRIBUTES,
                    FileQueryInfoFlags.NONE);

            FileInfo? info;
            while ((info = enumerator.next_file()) != null) {
                var image = image_file_service.from_file_info(enumerator.get_child(info), info);
                if (image != null) {
                    images.add(image);
                }
            }
            enumerator.close();

            images.sort((first, second) => first.name.collate(second.name));

            SourceImage[] sorted = {};
            for (uint index = 0; index < images.length; index++) {
                sorted += images[index];
            }
            return sorted;
        }
    }
}
