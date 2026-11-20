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
        private PlanOutputFilesAction plan_output_files_action;
        private PreviewFileNameAction preview_file_name_action;
        private ChooseOutputDirectoryAction choose_output_directory_action;
        private CheckCompletionNotificationAction check_completion_notification_action;
        private BuildConversionReportAction build_report_action;
        private GLib.Settings preferences;
        private Cancellable? current_stop_request = null;

        public ConversionSettings conversion_settings { get; private set; }

        public ConversionController ()
        {
            convert_image_action = new ConvertImageAction();
            plan_output_files_action = new PlanOutputFilesAction();
            preview_file_name_action = new PreviewFileNameAction();
            choose_output_directory_action = new ChooseOutputDirectoryAction();
            check_completion_notification_action = new CheckCompletionNotificationAction();
            build_report_action = new BuildConversionReportAction();
            conversion_settings = new ConversionSettings();

            preferences = new GLib.Settings(Config.APP_ID);
            bind_preferences();
        }

        public void set_output_directory(File directory)
        {
            choose_output_directory_action.execute(conversion_settings, directory);
        }

        // Validates the conversion and decides the converted file of every
        // image. Returns the first error, or null when the conversion can start.
        public string? prepare(SourceImage[] images, out File[] targets)
        {
            targets = {};
            var error = new ConversionValidator(images, conversion_settings).validate();
            if (error != null) {
                return error;
            }

            try {
                targets = plan_output_files_action.execute(images, conversion_settings);
            } catch (Error plan_error) {
                return plan_error.message;
            }
            return null;
        }

        // Builds an example of the new file names. Returns the validation
        // error of the rename options instead when they are not valid.
        public string? preview_file_name(out string preview)
        {
            preview = "";
            var error = new FileNamePatternValidator(conversion_settings).validate();
            if (error != null) {
                return error;
            }
            preview = preview_file_name_action.execute(conversion_settings);
            return null;
        }

        // Converts the images one by one and returns the report, also when the
        // conversion is stopped: the images already converted are kept and
        // reported.
        //
        // The stop request is not taken as a Cancellable parameter on purpose:
        // Vala binds such a parameter to the async call itself, which would
        // then finish without any report once cancelled.
        public async ConversionReport convert(SourceImage[] requested_images, File[] requested_targets,
            owned ProgressFunc progress)
        {
            // Async methods keep only a pointer to array arguments, which the
            // caller may free while the worker thread still reads them; these
            // copies hold their own reference to every image and file.
            SourceImage[] images = requested_images;
            File[] targets = requested_targets;
            var settings = conversion_settings.copy();
            var stop_request = new Cancellable();
            current_stop_request = stop_request;
            ConversionReport? report = null;
            SourceFunc resume = convert.callback;

            new Thread<void> ("redux-conversion", () => {
                var timer = new Timer();
                ConversionResult[] results = {};
                for (uint index = 0; index < images.length && !stop_request.is_cancelled(); index++) {
                    var image = images[index];
                    var completed = index;
                    Idle.add(() => {
                        progress(completed, images.length, image.name);
                        return Source.REMOVE;
                    });
                    results += convert_image_action.execute(image, targets[index], settings);
                }
                report = build_report_action.execute(results, settings.output_directory, stop_request.is_cancelled(),
                timer.elapsed());
                Idle.add((owned) resume);
            });

            yield;
            current_stop_request = null;
            return report;
        }

        // Whether the user should get a notification about this finished conversion.
        public bool should_notify_completion(ConversionReport report)
        {
            return check_completion_notification_action.execute(report, conversion_settings.notify_when_finished);
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
                "width", "height", "width-percentage", "height-percentage", "keep-aspect-ratio", "metadata-mode",
                "rename-enabled", "rename-pattern", "rename-prefix", "rename-suffix", "rename-start-number",
                "rename-digits", "notify-when-finished",
            };
            foreach (var key in keys) {
                preferences.bind(key, conversion_settings, key, SettingsBindFlags.DEFAULT);
            }
        }
    }
}
