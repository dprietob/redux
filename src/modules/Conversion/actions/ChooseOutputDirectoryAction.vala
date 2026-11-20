using Redux.Images;

namespace Redux.Conversion {

    // Sets the folder the converted images are written to, together with the
    // location shown to the user.
    public class ChooseOutputDirectoryAction : Object
    {

        private FileLocationService file_location_service;

        public ChooseOutputDirectoryAction ()
        {
            file_location_service = new FileLocationService();
        }

        public void execute(ConversionSettings settings, File directory)
        {
            settings.output_directory = directory;
            settings.output_directory_display_path = file_location_service.display_path(directory);
        }
    }
}
