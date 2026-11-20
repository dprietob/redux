namespace Redux.Conversion {

    // Decides whether a finished conversion deserves a notification: only
    // long conversions, which the user may have stopped watching, and never
    // cancelled ones, since the user was there to cancel them.
    public class CheckCompletionNotificationAction : Object
    {

        public bool execute(ConversionReport report, bool notifications_enabled)
        {
            return notifications_enabled
                   && !report.cancelled
                   && report.duration_seconds >= ConversionSettings.NOTIFICATION_MINIMUM_SECONDS;
        }
    }
}
