import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/application/auth_controller.dart';
import '../../thoughts/application/thoughts_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).asData?.value;
    final authAction = ref.watch(authControllerProvider);
    final thoughtsAction = ref.watch(thoughtsControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Text(
          'Profile & settings',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                user == null
                    ? 'No active session'
                    : user.email ?? 'Account connected',
              ),
              const SizedBox(height: 16),
              if (user == null)
                FilledButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Sign In'),
                )
              else
                FilledButton.tonalIcon(
                  onPressed: authAction.isLoading
                      ? null
                      : () async {
                          await ref.read(authControllerProvider.notifier).signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark mode'),
                value: themeMode == ThemeMode.dark,
                onChanged: (enabled) {
                  ref
                      .read(themeControllerProvider.notifier)
                      .toggleDarkMode(enabled);
                },
              ),
              TextButton(
                onPressed: () {
                  ref.read(themeControllerProvider.notifier).useSystemMode();
                },
                child: const Text('Use system mode'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Clear all saved thoughts from Firestore for the current account.',
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: thoughtsAction.isLoading
                    ? null
                    : () => _confirmClearData(context, ref),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear all data'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This removes every thought for the current account from Firestore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(thoughtsControllerProvider.notifier).clearAllThoughts();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All thoughts cleared.')));
    }
  }
}
