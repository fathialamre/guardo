import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'guardo_config.dart';

/// Base class for all Guardo-related exceptions
abstract class GuardoException implements Exception {
  final String message;
  final String? code;

  const GuardoException(this.message, [this.code]);

  @override
  String toString() => 'GuardoException: $message';
}

/// Exception thrown when biometric authentication is temporarily locked out
class BiometricLockoutException extends GuardoException {
  const BiometricLockoutException(super.message, [super.code]);

  @override
  String toString() => 'BiometricLockoutException: $message';
}

/// Exception thrown when biometric authentication is not available
class BiometricUnavailableException extends GuardoException {
  const BiometricUnavailableException(super.message, [super.code]);

  @override
  String toString() => 'BiometricUnavailableException: $message';
}

/// Exception thrown when authentication fails permanently
class AuthenticationFailedException extends GuardoException {
  const AuthenticationFailedException(super.message, [super.code]);

  @override
  String toString() => 'AuthenticationFailedException: $message';
}

/// Service class that handles biometric authentication
class GuardoService {
  final LocalAuthentication _localAuth;
  final GuardoConfig _config;

  GuardoService({GuardoConfig? config, LocalAuthentication? localAuth})
    : _config = config ?? const GuardoConfig(),
      _localAuth = localAuth ?? LocalAuthentication();

  /// Checks if biometric authentication is available on the device
  Future<bool> get canCheckBiometrics => _localAuth.canCheckBiometrics;

  /// Gets the list of available biometric types
  Future<List<BiometricType>> get availableBiometrics =>
      _localAuth.getAvailableBiometrics();

  /// Checks if the device is enrolled with biometrics
  Future<bool> get isDeviceSupported => _localAuth.isDeviceSupported();

  /// Gets the current configuration
  GuardoConfig get config => _config;

  /// Authenticates the user using biometrics
  ///
  /// Returns `true` if authentication was successful, `false` otherwise
  ///
  /// Throws:
  /// - [BiometricUnavailableException] if biometrics are not available
  /// - [BiometricLockoutException] if biometrics are temporarily locked out
  /// - [AuthenticationFailedException] if authentication fails permanently
  Future<bool> authenticate({bool allowFallback = false}) async {
    final canCheck = await canCheckBiometrics;
    if (!canCheck) {
      throw const BiometricUnavailableException(
        "Biometric authentication is not available on this device",
      );
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: _config.localizedReason,
        options: _config.authenticationOptions,
      );
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint("Authentication CODE: ${e.code}");
      debugPrint("Authentication MESSAGE: ${e.message}");
      debugPrint("Authentication DETAILS: ${e.details}");

      // Handle permanent lockout by automatically trying device credentials
      if (e.code == 'PermanentlyLockedOut') {
        debugPrint(
          "🔒 Biometrics permanently locked out, automatically trying device credentials...",
        );
        try {
          final deviceAuthResult = await authenticateWithDeviceCredentials();
          if (deviceAuthResult) {
            debugPrint("✅ Device credential authentication successful");
            return true;
          }
          return false;
        } catch (deviceAuthError) {
          debugPrint(
            "❌ Device credential authentication failed: $deviceAuthError",
          );
          throw AuthenticationFailedException(
            "Biometric authentication is permanently disabled. "
            "Device credential authentication also failed: ${deviceAuthError.toString().replaceAll('Exception: ', '')}",
            e.code,
          );
        }
      }

      // Handle temporary lockout error by throwing a specific exception
      if (e.code == 'LockedOut' || e.code == 'ERROR_LOCKOUT') {
        debugPrint(
          "🔒 Biometrics temporarily locked out, throwing lockout exception...",
        );
        throw BiometricLockoutException(
          "Biometric authentication is temporarily disabled due to too many failed attempts. Please try again later.",
          e.code,
        );
      }

      throw AuthenticationFailedException(
        e.message ?? 'Unknown authentication error',
        e.code,
      );
    } catch (e) {
      throw AuthenticationFailedException("Authentication failed: $e");
    }
  }

  /// Authenticates using device credentials (PIN/Pattern/Password) only
  /// This is useful when biometrics are locked out
  ///
  /// Throws [AuthenticationFailedException] if device authentication fails
  Future<bool> authenticateWithDeviceCredentials() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason:
            "Biometric authentication is temporarily disabled. Please enter your device PIN, pattern, or password to unlock.",
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint("Device Authentication CODE: ${e.code}");
      debugPrint("Device Authentication MESSAGE: ${e.message}");
      throw AuthenticationFailedException(
        e.message ?? 'Device authentication failed',
        e.code,
      );
    } catch (e) {
      throw AuthenticationFailedException("Device authentication failed: $e");
    }
  }

  /// Stops any ongoing authentication
  Future<bool> stopAuthentication() => _localAuth.stopAuthentication();
}
