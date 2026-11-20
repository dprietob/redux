using Redux.Metadata;

namespace Redux.Tests {

    private MetadataTag? find_tag(MetadataSelection selection, string key)
    {
        for (uint index = 0; index < selection.tags.get_n_items(); index++) {
            var tag = (MetadataTag) selection.tags.get_item(index);
            if (tag.key == key) {
                return tag;
            }
        }
        return null;
    }

    public void register_metadata_reader_service_tests()
    {
        Test.add_func("/metadata/reader/lists-tags-by-category", () => {
            var input = create_temporary_directory();
            var image = create_image_with_metadata(input, "photo.jpg");
            try {
                var selection = new MetadataReaderService().read(image.file);

                var make = find_tag(selection, "Exif.Image.Make");
                assert_nonnull(make);
                assert_cmpstr(make.description, CompareOperator.EQ, "Canon");
                assert_true(make.category == MetadataCategory.EXIF);
                assert_true(make.kept);
                assert_true(find_tag(selection, "Xmp.dc.creator").category == MetadataCategory.XMP);
                assert_true(find_tag(selection, "Iptc.Application2.Caption").category == MetadataCategory.IPTC);

                var comment = find_tag(selection, MetadataReaderService.COMMENT_KEY);
                assert_nonnull(comment);
                assert_cmpstr(comment.description, CompareOperator.EQ, "Taken with Redux");
            } catch (Error error) {
                GLib.error("Reading failed: %s", error.message);
            }
            delete_recursively(input);
        });

        Test.add_func("/metadata/reader/hides-automatic-tags", () => {
            var input = create_temporary_directory();
            var image = create_image_with_metadata(input, "photo.jpg");
            try {
                var selection = new MetadataReaderService().read(image.file);
                assert_null(find_tag(selection, "Exif.Image.Orientation"));
                assert_null(find_tag(selection, "Exif.Image.GPSTag"));
                assert_null(find_tag(selection, "Exif.Thumbnail.Compression"));
            } catch (Error error) {
                GLib.error("Reading failed: %s", error.message);
            }
            delete_recursively(input);
        });

        Test.add_func("/metadata/reader/image-without-metadata", () => {
            var input = create_temporary_directory();
            var image = create_image(input, "plain.png", 8, 8, false);
            try {
                assert_cmpuint(new MetadataReaderService().read(image.file).tags.get_n_items(), CompareOperator.EQ, 0);
            } catch (Error error) {
                GLib.error("Reading failed: %s", error.message);
            }
            delete_recursively(input);
        });

        Test.add_func("/metadata/category/toggles-only-its-tags", () => {
            var selection = new MetadataSelection();
            var make = new MetadataTag("Exif.Image.Make", "Make", "Canon", MetadataCategory.EXIF);
            var creator = new MetadataTag("Xmp.dc.creator", "Creator", "Redux", MetadataCategory.XMP);
            selection.tags.append(make);
            selection.tags.append(creator);

            new SetMetadataCategoryKeptAction().execute(selection, MetadataCategory.EXIF, false);
            assert_false(make.kept);
            assert_true(creator.kept);
        });
    }
}
