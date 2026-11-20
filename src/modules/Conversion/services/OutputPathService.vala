namespace Redux.Conversion {

    // Decides where the converted version of an image is written: the output
    // folder, with the original name and the extension of the new format.
    public class OutputPathService : Object
    {

        public File target_file(File source, File output_directory, OutputFormat format)
        {
            return output_directory.get_child("%s.%s".printf(name_without_extension(source), format.extension()));
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
