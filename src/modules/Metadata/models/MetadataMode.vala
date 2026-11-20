namespace Redux.Metadata {

    // What happens to the metadata of the images when they are converted. The
    // nicks match the GSettings enum and the order matches the mode selector.
    public enum MetadataMode {
        REMOVE_ALL,
        KEEP_EXIF,
        PER_IMAGE
    }
}
