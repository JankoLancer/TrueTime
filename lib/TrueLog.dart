import 'package:logger/logger.dart';

class TrueLog {
  static bool loggingEnabled = false;
  static Logger logger = Logger();

  static void v(String tag, String msg) {
    if (loggingEnabled) {
      logger.v(tag, msg);
    }
  }

  static void d(String tag, String msg) {
    if (loggingEnabled) {
      logger.d(tag, msg);
    }
  }

  static void i(String tag, String msg) {
    if (loggingEnabled) {
      logger.i(tag, msg);
    }
  }

  static void w(String tag, String msg) {
    if (loggingEnabled) {
      logger.w(tag, msg);
    }
  }

  static void e(String tag, String msg) {
    if (loggingEnabled) {
      logger.e(tag, msg);
    }
  }

  static void wtf(String tag, String msg) {
    if (loggingEnabled) {
      logger.wtf(tag, msg);
    }
  }

  static void setLoggingEnabled(bool isLoggingEnabled) {
    loggingEnabled = isLoggingEnabled;
  }
}
