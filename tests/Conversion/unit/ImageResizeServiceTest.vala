using Redux.Conversion;

namespace Redux.Tests {

    private void assert_target_size(ConversionSettings settings, int original_width, int original_height,
        int expected_width, int expected_height)
    {
        int width;
        int height;
        new ImageResizeService().target_size(original_width, original_height, settings, out width, out height);
        assert_cmpint(width, CompareOperator.EQ, expected_width);
        assert_cmpint(height, CompareOperator.EQ, expected_height);
    }

    public void register_image_resize_service_tests()
    {
        Test.add_func("/conversion/resize/disabled-keeps-original-size", () => {
            var settings = new ConversionSettings() {
                resize_enabled = false, width = 100, height = 100
            };
            assert_target_size(settings, 4000, 3000, 4000, 3000);
        });

        Test.add_func("/conversion/resize/pixels-fit-inside-bounding-box", () => {
            var settings = new ConversionSettings() {
                resize_enabled = true, resize_mode = ResizeMode.PIXELS,
                keep_aspect_ratio = true, width = 1000, height = 1000
            };
            assert_target_size(settings, 4000, 3000, 1000, 750);
            assert_target_size(settings, 3000, 4000, 750, 1000);
        });

        Test.add_func("/conversion/resize/pixels-zero-side-adapts", () => {
            var settings = new ConversionSettings() {
                resize_enabled = true, resize_mode = ResizeMode.PIXELS,
                keep_aspect_ratio = true, width = 0, height = 300
            };
            assert_target_size(settings, 4000, 3000, 400, 300);
        });

        Test.add_func("/conversion/resize/pixels-exact-without-aspect-ratio", () => {
            var settings = new ConversionSettings() {
                resize_enabled = true, resize_mode = ResizeMode.PIXELS,
                keep_aspect_ratio = false, width = 640, height = 640
            };
            assert_target_size(settings, 4000, 3000, 640, 640);
        });

        Test.add_func("/conversion/resize/percentage-keeps-aspect-ratio", () => {
            var settings = new ConversionSettings() {
                resize_enabled = true, resize_mode = ResizeMode.PERCENTAGE,
                keep_aspect_ratio = true, width_percentage = 25, height_percentage = 90
            };
            assert_target_size(settings, 4000, 3000, 1000, 750);
        });

        Test.add_func("/conversion/resize/percentage-independent-sides", () => {
            var settings = new ConversionSettings() {
                resize_enabled = true, resize_mode = ResizeMode.PERCENTAGE,
                keep_aspect_ratio = false, width_percentage = 50, height_percentage = 10
            };
            assert_target_size(settings, 4000, 3000, 2000, 300);
        });

        Test.add_func("/conversion/resize/never-below-one-pixel", () => {
            var settings = new ConversionSettings() {
                resize_enabled = true, resize_mode = ResizeMode.PERCENTAGE,
                keep_aspect_ratio = true, width_percentage = 1
            };
            assert_target_size(settings, 10, 10, 1, 1);
        });
    }
}
