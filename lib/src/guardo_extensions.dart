import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'guardo_service.dart';
import 'guardo_config.dart';
import 'guardo_gate.dart';

/// Extension on BuildContext to provide convenient authentication helpers
extension GuardoExtensions on BuildContext {
  /// Helper method to get or create a GuardoService
  GuardoService _getGuardoService({
    GuardoService? guardoService,
    GuardoConfig? config,
    String? reason,
  }) {
    if (guardoService != null) return guardoService;

    // Try to get the service from the existing state notifier
    final stateNotifier = _findGuardoStateNotifier();
    if (stateNotifier != null) {
      final existingService = stateNotifier.service;
      if (reason != null) {
        // Create a new service with updated config for custom reason
        final newConfig = existingService.config.copyWith(
          localizedReason: reason,
        );
        return GuardoService(config: newConfig);
      }
      return existingService;
    }

    // Fallback: create new service with provided or default config
    final effectiveConfig = config ?? const GuardoConfig();
    final authConfig = reason != null
        ? effectiveConfig.copyWith(localizedReason: reason)
        : effectiveConfig;

    return GuardoService(config: authConfig);
  }

  /// Common authentication logic with error handling
  Future<bool> _performAuthentication({
    GuardoService? guardoService,
    GuardoConfig? config,
    String? reason,
  }) async {
    final service = _getGuardoService(
      guardoService: guardoService,
      config: config,
      reason: reason,
    );

    try {
      return await service.authenticate();
    } catch (e) {
      // Log the error for debugging
      debugPrint('Guardo authentication failed: $e');
      rethrow;
    }
  }

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
  ///   onFailure: (exception) {
  ///     // Handle authentication failure
  ///     _showErrorMessage('Authentication failed: $exception');
  ///   },
  ///   reason: 'Please authenticate to delete your account',
  /// );
  /// ```
  Future<void> secureAction({
    required VoidCallback onSuccess,
    void Function(Object exception)? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    try {
      final authenticated = await _performAuthentication(
        guardoService: guardoService,
        config: config,
        reason: reason,
      );

      if (authenticated) {
        onSuccess();
      } else {
        onFailure?.call(
          const AuthenticationFailedException(
            'Authentication was cancelled or failed',
          ),
        );
      }
    } catch (e) {
      onFailure?.call(e);
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
  ///   onFailure: (exception) => 'Authentication failed: $exception',
  ///   reason: 'Please authenticate to perform this action',
  /// );
  /// ```
  Future<T?> guardoActionWithResult<T>({
    required T Function() onSuccess,
    T Function(Object exception)? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    try {
      final authenticated = await _performAuthentication(
        guardoService: guardoService,
        config: config,
        reason: reason,
      );

      if (authenticated) {
        return onSuccess();
      } else {
        return onFailure?.call(
          const AuthenticationFailedException(
            'Authentication was cancelled or failed',
          ),
        );
      }
    } catch (e) {
      return onFailure?.call(e);
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
  ///   onFailure: (exception) async {
  ///     // Handle authentication failure
  ///     await _logAuthenticationFailure(exception);
  ///   },
  ///   reason: 'Please authenticate to upload data',
  /// );
  /// ```
  Future<void> guardoAsyncAction({
    required Future<void> Function() onSuccess,
    Future<void> Function(Object exception)? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    try {
      final authenticated = await _performAuthentication(
        guardoService: guardoService,
        config: config,
        reason: reason,
      );

      if (authenticated) {
        await onSuccess();
      } else {
        await onFailure?.call(
          const AuthenticationFailedException(
            'Authentication was cancelled or failed',
          ),
        );
      }
    } catch (e) {
      await onFailure?.call(e);
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
  ///   onFailure: (exception) async => 'Failed to authenticate: $exception',
  ///   reason: 'Please authenticate to access secure data',
  /// );
  /// ```
  Future<T?> guardoAsyncActionWithResult<T>({
    required Future<T> Function() onSuccess,
    Future<T> Function(Object exception)? onFailure,
    String? reason,
    GuardoConfig? config,
    GuardoService? guardoService,
  }) async {
    try {
      final authenticated = await _performAuthentication(
        guardoService: guardoService,
        config: config,
        reason: reason,
      );

      if (authenticated) {
        return await onSuccess();
      } else {
        return await onFailure?.call(
          const AuthenticationFailedException(
            'Authentication was cancelled or failed',
          ),
        );
      }
    } catch (e) {
      return await onFailure?.call(e);
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
    final service = guardoService ?? _getGuardoService();
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
    final service = guardoService ?? _getGuardoService();
    return await service.isDeviceSupported;
  }

  /// Gets the list of available biometric types
  ///
  /// Example usage:
  /// ```dart
  /// final biometrics = await context.getAvailableBiometrics();
  /// if (biometrics.contains(BiometricType.face)) {
  ///   // Face ID is available
  /// }
  /// ```
  Future<List<BiometricType>> getAvailableBiometrics({
    GuardoService? guardoService,
  }) async {
    final service = guardoService ?? _getGuardoService();
    return await service.availableBiometrics;
  }

  /// Locks the app immediately by showing the lock screen
  ///
  /// This method will instantly lock the app, requiring authentication
  /// to access the content again.
  ///
  /// Example usage:
  /// ```dart
  /// // Lock the app when user navigates away or on sensitive action
  /// ElevatedButton(
  ///   onPressed: () {
  ///     context.lockApp();
  ///   },
  ///   child: Text('Lock App'),
  /// );
  /// ```
  ///
  /// Throws [StateError] if called outside of a Guardo widget context.
  void lockApp() {
    final guardoState = _findGuardoStateNotifier();
    if (guardoState != null) {
      guardoState.showLockScreen();
    } else {
      throw StateError(
        'No GuardoStateNotifier found in widget tree. '
        'Make sure this context is within a Guardo widget.',
      );
    }
  }

  /// Attempts to unlock the app using biometric authentication
  ///
  /// This method will prompt the user for biometric authentication
  /// and unlock the app if successful.
  ///
  /// Returns `true` if the app was successfully unlocked, `false` otherwise.
  ///
  /// Example usage:
  /// ```dart
  /// final unlocked = await context.unlockApp();
  /// if (unlocked) {
  ///   // App is now unlocked
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('App unlocked successfully')),
  ///   );
  /// } else {
  ///   // Failed to unlock
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Failed to unlock app')),
  ///   );
  /// }
  /// ```
  ///
  /// Throws [StateError] if called outside of a Guardo widget context.
  Future<bool> unlockApp() async {
    final guardoState = _findGuardoStateNotifier();
    if (guardoState != null) {
      try {
        await guardoState.authenticate();
        return guardoState.isAuthenticated;
      } catch (e) {
        debugPrint('Failed to unlock app: $e');
        return false;
      }
    } else {
      throw StateError(
        'No GuardoStateNotifier found in widget tree. '
        'Make sure this context is within a Guardo widget.',
      );
    }
  }

  /// Checks if the app is currently locked
  ///
  /// Returns `true` if the app is in a locked state, `false` if authenticated.
  ///
  /// Example usage:
  /// ```dart
  /// if (context.isAppLocked) {
  ///   // Show different UI for locked state
  ///   return LockScreenWidget();
  /// } else {
  ///   // Show normal app content
  ///   return AppContent();
  /// }
  /// ```
  bool get isAppLocked {
    final guardoState = _findGuardoStateNotifier();
    return guardoState?.isAuthenticated == false;
  }

  /// Checks if the app is currently authenticated
  ///
  /// Returns `true` if the user is authenticated, `false` otherwise.
  ///
  /// Example usage:
  /// ```dart
  /// if (context.isAuthenticated) {
  ///   // User is authenticated, show secure content
  ///   return SecureContent();
  /// } else {
  ///   // User needs to authenticate
  ///   return AuthenticationPrompt();
  /// }
  /// ```
  bool get isAuthenticated {
    final guardoState = _findGuardoStateNotifier();
    return guardoState?.isAuthenticated == true;
  }

  /// Gets the current authentication state
  ///
  /// Returns the current [GuardoState] or null if not in a Guardo context.
  ///
  /// Example usage:
  /// ```dart
  /// final state = context.guardoState;
  /// switch (state) {
  ///   case CheckingState():
  ///     // Show loading
  ///   case AuthenticatedState():
  ///     // Show authenticated content
  ///   case LockScreenState():
  ///     // Show lock screen
  ///   // ... handle other states
  /// }
  /// ```
  GuardoState? get guardoState {
    final guardoStateNotifier = _findGuardoStateNotifier();
    return guardoStateNotifier?.state;
  }

  /// Resets the lock timer, extending the time before automatic lock
  ///
  /// This method is useful when you want to keep the app unlocked
  /// for longer during active user interaction.
  ///
  /// Example usage:
  /// ```dart
  /// // Reset lock timer on user interaction
  /// GestureDetector(
  ///   onTap: () {
  ///     context.resetLockTimer();
  ///     // Handle tap
  ///   },
  ///   child: SomeWidget(),
  /// );
  /// ```
  void resetLockTimer() {
    final guardoState = _findGuardoStateNotifier();
    guardoState?.resetLockTimer();
  }

  /// Helper method to find the GuardoStateNotifier in the widget tree
  GuardoStateNotifier? _findGuardoStateNotifier() {
    try {
      return GuardoInherited.maybeOf(this);
    } catch (e) {
      debugPrint('Error finding GuardoStateNotifier: $e');
      return null;
    }
  }
}
