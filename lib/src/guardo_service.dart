import 'package:local_auth/local_auth.dart';
import 'guardo_config.dart';

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

  /// Authenticates the user using biometrics
  ///
  /// Returns `true` if authentication was successful, `false` otherwise
  /// Throws an exception if biometrics are not available
  Future<bool> authenticate() async {
    final canCheck = await canCheckBiometrics;
    if (!canCheck) {
      throw Exception(
        "Biometric authentication is not available on this device",
      );
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: _config.localizedReason,
        options: _config.authenticationOptions,
      );
      return authenticated;
    } catch (e) {
      throw Exception("Authentication failed: $e");
    }
  }

  /// Stops any ongoing authentication
  Future<bool> stopAuthentication() => _localAuth.stopAuthentication();

  /// Gets the current configuration
  GuardoConfig get config => _config;
}
