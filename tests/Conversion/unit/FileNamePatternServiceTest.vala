using Redux.Conversion;

namespace Redux.Tests {

    private ConversionSettings rename_settings(string pattern, string prefix, string suffix)
    {
        return new ConversionSettings() {
                   rename_enabled = true,
                   rename_pattern = pattern,
                   rename_prefix = prefix,
                   rename_suffix = suffix,
                   rename_digits = 3,
                   output_format = OutputFormat.WEBP
        };
    }

    public void register_file_name_pattern_service_tests()
    {
        Test.add_func("/conversion/file-name-pattern/expands-placeholders", () => {
            var settings = rename_settings("{date}_{time}_{name}_{number}", "trip-", "-small");
            var date = new DateTime.local(2026, 5, 1, 9, 8, 7);
            assert_cmpstr(new FileNamePatternService().file_name(settings, "IMG_1", 7, date), CompareOperator.EQ,
            "trip-2026-05-01_09-08-07_IMG_1_007-small.webp");
        });

        Test.add_func("/conversion/file-name-pattern/pads-to-digits-without-truncating", () => {
            var service = new FileNamePatternService();
            var settings = rename_settings("{number}", "", "");
            settings.rename_digits = 2;
            assert_cmpstr(service.file_name(settings, "photo", 5, null), CompareOperator.EQ, "05.webp");
            assert_cmpstr(service.file_name(settings, "photo", 1234, null), CompareOperator.EQ, "1234.webp");
        });

        Test.add_func("/conversion/file-name-pattern/keeps-placeholders-inside-original-name", () => {
            var settings = rename_settings("{name}", "", "");
            assert_cmpstr(new FileNamePatternService().file_name(settings, "my {number} photo", 1, null),
            CompareOperator.EQ, "my {number} photo.webp");
        });

        Test.add_func("/conversion/file-name-pattern/finds-unknown-placeholders", () => {
            var service = new FileNamePatternService();
            var unknown = service.unknown_placeholders("{name}_{counter}_{date}_{}");
            assert_cmpint(unknown.length, CompareOperator.EQ, 2);
            assert_cmpstr(unknown[0], CompareOperator.EQ, "{counter}");
            assert_cmpstr(unknown[1], CompareOperator.EQ, "{}");
            assert_true(service.uses_date("x_{time}"));
            assert_false(service.uses_date("{name}_{number}"));
        });

        Test.add_func("/conversion/file-name-pattern/validator-rules", () => {
            var settings = rename_settings("{name}", "", "");
            assert_null(new FileNamePatternValidator(settings).validate());

            string[] invalid_keys = {
                "rename_pattern.required", "rename_pattern.known_placeholders",
                "rename_pattern.file_name_characters", "rename_prefix.file_name_characters",
                "rename_digits.between",
            };
            ConversionSettings[] invalid_settings = {
                rename_settings("  ", "", ""),
                rename_settings("{nombre}", "", ""),
                rename_settings("a/{name}", "", ""),
                rename_settings("{name}", "x/", ""),
                rename_settings("{name}", "", ""),
            };
            invalid_settings[4].rename_digits = 0;

            for (int index = 0; index < invalid_keys.length; index++) {
                var validator = new FileNamePatternValidator(invalid_settings[index]);
                assert_cmpstr(validator.validate(), CompareOperator.EQ, validator.messages().get(invalid_keys[index]));
            }
        });
    }
}
