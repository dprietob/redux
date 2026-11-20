using Redux.Conversion;

namespace Redux.Tests {

    public void register_size_reduction_service_tests()
    {
        Test.add_func("/conversion/size-reduction/smaller-output", () => {
            assert_cmpfloat(new SizeReductionService().reduction_percentage(1000, 250), CompareOperator.EQ, 75.0);
        });

        Test.add_func("/conversion/size-reduction/larger-output-is-negative", () => {
            assert_cmpfloat(new SizeReductionService().reduction_percentage(1000, 1500), CompareOperator.EQ, -50.0);
        });

        Test.add_func("/conversion/size-reduction/empty-original", () => {
            assert_cmpfloat(new SizeReductionService().reduction_percentage(0, 100), CompareOperator.EQ, 0.0);
        });
    }
}
