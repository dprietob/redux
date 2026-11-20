using Redux.Images;
using Redux.Metadata;

namespace Redux.Conversion {

    // Decides where the converted version of each image is written: the
    // output folder, with the original name or the name built from the rename
    // pattern, and the extension of the new format.
    public class OutputPathService : Object
    {

        private FileNamePatternService file_name_pattern_service;
        private CaptureDateService capture_date_service;

        public OutputPathService ()
        {
            file_name_pattern_service = new FileNamePatternService();
            capture_date_service = new CaptureDateService();
        }

        // Returns the target file of every image, in the same order. Images
        // are numbered in that order, starting at the chosen first number.
        public File[] target_files(SourceImage[] images, ConversionSettings settings) throws Error
        {
            File[] targets = {};
            for (int index = 0; index < images.length; index++) {
                targets += settings.rename_enabled
                    ? renamed_target(images[index], settings, settings.rename_start_number + index)
                    : target_file(images[index].file, settings.output_directory, settings.output_format);
            }
            return targets;
        }

        public File target_file(File source, File output_directory, OutputFormat format)
        {
            return output_directory.get_child("%s.%s".printf(name_without_extension(source), format.extension()));
        }

        private File renamed_target(SourceImage image, ConversionSettings settings, int number) throws Error
        {
            var date = file_name_pattern_service.uses_date(settings.rename_pattern)
                ? capture_date_service.capture_date(image.file)
                : null;
            var name = file_name_pattern_service.file_name(settings, name_without_extension(image.file), number, date);
            return settings.output_directory.get_child(name);
        }

        private string name_without_extension(File source)
        {
            var name = source.get_basename();
            var extension_start = name.last_index_of_char('.');
            // A leading dot marks a hidden file, not an extension.
            if (extension_start <= 0) {
                return name;
            }
            return name.substring(0, extension_start);
        }
    }
}
