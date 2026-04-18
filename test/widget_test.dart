import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thought_dump_ai_organizer/features/auth/presentation/setup_required_screen.dart';

void main() {
  testWidgets('setup screen shows Firebase steps', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SetupRequiredScreen())),
    );

    expect(find.text('Firebase setup required'), findsOneWidget);
    expect(find.textContaining('flutterfire configure'), findsOneWidget);
  });
}
