namespace Redux.Metadata {

    // A single metadata entry of an image and whether it is kept in the
    // converted image.
    public class MetadataTag : Object
    {

        public string key { get; construct; }
        public string label { get; construct; }
        public string description { get; construct; }
        public MetadataCategory category { get; construct; }
        public bool kept { get; set; default = true; }

        public MetadataTag (string key, string label, string description, MetadataCategory category)
        {
            Object(key: key, label: label, description: description, category: category);
        }
    }
}
