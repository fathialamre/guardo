import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'guardo_service.dart';
import 'guardo_config.dart';

/// Sealed class representing the different authentication states
sealed class GuardoState {
  const GuardoState();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State when checking authentication
class CheckingState extends GuardoState {
  const CheckingState();
}

/// State when user is authenticated
class AuthenticatedState extends GuardoState {
  const AuthenticatedState();
}

/// State when showing lock screen
class LockScreenState extends GuardoState {
  const LockScreenState();
}

/// State when authentication failed with error
class ErrorState extends GuardoState {
  final String message;
  const ErrorState(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorState && other.message == message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

/// State when authentication failed (no biometrics available, user cancelled, etc.)
class FailedState extends GuardoState {
  final String? message;
  const FailedState([this.message]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FailedState && other.message == message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

/// State notifier for managing Guardo authentication state
class GuardoStateNotifier extends ChangeNotifier {
  GuardoState _state;
  final GuardoService _guardoService;
  final GuardoConfig _config;
  Timer? _lockTimer;

  GuardoStateNotifier({
    required GuardoService guardoService,
    required GuardoConfig config,
    GuardoState? initialState,
  }) : _guardoService = guardoService,
       _config = config,
       _state = initialState ?? const CheckingState();

  GuardoState get state => _state;
  GuardoService get service => _guardoService;
  GuardoConfig get config => _config;

  bool get isAuthenticated => _state is AuthenticatedState;

  void _setState(GuardoState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void startLockTimer() {
    _lockTimer?.cancel();

    if (_config.lockTimeout != null && _state is AuthenticatedState) {
      _lockTimer = Timer(_config.lockTimeout!, () {
        if (_state is AuthenticatedState) {
          _setState(const LockScreenState());
        }
      });
    }
  }

  void resetLockTimer() {
    if (_state is AuthenticatedState) {
      startLockTimer();
    }
  }

  void showLockScreen() {
    _setState(const LockScreenState());
  }

  Future<void> authenticate() async {
    _setState(const CheckingState());

    try {
      final authenticated = await _guardoService.authenticate();
      if (authenticated) {
        _setState(const AuthenticatedState());
        startLockTimer();
      } else if (!_config.autoCheckOnStart) {
        _setState(const LockScreenState());
      } else {
        _setState(const FailedState('Authentication failed'));
      }
    } catch (e) {
      if (_config.autoCheckOnStart) {
        _setState(ErrorState(e.toString()));
      } else {
        _setState(const LockScreenState());
      }
    }
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }
}

/// InheritedWidget that provides access to GuardoStateNotifier
class GuardoInherited extends InheritedWidget {
  final GuardoStateNotifier stateNotifier;

  const GuardoInherited({
    super.key,
    required this.stateNotifier,
    required super.child,
  });

  static GuardoStateNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GuardoInherited>()
        ?.stateNotifier;
  }

  static GuardoStateNotifier of(BuildContext context) {
    final result = maybeOf(context);
    if (result == null) {
      throw FlutterError(
        'GuardoInherited.of() called with a context that does not contain a GuardoInherited.\n'
        'No GuardoInherited ancestor could be found starting from the context that was passed to GuardoInherited.of().\n'
        'The context used was:\n'
        '  $context',
      );
    }
    return result;
  }

  @override
  bool updateShouldNotify(GuardoInherited oldWidget) {
    return stateNotifier != oldWidget.stateNotifier;
  }
}

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
  late final GuardoStateNotifier _stateNotifier;
  late final GuardoConfig _config;

  @override
  void initState() {
    super.initState();
    final guardoService =
        widget.guardoService ?? GuardoService(config: widget.config);
    _config = widget.config ?? guardoService.config;

    // Initialize state notifier with appropriate initial state
    final initialState = _config.autoCheckOnStart
        ? const CheckingState()
        : const LockScreenState();

    _stateNotifier = GuardoStateNotifier(
      guardoService: guardoService,
      config: _config,
      initialState: initialState,
    );

    _stateNotifier.addListener(_onStateChanged);
    WidgetsBinding.instance.addObserver(this);

    // Check if we should auto-check on start
    if (_config.autoCheckOnStart) {
      _stateNotifier.authenticate();
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});

      // Notify parent about authentication state changes
      widget.onAuthenticationChanged?.call(_stateNotifier.isAuthenticated);
    }
  }

  @override
  void dispose() {
    _stateNotifier.removeListener(_onStateChanged);
    _stateNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Re-authenticate when app comes back to foreground
    if (state == AppLifecycleState.resumed &&
        widget.autoRetry &&
        !_stateNotifier.isAuthenticated) {
      if (_config.autoCheckOnStart) {
        _stateNotifier.authenticate();
      } else {
        _stateNotifier.showLockScreen();
      }
    }

    // Resume the lock timer when app comes back to foreground
    if (state == AppLifecycleState.resumed && _stateNotifier.isAuthenticated) {
      _stateNotifier.startLockTimer();
    }
  }

  void _onUnlockPressed() {
    _stateNotifier.authenticate();
  }

  Widget _buildLoadingWidget() {
    return widget.loadingWidget ??
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Platform.isIOS
                      ? const CupertinoActivityIndicator()
                      : const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Checking authentication...',
                    semanticsLabel: 'Checking your authentication status',
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildLockScreenWidget() {
    if (widget.lockScreen != null) {
      return widget.lockScreen!(context, _onUnlockPressed);
    }

    // Build default lock screen using individual properties
    return _config.buildDefaultLockScreen(context, _onUnlockPressed);
  }

  Widget _buildFailedWidget([String? message]) {
    return widget.failedWidget ??
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security,
                    size: 64,
                    color: Colors.red,
                    semanticLabel: 'Security warning icon',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Authentication Failed",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    semanticsLabel: 'Authentication has failed',
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _config.autoCheckOnStart
                        ? () => _stateNotifier.authenticate()
                        : _onUnlockPressed,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      _config.autoCheckOnStart ? "Try Again" : "Unlock",
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildErrorWidget(String message) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint_outlined,
                size: 64,
                color: Colors.orange,
                semanticLabel: 'Biometric authentication error icon',
              ),
              const SizedBox(height: 16),
              const Text(
                "Authentication Error",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                semanticsLabel: 'Authentication error occurred',
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _stateNotifier.authenticate(),
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
    return GuardoInherited(
      stateNotifier: _stateNotifier,
      child: switch (_stateNotifier.state) {
        CheckingState() => _buildLoadingWidget(),
        ErrorState(:final message) => _buildErrorWidget(message),
        LockScreenState() => _buildLockScreenWidget(),
        AuthenticatedState() => Listener(
          onPointerDown: (_) => _stateNotifier.resetLockTimer(),
          onPointerMove: (_) => _stateNotifier.resetLockTimer(),
          onPointerUp: (_) => _stateNotifier.resetLockTimer(),
          child: widget.child,
        ),
        FailedState(:final message) => _buildFailedWidget(message),
      },
    );
  }
}
