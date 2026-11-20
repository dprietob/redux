namespace Redux.Images {

    // Validates the folder chosen to read the input images from.
    public class ImageDirectoryValidator : Object
    {

        private File? directory;

        public ImageDirectoryValidator (File? directory)
        {
            this.directory = directory;
        }

        public HashTable<string, string> rules()
        {
            var rules = new HashTable<string, string> (str_hash, str_equal);
            rules.set("directory", "required|directory");
            return rules;
        }

        public HashTable<string, string> messages()
        {
            var messages = new HashTable<string, string> (str_hash, str_equal);
            messages.set("directory.required", _("Choose a folder with images."));
            messages.set("directory.directory", _("The selected input folder does not exist."));
            return messages;
        }

        // Returns the first validation error message, or null when the data is valid.
        public string? validate()
        {
            var messages = this.messages();

            if (directory == null) {
                return messages.get("directory.required");
            }
            if (directory.query_file_type(FileQueryInfoFlags.NONE) != FileType.DIRECTORY) {
                return messages.get("directory.directory");
            }
            return null;
        }
    }
}
