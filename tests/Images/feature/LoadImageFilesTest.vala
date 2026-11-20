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

        Test.add_func("/images/preview/scales-and-keeps-orientation", () => {
            var input = create_temporary_directory();
            var photo = create_image_with_metadata(input, "camera.jpg");
            var large = create_image(input, "large.png", 800, 400, false);
            var loop = new MainLoop();
            var action = new LoadImagePreviewAction();

            action.execute.begin(large.file, 256, null, (object, result) => {
                try {
                    var preview = action.execute.end(result);
                    assert_cmpint(preview.width, CompareOperator.EQ, 256);
                    assert_cmpint(preview.height, CompareOperator.EQ, 128);
                } catch (Error error) {
                    GLib.error("Preview failed: %s", error.message);
                }
                action.execute.begin(photo.file, 256, null, (object, rotated_result) => {
                    try {
                        // The 64 × 48 photo is rotated by its camera orientation.
                        var preview = action.execute.end(rotated_result);
                        assert_cmpint(preview.width, CompareOperator.EQ, 48);
                        assert_cmpint(preview.height, CompareOperator.EQ, 64);
                    } catch (Error error) {
                        GLib.error("Preview failed: %s", error.message);
                    }
                    loop.quit();
                });
            });
            loop.run();
            delete_recursively(input);
        });

        Test.add_func("/images/list/moves-one-place-within-bounds", () => {
            var input = create_temporary_directory();
            var controller = new ImageListController();
            controller.add_files({
                create_image(input, "a.png", 4, 4, false).file,
                create_image(input, "b.png", 4, 4, false).file,
                create_image(input, "c.png", 4, 4, false).file,
            });
            var first = (SourceImage) controller.images.get_item(0);
            var last = (SourceImage) controller.images.get_item(2);

            controller.move_by(first, -1);
            controller.move_by(last, 1);
            assert_cmpstr(((SourceImage) controller.images.get_item(0)).name, CompareOperator.EQ, "a.png");
            assert_cmpstr(((SourceImage) controller.images.get_item(2)).name, CompareOperator.EQ, "c.png");

            controller.move_by(first, 1);
            assert_cmpstr(((SourceImage) controller.images.get_item(1)).name, CompareOperator.EQ, "a.png");
            controller.move_by(last, -1);
            assert_cmpstr(((SourceImage) controller.images.get_item(1)).name, CompareOperator.EQ, "c.png");
            delete_recursively(input);
        });

        Test.add_func("/images/list/reports-selection-changes-once", () => {
            var input = create_temporary_directory();
            var controller = new ImageListController();
            controller.add_files({ create_image(input, "a.png", 4, 4, false).file });
            var image = (SourceImage) controller.images.get_item(0);
            uint notifications = 0;
            controller.selection_changed.connect(() => notifications++);

            image.selected = false;
            assert_cmpuint(notifications, CompareOperator.EQ, 1);

            controller.remove(image);
            image.selected = true;
            assert_cmpuint(notifications, CompareOperator.EQ, 1);
            delete_recursively(input);
        });
    }
}
