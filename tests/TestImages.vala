namespace Redux.Tests {

    // Helpers that create throwaway folders and images for the tests. Nothing
    // is written outside the temporary directory.
    public File create_temporary_directory()
    {
        try {
            return File.new_for_path(DirUtils.make_tmp("redux-test-XXXXXX"));
        } catch (FileError error) {
            GLib.error("Could not create a temporary directory: %s", error.message);
        }
    }

    // Writes a noisy image, so the encoders produce sizes that depend on the
    // quality, and returns it as a source image.
    public Images.SourceImage create_image(File directory, string name, int width, int height, bool with_alpha)
    {
        var image = new Gdk.Pixbuf(Gdk.Colorspace.RGB, with_alpha, 8, width, height);
        unowned uint8[] pixels = image.get_pixels_with_length();
        for (int index = 0; index < pixels.length; index++) {
            pixels[index] = (uint8) ((index * 7919 + index / 3) % 251);
        }

        var file = directory.get_child(name);
        try {
            image.save(file.get_path(), "png");
            var info = file.query_info(FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NONE);
            return new Images.SourceImage(file, name, "image/png", info.get_size());
        } catch (Error error) {
            GLib.error("Could not write the test image %s: %s", name, error.message);
        }
    }

    public void delete_recursively(File directory)
    {
        try {
            var enumerator = directory.enumerate_children(FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
            FileInfo? info;
            while ((info = enumerator.next_file()) != null) {
                enumerator.get_child(info).delete();
            }
            directory.delete();
        } catch (Error error) {
            warning("Could not delete %s: %s", directory.get_path(), error.message);
        }
    }

    public Conversion.ConversionSettings settings_for(File output_directory, Conversion.OutputFormat format)
    {
        return new Conversion.ConversionSettings() {
                   output_directory = output_directory,
                   output_format = format
        };
    }
}
