class ThoughtClassification {
  const ThoughtClassification({
    required this.tasks,
    required this.ideas,
    required this.worries,
  });

  final List<String> tasks;
  final List<String> ideas;
  final List<String> worries;

  factory ThoughtClassification.empty() {
    return const ThoughtClassification(tasks: [], ideas: [], worries: []);
  }

  Map<String, dynamic> toMap() {
    return {'tasks': tasks, 'ideas': ideas, 'worries': worries};
  }

  factory ThoughtClassification.fromMap(Map<String, dynamic> map) {
    return ThoughtClassification(
      tasks: List<String>.from(map['tasks'] as List? ?? const []),
      ideas: List<String>.from(map['ideas'] as List? ?? const []),
      worries: List<String>.from(map['worries'] as List? ?? const []),
    );
  }
}
