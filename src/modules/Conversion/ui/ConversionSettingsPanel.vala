namespace Redux.Conversion {

    // Form with the conversion options. Every widget is bound to the
    // conversion settings, and only the rows that apply to the chosen format
    // and resize mode are shown.
    [GtkTemplate(ui = "/io/github/dprietob/redux/ui/conversion-settings-panel.ui")]
    public class ConversionSettingsPanel : Adw.NavigationPage
    {

        [GtkChild]
        private unowned Adw.ActionRow output_directory_row;
        [GtkChild]
        private unowned Adw.ComboRow format_row;
        [GtkChild]
        private unowned Adw.SpinRow quality_row;
        [GtkChild]
        private unowned Adw.SpinRow compression_row;
        [GtkChild]
        private unowned Adw.ExpanderRow resize_row;
        [GtkChild]
        private unowned Adw.ComboRow resize_mode_row;
        [GtkChild]
        private unowned Adw.SwitchRow keep_aspect_ratio_row;
        [GtkChild]
        private unowned Adw.SpinRow width_row;
        [GtkChild]
        private unowned Adw.SpinRow height_row;
        [GtkChild]
        private unowned Adw.SpinRow width_percentage_row;
        [GtkChild]
        private unowned Adw.SpinRow height_percentage_row;
        [GtkChild]
        private unowned Adw.ComboRow metadata_mode_row;
        [GtkChild]
        private unowned Adw.ExpanderRow rename_row;
        [GtkChild]
        private unowned Adw.EntryRow pattern_row;
        [GtkChild]
        private unowned Adw.EntryRow prefix_row;
        [GtkChild]
        private unowned Adw.EntryRow suffix_row;
        [GtkChild]
        private unowned Adw.SpinRow start_number_row;
        [GtkChild]
        private unowned Adw.SpinRow digits_row;
        [GtkChild]
        private unowned Adw.ActionRow preview_row;
        [GtkChild]
        private unowned Adw.SwitchRow notify_row;

        private const string[] RENAME_PROPERTIES = {
            "rename-pattern", "rename-prefix", "rename-suffix", "rename-start-number", "rename-digits", "output-format",
        };

        private ConversionController controller;
        private ConversionSettings settings;

        public ConversionSettingsPanel (ConversionController controller)
        {
            this.controller = controller;
            settings = controller.conversion_settings;
            bind_widgets();
            install_placeholder_action();

            settings.notify["output-directory-display-path"].connect(() => refresh_output_directory());
            settings.notify["output-format"].connect(() => refresh_format_rows());
            settings.notify["resize-mode"].connect(() => refresh_resize_rows());
            settings.notify["keep-aspect-ratio"].connect(() => refresh_resize_rows());
            settings.notify["metadata-mode"].connect(() => refresh_metadata_row());
            foreach (var property_name in RENAME_PROPERTIES) {
                settings.notify[property_name].connect(() => refresh_preview());
            }

            refresh_output_directory();
            refresh_format_rows();
            refresh_resize_rows();
            refresh_metadata_row();
            refresh_preview();
        }

        private void bind_widgets()
        {
            var flags = BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE;

            bind_enum_to_selection("output-format", format_row);
            settings.bind_property("quality", quality_row, "value", flags);
            settings.bind_property("compression-level", compression_row, "value", flags);
            settings.bind_property("resize-enabled", resize_row, "enable-expansion", flags);
            bind_enum_to_selection("resize-mode", resize_mode_row);
            settings.bind_property("keep-aspect-ratio", keep_aspect_ratio_row, "active", flags);
            settings.bind_property("width", width_row, "value", flags);
            settings.bind_property("height", height_row, "value", flags);
            settings.bind_property("width-percentage", width_percentage_row, "value", flags);
            settings.bind_property("height-percentage", height_percentage_row, "value", flags);
            bind_enum_to_selection("metadata-mode", metadata_mode_row);
            settings.bind_property("rename-enabled", rename_row, "enable-expansion", flags);
            settings.bind_property("rename-pattern", pattern_row, "text", flags);
            settings.bind_property("rename-prefix", prefix_row, "text", flags);
            settings.bind_property("rename-suffix", suffix_row, "text", flags);
            settings.bind_property("rename-start-number", start_number_row, "value", flags);
            settings.bind_property("rename-digits", digits_row, "value", flags);
            settings.bind_property("notify-when-finished", notify_row, "active", flags);
            notify_row.subtitle = _("Send a notification when a conversion takes longer than %d seconds").printf(
                ConversionSettings.NOTIFICATION_MINIMUM_SECONDS);
        }

        // Lets the placeholder menu insert its placeholder at the cursor of the
        // pattern entry.
        private void install_placeholder_action()
        {
            var insert_action = new SimpleAction("insert-placeholder", VariantType.STRING);
            insert_action.activate.connect((parameter) => {
                var position = pattern_row.get_position();
                pattern_row.insert_text(parameter.get_string(), -1, ref position);
                pattern_row.set_position(position);
                pattern_row.grab_focus();
            });

            var actions = new SimpleActionGroup();
            actions.add_action(insert_action);
            insert_action_group("rename", actions);
        }

        // Shows the name a sample photo would get, or why the options are not valid.
        private void refresh_preview()
        {
            string preview;
            var error = controller.preview_file_name(out preview);
            preview_row.subtitle = error ?? preview;
            if (error != null) {
                preview_row.add_css_class("error");
            } else {
                preview_row.remove_css_class("error");
            }
        }

        // Binds an enum setting to a combo row whose items follow the enum order.
        private void bind_enum_to_selection(string property_name, Adw.ComboRow row)
        {
            settings.bind_property(property_name, row, "selected",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
                (binding, source, ref target) => {
                target.set_uint((uint) source.get_enum());
                return true;
            },
                (binding, source, ref target) => {
                target.set_enum((int) source.get_uint());
                return true;
            });
        }

        private void refresh_output_directory()
        {
            output_directory_row.subtitle = settings.output_directory != null
                ? settings.output_directory_display_path
                : _("No folder selected");
        }

        // Lossy formats use a quality factor; PNG uses a compression level.
        private void refresh_format_rows()
        {
            var uses_quality = settings.output_format.uses_quality();
            quality_row.visible = uses_quality;
            compression_row.visible = !uses_quality;
        }

        private void refresh_metadata_row()
        {
            switch (settings.metadata_mode) {
            case Metadata.MetadataMode.KEEP_EXIF:
                metadata_mode_row.subtitle =
                    _("EXIF data such as the camera and date is kept; XMP, IPTC and comments are removed");
                break;

            case Metadata.MetadataMode.PER_IMAGE:
                metadata_mode_row.subtitle =
                    _("Use the metadata button of each image. Images you do not edit keep all their metadata");
                break;

            default:
                metadata_mode_row.subtitle = _("EXIF, XMP, IPTC and comments are removed from every image");
                break;
            }
        }

        private void refresh_resize_rows()
        {
            var in_pixels = settings.resize_mode == ResizeMode.PIXELS;
            var keep_aspect_ratio = settings.keep_aspect_ratio;

            width_row.visible = in_pixels;
            height_row.visible = in_pixels;
            width_percentage_row.visible = !in_pixels;
            height_percentage_row.visible = !in_pixels && !keep_aspect_ratio;

            var pixels_subtitle = keep_aspect_ratio ? _("Pixels, maximum size; 0 adapts to the other side") : _(
                "Pixels");
            width_row.subtitle = pixels_subtitle;
            height_row.subtitle = pixels_subtitle;

            width_percentage_row.title = keep_aspect_ratio ? _("Scale") : _("Width");
            width_percentage_row.subtitle = keep_aspect_ratio
                ? _("Percentage of the original size")
                : _("Percentage of the original width");
        }
    }
}
