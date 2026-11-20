namespace Redux.Metadata {

    // Reads the metadata of an image so the user can choose what to keep.
    public class LoadImageMetadataAction : Object
    {

        private MetadataReaderService metadata_reader_service;

        public LoadImageMetadataAction (MetadataReaderService metadata_reader_service)
        {
            this.metadata_reader_service = metadata_reader_service;
        }

        public MetadataSelection execute(File image_file) throws Error
        {
            return metadata_reader_service.read(image_file);
        }
    }
}
