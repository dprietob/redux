int main(string[] arguments)
{
    Test.init(ref arguments);

    Redux.Tests.register_image_resize_service_tests();
    Redux.Tests.register_output_path_service_tests();
    Redux.Tests.register_size_reduction_service_tests();
    Redux.Tests.register_build_conversion_report_action_tests();
    Redux.Tests.register_conversion_validator_tests();
    Redux.Tests.register_convert_image_tests();
    Redux.Tests.register_conversion_controller_tests();
    Redux.Tests.register_list_images_in_directory_tests();

    return Test.run();
}
