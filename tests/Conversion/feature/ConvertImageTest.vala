using Redux.Conversion;
using Redux.Images;

namespace Redux.Tests {

    // Converts the image and checks the written file has the expected format
    // and size.
    private ConversionResult convert_and_check(SourceImage source, ConversionSettings settings,
        string expected_format, int expected_width, int expected_height)
    {
        var result = convert_image(source, settings);
        if (!result.succeeded) {
            GLib.error("Conversion failed: %s", result.error_message);
        }

        var output = settings.output_directory.get_child(result.output_name);
        int width;
        int height;
        var format = Gdk.Pixbuf.get_file_info(output.get_path(), out width, out height);
        assert_nonnull(format);
        assert_cmpstr(format.get_name(), CompareOperator.EQ, expected_format);
        assert_cmpint(width, CompareOperator.EQ, expected_width);
        assert_cmpint(height, CompareOperator.EQ, expected_height);
        assert_cmpint(result.output_width, CompareOperator.EQ, expected_width);
        assert_cmpint(result.output_height, CompareOperator.EQ, expected_height);
        assert_true(result.output_size > 0);
        return result;
    }

    public void register_convert_image_tests()
    {
        Test.add_func("/conversion/convert/webp-quality-changes-size", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image(input, "noise.png", 256, 256, false);
            var settings = settings_for(output, OutputFormat.WEBP);

            settings.quality = 90;
            var high_quality = convert_and_check(source, settings, "webp", 256, 256);
            settings.quality = 10;
            var low_quality = convert_and_check(source, settings, "webp", 256, 256);

            assert_true(low_quality.output_size < high_quality.output_size);
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/convert/jpeg-flattens-transparency", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image(input, "transparent.png", 64, 48, true);

            convert_and_check(source, settings_for(output, OutputFormat.JPEG), "jpeg", 64, 48);
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/convert/png-resized-by-percentage", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image(input, "photo.png", 200, 100, true);
            var settings = settings_for(output, OutputFormat.PNG);
            settings.resize_enabled = true;
            settings.resize_mode = ResizeMode.PERCENTAGE;
            settings.width_percentage = 50;

            convert_and_check(source, settings, "png", 100, 50);
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/convert/never-overwrites-an-existing-file", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image(input, "photo.png", 8, 8, false);
            var existing = create_image(output, "photo.webp", 4, 4, false);

            var result = new ConvertImageAction().execute(source, existing.file, settings_for(output,
            OutputFormat.WEBP));
            assert_false(result.succeeded);
            try {
                var size = existing.file.query_info(FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NONE).get_size();
                assert_true(size == existing.size);
            } catch (Error error) {
                GLib.error("Could not read the existing file: %s", error.message);
            }
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/convert/unreadable-image-fails-gracefully", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var broken = input.get_child("broken.png");
            try {
                broken.replace_contents("not an image".data, null, false, FileCreateFlags.NONE, null);
            } catch (Error error) {
                GLib.error("Could not write the broken image: %s", error.message);
            }
            var source = new SourceImage(broken, "broken.png", "image/png", 12, broken.get_path());

            var result = convert_image(source, settings_for(output, OutputFormat.WEBP));
            assert_false(result.succeeded);
            assert_cmpstr(result.error_message, CompareOperator.NE, "");
            delete_recursively(input);
            delete_recursively(output);
        });
    }
}
