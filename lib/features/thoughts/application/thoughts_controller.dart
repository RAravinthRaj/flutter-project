import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/thought.dart';
import '../data/thought_repository.dart';

final thoughtRepositoryProvider = Provider<ThoughtRepository>((ref) {
  return ThoughtRepository();
});

final thoughtsStreamProvider = StreamProvider<List<Thought>>((ref) {
  return ref.watch(thoughtRepositoryProvider).watchThoughts();
});

class ThoughtSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) {
    state = value;
  }
}

final thoughtSearchQueryProvider =
    NotifierProvider<ThoughtSearchQueryNotifier, String>(
      ThoughtSearchQueryNotifier.new,
    );

class ThoughtsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addThought(String rawText) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(thoughtRepositoryProvider).addThought(rawText),
    );
  }

  Future<void> deleteThought(String thoughtId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(thoughtRepositoryProvider).deleteThought(thoughtId),
    );
  }

  Future<void> clearAllThoughts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(thoughtRepositoryProvider).clearAllThoughts,
    );
  }

  Future<void> refresh() async {
    await ref.read(thoughtRepositoryProvider).refresh();
  }
}

final thoughtsControllerProvider =
    AsyncNotifierProvider<ThoughtsController, void>(ThoughtsController.new);
