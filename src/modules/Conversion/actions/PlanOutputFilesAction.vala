using Redux.Images;

namespace Redux.Conversion {

    // Decides the converted file of every image before the conversion starts,
    // so the numbering follows the order of the list.
    public class PlanOutputFilesAction : Object
    {

        private OutputPathService output_path_service;

        public PlanOutputFilesAction ()
        {
            output_path_service = new OutputPathService();
        }

        public File[] execute(SourceImage[] images, ConversionSettings settings) throws Error
        {
            return output_path_service.target_files(images, settings);
        }
    }
}
