using Redux.Conversion;
using Redux.Images;

namespace Redux.Tests {

    // Returns the output name of each image, in order.
    private string[] output_names(SourceImage[] images, ConversionSettings settings)
    {
        string[] names = {};
        try {
            foreach (var target in new OutputPathService().target_files(images, settings)) {
                names += target.get_basename();
            }
        } catch (Error error) {
            GLib.error("Could not plan the output files: %s", error.message);
        }
        return names;
    }

    // An image that only exists as a name, enough to plan its output file.
    private SourceImage named_image(string path)
    {
        var file = File.new_for_path(path);
        return new SourceImage(file, file.get_basename(), "image/png", 0);
    }

    public void register_output_path_service_tests()
    {
        Test.add_func("/conversion/output-path/replaces-extension", () => {
            var output = create_temporary_directory();
            SourceImage[] images = { named_image("/photos/holiday.photo.JPG") };
            assert_cmpstr(output_names(images, settings_for(output, OutputFormat.WEBP))[0], CompareOperator.EQ,
            "holiday.photo.webp");
            delete_recursively(output);
        });

        Test.add_func("/conversion/output-path/uses-format-extension", () => {
            var output = create_temporary_directory();
            SourceImage[] images = { named_image("/photos/cat.webp") };
            assert_cmpstr(output_names(images, settings_for(output, OutputFormat.JPEG))[0], CompareOperator.EQ,
            "cat.jpg");
            assert_cmpstr(output_names(images, settings_for(output, OutputFormat.PNG))[0], CompareOperator.EQ,
            "cat.png");
            delete_recursively(output);
        });

        Test.add_func("/conversion/output-path/keeps-hidden-and-extensionless-names", () => {
            var output = create_temporary_directory();
            SourceImage[] images = { named_image("/photos/.hidden"), named_image("/photos/scan") };
            var names = output_names(images, settings_for(output, OutputFormat.PNG));
            assert_cmpstr(names[0], CompareOperator.EQ, ".hidden.png");
            assert_cmpstr(names[1], CompareOperator.EQ, "scan.png");
            delete_recursively(output);
        });

        Test.add_func("/conversion/output-path/suffixes-existing-files", () => {
            var output = create_temporary_directory();
            create_image(output, "photo.webp", 4, 4, false);
            create_image(output, "photo-1.webp", 4, 4, false);
            SourceImage[] images = { named_image("/photos/photo.png") };
            assert_cmpstr(output_names(images, settings_for(output, OutputFormat.WEBP))[0], CompareOperator.EQ,
            "photo-2.webp");
            delete_recursively(output);
        });

        Test.add_func("/conversion/output-path/never-targets-the-originals", () => {
            var folder = create_temporary_directory();
            SourceImage[] images = { create_image(folder, "photo.png", 4, 4, false) };
            assert_cmpstr(output_names(images, settings_for(folder, OutputFormat.PNG))[0], CompareOperator.EQ,
            "photo-1.png");
            delete_recursively(folder);
        });

        Test.add_func("/conversion/output-path/suffixes-names-repeated-in-the-batch", () => {
            var output = create_temporary_directory();
            SourceImage[] images = {
                named_image("/photos/photo.png"),
                named_image("/photos/photo.jpeg"),
                named_image("/photos/photo-1.bmp"),
            };
            var names = output_names(images, settings_for(output, OutputFormat.WEBP));
            assert_cmpstr(names[0], CompareOperator.EQ, "photo.webp");
            assert_cmpstr(names[1], CompareOperator.EQ, "photo-1.webp");
            assert_cmpstr(names[2], CompareOperator.EQ, "photo-1-1.webp");
            delete_recursively(output);
        });
    }
}
