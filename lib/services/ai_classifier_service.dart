import 'package:cloud_functions/cloud_functions.dart';

import '../models/thought_classification.dart';

class AiClassifierService {
  Future<ThoughtClassification> classify(String rawText) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'classifyThought',
      );

      final response = await callable.call<Map<String, dynamic>>({
        'text': rawText,
      });

      return ThoughtClassification.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    } catch (_) {
      return classifyLocalSync(rawText);
    }
  }

  /// New instant local classification to make the UI feel fast
  ThoughtClassification classifyLocalSync(String rawText) {
    final parts = rawText
        .split(RegExp(r'[\n\.\!\?]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final tasks = <String>[];
    final ideas = <String>[];
    final worries = <String>[];

    for (final part in parts) {
      final lowercase = part.toLowerCase();
      if (_containsAny(lowercase, [
        'need to', 'must', 'todo', 'follow up', 'finish', 'schedule', 
        'send', 'call', 'buy', 'submit', 'do', 'tomorrow', 'today', 'remind'
      ])) {
        tasks.add(part);
        continue;
      }

      if (_containsAny(lowercase, [
        'idea', 'what if', 'maybe', 'build', 'create', 'design', 
        'experiment', 'launch', 'think', 'project', 'start'
      ])) {
        ideas.add(part);
        continue;
      }

      if (_containsAny(lowercase, [
        'worried', 'anxious', 'stress', 'afraid', 'nervous', 
        'concerned', 'fear', 'overthinking', 'upset', 'sad', 'angry'
      ])) {
        worries.add(part);
        continue;
      }
    }

    // Default to Idea if nothing else matches
    if (tasks.isEmpty && ideas.isEmpty && worries.isEmpty) {
      ideas.add(rawText.trim());
    }

    return ThoughtClassification(tasks: tasks, ideas: ideas, worries: worries);
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
