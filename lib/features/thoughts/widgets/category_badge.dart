import 'package:flutter/material.dart';

import '../../../models/thought_category.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    super.key,
    required this.category,
    this.compact = false,
  });

  final ThoughtCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (category) {
      ThoughtCategory.tasks => const Color(0xFF2AA772),
      ThoughtCategory.ideas => const Color(0xFF5A7BFF),
      ThoughtCategory.worries => const Color(0xFFF59C38),
      ThoughtCategory.all => scheme.primary,
    };

    final label = switch (category) {
      ThoughtCategory.tasks => 'Task',
      ThoughtCategory.ideas => 'Idea',
      ThoughtCategory.worries => 'Worry',
      ThoughtCategory.all => 'Thought',
    };

    final icon = switch (category) {
      ThoughtCategory.tasks => Icons.check_circle_outline_rounded,
      ThoughtCategory.ideas => Icons.lightbulb_outline_rounded,
      ThoughtCategory.worries => Icons.warning_amber_rounded,
      ThoughtCategory.all => Icons.auto_awesome_rounded,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
