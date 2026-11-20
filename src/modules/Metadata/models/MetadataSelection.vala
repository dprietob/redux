namespace Redux.Metadata {

    // The metadata found in an image, each tag marked as kept or removed.
    public class MetadataSelection : Object
    {

        public GLib.ListStore tags { get; construct; }

        public MetadataSelection ()
        {
            Object(tags: new GLib.ListStore(typeof (MetadataTag)));
        }
    }
}
