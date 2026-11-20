namespace Redux.Conversion {

    // Measures how much smaller a converted file is than the original one.
    public class SizeReductionService : Object
    {

        // Returns the percentage of the original size that was saved. It is
        // negative when the output grew, and zero when there was no original.
        public double reduction_percentage(int64 original_size, int64 output_size)
        {
            if (original_size <= 0) {
                return 0;
            }
            return (double) (original_size - output_size) * 100.0 / (double) original_size;
        }
    }
}
