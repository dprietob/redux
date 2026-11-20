using Redux.Conversion;

namespace Redux.Tests {

    private ConversionResult build_result(bool succeeded, int64 original_size, int64 output_size)
    {
        return new ConversionResult() {
                   succeeded = succeeded,
                   original_size = original_size,
                   output_size = output_size
        };
    }

    public void register_build_conversion_report_action_tests()
    {
        Test.add_func("/conversion/report/totals-only-count-converted-images", () => {
            ConversionResult[] results = {
                build_result(true, 1000, 400),
                build_result(true, 3000, 600),
                build_result(false, 5000, 0),
            };
            var report = new BuildConversionReportAction().execute(results, null, false, 12.5);

            assert_cmpuint(report.converted_count, CompareOperator.EQ, 2);
            assert_cmpuint(report.failed_count, CompareOperator.EQ, 1);
            assert_true(report.original_total_size == 4000);
            assert_true(report.output_total_size == 1000);
            assert_true(report.saved_size == 3000);
            assert_cmpfloat(report.reduction_percentage, CompareOperator.EQ, 75.0);
            assert_cmpuint(report.results.get_n_items(), CompareOperator.EQ, 3);
        });

        Test.add_func("/conversion/report/grown-images-save-negative-space", () => {
            ConversionResult[] results = { build_result(true, 1000, 1200) };
            var report = new BuildConversionReportAction().execute(results, null, true, 0);

            assert_true(report.saved_size == -200);
            assert_cmpfloat(report.reduction_percentage, CompareOperator.EQ, -20.0);
            assert_true(report.cancelled);
        });

        Test.add_func("/conversion/report/notifies-only-long-finished-conversions", () => {
            var action = new CheckCompletionNotificationAction();
            ConversionResult[] results = { build_result(true, 1000, 400) };
            var builder = new BuildConversionReportAction();

            var long_report = builder.execute(results, null, false, ConversionSettings.NOTIFICATION_MINIMUM_SECONDS);
            assert_true(action.execute(long_report, true));
            assert_false(action.execute(long_report, false));
            assert_false(action.execute(builder.execute(results, null, false, 2), true));
            assert_false(action.execute(builder.execute(results, null, true, 60), true));
        });
    }
}
