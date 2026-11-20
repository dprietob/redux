namespace Redux.Conversion {

    // Validates the rename options: the pattern, the prefix, the suffix and
    // the numbering.
    public class FileNamePatternValidator : Object
    {

        private const string FORBIDDEN_CHARACTER = "/";

        private ConversionSettings settings;
        private FileNamePatternService file_name_pattern_service;

        public FileNamePatternValidator (ConversionSettings settings)
        {
            this.settings = settings;
            file_name_pattern_service = new FileNamePatternService();
        }

        public HashTable<string, string> rules()
        {
            var rules = new HashTable<string, string> (str_hash, str_equal);
            rules.set("rename_pattern", "required|known_placeholders|file_name_characters");
            rules.set("rename_prefix", "file_name_characters");
            rules.set("rename_suffix", "file_name_characters");
            rules.set("rename_start_number", "between:0,%d".printf(ConversionSettings.MAXIMUM_START_NUMBER));
            rules.set("rename_digits", "between:%d,%d".printf(ConversionSettings.MINIMUM_DIGITS,
                ConversionSettings.MAXIMUM_DIGITS));
            return rules;
        }

        public HashTable<string, string> messages()
        {
            var messages = new HashTable<string, string> (str_hash, str_equal);
            messages.set("rename_pattern.required", _("Enter a pattern for the new names."));
            messages.set("rename_pattern.known_placeholders",
                _("The pattern has an unknown placeholder. Use {name}, {number}, {date} or {time}."));
            messages.set("rename_pattern.file_name_characters", _("The pattern cannot contain “/”."));
            messages.set("rename_prefix.file_name_characters", _("The prefix cannot contain “/”."));
            messages.set("rename_suffix.file_name_characters", _("The suffix cannot contain “/”."));
            messages.set("rename_start_number.between", _("The first number must be between 0 and %d.").printf(
                    ConversionSettings.MAXIMUM_START_NUMBER));
            messages.set("rename_digits.between", _("The number of digits must be between %d and %d.").printf(
                    ConversionSettings.MINIMUM_DIGITS, ConversionSettings.MAXIMUM_DIGITS));
            return messages;
        }

        // Returns the first validation error message, or null when the data is valid.
        public string? validate()
        {
            var messages = this.messages();

            if (settings.rename_pattern.strip() == "") {
                return messages.get("rename_pattern.required");
            }
            if (file_name_pattern_service.unknown_placeholders(settings.rename_pattern).length > 0) {
                return messages.get("rename_pattern.known_placeholders");
            }
            if (FORBIDDEN_CHARACTER in settings.rename_pattern) {
                return messages.get("rename_pattern.file_name_characters");
            }
            if (FORBIDDEN_CHARACTER in settings.rename_prefix) {
                return messages.get("rename_prefix.file_name_characters");
            }
            if (FORBIDDEN_CHARACTER in settings.rename_suffix) {
                return messages.get("rename_suffix.file_name_characters");
            }
            if (settings.rename_start_number < 0 ||
                settings.rename_start_number > ConversionSettings.MAXIMUM_START_NUMBER) {
                return messages.get("rename_start_number.between");
            }
            if (settings.rename_digits < ConversionSettings.MINIMUM_DIGITS
                || settings.rename_digits > ConversionSettings.MAXIMUM_DIGITS) {
                return messages.get("rename_digits.between");
            }
            return null;
        }
    }
}
