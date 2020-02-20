import 'package:TrueTime/SntpClient.dart';
import 'package:TrueTime/TrueLog.dart';
import 'package:uptime/uptime.dart';

import 'CacheInterface.dart';

class DiskCacheClient {
  static const String KEY_CACHED_BOOT_TIME =
      "com.instacart.library.truetime.cached_boot_time";
  static const String KEY_CACHED_DEVICE_UPTIME =
      "com.instacart.library.truetime.cached_device_uptime";
  static const String KEY_CACHED_SNTP_TIME =
      "com.instacart.library.truetime.cached_sntp_time";
  static final String TAG = "DiskCacheClient";

  CacheInterface _cacheInterface;

  /// Provide your own cache interface to cache the true time information.
  /// @param cacheInterface the customized cache interface to save the true time data.
  void enableCacheInterface(CacheInterface cacheInterface) {
    this._cacheInterface = cacheInterface;
  }

  /// Clear the cache cache when the device is rebooted.
  /// @param cacheInterface the customized cache interface to save the true time data.
  void clearCachedInfo() {
    if (_cacheInterface != null) {
      _cacheInterface.clear();
    }
  }

  void cacheTrueTimeInfo(SntpClient sntpClient) {
    if (_cacheUnavailable()) {
      return;
    }

    int cachedSntpTime = sntpClient.getCachedSntpTime();
    int cachedDeviceUptime = sntpClient.getCachedDeviceUptime();
    int bootTime = cachedSntpTime - cachedDeviceUptime;

    TrueLog.d(TAG,
        "Caching true time info to disk sntp [$cachedSntpTime] device [$cachedDeviceUptime] boot [$bootTime]");

    _cacheInterface.put(KEY_CACHED_BOOT_TIME, bootTime);
    _cacheInterface.put(KEY_CACHED_DEVICE_UPTIME, cachedDeviceUptime);
    _cacheInterface.put(KEY_CACHED_SNTP_TIME, cachedSntpTime);
  }

  Future<bool> isTrueTimeCachedFromAPreviousBoot() async {
    if (_cacheUnavailable()) {
      return false;
    }

    int cachedBootTime = _cacheInterface.get(KEY_CACHED_BOOT_TIME, 0);
    if (cachedBootTime == 0) {
      return false;
    }

    // has boot time changed (simple check)
    bool bootTimeChanged = await Uptime.uptime < getCachedDeviceUptime();
    if (bootTimeChanged) {
      clearCachedInfo();
    }
    TrueLog.i(TAG, "---- boot time changed " + bootTimeChanged.toString());
    return !bootTimeChanged;
  }

  int getCachedDeviceUptime() {
    if (_cacheUnavailable()) {
      return 0;
    }

    return _cacheInterface.get(KEY_CACHED_DEVICE_UPTIME, 0);
  }

  int getCachedSntpTime() {
    if (_cacheUnavailable()) {
      return 0;
    }

    return _cacheInterface.get(KEY_CACHED_SNTP_TIME, 0);
  }

  // -----------------------------------------------------------------------------------

  bool _cacheUnavailable() {
    if (_cacheInterface == null) {
      TrueLog.w(TAG,
          "Cannot use disk caching strategy for TrueTime. CacheInterface unavailable");
      return true;
    }
    return false;
  }
}
