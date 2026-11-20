using Redux.Conversion;
using Redux.Images;

namespace Redux.Tests {

    private string[] target_names(SourceImage[] images, ConversionSettings settings)
    {
        string[] names = {};
        try {
            foreach (var target in new PlanOutputFilesAction().execute(images, settings)) {
                names += target.get_basename();
            }
        } catch (Error error) {
            GLib.error("Planning failed: %s", error.message);
        }
        return names;
    }

    private void set_modification_date(File file, DateTime date)
    {
        try {
            file.set_attribute_uint64(FileAttribute.TIME_MODIFIED, (uint64) date.to_unix(),
                FileQueryInfoFlags.NONE);
        } catch (Error error) {
            GLib.error("Could not change the date of %s: %s", file.get_path(), error.message);
        }
    }

    public void register_rename_output_files_tests()
    {
        Test.add_func("/conversion/rename/numbers-in-list-order", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = {
                create_image(input, "zebra.png", 4, 4, false),
                create_image(input, "apple.png", 4, 4, false),
            };
            var settings = settings_for(output, OutputFormat.JPEG);
            settings.rename_enabled = true;
            settings.rename_pattern = "holidays_{number}";
            settings.rename_prefix = "2026_";
            settings.rename_suffix = "_web";
            settings.rename_start_number = 9;
            settings.rename_digits = 2;

            var names = target_names(images, settings);
            assert_cmpstr(names[0], CompareOperator.EQ, "2026_holidays_09_web.jpg");
            assert_cmpstr(names[1], CompareOperator.EQ, "2026_holidays_10_web.jpg");
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/rename/date-taken-or-modified", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var plain = create_image(input, "plain.png", 4, 4, false);
            set_modification_date(plain.file, new DateTime.local(2024, 12, 31, 23, 59, 58));
            SourceImage[] images = { create_image_with_metadata(input, "camera.jpg"), plain };

            var settings = settings_for(output, OutputFormat.PNG);
            settings.rename_enabled = true;
            settings.rename_pattern = "{date}_{time}";

            var names = target_names(images, settings);
            assert_cmpstr(names[0], CompareOperator.EQ, "2026-05-01_10-00-00.png");
            assert_cmpstr(names[1], CompareOperator.EQ, "2024-12-31_23-59-58.png");
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/rename/disabled-keeps-original-names", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = { create_image(input, "photo.png", 4, 4, false) };
            var settings = settings_for(output, OutputFormat.WEBP);
            settings.rename_pattern = "{number}";

            assert_cmpstr(target_names(images, settings)[0], CompareOperator.EQ, "photo.webp");
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/rename/validator-rejects-repeated-names", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = {
                create_image(input, "first.png", 4, 4, false),
                create_image(input, "second.png", 4, 4, false),
            };
            var settings = settings_for(output, OutputFormat.WEBP);
            settings.rename_enabled = true;
            settings.rename_pattern = "same";

            var validator = new ConversionValidator(images, settings);
            assert_cmpstr(validator.validate(),
            CompareOperator.EQ,
            validator.messages().get("output_directory.distinct"));

            settings.rename_pattern = "{name}-{unknown}";
            var pattern_validator = new FileNamePatternValidator(settings);
            assert_cmpstr(new ConversionValidator(images, settings).validate(), CompareOperator.EQ,
            pattern_validator.messages().get("rename_pattern.known_placeholders"));
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/rename/converts-with-new-names", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = {
                create_image(input, "first.png", 8, 8, false),
                create_image(input, "second.png", 8, 8, false),
            };
            var controller = create_conversion_controller();
            controller.set_output_directory(output);
            controller.conversion_settings.output_format = OutputFormat.PNG;
            controller.conversion_settings.rename_enabled = true;
            controller.conversion_settings.rename_pattern = "photo_{number}";

            File[] targets;
            assert_null(controller.prepare(images, out targets));
            var loop = new MainLoop();
            controller.convert.begin(images, targets, (completed, total, current_name) => {}, (object, result) => {
                controller.convert.end(result);
                loop.quit();
            });
            loop.run();

            assert_true(output.get_child("photo_001.png").query_exists());
            assert_true(output.get_child("photo_002.png").query_exists());
            delete_recursively(input);
            delete_recursively(output);
        });
    }
}
