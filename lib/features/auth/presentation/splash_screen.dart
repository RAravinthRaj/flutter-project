import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_scaffold.dart';
import '../../../services/bootstrap_service.dart';
import 'setup_required_screen.dart';

final bootstrapServiceProvider = Provider<BootstrapService>((ref) {
  return BootstrapService();
});

final bootstrapProvider = FutureProvider<BootstrapStatus>((ref) async {
  return ref.watch(bootstrapServiceProvider).initialize();
});

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(bootstrapProvider);

    ref.listen<AsyncValue<BootstrapStatus>>(bootstrapProvider, (_, next) {
      next.whenData((status) {
        if (_navigated) {
          return;
        }

        if (status == BootstrapStatus.ready) {
          _navigated = true;
          context.go('/home');
        }
      });
    });

    return GradientScaffold(
      body: bootstrap.when(
        data: (status) {
          if (status == BootstrapStatus.needsFirebaseSetup) {
            return const SetupRequiredScreen();
          }

          return const _SplashContent();
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        loading: () => const _SplashContent(),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7867FF), Color(0xFF48C6F9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7867FF).withValues(alpha: 0.3),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1.04, 1.04),
                duration: 1400.ms,
              ),
          const SizedBox(height: 24),
          Text(
            'Thought Dump',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Turn messy thoughts into clear tasks, ideas, and worries.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
