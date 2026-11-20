using Redux.Images;

namespace Redux.Conversion {

    // Reports which image is being converted and how many are already done.
    public delegate void ProgressFunc(uint completed, uint total, string current_name);

    // Coordinates a conversion: it keeps the options in sync with the saved
    // preferences, runs the validator and converts the images on a worker
    // thread so the interface stays responsive.
    public class ConversionController : Object
    {

        private ConvertImageAction convert_image_action;
        private BuildConversionReportAction build_report_action;
        private GLib.Settings preferences;
        private Cancellable? current_stop_request = null;

        public ConversionSettings conversion_settings { get; private set; }

        public ConversionController ()
        {
            convert_image_action = new ConvertImageAction();
            build_report_action = new BuildConversionReportAction();
            conversion_settings = new ConversionSettings();

            preferences = new GLib.Settings(Config.APP_ID);
            bind_preferences();
        }

        public void set_output_directory(File directory)
        {
            conversion_settings.output_directory = directory;
        }

        // Returns the first validation error, or null when the conversion can start.
        public string? validate(SourceImage[] images)
        {
            return new ConversionValidator(images, conversion_settings).validate();
        }

        // Converts the images one by one and returns the report, also when the
        // conversion is stopped: the images already converted are kept and
        // reported.
        //
        // The stop request is not taken as a Cancellable parameter on purpose:
        // Vala binds such a parameter to the async call itself, which would
        // then finish without any report once cancelled.
        public async ConversionReport convert(SourceImage[] requested_images, owned ProgressFunc progress)
        {
            // Async methods keep only a pointer to array arguments, which the
            // caller may free while the worker thread still reads them; this
            // copy holds its own reference to every image.
            SourceImage[] images = requested_images;
            var settings = conversion_settings.copy();
            var stop_request = new Cancellable();
            current_stop_request = stop_request;
            ConversionReport? report = null;
            SourceFunc resume = convert.callback;

            new Thread<void> ("redux-conversion", () => {
                ConversionResult[] results = {};
                for (uint index = 0; index < images.length && !stop_request.is_cancelled(); index++) {
                    var image = images[index];
                    var completed = index;
                    Idle.add(() => {
                        progress(completed, images.length, image.name);
                        return Source.REMOVE;
                    });
                    results += convert_image_action.execute(image, settings);
                }
                report = build_report_action.execute(results, settings.output_directory, stop_request.is_cancelled());
                Idle.add((owned) resume);
            });

            yield;
            current_stop_request = null;
            return report;
        }

        // Asks the running conversion to stop before the next image.
        public void stop()
        {
            if (current_stop_request != null) {
                current_stop_request.cancel();
            }
        }

        // Persists every option except the output folder, which may point to a
        // removable or sandboxed location.
        private void bind_preferences()
        {
            string[] keys = {
                "output-format", "quality", "compression-level", "resize-enabled", "resize-mode",
                "width", "height", "width-percentage", "height-percentage", "keep-aspect-ratio",
            };
            foreach (var key in keys) {
                preferences.bind(key, conversion_settings, key, SettingsBindFlags.DEFAULT);
            }
        }
    }
}
