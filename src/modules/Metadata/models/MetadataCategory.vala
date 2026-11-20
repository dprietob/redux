namespace Redux.Metadata {

    // Families of metadata an image can carry. COMMENT is the comment stored
    // in the file itself (for example the JPEG comment), not an EXIF tag.
    public enum MetadataCategory {
        EXIF,
        XMP,
        IPTC,
        COMMENT
    }
}
