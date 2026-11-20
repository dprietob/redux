using Redux.Images;

namespace Redux.Tests {

    public void register_load_image_files_tests()
    {
        Test.add_func("/images/load-files/keeps-only-supported-images", () => {
            var input = create_temporary_directory();
            var photo = create_image(input, "photo.png", 4, 4, false);
            var notes = input.get_child("notes.txt");
            try {
                notes.replace_contents("plain text".data, null, false, FileCreateFlags.NONE, null);
            } catch (Error error) {
                GLib.error("Could not write the text file: %s", error.message);
            }
            var missing = input.get_child("missing.png");

            var images = new LoadImageFilesAction(new ImageFileService()).execute({ photo.file, notes, missing });
            assert_cmpint(images.length, CompareOperator.EQ, 1);
            assert_cmpstr(images[0].name, CompareOperator.EQ, "photo.png");
            assert_true(images[0].selected);
            delete_recursively(input);
        });

        Test.add_func("/images/list/skips-images-already-added", () => {
            var input = create_temporary_directory();
            var photo = create_image(input, "photo.png", 4, 4, false);
            var controller = new ImageListController();

            assert_cmpuint(controller.add_files({ photo.file }), CompareOperator.EQ, 1);
            assert_cmpuint(controller.add_files({ photo.file }), CompareOperator.EQ, 0);
            assert_cmpuint(controller.images.get_n_items(), CompareOperator.EQ, 1);
            delete_recursively(input);
        });

        Test.add_func("/images/list/moves-images", () => {
            var input = create_temporary_directory();
            var first = create_image(input, "a.png", 4, 4, false);
            var second = create_image(input, "b.png", 4, 4, false);
            var third = create_image(input, "c.png", 4, 4, false);
            var controller = new ImageListController();
            controller.add_files({ first.file, second.file, third.file });

            var a = (SourceImage) controller.images.get_item(0);
            var c = (SourceImage) controller.images.get_item(2);
            controller.move(a, c, true);
            assert_cmpstr(((SourceImage) controller.images.get_item(2)).name, CompareOperator.EQ, "a.png");
            controller.move(a, (SourceImage) controller.images.get_item(0), false);
            assert_cmpstr(((SourceImage) controller.images.get_item(0)).name, CompareOperator.EQ, "a.png");
            assert_cmpuint(controller.images.get_n_items(), CompareOperator.EQ, 3);
            delete_recursively(input);
        });
    }
}
