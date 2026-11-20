namespace Redux.Conversion {

    // Summarizes the results of a conversion into a report with the totals of
    // the converted images.
    public class BuildConversionReportAction : Object
    {

        private SizeReductionService size_reduction_service;

        public BuildConversionReportAction ()
        {
            size_reduction_service = new SizeReductionService();
        }

        public ConversionReport execute(ConversionResult[] results, File? output_directory, bool cancelled,
            double duration_seconds)
        {
            var report = new ConversionReport() {
                output_directory = output_directory,
                cancelled = cancelled,
                duration_seconds = duration_seconds
            };

            foreach (var result in results) {
                report.results.append(result);
                if (!result.succeeded) {
                    report.failed_count++;
                    continue;
                }
                report.converted_count++;
                report.original_total_size += result.original_size;
                report.output_total_size += result.output_size;
            }

            report.saved_size = report.original_total_size - report.output_total_size;
            report.reduction_percentage = size_reduction_service.reduction_percentage(report.original_total_size,
                    report.output_total_size);
            return report;
        }
    }
}
