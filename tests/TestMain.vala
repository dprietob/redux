int main(string[] arguments)
{
    Test.init(ref arguments);
    GExiv2.initialize();

    Redux.Tests.register_image_resize_service_tests();
    Redux.Tests.register_output_path_service_tests();
    Redux.Tests.register_size_reduction_service_tests();
    Redux.Tests.register_build_conversion_report_action_tests();
    Redux.Tests.register_conversion_validator_tests();
    Redux.Tests.register_file_name_pattern_service_tests();
    Redux.Tests.register_rename_output_files_tests();
    Redux.Tests.register_convert_image_tests();
    Redux.Tests.register_conversion_controller_tests();
    Redux.Tests.register_convert_image_metadata_tests();
    Redux.Tests.register_metadata_reader_service_tests();
    Redux.Tests.register_load_image_files_tests();

    return Test.run();
}
