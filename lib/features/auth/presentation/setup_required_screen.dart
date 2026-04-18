import 'package:flutter/material.dart';

import '../../../core/widgets/glass_card.dart';

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firebase setup required',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The app code is ready, but this project still needs Firebase configuration files and platform registration.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'Run these commands from the project root:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const SelectableText(
                  'npm install -g firebase-tools\n'
                  'firebase login\n'
                  'dart pub global activate flutterfire_cli\n'
                  'flutterfire configure',
                ),
                const SizedBox(height: 20),
                Text(
                  'Then replace the placeholder values in lib/firebase_options.dart with the generated file.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
