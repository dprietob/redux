using Redux.Images;

namespace Redux.Tests {

    public void register_list_images_in_directory_tests()
    {
        Test.add_func("/images/list-directory/only-supported-images-sorted", () => {
            var input = create_temporary_directory();
            create_image(input, "b.png", 4, 4, false);
            create_image(input, "a.png", 4, 4, false);
            try {
                input.get_child("notes.txt").replace_contents("plain text".data, null, false,
                FileCreateFlags.NONE, null);

                var images = new ListImagesInDirectoryAction(new ImageFileService()).execute(input);
                assert_cmpint(images.length, CompareOperator.EQ, 2);
                assert_cmpstr(images[0].name, CompareOperator.EQ, "a.png");
                assert_cmpstr(images[1].name, CompareOperator.EQ, "b.png");
                assert_true(images[0].selected);
            } catch (Error error) {
                GLib.error("Listing failed: %s", error.message);
            }
            delete_recursively(input);
        });

        Test.add_func("/images/directory-validator/rejects-missing-folder", () => {
            var validator = new ImageDirectoryValidator(File.new_for_path("/nonexistent/redux/folder"));
            assert_cmpstr(validator.validate(), CompareOperator.EQ, validator.messages().get("directory.directory"));
        });
    }
}
