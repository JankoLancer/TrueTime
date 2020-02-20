
class TrueLog {
    static bool LOGGING_ENABLED = false;

    static void v(String tag, String msg) {
        if (LOGGING_ENABLED) {
            // Log.v(tag, msg);
        }
    }

    static void d(String tag, String msg) {
        if (LOGGING_ENABLED) {
            // Log.d(tag, msg);
        }
    }

    static void i(String tag, String msg) {
        if (LOGGING_ENABLED) {
            // Log.i(tag, msg);
        }
    }

    static void w(String tag, String msg) {
        if (LOGGING_ENABLED) {
            // Log.w(tag, msg);
        }
    }


    static void e(String tag, String msg) {
        if (LOGGING_ENABLED) {
            // Log.e(tag, msg);
        }
    }

    static void wtf(String tag, String msg) {
        if (LOGGING_ENABLED) {
            // Log.wtf(tag, msg);
        }
    }

    

    static void setLoggingEnabled(bool isLoggingEnabled) {
        LOGGING_ENABLED = isLoggingEnabled;
    }
}