import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kronos/flutter_kronos.dart';

class TimeManager {
  static const int maxOfflineSeconds = 8 * 60 * 60;
  static const int maxTimeDriftSeconds = 30;
  static const String timeSeedKey = 'time_seed';
  static const String lastTrustedTimeKey = 'last_trusted';
  static const String lastLocalTimeKey = 'last_local';

  int? _cachedNtpTime;
  int? _lastLocalTime;
  String? _timeSeedHash;
  bool _isWeb = false;

  Future<void> initialize() async {
    // Check if running on web platform
    _isWeb = kIsWeb;

    if (_isWeb) {
      // On web, use local time immediately
      _cachedNtpTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      // On mobile, try to use NTP
      try {
        // Call sync() but don't await - it's fire-and-forget
        try {
          FlutterKronos.sync();
        } catch (_) {
          // Ignore sync errors
        }

        // Try to get NTP time with timeout
        final ntpTime = await FlutterKronos.getCurrentTimeMs.timeout(
          Duration(seconds: 2),
          onTimeout: () => null,
        );

        if (ntpTime != null) {
          _cachedNtpTime = ntpTime;
        } else {
          _cachedNtpTime = DateTime.now().millisecondsSinceEpoch;
        }
      } on MissingPluginException catch (_) {
        // Plugin not available, fall back to local time
        _cachedNtpTime = DateTime.now().millisecondsSinceEpoch;
      } catch (e) {
        // Any other error, use local time
        _cachedNtpTime = DateTime.now().millisecondsSinceEpoch;
      }
    }

    _lastLocalTime = DateTime.now().millisecondsSinceEpoch;
    _timeSeedHash = await _generateTimeSeed();
  }

  Future<String> _generateTimeSeed() async {
    final ntpTime = await getTrustedTimeMillis();
    final seed = '${ntpTime}_${_generateRandomSalt()}';
    final bytes = utf8.encode(seed);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  String _generateRandomSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  Future<int> getTrustedTimeMillis() async {
    if (_isWeb) {
      // On web, just use local time
      return DateTime.now().millisecondsSinceEpoch;
    }

    try {
      final ntpTime = await FlutterKronos.getCurrentTimeMs.timeout(
        Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (ntpTime != null) {
        _cachedNtpTime = ntpTime;
        return ntpTime;
      }
    } on MissingPluginException {
      _isWeb = true;
      return DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      // Fall through to fallback
    }

    if (_cachedNtpTime != null) {
      final localNow = DateTime.now().millisecondsSinceEpoch;
      final localDiff = localNow - _lastLocalTime!;
      _cachedNtpTime = _cachedNtpTime! + localDiff;
      _lastLocalTime = localNow;
      return _cachedNtpTime!;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<TimeValidationResult> validateOfflineTime(
    int lastTrustedTime,
    int lastLocalTime,
  ) async {
    final nowTrusted = await getTrustedTimeMillis();
    final nowLocal = DateTime.now().millisecondsSinceEpoch;

    final trustedDiff = nowTrusted - lastTrustedTime;
    final localDiff = nowLocal - lastLocalTime;
    final drift = (trustedDiff - localDiff).abs() ~/ 1000;

    // On web, skip drift detection since we're using local time
    if (!_isWeb && drift > maxTimeDriftSeconds) {
      return TimeValidationResult(
        isValid: false,
        offlineSeconds: min(trustedDiff ~/ 1000, maxOfflineSeconds),
        wasManipulated: true,
      );
    }

    final offlineSeconds = trustedDiff ~/ 1000;
    final cappedSeconds = min(offlineSeconds, maxOfflineSeconds);

    return TimeValidationResult(
      isValid: true,
      offlineSeconds: cappedSeconds,
      wasManipulated: false,
    );
  }

  Future<Duration> calculateSafeOfflineTime(
    int lastTrustedTime,
    int lastLocalTime, {
    bool strictMode = false,
  }) async {
    final validation = await validateOfflineTime(
      lastTrustedTime,
      lastLocalTime,
    );

    if (!validation.isValid && strictMode) {
      return Duration.zero;
    }

    return Duration(seconds: validation.offlineSeconds);
  }

  Future<Map<String, int>> getCurrentTimeSnapshot() async {
    final trusted = await getTrustedTimeMillis();
    final local = DateTime.now().millisecondsSinceEpoch;

    return {'trusted': trusted, 'local': local};
  }

  bool verifyTimeSeed(String storedHash) {
    if (_timeSeedHash == null) return false;
    return _timeSeedHash == storedHash;
  }

  String? get currentTimeSeed => _timeSeedHash;
}

class TimeValidationResult {
  final bool isValid;
  final int offlineSeconds;
  final bool wasManipulated;

  TimeValidationResult({
    required this.isValid,
    required this.offlineSeconds,
    required this.wasManipulated,
  });
}
