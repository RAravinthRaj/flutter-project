import 'package:flutter/material.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../models/thought.dart';
import '../../../models/thought_category.dart';
import 'category_badge.dart';

class ThoughtCard extends StatelessWidget {
  const ThoughtCard({
    super.key,
    required this.thought,
    this.focusCategory = ThoughtCategory.all,
    this.onDelete,
  });

  final Thought thought;
  final ThoughtCategory focusCategory;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final lines = focusCategory == ThoughtCategory.all
        ? [thought.rawText]
        : thought.itemsFor(focusCategory);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryBadge(
                category: focusCategory == ThoughtCategory.all
                    ? thought.primaryCategory
                    : focusCategory,
              ),
              const Spacer(),
              Text(
                thought.formattedTimestamp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete thought',
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          for (final line in lines.take(3)) ...[
            Text(
              line,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 8),
          ],
          if (focusCategory == ThoughtCategory.all) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (thought.tasks.isNotEmpty)
                  _MiniCount(label: 'Tasks', count: thought.tasks.length),
                if (thought.ideas.isNotEmpty)
                  _MiniCount(label: 'Ideas', count: thought.ideas.length),
                if (thought.worries.isNotEmpty)
                  _MiniCount(label: 'Worries', count: thought.worries.length),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniCount extends StatelessWidget {
  const _MiniCount({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Text('$count $label'),
    );
  }
}
