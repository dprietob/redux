using Redux.Conversion;

namespace Redux.Tests {

    public void register_output_path_service_tests()
    {
        Test.add_func("/conversion/output-path/replaces-extension", () => {
            var target = new OutputPathService().target_file(File.new_for_path("/photos/holiday.photo.JPG"),
            File.new_for_path("/output"), OutputFormat.WEBP);
            assert_cmpstr(target.get_path(), CompareOperator.EQ, "/output/holiday.photo.webp");
        });

        Test.add_func("/conversion/output-path/uses-format-extension", () => {
            var service = new OutputPathService();
            var source = File.new_for_path("/photos/cat.webp");
            var output = File.new_for_path("/output");
            assert_cmpstr(service.target_file(source, output, OutputFormat.JPEG).get_basename(),
            CompareOperator.EQ, "cat.jpg");
            assert_cmpstr(service.target_file(source, output, OutputFormat.PNG).get_basename(),
            CompareOperator.EQ, "cat.png");
        });

        Test.add_func("/conversion/output-path/keeps-hidden-and-extensionless-names", () => {
            var service = new OutputPathService();
            var output = File.new_for_path("/output");
            assert_cmpstr(service.target_file(File.new_for_path("/photos/.hidden"), output,
            OutputFormat.PNG).get_basename(), CompareOperator.EQ, ".hidden.png");
            assert_cmpstr(service.target_file(File.new_for_path("/photos/scan"), output,
            OutputFormat.PNG).get_basename(), CompareOperator.EQ, "scan.png");
        });
    }
}
