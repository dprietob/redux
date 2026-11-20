using Redux.Conversion;
using Redux.Images;

namespace Redux.Tests {

    // Starts a conversion from a local array that is freed as soon as this
    // function returns, like the window does.
    private void start_conversion_from_temporary_array(ConversionController controller, File input,
        owned AsyncReadyCallback finished)
    {
        SourceImage[] images = {
            create_image(input, "first.png", 32, 32, false),
            create_image(input, "second.png", 32, 32, false),
        };
        controller.convert.begin(images, (completed, total, current_name) => {}, (owned) finished);
    }

    public void register_conversion_controller_tests()
    {
        Test.add_func("/conversion/controller/converts-in-background-and-reports", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = {
                create_image(input, "first.png", 120, 80, false),
                create_image(input, "second.png", 60, 60, true),
            };

            var controller = new ConversionController();
            controller.set_output_directory(output);
            controller.conversion_settings.output_format = OutputFormat.JPEG;
            controller.conversion_settings.resize_enabled = false;
            assert_null(controller.validate(images));

            var loop = new MainLoop();
            uint progress_calls = 0;
            ConversionReport? report = null;
            controller.convert.begin(images, (completed, total, current_name) => {
                assert_cmpuint(total, CompareOperator.EQ, 2);
                progress_calls++;
            }, (object, result) => {
                report = controller.convert.end(result);
                loop.quit();
            });
            loop.run();

            assert_cmpuint(progress_calls, CompareOperator.EQ, 2);
            assert_cmpuint(report.converted_count, CompareOperator.EQ, 2);
            assert_cmpuint(report.failed_count, CompareOperator.EQ, 0);
            assert_false(report.cancelled);
            assert_true(output.get_child("first.jpg").query_exists());
            assert_true(output.get_child("second.jpg").query_exists());
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/controller/survives-caller-freeing-images", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var controller = new ConversionController();
            controller.set_output_directory(output);

            var loop = new MainLoop();
            ConversionReport? report = null;
            start_conversion_from_temporary_array(controller, input, (object, result) => {
                report = controller.convert.end(result);
                loop.quit();
            });
            loop.run();

            assert_nonnull(report);
            assert_cmpuint(report.converted_count, CompareOperator.EQ, 2);
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/controller/stop-keeps-converted-images", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            SourceImage[] images = {
                create_image(input, "first.png", 16, 16, false),
                create_image(input, "second.png", 16, 16, false),
                create_image(input, "third.png", 16, 16, false),
            };

            var controller = new ConversionController();
            controller.set_output_directory(output);

            // Stopping right after the conversion starts lets at most the image
            // already in progress finish.
            var loop = new MainLoop();
            ConversionReport? report = null;
            controller.convert.begin(images, (completed, total, current_name) => {}, (object, result) => {
                report = controller.convert.end(result);
                loop.quit();
            });
            controller.stop();
            loop.run();

            assert_nonnull(report);
            assert_true(report.cancelled);
            assert_cmpuint(report.results.get_n_items(), CompareOperator.LE, 1);
            delete_recursively(input);
            delete_recursively(output);
        });
    }
}
