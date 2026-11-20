namespace Redux.Images {

    // Describes where a file is in a way the user recognizes. Inside Flatpak,
    // files chosen through the file portal live under /run/user/…/doc, so the
    // original location stored by the portal is shown instead.
    public class FileLocationService : Object
    {

        public const string HOST_PATH_ATTRIBUTE = "xattr::document-portal.host-path";

        // Returns the original path of the file, with the home folder shown
        // as "~".
        public string display_path(File file)
        {
            try {
                return display_path_from_info(file, file.query_info(HOST_PATH_ATTRIBUTE, FileQueryInfoFlags.NONE));
            } catch (Error error) {
                // Without the portal attribute the file's own path is already
                // the one the user knows.
                return shortened(file.get_path() ?? file.get_parse_name());
            }
        }

        // Same as display_path(), reusing file information that already
        // includes the host path attribute.
        public string display_path_from_info(File file, FileInfo info)
        {
            var host_path = info.get_attribute_string(HOST_PATH_ATTRIBUTE);
            return shortened(host_path ?? file.get_path() ?? file.get_parse_name());
        }

        private string shortened(string path)
        {
            var home = Environment.get_home_dir();
            if (path == home || path.has_prefix(home + "/")) {
                return "~" + path.substring(home.length);
            }
            return path;
        }
    }
}
