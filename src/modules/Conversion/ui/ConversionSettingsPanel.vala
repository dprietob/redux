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

        private ConversionSettings settings;

        public ConversionSettingsPanel (ConversionSettings settings)
        {
            this.settings = settings;
            bind_widgets();

            settings.notify["output-directory"].connect(() => refresh_output_directory());
            settings.notify["output-format"].connect(() => refresh_format_rows());
            settings.notify["resize-mode"].connect(() => refresh_resize_rows());
            settings.notify["keep-aspect-ratio"].connect(() => refresh_resize_rows());

            refresh_output_directory();
            refresh_format_rows();
            refresh_resize_rows();
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
            var directory = settings.output_directory;
            output_directory_row.subtitle = directory != null ? directory.get_path() : _("No folder selected");
        }

        // Lossy formats use a quality factor; PNG uses a compression level.
        private void refresh_format_rows()
        {
            var uses_quality = settings.output_format.uses_quality();
            quality_row.visible = uses_quality;
            compression_row.visible = !uses_quality;
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
