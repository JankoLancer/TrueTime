abstract class CacheInterface {
  static const String KEY_CACHED_BOOT_TIME =
      "com.instacart.library.truetime.cached_boot_time";
  static const String KEY_CACHED_DEVICE_UPTIME =
      "com.instacart.library.truetime.cached_device_uptime";
  static const String KEY_CACHED_SNTP_TIME =
      "com.instacart.library.truetime.cached_sntp_time";

  void put(String key, int value);

  int get(String key, int defaultValue);

  void clear();
}
