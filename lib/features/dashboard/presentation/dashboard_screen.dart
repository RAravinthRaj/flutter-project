import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/thought.dart';
import '../../../models/thought_category.dart';
import '../../thoughts/application/thoughts_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thoughts = ref.watch(thoughtsStreamProvider);

    return thoughts.when(
      data: (items) {
        final stats = _DashboardStats.fromThoughts(items);

        return RefreshIndicator(
          onRefresh: ref.read(thoughtsControllerProvider.notifier).refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Text(
                'Insight dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A quick pulse check on what has been filling your head lately.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _StatCard(
                    label: 'This week',
                    value: '${stats.totalThisWeek}',
                    icon: Icons.calendar_month_rounded,
                  ),
                  _StatCard(
                    label: 'Tasks',
                    value: '${stats.tasks}',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  _StatCard(
                    label: 'Ideas',
                    value: '${stats.ideas}',
                    icon: Icons.lightbulb_outline_rounded,
                  ),
                  _StatCard(
                    label: 'Worries',
                    value: '${stats.worries}',
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most common category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stats.leadingLabel,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final label = switch (value.toInt()) {
                                    0 => 'Tasks',
                                    1 => 'Ideas',
                                    _ => 'Worries',
                                  };
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(label),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            _bar(0, stats.tasks, const Color(0xFF2AA772)),
                            _bar(1, stats.ideas, const Color(0xFF5A7BFF)),
                            _bar(2, stats.worries, const Color(0xFFF59C38)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncStateView(message: error.toString()),
    );
  }

  BarChartGroupData _bar(int x, int value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          width: 24,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.75), color],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 54) / 2;

    return SizedBox(
      width: width.clamp(140, 220),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _DashboardStats {
  const _DashboardStats({
    required this.totalThisWeek,
    required this.tasks,
    required this.ideas,
    required this.worries,
  });

  final int totalThisWeek;
  final int tasks;
  final int ideas;
  final int worries;

  String get leadingLabel {
    final values = {
      ThoughtCategory.tasks: tasks,
      ThoughtCategory.ideas: ideas,
      ThoughtCategory.worries: worries,
    };

    final best = values.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    return switch (best) {
      ThoughtCategory.tasks => 'Tasks are leading this week',
      ThoughtCategory.ideas => 'Ideas are leading this week',
      ThoughtCategory.worries => 'Worries are leading this week',
      ThoughtCategory.all => 'No data yet',
    };
  }

  factory _DashboardStats.fromThoughts(List<Thought> thoughts) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    var tasks = 0;
    var ideas = 0;
    var worries = 0;
    var totalThisWeek = 0;

    for (final thought in thoughts) {
      if (thought.createdAt.isAfter(weekAgo)) {
        totalThisWeek += 1;
      }

      tasks += thought.tasks.length;
      ideas += thought.ideas.length;
      worries += thought.worries.length;
    }

    return _DashboardStats(
      totalThisWeek: totalThisWeek,
      tasks: tasks,
      ideas: ideas,
      worries: worries,
    );
  }
}
