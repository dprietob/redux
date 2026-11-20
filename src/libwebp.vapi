// Minimal binding for the simple encoding API of libwebp (webp/encode.h).
[CCode (cheader_filename = "webp/encode.h")]
namespace WebP {
    // Encodes packed 8-bit RGB pixels as lossy WebP. Returns the size of the
    // encoded buffer, or zero on failure. The buffer must be released with free().
    [CCode (cname = "WebPEncodeRGB")]
    public size_t encode_rgb([CCode (array_length = false)] uint8[] pixels, int width, int height, int stride,
        float quality_factor, out uint8 * output);

    // Encodes packed 8-bit RGBA pixels as lossy WebP, preserving transparency.
    [CCode (cname = "WebPEncodeRGBA")]
    public size_t encode_rgba([CCode (array_length = false)] uint8[] pixels, int width, int height, int stride,
        float quality_factor, out uint8 * output);

    // Releases a buffer allocated by the encoder.
    [CCode (cname = "WebPFree")]
    public void free(void * pointer);
}
