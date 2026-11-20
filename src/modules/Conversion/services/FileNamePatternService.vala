namespace Redux.Conversion {

    // Builds the new name of an image from the rename pattern, its
    // placeholders, the prefix and the suffix.
    public class FileNamePatternService : Object
    {

        public const string NAME_PLACEHOLDER = "{name}";
        public const string NUMBER_PLACEHOLDER = "{number}";
        public const string DATE_PLACEHOLDER = "{date}";
        public const string TIME_PLACEHOLDER = "{time}";

        private const string[] PLACEHOLDERS = {
            NAME_PLACEHOLDER, NUMBER_PLACEHOLDER, DATE_PLACEHOLDER, TIME_PLACEHOLDER,
        };
        private const string DATE_FORMAT = "%Y-%m-%d";
        // Colons are not valid in file names on every system.
        private const string TIME_FORMAT = "%H-%M-%S";

        private Regex placeholder_expression;

        public FileNamePatternService ()
        {
            try {
                placeholder_expression = new Regex("\\{[^{}]*\\}");
            } catch (RegexError error) {
                GLib.error("Invalid placeholder expression: %s", error.message);
            }
        }

        // Returns the full file name, extension included. The date may be null
        // when the pattern does not use it.
        public string file_name(ConversionSettings settings, string original_name, int number, DateTime? date)
        {
            return "%s.%s".printf(base_name(settings, original_name, number, date),
                       settings.output_format.extension());
        }

        // Returns the new name without its extension: the prefix, the expanded
        // pattern and the suffix.
        public string base_name(ConversionSettings settings, string original_name, int number, DateTime? date)
        {
            return settings.rename_prefix
                   + expand(settings.rename_pattern, original_name, number, settings.rename_digits, date)
                   + settings.rename_suffix;
        }

        public bool uses_date(string pattern)
        {
            return DATE_PLACEHOLDER in pattern || TIME_PLACEHOLDER in pattern;
        }

        public string[] unknown_placeholders(string pattern)
        {
            string[] unknown = {};
            MatchInfo match;
            placeholder_expression.match(pattern, 0, out match);
            while (match.matches()) {
                var placeholder = match.fetch(0);
                if (!(placeholder in PLACEHOLDERS)) {
                    unknown += placeholder;
                }
                try {
                    match.next();
                } catch (RegexError error) {
                    GLib.error("Placeholder matching failed: %s", error.message);
                }
            }
            return unknown;
        }

        // Replaces every placeholder in a single pass, so placeholders that
        // happen to be part of the original name are left untouched.
        private string expand(string pattern, string original_name, int number, int digits, DateTime? date)
        {
            try {
                return placeholder_expression.replace_eval(pattern, -1, 0, 0, (match, result) => {
                    result.append(placeholder_value(match.fetch(0), original_name, number, digits, date));
                    return false;
                });
            } catch (RegexError error) {
                GLib.error("Placeholder replacement failed: %s", error.message);
            }
        }

        private string placeholder_value(string placeholder, string original_name, int number, int digits,
            DateTime? date)
        {
            switch (placeholder) {
            case NAME_PLACEHOLDER:
                return original_name;

            case NUMBER_PLACEHOLDER:
                return padded(number, digits);

            case DATE_PLACEHOLDER:
                return date != null ? date.format(DATE_FORMAT) : "";

            case TIME_PLACEHOLDER:
                return date != null ? date.format(TIME_FORMAT) : "";

            default:
                return placeholder;
            }
        }

        private string padded(int number, int digits)
        {
            var text = number.to_string();
            return string.nfill(int.max(0, digits - text.length), '0') + text;
        }
    }
}
