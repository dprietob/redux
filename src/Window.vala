using Redux.Images;
using Redux.Conversion;
using Redux.Metadata;

namespace Redux {

    // Application shell. Owns the controllers, places the input list and the
    // conversion options side by side, and presents dialogs and toasts on
    // behalf of the modules.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/window.ui")]
    public class Window : Adw.ApplicationWindow
    {
        private delegate void ActivateCallback();

        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        private unowned Adw.NavigationSplitView split_view;

        private GLib.Settings settings;
        private ImageListController image_controller;
        private ConversionController conversion_controller;
        private MetadataController metadata_controller;
        private SimpleAction convert_action;

        public Window (Gtk.Application application)
        {
            Object(application: application);

            settings = new GLib.Settings(Config.APP_ID);
            settings.bind("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
            settings.bind("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
            settings.bind("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);

            image_controller = new ImageListController();
            conversion_controller = new ConversionController();
            metadata_controller = new MetadataController();

            var image_panel = new ImageListPanel(image_controller);
            image_panel.metadata_requested.connect(on_metadata_requested);
            conversion_controller.conversion_settings.bind_property("metadata-mode", image_panel, "metadata-editable",
                BindingFlags.SYNC_CREATE, (binding, source, ref target) => {
                target.set_boolean(source.get_enum() == MetadataMode.PER_IMAGE);
                return true;
            });

            split_view.sidebar = image_panel;
            split_view.content = new ConversionSettingsPanel(conversion_controller);

            register_actions();
        }

        private void register_actions()
        {
            add_simple_action("add-images", on_add_images);
            add_simple_action("clear-images", () => image_controller.clear());
            add_simple_action("choose-output-folder", on_choose_output_folder);
            convert_action = add_simple_action("convert", on_convert);
        }

        private SimpleAction add_simple_action(string name, owned ActivateCallback callback)
        {
            var action = new SimpleAction(name, null);
            action.activate.connect(() => callback());
            add_action(action);
            return action;
        }

        private void on_add_images()
        {
            var dialog = new Gtk.FileDialog() {
                title = _("Add Images"),
                default_filter = build_image_filter()
            };
            dialog.open_multiple.begin(this, null, (object, result) => {
                ListModel selection;
                try {
                    selection = dialog.open_multiple.end(result);
                } catch (Error error) {
                    // Dismissing the dialog is not an error worth reporting.
                    return;
                }

                File[] files = {};
                for (uint index = 0; index < selection.get_n_items(); index++) {
                    files += (File) selection.get_item(index);
                }
                report_skipped_files(files.length - image_controller.add_files(files));
            });
        }

        private Gtk.FileFilter build_image_filter()
        {
            var filter = new Gtk.FileFilter() {
                name = _("Images")
            };
            foreach (var content_type in image_controller.supported_content_types()) {
                filter.add_mime_type(content_type);
            }
            return filter;
        }

        private void on_choose_output_folder()
        {
            var dialog = new Gtk.FileDialog() {
                title = _("Choose Output Folder")
            };
            dialog.select_folder.begin(this, null, (object, result) => {
                try {
                    conversion_controller.set_output_directory(dialog.select_folder.end(result));
                } catch (Error error) {
                    // Dismissing the dialog is not an error worth reporting.
                    return;
                }
            });
        }

        private void on_metadata_requested(SourceImage image)
        {
            MetadataSelection? selection;
            var error = metadata_controller.load(image, out selection);
            if (error != null) {
                report(_("The metadata of “%s” could not be read: %s").printf(image.name, error));
                return;
            }
            new MetadataDialog(metadata_controller, image.name, selection).present(this);
        }

        private void on_convert()
        {
            var images = image_controller.selected_images();
            File[] targets;
            var error = conversion_controller.prepare(images, out targets);
            if (error != null) {
                report(error);
                return;
            }

            var progress_dialog = new ConversionProgressDialog();
            progress_dialog.cancel_requested.connect(() => conversion_controller.stop());
            progress_dialog.present(this);
            convert_action.set_enabled(false);

            conversion_controller.convert.begin(images, targets,
                (completed, total, current_name) => progress_dialog.update(completed, total, current_name),
                (object, result) => {
                progress_dialog.force_close();
                convert_action.set_enabled(true);
                show_report(conversion_controller.convert.end(result));
            });
        }

        private void show_report(ConversionReport conversion_report)
        {
            var dialog = new ConversionReportDialog(conversion_report);
            dialog.open_folder_requested.connect(open_folder);
            dialog.present(this);
        }

        private void open_folder(File directory)
        {
            var launcher = new Gtk.FileLauncher(directory);
            launcher.launch.begin(this, null, (object, result) => {
                try {
                    launcher.launch.end(result);
                } catch (Error error) {
                    report(error.message);
                }
            });
        }

        private void report_skipped_files(uint skipped)
        {
            if (skipped > 0) {
                report(ngettext("%u file was skipped because it is not a supported image or is already in the list.",
                    "%u files were skipped because they are not supported images or are already in the list.",
                    skipped).printf(skipped));
            }
        }

        // Shows a toast when a controller reports an error.
        private void report(string? error)
        {
            if (error != null) {
                toast_overlay.add_toast(new Adw.Toast(error));
            }
        }
    }
}
