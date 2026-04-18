import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/thought.dart';
import '../application/thoughts_controller.dart';
import '../widgets/thought_card.dart';
import '../widgets/thought_input_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    await ref.read(thoughtsControllerProvider.notifier).addThought(text);

    if (!mounted) {
      return;
    }

    final submissionState = ref.read(thoughtsControllerProvider);
    if (!submissionState.hasError) {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thought organized successfully.')),
      );
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is unavailable.')),
      );
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      onSoundLevelChange: (_) {},
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thoughts = ref.watch(thoughtsStreamProvider);
    final actionState = ref.watch(thoughtsControllerProvider);

    ref.listen<AsyncValue<void>>(thoughtsControllerProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    return RefreshIndicator(
      onRefresh: ref.read(thoughtsControllerProvider.notifier).refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
        children: [
          Text(
            'Capture what is on your mind',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
          const SizedBox(height: 10),
          Text(
            'Tasks, ideas, and worries get sorted instantly so you can think less and act faster.',
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15),
          const SizedBox(height: 22),
          ThoughtInputCard(
            controller: _controller,
            onSubmit: _submit,
            onMicTap: _toggleListening,
            isSubmitting: actionState.isLoading,
            isListening: _isListening,
          ).animate(delay: 160.ms).fadeIn(duration: 450.ms).slideY(begin: 0.18),
          const SizedBox(height: 22),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent thoughts',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                thoughts.when(
                  data: (items) =>
                      _RecentThoughtsList(thoughts: items.take(3).toList()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      AsyncStateView(message: error.toString()),
                ),
              ],
            ),
          ).animate(delay: 220.ms).fadeIn(duration: 450.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _RecentThoughtsList extends StatelessWidget {
  const _RecentThoughtsList({required this.thoughts});

  final List<Thought> thoughts;

  @override
  Widget build(BuildContext context) {
    if (thoughts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No thoughts yet. Start by dumping something messy above.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < thoughts.length; index++) ...[
          ThoughtCard(thought: thoughts[index]),
          if (index != thoughts.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
