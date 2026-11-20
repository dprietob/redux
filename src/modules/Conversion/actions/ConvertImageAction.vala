using Redux.Images;
using Redux.Metadata;

namespace Redux.Conversion {

    // Converts a single image: loads it, resizes it, encodes it in the output
    // format and writes it to the output folder with the metadata to keep.
    public class ConvertImageAction : Object
    {

        private ImageResizeService image_resize_service;
        private ImageEncoderService image_encoder_service;
        private OutputPathService output_path_service;
        private SizeReductionService size_reduction_service;
        private MetadataWriterService metadata_writer_service;

        public ConvertImageAction ()
        {
            image_resize_service = new ImageResizeService();
            image_encoder_service = new ImageEncoderService();
            output_path_service = new OutputPathService();
            size_reduction_service = new SizeReductionService();
            metadata_writer_service = new MetadataWriterService();
        }

        // Never throws: a failure is described by the returned result, so one
        // broken image does not stop the rest of the batch.
        public ConversionResult execute(SourceImage source, ConversionSettings settings)
        {
            var target = output_path_service.target_file(source.file, settings.output_directory,
                    settings.output_format);
            var result = new ConversionResult() {
                source_name = source.name,
                output_name = target.get_basename(),
                original_size = source.size
            };

            try {
                var original = load(source.file);
                result.original_width = original.width;
                result.original_height = original.height;

                var resized = image_resize_service.resize(original, settings);
                result.output_width = resized.width;
                result.output_height = resized.height;

                var encoded = image_encoder_service.encode(resized, settings);
                write_output(source, target, encoded, settings, resized.width, resized.height);

                result.output_size = output_size(target);
                result.reduction_percentage = size_reduction_service.reduction_percentage(result.original_size,
                        result.output_size);
                result.succeeded = true;
            } catch (Error error) {
                result.error_message = error.message;
            }
            return result;
        }

        // Writes the encoded image and then its metadata. A converted image
        // whose metadata could not be written is deleted, so the user never
        // gets a file with metadata they did not choose.
        private void write_output(SourceImage source, File target, Bytes encoded, ConversionSettings settings,
            int output_width, int output_height) throws Error
        {
            target.replace_contents(encoded.get_data(), null, false, FileCreateFlags.REPLACE_DESTINATION, null, null);
            try {
                metadata_writer_service.write(source.file, target, settings.metadata_mode, source.metadata_selection,
                    output_width, output_height);
            } catch (Error metadata_error) {
                delete_quietly(target);
                throw metadata_error;
            }
        }

        // The cleanup error is not reported: the metadata error that caused
        // the cleanup is the one the user needs to see.
        private void delete_quietly(File file)
        {
            try {
                file.delete();
            } catch (Error error) {
                warning("Could not delete %s: %s", file.get_path(), error.message);
            }
        }

        private int64 output_size(File target) throws Error
        {
            return target.query_info(FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NONE).get_size();
        }

        // Loads the image upright, following the orientation stored by cameras.
        private Gdk.Pixbuf load(File file) throws Error
        {
            var image = new Gdk.Pixbuf.from_file(file.get_path());
            return image.apply_embedded_orientation() ?? image;
        }
    }
}
