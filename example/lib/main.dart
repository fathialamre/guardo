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
        localizedReason: 'Please authenticate to access the secure app 22',
        biometricOnly: true,
        stickyAuth: true,
        // Lock the app after 30 seconds of inactivity
        lockTimeout: const Duration(seconds: 5),
        // Show lock screen instead of auto-checking authentication
        autoCheckOnStart: true,
      ),
      // Optional: Handle authentication state changes
      onAuthenticationChanged: (isAuthenticated) {
        debugPrint('Authentication state changed: $isAuthenticated');
      },

      // The app content to show when authenticated
      child: MaterialApp(
        title: 'Secure App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello, World!'),
                ElevatedButton(
                  onPressed: () {
                    context.secureAction(
                      onSuccess: () {
                        debugPrint('Guarded Action Success');
                      },
                      onFailure: () {
                        debugPrint('Guarded Action Failed');
                      },
                    );
                  },
                  child: const Text('Secured Action'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
