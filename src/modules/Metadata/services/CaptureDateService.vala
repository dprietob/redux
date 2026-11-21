namespace Redux.Metadata {

    // Finds when a photo was taken: the EXIF capture date when there is one,
    // otherwise the date the file was last modified.
    public class CaptureDateService : Object
    {

        private const string[] DATE_TAGS = {
            "Exif.Photo.DateTimeOriginal",
            "Exif.Photo.DateTimeDigitized",
            "Exif.Image.DateTime",
        };

        public DateTime capture_date(File file) throws Error
        {
            return exif_date(file) ?? modification_date(file);
        }

        // Returns null when the image has no readable EXIF date. Images whose
        // metadata cannot be read at all simply fall back to the file date.
        private DateTime? exif_date(File file)
        {
            try {
                var metadata = new GExiv2.Metadata();
                metadata.open_path(file.get_path());
                foreach (var key in DATE_TAGS) {
                    if (MetadataLibraryService.has_tag(metadata, key)) {
                        var date = parse_exif_date(MetadataLibraryService.tag_string(metadata, key));
                        if (date != null) {
                            return date;
                        }
                    }
                }
            } catch (Error error) {
                debug("No EXIF date for %s: %s", file.get_uri(), error.message);
            }
            return null;
        }

        // EXIF dates look like "2026:05:01 10:30:00" and carry no time zone,
        // so they are read as local time.
        private DateTime? parse_exif_date(string? text)
        {
            int year = 0, month = 0, day = 0, hour = 0, minute = 0, second = 0;
            if (text == null || text.scanf("%d:%d:%d %d:%d:%d", &year, &month, &day, &hour, &minute, &second) != 6) {
                return null;
            }
            return new DateTime.local(year, month, day, hour, minute, second);
        }

        private DateTime modification_date(File file) throws Error
        {
            var info = file.query_info(FileAttribute.TIME_MODIFIED, FileQueryInfoFlags.NONE);
            return info.get_modification_date_time().to_local();
        }
    }
}
