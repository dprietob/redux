using Redux.Images;
using Redux.Metadata;

namespace Redux.Conversion {

    // Decides where the converted version of each image is written: the
    // output folder, with the original name or the name built from the rename
    // pattern, and the extension of the new format. A name that already exists
    // in the folder, or that another image of the batch takes first, gets a
    // numeric suffix, so no file is ever overwritten.
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
            var taken_names = new GenericSet<string> (str_hash, str_equal);
            File[] targets = {};
            for (int index = 0; index < images.length; index++) {
                var base_name = settings.rename_enabled
                    ? renamed_base_name(images[index], settings, settings.rename_start_number + index)
                    : name_without_extension(images[index].file);
                var target = available_target(settings.output_directory, base_name,
                        settings.output_format.extension(), taken_names);
                taken_names.add(target.get_basename());
                targets += target;
            }
            return targets;
        }

        private string renamed_base_name(SourceImage image, ConversionSettings settings, int number) throws Error
        {
            var date = file_name_pattern_service.uses_date(settings.rename_pattern)
                ? capture_date_service.capture_date(image.file)
                : null;
            return file_name_pattern_service.base_name(settings, name_without_extension(image.file), number, date);
        }

        // Returns "name.ext", or "name-1.ext", "name-2.ext"… when the name is
        // already in the folder or taken by another image of the batch.
        private File available_target(File directory, string base_name, string extension,
            GenericSet<string> taken_names)
        {
            var candidate = directory.get_child("%s.%s".printf(base_name, extension));
            for (int suffix = 1; is_taken(candidate, taken_names); suffix++) {
                candidate = directory.get_child("%s-%d.%s".printf(base_name, suffix, extension));
            }
            return candidate;
        }

        private bool is_taken(File candidate, GenericSet<string> taken_names)
        {
            return taken_names.contains(candidate.get_basename()) || candidate.query_exists();
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
