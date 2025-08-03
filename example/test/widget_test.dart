// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardo/guardo.dart';
void main() {
  testWidgets('MyHomePage widget test', (WidgetTester tester) async {
    // Test the home page widget directly (bypassing authentication)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Hello, World!'))),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(find.text('🎉 Welcome! You are authenticated.'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('GuardoConfig test', (WidgetTester tester) async {
    // Test GuardoConfig creation and copyWith
    const config = GuardoConfig(
      localizedReason: 'Test message',
      biometricOnly: false,
    );

    expect(config.localizedReason, 'Test message');
    expect(config.biometricOnly, false);
    expect(config.stickyAuth, true); // default value

    final updatedConfig = config.copyWith(localizedReason: 'Updated message');

    expect(updatedConfig.localizedReason, 'Updated message');
    expect(updatedConfig.biometricOnly, false); // preserved
    expect(updatedConfig.stickyAuth, true); // preserved
  });

  testWidgets('GuardoGate widget structure test', (WidgetTester tester) async {
    // Test that GuardoGate can be created with minimal setup
    // This will likely show loading or authentication failure, which is expected in test environment
    await tester.pumpWidget(
      Guardo(
        child: const MaterialApp(
          home: Scaffold(body: Center(child: Text('Authenticated Content'))),
        ),
      ),
    );

    // Verify GuardoGate is present
    expect(find.byType(Guardo), findsOneWidget);

    // Since biometric auth will fail in test environment, we should not see the authenticated content
    expect(find.text('Authenticated Content'), findsNothing);
  });
}
