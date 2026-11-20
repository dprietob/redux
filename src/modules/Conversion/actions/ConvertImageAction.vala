using Redux.Images;

namespace Redux.Conversion {

    // Converts a single image: loads it, resizes it, encodes it in the output
    // format and writes it to the output folder.
    public class ConvertImageAction : Object
    {

        private ImageResizeService image_resize_service;
        private ImageEncoderService image_encoder_service;
        private OutputPathService output_path_service;
        private SizeReductionService size_reduction_service;

        public ConvertImageAction ()
        {
            image_resize_service = new ImageResizeService();
            image_encoder_service = new ImageEncoderService();
            output_path_service = new OutputPathService();
            size_reduction_service = new SizeReductionService();
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
                target.replace_contents(encoded.get_data(), null, false, FileCreateFlags.REPLACE_DESTINATION,
                    null, null);

                result.output_size = encoded.get_size();
                result.reduction_percentage = size_reduction_service.reduction_percentage(result.original_size,
                        result.output_size);
                result.succeeded = true;
            } catch (Error error) {
                result.error_message = error.message;
            }
            return result;
        }

        // Loads the image upright, following the orientation stored by cameras.
        private Gdk.Pixbuf load(File file) throws Error
        {
            var image = new Gdk.Pixbuf.from_file(file.get_path());
            return image.apply_embedded_orientation() ?? image;
        }
    }
}
