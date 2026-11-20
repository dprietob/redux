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

    // Writes a 64 × 48 JPEG rotated by the camera (orientation tag) with EXIF,
    // GPS, XMP and IPTC data, a file comment and an EXIF thumbnail.
    public Images.SourceImage create_image_with_metadata(File directory, string name)
    {
        var image = new Gdk.Pixbuf(Gdk.Colorspace.RGB, false, 8, 64, 48);
        image.fill(0x336699ff);
        var file = directory.get_child(name);
        try {
            image.save(file.get_path(), "jpeg");

            var thumbnail = image.scale_simple(16, 12, Gdk.InterpType.BILINEAR);
            uint8[] thumbnail_buffer;
            thumbnail.save_to_buffer(out thumbnail_buffer, "jpeg");

            var metadata = new GExiv2.Metadata();
            metadata.open_path(file.get_path());
            metadata.set_tag_string("Exif.Image.Make", "Canon");
            metadata.set_tag_string("Exif.Image.Model", "EOS R6");
            metadata.set_tag_string("Exif.Photo.DateTimeOriginal", "2026:05:01 10:00:00");
            metadata.set_tag_string("Exif.GPSInfo.GPSLatitude", "40/1 25/1 0/1");
            // Set as text so the tags get their standard types, like a camera.
            metadata.set_tag_string("Exif.Photo.PixelXDimension", "64");
            metadata.set_tag_string("Exif.Photo.PixelYDimension", "48");
            metadata.set_tag_string("Exif.Image.Orientation", "6");
            metadata.set_tag_string("Xmp.dc.creator", "Redux");
            metadata.set_tag_string("Xmp.xmp.Rating", "5");
            metadata.set_tag_string("Iptc.Application2.Caption", "Holidays");
            metadata.set_exif_thumbnail_from_buffer(thumbnail_buffer);
            metadata.set_comment("Taken with Redux");
            metadata.save_file(file.get_path());

            var info = file.query_info(FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NONE);
            return new Images.SourceImage(file, name, "image/jpeg", info.get_size());
        } catch (Error error) {
            GLib.error("Could not write the test image %s: %s", name, error.message);
        }
    }

    public GExiv2.Metadata read_metadata(File file)
    {
        var metadata = new GExiv2.Metadata();
        try {
            metadata.open_path(file.get_path());
        } catch (Error error) {
            GLib.error("Could not read the metadata of %s: %s", file.get_path(), error.message);
        }
        return metadata;
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
