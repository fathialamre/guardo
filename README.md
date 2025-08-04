# Guardo

**A powerful Flutter package for biometric authentication with lock screen functionality**

[![Pub Version](https://img.shields.io/pub/v/guardo.svg)](https://pub.dev/packages/guardo)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)

Guardo provides a seamless way to add biometric authentication and app locking functionality to your Flutter applications. With automatic lockout handling, customizable lock screens, and comprehensive error management, it's the perfect solution for securing sensitive apps.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Basic Setup](#basic-setup)
  - [Configuration Options](#configuration-options)
  - [Extension Methods](#extension-methods)
  - [Custom Lock Screens](#custom-lock-screens)
- [API Reference](#api-reference)
  - [Guardo Widget](#guardo-widget)
  - [GuardoConfig](#guardoconfig)
  - [GuardoService](#guardoservice)
  - [GuardoExtensions](#guardoextensions)
  - [Authentication States](#authentication-states)
- [Error Handling](#error-handling)
- [Accessibility](#accessibility)
- [Platform Support](#platform-support)
- [Actions & Use Cases](#actions--use-cases)
  - [Secure Actions](#secure-actions)
  - [Async Actions](#async-actions)
  - [Actions with Results](#actions-with-results)
  - [Device Capability Checks](#device-capability-checks)
  - [App Control Actions](#app-control-actions)
- [Examples](#examples)
  - [Basic Authentication](#basic-authentication)
  - [Custom Lock Screen](#custom-lock-screen)
  - [Manual Lock/Unlock](#manual-lockunlock)
  - [Advanced Error Handling](#advanced-error-handling)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### **Authentication**
- **Biometric Authentication** - Fingerprint, Face ID, and other biometric methods
- **Device Credentials Fallback** - Automatic fallback to PIN/Pattern/Password when biometrics are locked out
- **Automatic Lockout Handling** - Smart handling of temporary and permanent biometric lockouts

### **User Interface**
- **Customizable Lock Screens** - Build your own lock screen or use the default
- **Multiple UI States** - Loading, authenticated, locked, error, and failed states
- **Theme Support** - Light and dark theme compatibility
- **Accessibility** - Full screen reader support and WCAG compliance

### **Configuration**
- **Auto-lock Timer** - Configurable inactivity timeout
- **Authentication Options** - Flexible biometric and credential settings
- **App Lifecycle Management** - Proper handling of app resume/pause states
- **Sticky Authentication** - Keep authentication active across app launches

### **Developer Experience**
- **Extension Methods** - Convenient `BuildContext` extensions for easy integration
- **Comprehensive Error Handling** - Typed exceptions with detailed error information
- **State Management** - Built-in state notifier with reactive updates
- **Debug Support** - Extensive logging and debugging capabilities

---

## Installation

Add Guardo to your `pubspec.yaml` file:

```yaml
dependencies:
  guardo: ^1.0.0
```

### Platform Setup

#### Android
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

#### iOS
Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

Here's the simplest way to add biometric authentication to your app:

```dart
import 'package:flutter/material.dart';
import 'package:guardo/guardo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Guardo(
      config: GuardoConfig(
        localizedReason: 'Please authenticate to access the app',
        lockTimeout: Duration(minutes: 5),
      ),
      child: MaterialApp(
        home: SecureHomePage(),
      ),
    );
  }
}

class SecureHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Secure App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.secureAction(
              onSuccess: () => print('Secure action completed!'),
              onFailure: (error) => print('Authentication failed: $error'),
            );
          },
          child: Text('Perform Secure Action'),
        ),
      ),
    );
  }
}
```

---

## Usage

### Basic Setup

Wrap your app with the `Guardo` widget to enable authentication:

```dart
Guardo(
  config: GuardoConfig(
    localizedReason: 'Please authenticate to access the app',
    biometricOnly: true,
    stickyAuth: true,
    lockTimeout: Duration(minutes: 5),
    autoCheckOnStart: true,
  ),
  onAuthenticationChanged: (isAuthenticated) {
    print('Auth state: $isAuthenticated');
  },
  child: YourApp(),
)
```

### Configuration Options

Configure Guardo behavior with `GuardoConfig`:

```dart
GuardoConfig(
  // Message shown to user during authentication
  localizedReason: 'Please authenticate to access the app',
  
  // Use only biometrics (no PIN/password fallback in normal flow)
  biometricOnly: true,
  
  // Keep authentication active between prompts
  stickyAuth: true,
  
  // Auto-lock after inactivity (null to disable)
  lockTimeout: Duration(minutes: 5),
  
  // Automatically check auth on app start
  autoCheckOnStart: true,
  
  // Advanced authentication options
  authenticationOptions: AuthenticationOptions(
    biometricOnly: true,
    stickyAuth: true,
  ),
)
```

### Extension Methods

Use convenient extension methods for common operations:

```dart
// Check authentication status
if (context.isAuthenticated) {
  // User is authenticated
}

// Lock the app manually
context.lockApp();

// Unlock the app
final success = await context.unlockApp();

// Reset the auto-lock timer
context.resetLockTimer();

// Check device capabilities
final canAuth = await context.canAuthenticate();
final isSupported = await context.isDeviceSupported();
final biometrics = await context.getAvailableBiometrics();

// Perform secure actions
await context.secureAction(
  onSuccess: () => performSensitiveOperation(),
  onFailure: (error) => handleAuthError(error),
  reason: 'Custom authentication reason',
);
```

### Custom Lock Screens

Create your own lock screen design:

```dart
Guardo(
  lockScreen: (context, onUnlock) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 100),
            SizedBox(height: 20),
            Text('App Locked', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onUnlock,
              child: Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  },
  child: YourApp(),
)
```

---

## API Reference

### Guardo Widget

The main widget that provides authentication functionality.

| Property | Type | Description |
|----------|------|-------------|
| `child` | `Widget` | The widget to show when authenticated |
| `config` | `GuardoConfig?` | Authentication configuration |
| `lockScreen` | `LockScreenBuilder?` | Custom lock screen builder |
| `loadingWidget` | `Widget?` | Custom loading widget |
| `failedWidget` | `Widget?` | Custom failed authentication widget |
| `guardoService` | `GuardoService?` | Custom service instance |
| `onAuthenticationChanged` | `Function(bool)?` | Authentication state callback |
| `autoRetry` | `bool` | Auto-retry on app resume (default: true) |

### GuardoConfig

Configuration class for authentication behavior.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `localizedReason` | `String` | 'Please authenticate...' | User-facing auth reason |
| `biometricOnly` | `bool` | `true` | Use only biometrics in normal flow |
| `stickyAuth` | `bool` | `true` | Keep auth session active |
| `lockTimeout` | `Duration?` | `null` | Auto-lock timeout |
| `autoCheckOnStart` | `bool` | `true` | Check auth on app start |
| `authenticationOptions` | `AuthenticationOptions` | Biometric options | Advanced auth settings |

### GuardoService

Service class handling biometric authentication.

#### Methods

```dart
// Check device capabilities
Future<bool> get canCheckBiometrics
Future<bool> get isDeviceSupported
Future<List<BiometricType>> get availableBiometrics

// Authentication
Future<bool> authenticate({bool allowFallback = false})
Future<bool> authenticateWithDeviceCredentials()
Future<bool> stopAuthentication()

// Configuration
GuardoConfig get config
```

### GuardoExtensions

Extension methods on `BuildContext` for convenient access.

#### Authentication Methods

```dart
// Secure actions
Future<void> secureAction({...})
Future<T?> guardoActionWithResult<T>({...})
Future<void> guardoAsyncAction({...})
Future<T?> guardoAsyncActionWithResult<T>({...})

// Device capabilities
Future<bool> canAuthenticate({GuardoService? guardoService})
Future<bool> isDeviceSupported({GuardoService? guardoService})
Future<List<BiometricType>> getAvailableBiometrics({GuardoService? guardoService})
```

#### App Control Methods

```dart
// Lock/unlock
void lockApp()
Future<bool> unlockApp()
void resetLockTimer()

// State checking
bool get isAuthenticated
bool get isAppLocked
GuardoState? get guardoState
```

### Authentication States

Guardo uses a sealed class hierarchy for state management:

```dart
sealed class GuardoState

class CheckingState extends GuardoState      // Checking authentication
class AuthenticatedState extends GuardoState // User authenticated
class LockScreenState extends GuardoState    // Showing lock screen
class ErrorState extends GuardoState         // Authentication error
class FailedState extends GuardoState        // Authentication failed
```

---

## Error Handling

Guardo provides a comprehensive exception hierarchy for detailed error handling:

### Exception Types

```dart
// Base exception class
abstract class GuardoException implements Exception

// Specific exception types
class BiometricLockoutException extends GuardoException
class BiometricUnavailableException extends GuardoException
class AuthenticationFailedException extends GuardoException
```

### Handling Errors

```dart
try {
  await context.secureAction(
    onSuccess: () => performSecureAction(),
  );
} on BiometricLockoutException catch (e) {
  // Biometrics temporarily disabled
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Biometrics Locked'),
      content: Text('Too many failed attempts. Try again later.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
} on BiometricUnavailableException catch (e) {
  // Biometrics not available on device
  showSnackBar('Biometric authentication not available');
} on AuthenticationFailedException catch (e) {
  // General authentication failure
  showSnackBar('Authentication failed: ${e.message}');
}
```

---

## Accessibility

Guardo is built with accessibility in mind:

### Features
- **Screen Reader Support** - All UI elements have semantic labels
- **High Contrast** - Theme-aware colors for better visibility
- **Keyboard Navigation** - Full keyboard support
- **Voice Control** - Compatible with voice control systems

### Customization

Add semantic labels to your custom lock screens:

```dart
lockScreen: (context, onUnlock) {
  return Scaffold(
    body: Semantics(
      label: 'Application lock screen',
      child: Center(
        child: Column(
          children: [
            Semantics(
              label: 'Lock icon',
              child: Icon(Icons.lock, size: 100),
            ),
            ElevatedButton(
              onPressed: onUnlock,
              child: Text('Unlock App'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## Platform Support

| Platform | Biometric Types | Requirements |
|----------|----------------|--------------|
| **iOS** | Face ID, Touch ID | iOS 9.0+, Xcode 12+ |
| **Android** | Fingerprint, Face, Iris | Android API 23+ |

### Supported Biometric Types

```dart
enum BiometricType {
  face,      // Face recognition
  fingerprint, // Fingerprint
  iris,      // Iris scanning
  weak,      // Device credentials (PIN/Pattern)
  strong,    // Strong biometrics
}
```

---

## Actions & Use Cases

Guardo provides various action methods to handle different authentication scenarios. Each action type is designed for specific use cases with built-in error handling and user experience considerations.

### Secure Actions

**Purpose**: Execute simple actions that require authentication without returning values.

**Preview**:
```dart
context.secureAction(
  onSuccess: () => deleteAccount(),
  onFailure: (error) => showError(error),
  reason: 'Authenticate to delete account',
);
```

#### Use Cases

| **Use Case** | **Example** | **Best For** |
|--------------|-------------|--------------|
| **Account Deletion** | Delete user account | Destructive operations |
| **Settings Changes** | Update security settings | Configuration changes |
| **Data Export** | Export sensitive data | Data operations |
| **Payment Actions** | Process payment | Financial transactions |

#### Complete Example

```dart
class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Delete Account Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _deleteAccount(context),
          icon: Icon(Icons.delete_forever),
          label: Text('Delete Account'),
        ),
        
        // Change Password Button
        ElevatedButton.icon(
          onPressed: () => _changePassword(context),
          icon: Icon(Icons.password),
          label: Text('Change Password'),
        ),
      ],
    );
  }

  void _deleteAccount(BuildContext context) {
    context.secureAction(
      reason: 'Please authenticate to delete your account permanently',
      onSuccess: () async {
        await ApiService.deleteAccount();
        Navigator.of(context).pushReplacementNamed('/welcome');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully')),
        );
      },
      onFailure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _changePassword(BuildContext context) {
    context.secureAction(
      reason: 'Authenticate to change your password',
      onSuccess: () {
        Navigator.of(context).pushNamed('/change-password');
      },
      onFailure: (error) => _showAuthError(context, error),
    );
  }
}
```

### Async Actions

**Purpose**: Execute asynchronous operations that require authentication without returning values.

**Preview**:
```dart
await context.guardoAsyncAction(
  onSuccess: () async => await uploadSecureData(),
  onFailure: (error) async => await logError(error),
  reason: 'Authenticate to upload data',
);
```

#### Use Cases

| **Use Case** | **Example** | **Best For** |
|--------------|-------------|--------------|
| **File Upload** | Upload encrypted files | Long-running operations |
| **Data Sync** | Sync sensitive data | Background processes |
| **API Calls** | Make secure API requests | Network operations |
| **Database Operations** | Update secure records | Data persistence |

#### Complete Example

```dart
class SecureFileManager extends StatefulWidget {
  @override
  _SecureFileManagerState createState() => _SecureFileManagerState();
}

class _SecureFileManagerState extends State<SecureFileManager> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isUploading)
          LinearProgressIndicator(value: _uploadProgress),
        
        ElevatedButton.icon(
          onPressed: _isUploading ? null : () => _uploadSecureFiles(context),
          icon: Icon(Icons.cloud_upload),
          label: Text('Upload Secure Files'),
        ),
        
        ElevatedButton.icon(
          onPressed: () => _syncData(context),
          icon: Icon(Icons.sync),
          label: Text('Sync Encrypted Data'),
        ),
      ],
    );
  }

  Future<void> _uploadSecureFiles(BuildContext context) async {
    setState(() => _isUploading = true);
    
    await context.guardoAsyncAction(
      reason: 'Authenticate to upload your secure files',
      onSuccess: () async {
        try {
          final files = await FileService.getSelectedFiles();
          
          for (int i = 0; i < files.length; i++) {
            await FileService.uploadEncryptedFile(files[i]);
            setState(() => _uploadProgress = (i + 1) / files.length);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${files.length} files uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          throw Exception('Upload failed: $e');
        }
      },
      onFailure: (error) async {
        await Logger.logError('File upload failed', error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
    
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }

  Future<void> _syncData(BuildContext context) async {
    await context.guardoAsyncAction(
      reason: 'Authenticate to sync your encrypted data',
      onSuccess: () async {
        await DataService.syncEncryptedData();
        await CacheService.clearSensitiveCache();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data synced successfully')),
        );
      },
      onFailure: (error) async {
        await Logger.logError('Sync failed', error);
      },
    );
  }
}
```

### Actions with Results

**Purpose**: Execute operations that require authentication and return values.

**Preview**:
```dart
final result = await context.guardoActionWithResult<String>(
  onSuccess: () => getSecretKey(),
  onFailure: (error) => 'Default key',
  reason: 'Authenticate to access encryption key',
);
```

#### Use Cases

| **Use Case** | **Example** | **Best For** |
|--------------|-------------|--------------|
| **Key Retrieval** | Get encryption keys | Security operations |
| **Data Fetching** | Fetch sensitive data | Data retrieval |
| **Token Generation** | Generate auth tokens | Authentication flows |
| **Calculation Results** | Compute sensitive values | Processing operations |

#### Complete Example

```dart
class CryptoWallet extends StatefulWidget {
  @override
  _CryptoWalletState createState() => _CryptoWalletState();
}

class _CryptoWalletState extends State<CryptoWallet> {
  String? _balance;
  String? _privateKey;
  List<Transaction>? _transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Balance Card
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Wallet Balance', style: TextStyle(fontSize: 16)),
                Text(
                  _balance ?? 'Hidden',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _getBalance(context),
                  child: Text('Show Balance'),
                ),
              ],
            ),
          ),
        ),
        
        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _exportPrivateKey(context),
              icon: Icon(Icons.key),
              label: Text('Export Key'),
            ),
            ElevatedButton.icon(
              onPressed: () => _getTransactionHistory(context),
              icon: Icon(Icons.history),
              label: Text('History'),
            ),
          ],
        ),
        
        // Transaction List
        if (_transactions != null)
          Expanded(
            child: ListView.builder(
              itemCount: _transactions!.length,
              itemBuilder: (context, index) => TransactionTile(_transactions![index]),
            ),
          ),
      ],
    );
  }

  Future<void> _getBalance(BuildContext context) async {
    final balance = await context.guardoActionWithResult<String>(
      reason: 'Authenticate to view your wallet balance',
      onSuccess: () async {
        final wallet = await WalletService.getSecureWallet();
        return await wallet.getBalance();
      },
      onFailure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get balance: $error')),
        );
        return null;
      },
    );
    
    setState(() => _balance = balance);
  }

  Future<void> _exportPrivateKey(BuildContext context) async {
    final privateKey = await context.guardoAsyncActionWithResult<String>(
      reason: 'Authenticate to export your private key',
      onSuccess: () async {
        final wallet = await WalletService.getSecureWallet();
        return await wallet.exportPrivateKey();
      },
      onFailure: (error) async {
        await Logger.logSecurityEvent('Private key export failed', error);
        return null;
      },
    );
    
    if (privateKey != null) {
      _showPrivateKeyDialog(context, privateKey);
    }
  }

  Future<void> _getTransactionHistory(BuildContext context) async {
    final transactions = await context.guardoAsyncActionWithResult<List<Transaction>>(
      reason: 'Authenticate to view transaction history',
      onSuccess: () async {
        final wallet = await WalletService.getSecureWallet();
        return await wallet.getTransactionHistory();
      },
      onFailure: (error) async => <Transaction>[],
    );
    
    setState(() => _transactions = transactions);
  }
}
```

### Device Capability Checks

**Purpose**: Check device biometric capabilities and availability.

**Preview**:
```dart
final canAuth = await context.canAuthenticate();
final biometrics = await context.getAvailableBiometrics();
```

#### Use Cases

| **Use Case** | **Example** | **Best For** |
|--------------|-------------|--------------|
| **Feature Detection** | Show/hide biometric options | UI adaptation |
| **Fallback Planning** | Provide alternative auth | User experience |
| **Capability Display** | Show supported methods | User information |
| **Setup Validation** | Check before enabling | Configuration |

#### Complete Example

```dart
class BiometricSetup extends StatefulWidget {
  @override
  _BiometricSetupState createState() => _BiometricSetupState();
}

class _BiometricSetupState extends State<BiometricSetup> {
  bool? _canAuthenticate;
  bool? _isDeviceSupported;
  List<BiometricType>? _availableBiometrics;
  String _statusMessage = 'Checking device capabilities...';

  @override
  void initState() {
    super.initState();
    _checkCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Card
        Card(
          color: _getStatusColor(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  _statusMessage,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        
        // Capabilities List
        if (_availableBiometrics != null)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Authentication Methods',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ..._availableBiometrics!.map((biometric) => ListTile(
                    leading: Icon(_getBiometricIcon(biometric)),
                    title: Text(_getBiometricName(biometric)),
                    subtitle: Text(_getBiometricDescription(biometric)),
                    trailing: Icon(Icons.check, color: Colors.green),
                  )),
                ],
              ),
            ),
          ),
        
        // Setup Button
        if (_canAuthenticate == true)
          ElevatedButton.icon(
            onPressed: () => _enableBiometricSecurity(context),
            icon: Icon(Icons.security),
            label: Text('Enable Biometric Security'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
      ],
    );
  }

  Future<void> _checkCapabilities() async {
    try {
      final results = await Future.wait([
        context.canAuthenticate(),
        context.isDeviceSupported(),
        context.getAvailableBiometrics(),
      ]);
      
      setState(() {
        _canAuthenticate = results[0] as bool;
        _isDeviceSupported = results[1] as bool;
        _availableBiometrics = results[2] as List<BiometricType>;
        _updateStatusMessage();
      });
    } catch (e) {
      setState(() {
        _canAuthenticate = false;
        _isDeviceSupported = false;
        _statusMessage = 'Error checking capabilities: $e';
      });
    }
  }

  void _updateStatusMessage() {
    if (_canAuthenticate == true && _isDeviceSupported == true) {
      _statusMessage = 'Device supports biometric authentication';
    } else if (_isDeviceSupported == false) {
      _statusMessage = 'Device does not support biometric authentication';
    } else if (_canAuthenticate == false) {
      _statusMessage = 'Biometric authentication not available. Please set up biometrics in device settings.';
    }
  }

  Color _getStatusColor() {
    if (_canAuthenticate == true) return Colors.green;
    if (_canAuthenticate == false) return Colors.orange;
    return Colors.grey;
  }

  IconData _getStatusIcon() {
    if (_canAuthenticate == true) return Icons.verified_user;
    if (_canAuthenticate == false) return Icons.warning;
    return Icons.help_outline;
  }

  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face: return 'Face Recognition';
      case BiometricType.fingerprint: return 'Fingerprint';
      case BiometricType.iris: return 'Iris Scanner';
      case BiometricType.weak: return 'Device PIN/Pattern';
      case BiometricType.strong: return 'Strong Biometrics';
    }
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face: return Icons.face;
      case BiometricType.fingerprint: return Icons.fingerprint;
      case BiometricType.iris: return Icons.visibility;
      case BiometricType.weak: return Icons.pin;
      case BiometricType.strong: return Icons.security;
    }
  }

  String _getBiometricDescription(BiometricType type) {
    switch (type) {
      case BiometricType.face: return 'Use your face to unlock';
      case BiometricType.fingerprint: return 'Use your fingerprint to unlock';
      case BiometricType.iris: return 'Use your iris to unlock';
      case BiometricType.weak: return 'Use device PIN or pattern';
      case BiometricType.strong: return 'High-security biometric method';
    }
  }

  void _enableBiometricSecurity(BuildContext context) {
    // Navigate to app settings or show configuration dialog
    Navigator.of(context).pushNamed('/security-settings');
  }
}
```

### App Control Actions

**Purpose**: Control app lock state and authentication flow.

**Preview**:
```dart
context.lockApp();                    // Lock immediately
final success = await context.unlockApp(); // Unlock with auth
context.resetLockTimer();             // Reset auto-lock timer
```

#### Use Cases

| **Use Case** | **Example** | **Best For** |
|--------------|-------------|--------------|
| **Manual Lock** | Lock when leaving app | Security control |
| **Emergency Lock** | Lock on security threat | Security response |
| **Session Extension** | Reset timer on activity | User experience |
| **Programmatic Unlock** | Unlock after verification | Automation |

#### Complete Example

```dart
class SecurityControlPanel extends StatefulWidget {
  @override
  _SecurityControlPanelState createState() => _SecurityControlPanelState();
}

class _SecurityControlPanelState extends State<SecurityControlPanel> {
  Timer? _activityTimer;
  int _activityCount = 0;

  @override
  void initState() {
    super.initState();
    _startActivityMonitoring();
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Dashboard
        _buildStatusDashboard(context),
        
        // Control Buttons
        _buildControlButtons(context),
        
        // Security Actions
        _buildSecurityActions(context),
        
        // Activity Monitor
        _buildActivityMonitor(context),
      ],
    );
  }

  Widget _buildStatusDashboard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Security Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  icon: context.isAuthenticated ? Icons.lock_open : Icons.lock,
                  label: context.isAuthenticated ? 'Unlocked' : 'Locked',
                  color: context.isAuthenticated ? Colors.green : Colors.red,
                ),
                _buildStatusItem(
                  icon: Icons.timer,
                  label: 'Auto-lock: 5min',
                  color: Colors.blue,
                ),
                _buildStatusItem(
                  icon: Icons.activity,
                  label: 'Activity: $_activityCount',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _lockApp(context),
                  icon: Icon(Icons.lock),
                  label: Text('Lock Now'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: () => _unlockApp(context),
                  icon: Icon(Icons.lock_open),
                  label: Text('Unlock'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () => _resetTimer(context),
                  icon: Icon(Icons.timer_off),
                  label: Text('Reset Timer'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.orange),
              title: Text('Secure Logout'),
              subtitle: Text('Lock app and clear session'),
              onTap: () => _secureLogout(context),
            ),
            ListTile(
              leading: Icon(Icons.emergency, color: Colors.red),
              title: Text('Emergency Lock'),
              subtitle: Text('Immediate lock with notification clear'),
              onTap: () => _emergencyLock(context),
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.blue),
              title: Text('Scheduled Lock'),
              subtitle: Text('Set custom lock timer'),
              onTap: () => _showScheduleDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMonitor(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Monitor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('User activity count: $_activityCount'),
            Text('Last activity: ${DateTime.now().toString().substring(0, 19)}'),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_activityCount % 100) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  void _lockApp(BuildContext context) {
    try {
      context.lockApp();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App locked successfully'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to lock app: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _unlockApp(BuildContext context) async {
    try {
      final success = await context.unlockApp();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'App unlocked successfully' : 'Failed to unlock app'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unlock error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetTimer(BuildContext context) {
    context.resetLockTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Auto-lock timer reset'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _secureLogout(BuildContext context) {
    context.lockApp();
    // Clear user session, cache, sensitive data
    UserSession.clear();
    CacheService.clearSensitive();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Secure logout completed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _emergencyLock(BuildContext context) {
    context.lockApp();
    // Clear notifications, hide sensitive content
    NotificationService.clearAll();
    AppStateService.hideFromRecents();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency lock activated'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Auto-Lock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('1 minute'),
              onTap: () => _setCustomTimer(Duration(minutes: 1)),
            ),
            ListTile(
              title: Text('5 minutes'),
              onTap: () => _setCustomTimer(Duration(minutes: 5)),
            ),
            ListTile(
              title: Text('15 minutes'),
              onTap: () => _setCustomTimer(Duration(minutes: 15)),
            ),
            ListTile(
              title: Text('Disable'),
              onTap: () => _setCustomTimer(null),
            ),
          ],
        ),
      ),
    );
  }

  void _setCustomTimer(Duration? duration) {
    Navigator.pop(context);
    // This would require updating the GuardoConfig
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          duration != null 
            ? 'Auto-lock set to ${duration.inMinutes} minutes'
            : 'Auto-lock disabled'
        ),
      ),
    );
  }

  void _startActivityMonitoring() {
    _activityTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _activityCount++);
      
      // Reset lock timer on activity
      if (_activityCount % 30 == 0) {
        context.resetLockTimer();
      }
    });
  }
}
```

---

## Examples

### Basic Authentication

```dart
import 'package:flutter/material.dart';
import 'package:guardo/guardo.dart';

class BasicAuthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Guardo(
      config: GuardoConfig(
        localizedReason: 'Authenticate to access your secure data',
        lockTimeout: Duration(minutes: 2),
      ),
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
```

### Custom Lock Screen

```dart
Guardo(
  lockScreen: (context, onUnlock) => CustomLockScreen(onUnlock: onUnlock),
  child: YourApp(),
)

class CustomLockScreen extends StatelessWidget {
  final VoidCallback onUnlock;
  
  const CustomLockScreen({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 120,
              color: Colors.white,
              semanticLabel: 'Security lock icon',
            ),
            SizedBox(height: 40),
            Text(
              'Secure Area',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Please authenticate to continue',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: onUnlock,
              icon: Icon(Icons.fingerprint),
              label: Text('Authenticate'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Manual Lock/Unlock

```dart
class ControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status indicator
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  context.isAuthenticated ? Icons.lock_open : Icons.lock,
                  color: context.isAuthenticated ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  context.isAuthenticated ? 'Unlocked' : 'Locked',
                  style: TextStyle(
                    color: context.isAuthenticated ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => context.lockApp(),
              child: Text('Lock App'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await context.unlockApp();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Unlocked!' : 'Failed to unlock'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text('Unlock App'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Advanced Error Handling

```dart
class SecureAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _performSecureAction(context),
      child: Text('Delete Account'),
    );
  }

  Future<void> _performSecureAction(BuildContext context) async {
    try {
      await context.secureAction(
        reason: 'Please authenticate to delete your account',
        onSuccess: () async {
          // Perform the actual deletion
          await deleteAccount();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account deleted successfully')),
          );
        },
      );
    } on BiometricLockoutException catch (e) {
      _showLockoutDialog(context, e);
    } on BiometricUnavailableException catch (e) {
      _showUnavailableDialog(context, e);
    } on AuthenticationFailedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLockoutDialog(BuildContext context, BiometricLockoutException e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Biometrics Locked'),
        content: Text(e.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Offer device credentials as fallback
              _tryDeviceCredentials(context);
            },
            child: Text('Use PIN/Password'),
          ),
        ],
      ),
    );
  }

  void _showUnavailableDialog(BuildContext context, BiometricUnavailableException e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Biometrics Unavailable'),
        content: Text('${e.message}\n\nPlease ensure biometric authentication is set up on your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _tryDeviceCredentials(BuildContext context) async {
    // Implementation for device credential authentication
  }
}
```

---

## Security Considerations

### Best Practices

1. **Sensitive Data Handling**
   ```dart
   // Good: Use secure actions for sensitive operations
   context.secureAction(
     onSuccess: () => transferMoney(amount),
     reason: 'Authenticate to transfer money',
   );
   ```

2. **Timeout Configuration**
   ```dart
   // Good: Set appropriate timeouts
   GuardoConfig(
     lockTimeout: Duration(minutes: 5), // Adjust based on app sensitivity
   )
   ```

3. **Error Information**
   ```dart
   // Good: Don't expose sensitive error details to users
   onFailure: (error) {
     logger.error('Auth failed: $error'); // Log detailed error
     showUserFriendlyMessage(); // Show generic message to user
   }
   ```

### Security Features

- **Automatic Lockout Handling** - Graceful degradation when biometrics fail
- **Session Management** - Proper cleanup of authentication sessions
- **State Protection** - Secure state transitions and validation
- **Platform Integration** - Uses platform-native security features

---

## Troubleshooting

### Common Issues

#### 1. Biometrics Not Working
```dart
// Check device capabilities first
final canAuth = await context.canAuthenticate();
final isSupported = await context.isDeviceSupported();

if (!canAuth || !isSupported) {
  // Handle unsupported device
  showFallbackOptions();
}
```

#### 2. App Not Locking
```dart
// Ensure Guardo widget wraps your entire app
Guardo(
  config: GuardoConfig(
    lockTimeout: Duration(minutes: 5), // Make sure timeout is set
  ),
  child: MaterialApp(...), // App should be inside Guardo
)
```

#### 3. Custom Lock Screen Not Showing
```dart
// Make sure to return a complete widget
lockScreen: (context, onUnlock) {
  return Scaffold( // Return a complete screen
    body: YourLockScreenContent(onUnlock: onUnlock),
  );
}
```

#### 4. Authentication State Issues
```dart
// Use the context extensions within Guardo widget tree
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This works - within Guardo tree
    final isAuth = context.isAuthenticated;
    
    return YourWidget();
  }
}
```

### Debug Mode

Enable detailed logging:

```dart
import 'package:flutter/foundation.dart';

// In debug mode, Guardo automatically provides detailed logs
if (kDebugMode) {
  // Check console for authentication flow logs
}
```

---

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/guardo.git

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

### Reporting Issues

When reporting issues, please include:

- Flutter version (`flutter --version`)
- Platform (iOS/Android) and version
- Device model and biometric capabilities
- Complete error messages and stack traces
- Minimal reproduction code

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Built with [local_auth](https://pub.dev/packages/local_auth) package
- Inspired by the Flutter community's security needs
- Thanks to all contributors and users

---

<div align="center">

**Made with love for the Flutter community**

[Star us on GitHub](https://github.com/yourusername/guardo) • [Report Bug](https://github.com/yourusername/guardo/issues) • [Request Feature](https://github.com/yourusername/guardo/issues)

</div>
