import 'package:flutter/material.dart';

import '../../../core/widgets/glass_card.dart';

class ThoughtInputCard extends StatelessWidget {
  const ThoughtInputCard({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onMicTap,
    required this.isSubmitting,
    required this.isListening,
  });

  final TextEditingController controller;
  final Future<void> Function() onSubmit;
  final VoidCallback onMicTap;
  final bool isSubmitting;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thought Dump',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Dump your thoughts and let AI organize the mess.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            minLines: 6,
            maxLines: 9,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Dump your thoughts…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onMicTap,
                icon: Icon(
                  isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : onSubmit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    isSubmitting ? 'Organizing...' : 'Organize Thought',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
