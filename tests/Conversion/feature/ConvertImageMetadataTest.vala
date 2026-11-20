using Redux.Conversion;
using Redux.Images;
using Redux.Metadata;

namespace Redux.Tests {

    // Converts the image and returns the metadata of the converted file.
    private GExiv2.Metadata convert_with_metadata(SourceImage source, File output, OutputFormat format,
        MetadataMode mode)
    {
        var settings = settings_for(output, format);
        settings.metadata_mode = mode;
        var result = convert_image(source, settings);
        if (!result.succeeded) {
            GLib.error("Conversion failed: %s", result.error_message);
        }
        return read_metadata(output.get_child(result.output_name));
    }

    private bool has(GExiv2.Metadata metadata, string key)
    {
        try {
            return metadata.has_tag(key);
        } catch (Error error) {
            GLib.error("Could not check %s: %s", key, error.message);
        }
    }

    private string? file_comment_of(GExiv2.Metadata metadata)
    {
        metadata.clear_exif();
        metadata.clear_xmp();
        metadata.clear_iptc();
        try {
            return metadata.get_comment();
        } catch (Error error) {
            GLib.error("Could not read the comment: %s", error.message);
        }
    }

    public void register_convert_image_metadata_tests()
    {
        Test.add_func("/conversion/metadata/remove-all", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image_with_metadata(input, "photo.jpg");

            foreach (var format in new OutputFormat[] { OutputFormat.WEBP, OutputFormat.JPEG, OutputFormat.PNG }) {
                var metadata = convert_with_metadata(source, output, format, MetadataMode.REMOVE_ALL);
                assert_cmpint(metadata.get_exif_tags().length, CompareOperator.EQ, 0);
                assert_cmpint(metadata.get_xmp_tags().length, CompareOperator.EQ, 0);
                assert_cmpint(metadata.get_iptc_tags().length, CompareOperator.EQ, 0);
            }
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/metadata/keep-exif-only", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image_with_metadata(input, "photo.jpg");

            foreach (var format in new OutputFormat[] { OutputFormat.WEBP, OutputFormat.JPEG, OutputFormat.PNG }) {
                var metadata = convert_with_metadata(source, output, format, MetadataMode.KEEP_EXIF);
                assert_true(has(metadata, "Exif.Image.Make"));
                assert_true(has(metadata, "Exif.GPSInfo.GPSLatitude"));
                assert_cmpint(metadata.get_xmp_tags().length, CompareOperator.EQ, 0);
                assert_cmpint(metadata.get_iptc_tags().length, CompareOperator.EQ, 0);
                assert_null(file_comment_of(metadata));
            }
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/metadata/kept-exif-matches-converted-pixels", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image_with_metadata(input, "photo.jpg");

            var metadata = convert_with_metadata(source, output, OutputFormat.JPEG, MetadataMode.KEEP_EXIF);
            try {
                // The camera orientation is applied to the pixels (64 × 48 turned
                // to 48 × 64), so the tag is reset and the stored size updated.
                assert_cmpint((int) metadata.get_tag_long("Exif.Image.Orientation"), CompareOperator.EQ, 1);
                assert_cmpint((int) metadata.get_tag_long("Exif.Photo.PixelXDimension"), CompareOperator.EQ, 48);
                assert_cmpint((int) metadata.get_tag_long("Exif.Photo.PixelYDimension"), CompareOperator.EQ, 64);
            } catch (Error error) {
                GLib.error("Could not read the tags: %s", error.message);
            }
            assert_false(has(metadata, "Exif.Thumbnail.Compression"));
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/metadata/per-image-selection", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image_with_metadata(input, "photo.jpg");
            try {
                source.metadata_selection = new MetadataReaderService().read(source.file);
            } catch (Error error) {
                GLib.error("Reading failed: %s", error.message);
            }
            find_tag(source.metadata_selection, "Exif.GPSInfo.GPSLatitude").kept = false;
            find_tag(source.metadata_selection, MetadataReaderService.COMMENT_KEY).kept = false;
            new SetMetadataCategoryKeptAction().execute(source.metadata_selection, MetadataCategory.IPTC, false);

            var metadata = convert_with_metadata(source, output, OutputFormat.PNG, MetadataMode.PER_IMAGE);
            assert_true(has(metadata, "Exif.Image.Make"));
            assert_false(has(metadata, "Exif.GPSInfo.GPSLatitude"));
            assert_true(has(metadata, "Xmp.dc.creator"));
            assert_cmpint(metadata.get_iptc_tags().length, CompareOperator.EQ, 0);
            assert_null(file_comment_of(metadata));
            delete_recursively(input);
            delete_recursively(output);
        });

        Test.add_func("/conversion/metadata/per-image-unedited-keeps-everything", () => {
            var input = create_temporary_directory();
            var output = create_temporary_directory();
            var source = create_image_with_metadata(input, "photo.jpg");

            var metadata = convert_with_metadata(source, output, OutputFormat.JPEG, MetadataMode.PER_IMAGE);
            assert_true(has(metadata, "Exif.GPSInfo.GPSLatitude"));
            assert_true(has(metadata, "Xmp.xmp.Rating"));
            assert_true(has(metadata, "Iptc.Application2.Caption"));
            assert_cmpstr(file_comment_of(metadata), CompareOperator.EQ, "Taken with Redux");
            delete_recursively(input);
            delete_recursively(output);
        });
    }
}
