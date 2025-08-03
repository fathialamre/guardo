import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// Callback function type for building a custom lock screen widget
typedef LockScreenBuilder =
    Widget Function(BuildContext context, VoidCallback onTap);

/// Configuration options for Guardo authentication
class GuardoConfig {
  /// The reason displayed to the user when requesting authentication
  final String localizedReason;

  /// Authentication options for biometric authentication
  final AuthenticationOptions authenticationOptions;

  /// Whether to use biometrics only (no PIN/password fallback)
  final bool biometricOnly;

  /// Whether to keep the authentication session active
  final bool stickyAuth;

  /// Duration after which the app will automatically lock due to inactivity
  /// Set to null to disable automatic locking
  final Duration? lockTimeout;

  /// Whether to automatically check authentication when app opens
  /// If false, shows lock screen with unlock button
  final bool autoCheckOnStart;

  const GuardoConfig({
    this.localizedReason = 'Please authenticate to access the app',
    this.biometricOnly = true,
    this.stickyAuth = true,
    this.lockTimeout,
    this.autoCheckOnStart = true,
    this.authenticationOptions = const AuthenticationOptions(
      biometricOnly: true,
      stickyAuth: true,
    ),
  });

  /// Builds the default lock screen widget
  Widget buildDefaultLockScreen(BuildContext context, VoidCallback onTap) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'App Locked',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please authenticate to access the app',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a copy of this configuration with optional overrides
  GuardoConfig copyWith({
    String? localizedReason,
    AuthenticationOptions? authenticationOptions,
    bool? biometricOnly,
    bool? stickyAuth,
    Duration? lockTimeout,
    bool? autoCheckOnStart,
  }) {
    return GuardoConfig(
      localizedReason: localizedReason ?? this.localizedReason,
      authenticationOptions:
          authenticationOptions ?? this.authenticationOptions,
      biometricOnly: biometricOnly ?? this.biometricOnly,
      stickyAuth: stickyAuth ?? this.stickyAuth,
      lockTimeout: lockTimeout ?? this.lockTimeout,
      autoCheckOnStart: autoCheckOnStart ?? this.autoCheckOnStart,
    );
  }
}
