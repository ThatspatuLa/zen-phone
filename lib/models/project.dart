/// Project — one of the 7 active project slots (zen, kiyosaki, minato, nami, rin, toji, kazuki).
class Project {
  final String id;
  final String label;
  final String color;
  final int backlogCount;
  final int inProgressCount;
  final int blockedCount;
  final int doneCount;
  final int totalActive;
  final String? nextAction;
  final DateTime? lastActive;
  final bool hasSession;

  const Project({
    required this.id,
    required this.label,
    required this.color,
    required this.backlogCount,
    required this.inProgressCount,
    required this.blockedCount,
    required this.doneCount,
    required this.totalActive,
    this.nextAction,
    this.lastActive,
    required this.hasSession,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        label: json['label'] as String,
        color: json['color'] as String? ?? '#6366f1',
        backlogCount: json['taskCounts']?['backlog'] as int? ?? 0,
        inProgressCount: json['taskCounts']?['in_progress'] as int? ?? 0,
        blockedCount: json['taskCounts']?['blocked'] as int? ?? 0,
        doneCount: json['taskCounts']?['done'] as int? ?? 0,
        totalActive: json['totalActive'] as int? ?? 0,
        nextAction: json['nextAction'] as String?,
        lastActive: json['lastActive'] != null
            ? DateTime.tryParse(json['lastActive'] as String)
            : null,
        hasSession: json['hasSession'] as bool? ?? false,
      );

  /// Parse color hex like "#6366f1" to int 0xFF6366f1 for use with Flutter.
  int get colorInt {
    final clean = color.replaceFirst('#', '');
    return int.parse('FF$clean', radix: 16);
  }

  bool get hasOpenTasks => backlogCount + inProgressCount + blockedCount > 0;
}
