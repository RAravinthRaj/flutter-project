import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_state_view.dart';
import '../../../models/thought.dart';
import '../../../models/thought_category.dart';
import '../application/thoughts_controller.dart';
import '../widgets/thought_card.dart';

class CategorizedViewScreen extends ConsumerWidget {
  const CategorizedViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thoughts = ref.watch(thoughtsStreamProvider);
    final query = ref.watch(thoughtSearchQueryProvider);

    return DefaultTabController(
      length: ThoughtCategory.values.length,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse organized thoughts',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search thoughts, tasks, ideas, worries...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) {
                    ref.read(thoughtSearchQueryProvider.notifier).update(value);
                  },
                ),
                const SizedBox(height: 16),
                const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'Tasks'),
                    Tab(text: 'Ideas'),
                    Tab(text: 'Worries'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: thoughts.when(
              data: (items) => TabBarView(
                children: [
                  for (final category in ThoughtCategory.values)
                    _ThoughtListTab(
                      thoughts: _filterThoughts(items, category, query),
                      category: category,
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AsyncStateView(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  List<Thought> _filterThoughts(
    List<Thought> thoughts,
    ThoughtCategory category,
    String query,
  ) {
    return thoughts
        .where((thought) => thought.belongsTo(category))
        .where((thought) => thought.matchesSearch(query))
        .toList();
  }
}

class _ThoughtListTab extends ConsumerWidget {
  const _ThoughtListTab({required this.thoughts, required this.category});

  final List<Thought> thoughts;
  final ThoughtCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (thoughts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Nothing matched this category yet.'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ref.read(thoughtsControllerProvider.notifier).refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: thoughts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final thought = thoughts[index];
          return ThoughtCard(
            thought: thought,
            focusCategory: category,
            onDelete: () {
              ref
                  .read(thoughtsControllerProvider.notifier)
                  .deleteThought(thought.id);
            },
          );
        },
      ),
    );
  }
}
