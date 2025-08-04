import 'package:flutter/material.dart';
import 'package:guardo/guardo.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Guardo(
      // Configuration for the authentication
      config: GuardoConfig(
        localizedReason: 'Please authenticate to access the secure app',
        // Use biometrics by default - lockout scenarios will automatically fallback to device credentials
        biometricOnly: true,
        stickyAuth: true,
        // Lock the app after 30 seconds of inactivity
        lockTimeout: const Duration(seconds: 40),
        // Show lock screen instead of auto-checking authentication
        autoCheckOnStart: false,
        // Use biometric authentication by default
        authenticationOptions: const AuthenticationOptions(
          biometricOnly: true, // Normal biometric authentication
          stickyAuth: true,
        ),
      ),
      onAuthenticationChanged: (isAuthenticated) {
        debugPrint('Authentication state changed: $isAuthenticated');
      },
      child: MaterialApp(
        title: 'Secure App',
        theme: ThemeData(useMaterial3: true),
        home: const SecureHomePage(),
      ),
    );
  }
}

class SecureHomePage extends StatefulWidget {
  const SecureHomePage({super.key});

  @override
  State<SecureHomePage> createState() => _SecureHomePageState();
}

class _SecureHomePageState extends State<SecureHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure App'),
        actions: [
          // Authentication status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  context.isAuthenticated ? Icons.lock_open : Icons.lock,
                  color: context.isAuthenticated ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  context.isAuthenticated ? 'Unlocked' : 'Locked',
                  style: TextStyle(
                    color: context.isAuthenticated ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Welcome to the Secure App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have successfully authenticated',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Lock App Button
            ElevatedButton.icon(
              onPressed: () {
                context.lockApp();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App locked manually')),
                );
              },
              icon: const Icon(Icons.lock),
              label: const Text('Lock App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Unlock App Button
            ElevatedButton.icon(
              onPressed: () async {
                final unlocked = await context.unlockApp();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        unlocked
                            ? 'App unlocked successfully'
                            : 'Failed to unlock app',
                      ),
                      backgroundColor: unlocked ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Unlock App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Reset Lock Timer Button
            ElevatedButton.icon(
              onPressed: () {
                context.resetLockTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lock timer reset')),
                );
              },
              icon: const Icon(Icons.timer),
              label: const Text('Reset Lock Timer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Original secure action example
            ElevatedButton.icon(
              onPressed: () {
                context.secureAction(
                  onSuccess: () {
                    debugPrint('Guarded Action Success');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Secure action completed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  onFailure: (e) {
                    debugPrint('Guarded Action Failed: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Secure action failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  reason: 'Please authenticate to perform this secure action',
                );
              },
              icon: const Icon(Icons.verified_user),
              label: const Text('Perform Secure Action'),
            ),

            const SizedBox(height: 16),

            // Authentication status info
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Authentication Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Is Authenticated:'),
                        Text(
                          context.isAuthenticated ? 'Yes' : 'No',
                          style: TextStyle(
                            color: context.isAuthenticated
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Is App Locked:'),
                        Text(
                          context.isAppLocked ? 'Yes' : 'No',
                          style: TextStyle(
                            color: context.isAppLocked
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
