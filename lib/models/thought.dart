import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'thought_category.dart';

class Thought {
  const Thought({
    required this.id,
    required this.rawText,
    required this.createdAt,
    required this.tasks,
    required this.ideas,
    required this.worries,
  });

  final String id;
  final String rawText;
  final DateTime createdAt;
  final List<String> tasks;
  final List<String> ideas;
  final List<String> worries;

  factory Thought.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    final createdAt = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.now();

    return Thought(
      id: doc.id,
      rawText: data['rawText'] as String? ?? '',
      createdAt: createdAt,
      tasks: List<String>.from(data['tasks'] as List? ?? const []),
      ideas: List<String>.from(data['ideas'] as List? ?? const []),
      worries: List<String>.from(data['worries'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rawText': rawText,
      'createdAt': Timestamp.fromDate(createdAt),
      'tasks': tasks,
      'ideas': ideas,
      'worries': worries,
    };
  }

  List<String> itemsFor(ThoughtCategory category) {
    switch (category) {
      case ThoughtCategory.tasks:
        return tasks;
      case ThoughtCategory.ideas:
        return ideas;
      case ThoughtCategory.worries:
        return worries;
      case ThoughtCategory.all:
        return [rawText];
    }
  }

  bool matchesSearch(String query) {
    if (query.trim().isEmpty) {
      return true;
    }

    final normalized = query.toLowerCase();
    final values = [
      rawText,
      ...tasks,
      ...ideas,
      ...worries,
    ].map((entry) => entry.toLowerCase());

    return values.any((entry) => entry.contains(normalized));
  }

  bool belongsTo(ThoughtCategory category) {
    switch (category) {
      case ThoughtCategory.tasks:
        return tasks.isNotEmpty;
      case ThoughtCategory.ideas:
        return ideas.isNotEmpty;
      case ThoughtCategory.worries:
        return worries.isNotEmpty;
      case ThoughtCategory.all:
        return true;
    }
  }

  String get formattedTimestamp =>
      DateFormat('EEE, MMM d • h:mm a').format(createdAt);

  ThoughtCategory get primaryCategory {
    final counts = {
      ThoughtCategory.tasks: tasks.length,
      ThoughtCategory.ideas: ideas.length,
      ThoughtCategory.worries: worries.length,
    };

    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
