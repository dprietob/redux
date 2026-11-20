namespace Redux.Conversion {

    // Shows how the rename options name a typical photo, numbered with the
    // first number and dated now.
    public class PreviewFileNameAction : Object
    {

        private const string SAMPLE_NAME = "IMG_1234";

        private FileNamePatternService file_name_pattern_service;

        public PreviewFileNameAction ()
        {
            file_name_pattern_service = new FileNamePatternService();
        }

        public string execute(ConversionSettings settings)
        {
            return file_name_pattern_service.file_name(settings, SAMPLE_NAME, settings.rename_start_number,
                       new DateTime.now_local());
        }
    }
}
