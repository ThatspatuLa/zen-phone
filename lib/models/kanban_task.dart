/// Kanban task — single work item on a project's board.
class KanbanTask {
  final String id;
  final String title;
  final String project;
  final String status; // 'backlog' | 'in_progress' | 'blocked' | 'done'
  final String priority;
  final String risk;
  final String? description;
  final String? created;
  final String? lastActive;
  final String? why;
  final bool? archived;

  const KanbanTask({
    required this.id,
    required this.title,
    required this.project,
    required this.status,
    required this.priority,
    required this.risk,
    this.description,
    this.created,
    this.lastActive,
    this.why,
    this.archived,
  });

  factory KanbanTask.fromJson(Map<String, dynamic> json) => KanbanTask(
        id: json['id'] as String,
        title: json['title'] as String? ?? '(no title)',
        project: json['project'] as String? ?? '',
        status: json['status'] as String? ?? 'backlog',
        priority: json['priority'] as String? ?? 'Medium',
        risk: json['risk'] as String? ?? 'Low',
        description: json['description'] as String?,
        created: json['created'] as String?,
        lastActive: json['lastActive'] as String?,
        why: json['why'] as String?,
        archived: json['archived'] as bool?,
      );

  /// Returns true if this task is in an open (non-done) state.
  bool get isOpen =>
      status != 'done' && status != 'archived';
}
