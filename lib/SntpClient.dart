import 'dart:io';

import 'package:TrueTime/TrueLog.dart';
import 'package:ntp/ntp.dart';
import 'package:uptime/uptime.dart';

class SntpClient {
  static const int RESPONSE_INDEX_ORIGINATE_TIME = 0;
  static const int RESPONSE_INDEX_RECEIVE_TIME = 1;
  static const int RESPONSE_INDEX_TRANSMIT_TIME = 2;
  static const int RESPONSE_INDEX_RESPONSE_TIME = 3;
  static const int RESPONSE_INDEX_ROOT_DELAY = 4;
  static const int RESPONSE_INDEX_DISPERSION = 5;
  static const int RESPONSE_INDEX_STRATUM = 6;
  static const int RESPONSE_INDEX_RESPONSE_TICKS = 7;
  static const int RESPONSE_INDEX_SIZE = 8;

  static const String TAG = "SntpClient";

  static const int NTP_PORT = 123;
  static const int NTP_MODE = 3;
  static const int NTP_VERSION = 3;
  static const int NTP_PACKET_SIZE = 48;

  static const int INDEX_VERSION = 0;
  static const int INDEX_ROOT_DELAY = 4;
  static const int INDEX_ROOT_DISPERSION = 8;
  static const int INDEX_ORIGINATE_TIME = 24;
  static const int INDEX_RECEIVE_TIME = 32;
  static const int INDEX_TRANSMIT_TIME = 40;

  // 70 years plus 17 leap days
  static const int OFFSET_1900_TO_1970 = ((365 * 70) + 17) * 24 * 60 * 60;

  int _cachedDeviceUptime;
  int _cachedSntpTime;
  bool _sntpInitialized = false;

  /// See δ :
  /// https://en.wikipedia.org/wiki/Network_Time_Protocol#Clock_synchronization_algorithm
  static int getRoundTripDelay(List<int> response) {
    return (response[RESPONSE_INDEX_RESPONSE_TIME] -
            response[RESPONSE_INDEX_ORIGINATE_TIME]) -
        (response[RESPONSE_INDEX_TRANSMIT_TIME] -
            response[RESPONSE_INDEX_RECEIVE_TIME]);
  }

  /// See θ :
  /// https://en.wikipedia.org/wiki/Network_Time_Protocol#Clock_synchronization_algorithm
  static int getClockOffset(List<int> response) {
    return ((response[RESPONSE_INDEX_RECEIVE_TIME] -
                response[RESPONSE_INDEX_ORIGINATE_TIME]) +
            (response[RESPONSE_INDEX_TRANSMIT_TIME] -
                response[RESPONSE_INDEX_RESPONSE_TIME])) ~/
        2;
  }

  /// Sends an NTP request to the given host and processes the response.
  /// @param ntpHost           host name of the server.
  Future<void> initialize(
      String ntpHost,
      double rootDelayMax,
      double rootDispersionMax,
      int serverResponseDelayMax,
      int timeoutInMillis) async {

    try {
      DateTime now = await NTP.now();
      int uptime = await Uptime.uptime;
      _sntpInitialized = true;
      cacheTrueTimeInfo(
          now.millisecondsSinceEpoch, uptime);
    } catch (e) {
      TrueLog.d(TAG, "---- SNTP request failed for " + ntpHost);
      throw e;
    }
  }

  void cacheTrueTimeInfo(sntpTime, deviceTime) {
    _cachedSntpTime = sntpTime;
    _cachedDeviceUptime = deviceTime;
  }

  bool wasInitialized() {
    return _sntpInitialized;
  }

  /// @return time value computed from NTP server response
  int getCachedSntpTime() {
    return _cachedSntpTime;
  }

  /// @return device uptime computed at time of executing the NTP request
  int getCachedDeviceUptime() {
    return _cachedDeviceUptime;
  }

  // // -----------------------------------------------------------------------------------
  // // private helpers

  // /**
  //  * Writes NTP version as defined in RFC-1305
  //  */
  // private void writeVersion(List<int> buffer) {
  //     // mode is in low 3 bits of first byte
  //     // version is in bits 3-5 of first byte
  //     buffer[INDEX_VERSION] = NTP_MODE | (NTP_VERSION << 3);
  // }

  /**
     * Writes system time (milliseconds since January 1, 1970)
     * as an NTP time stamp as defined in RFC-1305
     * at the given offset in the buffer
     */
  // void _writeTimeStamp(List<int> buffer, int offset, int time) {

  //     int seconds = time ~/ 1000;
  //     int milliseconds = time - seconds * 1000;

  //     // consider offset for number of seconds
  //     // between Jan 1, 1900 (NTP epoch) and Jan 1, 1970 (Java epoch)
  //     seconds += OFFSET_1900_TO_1970;

  //     // write seconds in big endian format
  //     buffer[offset++] = (byte) (seconds >> 24);
  //     buffer[offset++] = (byte) (seconds >> 16);
  //     buffer[offset++] = (byte) (seconds >> 8);
  //     buffer[offset++] = (byte) (seconds >> 0);

  //     int fraction = milliseconds * 0x100000000L / 1000L;

  //     // write fraction in big endian format
  //     buffer[offset++] = (byte) (fraction >> 24);
  //     buffer[offset++] = (byte) (fraction >> 16);
  //     buffer[offset++] = (byte) (fraction >> 8);

  //     // low order bits should be random data
  //     buffer[offset++] = (byte) (Math.random() * 255.0);
  // }

  // /**
  //  * @param offset offset index in buffer to start reading from
  //  * @return NTP timestamp in Java epoch
  //  */
  // private int readTimeStamp(List<int> buffer, int offset) {
  //     int seconds = read(buffer, offset);
  //     int fraction = read(buffer, offset + 4);

  //     return ((seconds - OFFSET_1900_TO_1970) * 1000) + ((fraction * 1000L) / 0x100000000L);
  // }

  // /**
  //  * Reads an unsigned 32 bit big endian number
  //  * from the given offset in the buffer
  //  *
  //  * @return 4 bytes as a 32-bit int (unsigned big endian)
  //  */
  // private int read(List<int> buffer, int offset) {
  //     byte b0 = buffer[offset];
  //     byte b1 = buffer[offset + 1];
  //     byte b2 = buffer[offset + 2];
  //     byte b3 = buffer[offset + 3];

  //     return ((int) ui(b0) << 24) +
  //            ((int) ui(b1) << 16) +
  //            ((int) ui(b2) << 8) +
  //            (int) ui(b3);
  // }

  // /***
  //  * Convert (signed) byte to an unsigned int
  //  *
  //  * Java only has signed types so we have to do
  //  * more work to get unsigned ops
  //  *
  //  * @param b input byte
  //  * @return unsigned int value of byte
  //  */
  // private int ui(byte b) {
  //     return b & 0xFF;
  // }

  // /**
  //  * Used for root delay and dispersion
  //  *
  //  * According to the NTP spec, they are in the NTP Short format
  //  * viz. signed 16.16 fixed point
  //  *
  //  * @param fix signed fixed point number
  //  * @return as a double in milliseconds
  //  */
  // private double doubleMillis(int fix) {
  //     return fix / 65.536D;
  // }
}
