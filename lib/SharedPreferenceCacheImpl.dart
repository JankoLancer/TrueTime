import 'package:TrueTime/CacheInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceCacheImpl implements CacheInterface {
  static const String KEY_CACHED_SHARED_PREFS =
      "com.instacart.library.truetime.shared_preferences";

  static SharedPreferences _sharedPreferences;
  static SharedPreferenceCacheImpl _instance;

  SharedPreferenceCacheImpl();

  static Future<SharedPreferenceCacheImpl> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferenceCacheImpl();
    }

    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }

  @override
  void put(String key, int value) {
    _sharedPreferences.setInt(key, value);
  }

  @override
  int get(String key, int defaultValue) {
    return _sharedPreferences.getInt(key) ?? defaultValue;
  }

  @override
  void clear() {
    _remove(CacheInterface.KEY_CACHED_BOOT_TIME);
    _remove(CacheInterface.KEY_CACHED_DEVICE_UPTIME);
    _remove(CacheInterface.KEY_CACHED_SNTP_TIME);
  }

  void _remove(String key) {
    _sharedPreferences.remove(key);
  }
}
