import 'package:flutter/material.dart';
import 'guardo_service.dart';
import 'guardo_config.dart';

/// Extension on BuildContext to provide convenient authentication helpers
extension GuardoExtensions on BuildContext {
  /// Protects an action with biometric authentication
  ///
  /// This method will prompt the user for biometric authentication and
  /// execute the appropriate callback based on the result.
  ///
  /// Example usage:
  /// ```dart
  /// context.secureAction(
  ///   onSuccess: () {
  ///     // Perform protected action
  ///     _deleteAccount();
  ///   },
  ///   onFailure: () {
  ///     // Handle authentication failure
  ///     _showErrorMessage('Authentication failed');
  ///   },
  ///   reason: 'Please authenticate to delete your account',
  /// );
  /// ```
  Future<void> secureAction({
    required VoidCallback onSuccess,
    VoidCallback? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    final effectiveConfig = config ?? const GuardoConfig();

    // Override the reason if provided
    final authConfig = reason != null
        ? effectiveConfig.copyWith(localizedReason: reason)
        : effectiveConfig;

    final authService = GuardoService(config: authConfig);

    try {
      final authenticated = await authService.authenticate();

      if (authenticated) {
        onSuccess();
      } else {
        onFailure?.call();
      }
    } catch (e) {
      onFailure?.call();
    }
  }

  /// Protects an action with biometric authentication and returns a result
  ///
  /// This method will prompt the user for biometric authentication and
  /// execute the appropriate callback based on the result, returning the result.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await context.guardoActionWithResult<String>(
  ///   onSuccess: () => 'Action completed successfully',
  ///   onFailure: () => 'Authentication failed',
  ///   reason: 'Please authenticate to perform this action',
  /// );
  /// ```
  Future<T?> guardoActionWithResult<T>({
    required T Function() onSuccess,
    T Function()? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    final effectiveConfig = config ?? const GuardoConfig();

    // Override the reason if provided
    final authConfig = reason != null
        ? effectiveConfig.copyWith(localizedReason: reason)
        : effectiveConfig;

    final authService = GuardoService(config: authConfig);

    try {
      final authenticated = await authService.authenticate();

      if (authenticated) {
        return onSuccess();
      } else {
        return onFailure?.call();
      }
    } catch (e) {
      return onFailure?.call();
    }
  }

  /// Protects an async action with biometric authentication
  ///
  /// This method will prompt the user for biometric authentication and
  /// execute the appropriate async callback based on the result.
  ///
  /// Example usage:
  /// ```dart
  /// await context.guardoAsyncAction(
  ///   onSuccess: () async {
  ///     // Perform protected async action
  ///     await _uploadSecureData();
  ///   },
  ///   onFailure: () async {
  ///     // Handle authentication failure
  ///     await _logAuthenticationFailure();
  ///   },
  ///   reason: 'Please authenticate to upload data',
  /// );
  /// ```
  Future<void> guardoAsyncAction({
    required Future<void> Function() onSuccess,
    Future<void> Function()? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    final effectiveConfig = config ?? const GuardoConfig();

    // Override the reason if provided
    final authConfig = reason != null
        ? effectiveConfig.copyWith(localizedReason: reason)
        : effectiveConfig;

    final authService = GuardoService(config: authConfig);

    try {
      final authenticated = await authService.authenticate();

      if (authenticated) {
        await onSuccess();
      } else {
        await onFailure?.call();
      }
    } catch (e) {
      await onFailure?.call();
    }
  }

  /// Protects an async action with biometric authentication and returns a result
  ///
  /// This method will prompt the user for biometric authentication and
  /// execute the appropriate async callback based on the result, returning the result.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await context.guardoAsyncActionWithResult<String>(
  ///   onSuccess: () async => await _fetchSecureData(),
  ///   onFailure: () async => 'Failed to authenticate',
  ///   reason: 'Please authenticate to access secure data',
  /// );
  /// ```
  Future<T?> guardoAsyncActionWithResult<T>({
    required Future<T> Function() onSuccess,
    Future<T> Function()? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    final effectiveConfig = config ?? const GuardoConfig();

    // Override the reason if provided
    final authConfig = reason != null
        ? effectiveConfig.copyWith(localizedReason: reason)
        : effectiveConfig;

    final authService = GuardoService(config: authConfig);

    try {
      final authenticated = await authService.authenticate();

      if (authenticated) {
        return await onSuccess();
      } else {
        return await onFailure?.call();
      }
    } catch (e) {
      return await onFailure?.call();
    }
  }

  /// Checks if biometric authentication is available on the device
  ///
  /// Example usage:
  /// ```dart
  /// if (await context.canAuthenticate()) {
  ///   // Show biometric-protected actions
  /// } else {
  ///   // Show alternative UI
  /// }
  /// ```
  Future<bool> canAuthenticate({GuardoService? guardoService}) async {
    final service = guardoService ?? GuardoService();
    return await service.canCheckBiometrics;
  }

  /// Checks if the device supports biometric authentication
  ///
  /// Example usage:
  /// ```dart
  /// if (await context.isDeviceSupported()) {
  ///   // Device supports biometrics
  /// }
  /// ```
  Future<bool> isDeviceSupported({GuardoService? guardoService}) async {
    final service = guardoService ?? GuardoService();
    return await service.isDeviceSupported;
  }
}
