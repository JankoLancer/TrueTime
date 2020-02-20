library TrueTime;

import 'package:TrueTime/CacheInterface.dart';
import 'package:TrueTime/DiskCacheClient.dart';
import 'package:TrueTime/SharedPreferenceCacheImpl.dart';
import 'package:TrueTime/SntpClient.dart';
import 'package:TrueTime/TrueLog.dart';
import 'package:uptime/uptime.dart';

class TrueTime {
    static final String TAG = "TrueTime";
    static final DiskCacheClient _DISK_CACHE_CLIENT = new DiskCacheClient();
    static final SntpClient _SNTP_CLIENT = new SntpClient();

    static TrueTime _instance = new TrueTime();
    static double _rootDelayMax = 100;
    static double _rootDispersionMax = 100;
    static int _serverResponseDelayMax = 750;
    static int _udpSocketTimeoutInMillis = 30000;

    String _ntpHost = "1.us.pool.ntp.org";

    static Future<TrueTime> getInstance() async {
      if (_instance == null) {
        _instance = TrueTime();
      }

      return _instance;
    }

    /// @return Date object that returns the current time in the default Timezone
    static Future<DateTime> now() async {
        if (!(await isInitialized())) {
            throw Exception("You need to call init() on TrueTime at least once.");
        }

        int cachedSntpTime = _getCachedSntpTime();
        int cachedDeviceUptime = _getCachedDeviceUptime();
        int deviceUptime = await Uptime.uptime;
        int now = cachedSntpTime + (deviceUptime - cachedDeviceUptime);

        return DateTime.fromMillisecondsSinceEpoch(now);
    }

    static Future<bool> isInitialized() async {
        return _SNTP_CLIENT.wasInitialized() || await _DISK_CACHE_CLIENT.isTrueTimeCachedFromAPreviousBoot();
    }

    static TrueTime build() {
        return _instance;
    }

    /// Cache TrueTime initialization information in SharedPreferences
    /// This can help avoid additional TrueTime initialization on app kills
    Future<TrueTime> withSharedPreferencesCache() async {
        _DISK_CACHE_CLIENT.enableCacheInterface(await SharedPreferenceCacheImpl.getInstance());
        return _instance;
    }

    /// Customized TrueTime Cache implementation.
    TrueTime withCustomizedCache(CacheInterface cacheInterface) {
        _DISK_CACHE_CLIENT.enableCacheInterface(cacheInterface);
        return _instance;
    }

    /// clear the cached TrueTime info on device reboot.
    static void clearCachedInfo() {
        _DISK_CACHE_CLIENT.clearCachedInfo();
    }

    TrueTime withConnectionTimeout(int timeoutInMillis) {
        _udpSocketTimeoutInMillis = timeoutInMillis;
        return _instance;
    }

    TrueTime withRootDelayMax(double rootDelayMax) {
        if (rootDelayMax > _rootDelayMax) {
          String log = 
              "The recommended max rootDelay value is $_rootDelayMax. You are setting it at $rootDelayMax";
          TrueLog.w(TAG, log);
        }

        _rootDelayMax = rootDelayMax;
        return _instance;
    }

    TrueTime withRootDispersionMax(double rootDispersionMax) {
      if (rootDispersionMax > _rootDispersionMax) {
        String log = 
            "The recommended max rootDispersion value is $_rootDispersionMax. You are setting it at $rootDispersionMax";
        TrueLog.w(TAG, log);
      }

      _rootDispersionMax = rootDispersionMax;
      return _instance;
    }

    TrueTime withServerResponseDelayMax(int serverResponseDelayInMillis) {
        _serverResponseDelayMax = serverResponseDelayInMillis;
        return _instance;
    }

    TrueTime withNtpHost(String ntpHost) {
        _ntpHost = ntpHost;
        return _instance;
    }

    TrueTime withLoggingEnabled(bool isLoggingEnabled) {
        TrueLog.setLoggingEnabled(isLoggingEnabled);
        return _instance;
    }

    // -----------------------------------------------------------------------------------

    Future<void> initialize(String ntpHost) async {
        if (await isInitialized()) {
            TrueLog.i(TAG, "---- TrueTime already initialized from previous boot/init");
            return;
        }

        await requestTime(ntpHost);
        saveTrueTimeInfoToDisk();
    }

    Future<List<int>> requestTime(String ntpHost) async {
        return await _SNTP_CLIENT.requestTime(ntpHost,
            _rootDelayMax,
            _rootDispersionMax,
            _serverResponseDelayMax,
            _udpSocketTimeoutInMillis);
    }

    static void saveTrueTimeInfoToDisk() {
        if (!_SNTP_CLIENT.wasInitialized()) {
            TrueLog.i(TAG, "---- SNTP client not available. not caching TrueTime info in disk");
            return;
        }
        _DISK_CACHE_CLIENT.cacheTrueTimeInfo(_SNTP_CLIENT);
    }

    static int _getCachedDeviceUptime() {
        int cachedDeviceUptime = _SNTP_CLIENT.wasInitialized()
                                  ? _SNTP_CLIENT.getCachedDeviceUptime()
                                  : _DISK_CACHE_CLIENT.getCachedDeviceUptime();

        if (cachedDeviceUptime == 0) {
            throw new Exception("expected device time from last boot to be cached. couldn't find it.");
        }

        return cachedDeviceUptime;
    }

    static int _getCachedSntpTime() {
        int cachedSntpTime = _SNTP_CLIENT.wasInitialized()
                              ? _SNTP_CLIENT.getCachedSntpTime()
                              : _DISK_CACHE_CLIENT.getCachedSntpTime();

        if (cachedSntpTime == 0) {
            throw new Exception("expected SNTP time from last boot to be cached. couldn't find it.");
        }

        return cachedSntpTime;
    }
}
