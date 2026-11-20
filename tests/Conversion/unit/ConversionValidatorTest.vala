using Redux.Conversion;
using Redux.Images;

namespace Redux.Tests {

    public void register_conversion_validator_tests()
    {
        Test.add_func("/conversion/validator/requires-images", () => {
            var output = create_temporary_directory();
            SourceImage[] images = {};
            var validator = new ConversionValidator(images, settings_for(output, OutputFormat.WEBP));
            assert_cmpstr(validator.validate(), CompareOperator.EQ, validator.messages().get("images.required"));
            delete_recursively(output);
        });

        Test.add_func("/conversion/validator/requires-output-directory", () => {
            var input = create_temporary_directory();
            SourceImage[] images = { create_image(input, "photo.png", 8, 8, false) };
            var validator = new ConversionValidator(images, new ConversionSettings());
            assert_cmpstr(validator.validate(), CompareOperator.EQ,
            validator.messages().get("output_directory.required"));
            delete_recursively(input);
        });

        Test.add_func("/conversion/validator/rejects-overwriting-sources", () => {
            var input = create_temporary_directory();
            SourceImage[] images = { create_image(input, "photo.png", 8, 8, false) };
            var validator = new ConversionValidator(images, settings_for(input, OutputFormat.PNG));
            assert_cmpstr(validator.validate(), CompareOperator.EQ,
            validator.messages().get("output_directory.not_overwriting"));
            delete_recursively(input);
        });

        Test.add_func("/conversion/validator/rejects-duplicated-output-names", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = {
                create_image(input, "photo.png", 8, 8, false),
                create_image(input, "photo.bmp.png", 8, 8, false),
                create_image(input, "photo.jpeg", 8, 8, false),
            };
            var validator = new ConversionValidator(images, settings_for(output, OutputFormat.WEBP));
            assert_cmpstr(validator.validate(), CompareOperator.EQ,
            validator.messages().get("output_directory.distinct"));
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/validator/requires-both-sides-without-aspect-ratio", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = { create_image(input, "photo.png", 8, 8, false) };
            var settings = settings_for(output, OutputFormat.WEBP);
            settings.resize_enabled = true;
            settings.keep_aspect_ratio = false;
            settings.width = 100;
            settings.height = 0;

            var validator = new ConversionValidator(images, settings);
            assert_cmpstr(validator.validate(), CompareOperator.EQ,
            validator.messages().get("dimensions.required_with"));

            settings.height = 100;
            assert_null(new ConversionValidator(images, settings).validate());
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/validator/accepts-valid-conversion", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = { create_image(input, "photo.png", 8, 8, false) };
            assert_null(new ConversionValidator(images, settings_for(output, OutputFormat.JPEG)).validate());
            delete_recursively(input);
            delete_recursively(output);
        });
    }
}
