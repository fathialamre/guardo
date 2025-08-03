import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'guardo_service.dart';
import 'guardo_config.dart';

/// A widget that provides a biometric authentication gate for your app
///
/// This widget will handle the authentication flow and only show the
/// authenticated content when the user has successfully authenticated.
class Guardo extends StatefulWidget {
  /// The widget to show when the user is authenticated
  final Widget child;

  /// The widget to show while checking authentication (optional)
  final Widget? loadingWidget;

  /// The widget to show when authentication fails (optional)
  final Widget? failedWidget;

  /// Custom lock screen builder function
  /// Takes (BuildContext context, VoidCallback onTap) and returns a Widget
  /// This is the preferred way to configure the lock screen
  final LockScreenBuilder? lockScreen;

  /// Configuration for the authentication process
  final GuardoConfig? config;

  /// Custom GuardoService instance (optional)
  final GuardoService? guardoService;

  /// Callback when authentication state changes
  final void Function(bool isAuthenticated)? onAuthenticationChanged;

  /// Whether to automatically retry authentication on app resume
  final bool autoRetry;

  const Guardo({
    super.key,
    required this.child,
    this.loadingWidget,
    this.failedWidget,
    this.lockScreen,
    this.config,
    this.guardoService,
    this.onAuthenticationChanged,
    this.autoRetry = true,
  });

  @override
  State<Guardo> createState() => _GuardoState();
}

class _GuardoState extends State<Guardo> with WidgetsBindingObserver {
  late final GuardoService _guardoService;
  late final GuardoConfig _config;
  bool _isChecking = false;
  bool _isAuthenticated = false;
  bool _showLockScreen = false;
  bool _isError = false;
  String? _errorMessage;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _guardoService =
        widget.guardoService ?? GuardoService(config: widget.config);
    _config = widget.config ?? _guardoService.config;
    WidgetsBinding.instance.addObserver(this);

    // Check if we should auto-check on start or show lock screen
    if (_config.autoCheckOnStart) {
      _checkAuthentication();
    } else {
      setState(() {
        _showLockScreen = true;
      });
    }
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Re-authenticate when app comes back to foreground
    if (state == AppLifecycleState.resumed &&
        widget.autoRetry &&
        !_isAuthenticated) {
      if (_config.autoCheckOnStart) {
        _checkAuthentication();
      } else {
        setState(() {
          _showLockScreen = true;
        });
      }
    }

    // Pause/resume the lock timer based on app lifecycle
    if (state == AppLifecycleState.paused) {
      _lockTimer?.cancel();
    } else if (state == AppLifecycleState.resumed && _isAuthenticated) {
      _startLockTimer();
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();

    if (_config.lockTimeout != null && _isAuthenticated) {
      _lockTimer = Timer(_config.lockTimeout!, () {
        if (mounted && _isAuthenticated) {
          setState(() {
            _isAuthenticated = false;
            _showLockScreen = true;
          });
          widget.onAuthenticationChanged?.call(false);
        }
      });
    }
  }

  void _resetLockTimer() {
    if (_isAuthenticated) {
      _startLockTimer();
    }
  }

  void _onUnlockPressed() {
    setState(() {
      _showLockScreen = false;
    });
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
      _isError = false;
      _showLockScreen = false;
    });

    try {
      final authenticated = await _guardoService.authenticate();
      setState(() {
        _isAuthenticated = authenticated;
        _isChecking = false;
        _isError = false;
        _showLockScreen = false;
      });

      if (authenticated) {
        _startLockTimer();
      } else if (!_config.autoCheckOnStart) {
        setState(() {
          _showLockScreen = true;
        });
      }

      widget.onAuthenticationChanged?.call(authenticated);
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isChecking = false;
        _isError = true;
        _errorMessage = e.toString();
        _showLockScreen = !_config.autoCheckOnStart;
      });

      widget.onAuthenticationChanged?.call(false);
    }
  }

  Widget _buildLoadingWidget() {
    return widget.loadingWidget ??
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !Platform.isAndroid
                      ? const CupertinoActivityIndicator()
                      : const CupertinoActivityIndicator(),
                  const SizedBox(height: 16),
                  SizedBox(height: 16),
                  Text('Checking authentication...'),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildLockScreenWidget() {
    // Priority order:
    // 2. Custom lockScreen callback from Guardo widget
    // 3. Default lock screen built from individual properties

    if (widget.lockScreen != null) {
      return widget.lockScreen!(context, _onUnlockPressed);
    }

    // Build default lock screen using individual properties
    return _config.buildDefaultLockScreen(context, _onUnlockPressed);
  }

  Widget _buildFailedWidget() {
    return widget.failedWidget ??
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    "Authentication Failed",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _config.autoCheckOnStart
                        ? _checkAuthentication
                        : _onUnlockPressed,
                    icon: const Icon(Icons.refresh),
                    label: Text(_config.autoCheckOnStart ? "Try Again" : ""),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                "Authentication Error",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkAuthentication,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildLoadingWidget();
    }

    if (_isError) {
      return _buildErrorWidget();
    }

    if (_showLockScreen) {
      return _buildLockScreenWidget();
    }

    if (_isAuthenticated) {
      // Wrap the authenticated content with a Listener to detect user activity
      return Listener(
        onPointerDown: (_) => _resetLockTimer(),
        onPointerMove: (_) => _resetLockTimer(),
        onPointerUp: (_) => _resetLockTimer(),
        child: widget.child,
      );
    }

    return _buildFailedWidget();
  }
}
