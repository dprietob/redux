using Redux.Images;

namespace Redux.Conversion {

    // Validates the images and options of a conversion before it starts.
    public class ConversionValidator : Object
    {

        private SourceImage[] images;
        private ConversionSettings settings;
        private OutputPathService output_path_service;

        public ConversionValidator (SourceImage[] images, ConversionSettings settings)
        {
            this.images = images;
            this.settings = settings;
            output_path_service = new OutputPathService();
        }

        public HashTable<string, string> rules()
        {
            var rules = new HashTable<string, string> (str_hash, str_equal);
            rules.set("images", "required|readable");
            rules.set("output_directory", "required|directory|writable");
            rules.set("quality", "between:%d,%d".printf(ConversionSettings.MINIMUM_QUALITY,
                ConversionSettings.MAXIMUM_QUALITY));
            rules.set("compression_level", "between:%d,%d".printf(ConversionSettings.MINIMUM_COMPRESSION_LEVEL,
                ConversionSettings.MAXIMUM_COMPRESSION_LEVEL));
            rules.set("dimensions", "required_with:resize_enabled|between:0,%d".printf(
                    ConversionSettings.MAXIMUM_DIMENSION));
            rules.set("percentages", "between:%d,%d".printf(ConversionSettings.MINIMUM_PERCENTAGE,
                ConversionSettings.MAXIMUM_PERCENTAGE));
            return rules;
        }

        public HashTable<string, string> messages()
        {
            var messages = new HashTable<string, string> (str_hash, str_equal);
            messages.set("images.required", _("Select at least one image to convert."));
            messages.set("output_directory.required", _("Choose an output folder."));
            messages.set("output_directory.directory", _("The output folder does not exist."));
            messages.set("output_directory.writable", _("The output folder is not writable."));
            messages.set("images.readable", _("The date of an image could not be read to build its new name."));
            messages.set("quality.between", _("The quality must be between %d and %d.").printf(
                    ConversionSettings.MINIMUM_QUALITY, ConversionSettings.MAXIMUM_QUALITY));
            messages.set("compression_level.between", _("The compression level must be between %d and %d.").printf(
                    ConversionSettings.MINIMUM_COMPRESSION_LEVEL, ConversionSettings.MAXIMUM_COMPRESSION_LEVEL));
            messages.set("dimensions.required_with", settings.keep_aspect_ratio
                ? _("Enter a width, a height or both.")
                : _("Enter both a width and a height."));
            messages.set("dimensions.between", _("The width and height must be at most %d pixels.").printf(
                    ConversionSettings.MAXIMUM_DIMENSION));
            messages.set("percentages.between", _("The percentages must be between %d and %d.").printf(
                    ConversionSettings.MINIMUM_PERCENTAGE, ConversionSettings.MAXIMUM_PERCENTAGE));
            return messages;
        }

        // Returns the first validation error message, or null when the data is valid.
        public string? validate()
        {
            var messages = this.messages();

            if (images.length == 0) {
                return messages.get("images.required");
            }

            if (settings.rename_enabled) {
                var rename_error = new FileNamePatternValidator(settings).validate();
                if (rename_error != null) {
                    return rename_error;
                }
            }

            var output_error = validate_output_directory(messages);
            if (output_error != null) {
                return output_error;
            }

            if (!is_between(settings.quality, ConversionSettings.MINIMUM_QUALITY, ConversionSettings.MAXIMUM_QUALITY)) {
                return messages.get("quality.between");
            }
            if (!is_between(settings.compression_level, ConversionSettings.MINIMUM_COMPRESSION_LEVEL,
                ConversionSettings.MAXIMUM_COMPRESSION_LEVEL)) {
                return messages.get("compression_level.between");
            }

            if (settings.resize_enabled) {
                return validate_resize(messages);
            }
            return null;
        }

        private string? validate_output_directory(HashTable<string, string> messages)
        {
            var directory = settings.output_directory;
            if (directory == null) {
                return messages.get("output_directory.required");
            }
            if (directory.query_file_type(FileQueryInfoFlags.NONE) != FileType.DIRECTORY) {
                return messages.get("output_directory.directory");
            }
            if (!is_writable(directory)) {
                return messages.get("output_directory.writable");
            }

            // Building the new names reads the date of the images when the
            // rename pattern uses it, which fails for unreadable files.
            try {
                output_path_service.target_files(images, settings);
            } catch (Error error) {
                return messages.get("images.readable");
            }
            return null;
        }

        private string? validate_resize(HashTable<string, string> messages)
        {
            if (settings.resize_mode == ResizeMode.PERCENTAGE) {
                var percentages_valid = is_between(settings.width_percentage,
                        ConversionSettings.MINIMUM_PERCENTAGE, ConversionSettings.MAXIMUM_PERCENTAGE)
                    && (settings.keep_aspect_ratio || is_between(settings.height_percentage,
                    ConversionSettings.MINIMUM_PERCENTAGE, ConversionSettings.MAXIMUM_PERCENTAGE));
                return percentages_valid ? null : messages.get("percentages.between");
            }

            if (!is_between(settings.width, 0, ConversionSettings.MAXIMUM_DIMENSION)
                || !is_between(settings.height, 0, ConversionSettings.MAXIMUM_DIMENSION)) {
                return messages.get("dimensions.between");
            }
            var dimensions_given = settings.keep_aspect_ratio
                ? settings.width > 0 || settings.height > 0
                : settings.width > 0 && settings.height > 0;
            return dimensions_given ? null : messages.get("dimensions.required_with");
        }

        private bool is_writable(File directory)
        {
            try {
                var info = directory.query_info(FileAttribute.ACCESS_CAN_WRITE, FileQueryInfoFlags.NONE);
                return info.get_attribute_boolean(FileAttribute.ACCESS_CAN_WRITE);
            } catch (Error error) {
                return false;
            }
        }

        private bool is_between(int number, int minimum, int maximum)
        {
            return number >= minimum && number <= maximum;
        }
    }
}
