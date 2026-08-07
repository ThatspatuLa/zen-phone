import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/kanban_task.dart';
import '../widgets/kanban_card.dart';

/// Kanban — single project board at a time, swipe horizontally between projects.
class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final _columns = const [
    _Column('backlog', 'Backlog'),
    _Column('in_progress', 'In Progress'),
    _Column('blocked', 'Blocked'),
    _Column('done', 'Done'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final projects = ['zen', 'kiyosaki', 'minato', 'nami', 'rin', 'toji', 'kazuki'];
    final activeProject = state.currentProject ?? projects.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban'),
        leading: Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          );
        }),
      ),
      body: Column(
        children: [
          _ProjectSelector(
            projects: projects,
            selected: activeProject,
            onSelect: (p) => state.selectProject(p),
          ),
          Expanded(
            child: _KanbanBoard(project: activeProject, columns: _columns),
          ),
        ],
      ),
    );
  }
}

class _Column {
  final String id;
  final String label;
  const _Column(this.id, this.label);
}

class _ProjectSelector extends StatelessWidget {
  final List<String> projects;
  final String selected;
  final ValueChanged<String> onSelect;
  const _ProjectSelector({required this.projects, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final p in projects)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(p),
                selected: selected == p,
                onSelected: (_) => onSelect(p),
                selectedColor: AppTheme.accent.withValues(alpha: 0.2),
                backgroundColor: AppTheme.bgTertiary,
                labelStyle: TextStyle(
                  color: selected == p ? AppTheme.accent : AppTheme.textPrimary,
                  fontWeight: selected == p ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(color: AppTheme.border, width: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _KanbanBoard extends StatefulWidget {
  final String project;
  final List<_Column> columns;
  const _KanbanBoard({required this.project, required this.columns});

  @override
  State<_KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<_KanbanBoard> {
  late Future<List<KanbanTask>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _KanbanBoard old) {
    super.didUpdateWidget(old);
    if (old.project != widget.project) _load();
  }

  void _load() {
    final api = context.read<AppState>().api;
    setState(() {
      _future = api.projectKanban(widget.project);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<KanbanTask>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}',
                style: const TextStyle(color: AppTheme.textSecondary)),
          );
        }
        final tasks = snap.data ?? [];
        final byCol = <String, List<KanbanTask>>{};
        for (final c in widget.columns) {
          byCol[c.id] = [];
        }
        for (final t in tasks) {
          byCol[t.status]?.add(t);
        }
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          children: [
            for (final c in widget.columns)
              SizedBox(
                width: 280,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ColumnView(
                    column: c,
                    tasks: byCol[c.id] ?? [],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ColumnView extends StatelessWidget {
  final _Column column;
  final List<KanbanTask> tasks;
  const _ColumnView({required this.column, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  column.label,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Empty',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final t = tasks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: KanbanCard(
                          task: t,
                          onTap: () => _showTaskDetail(context, t),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetail(BuildContext context, KanbanTask task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgTertiary,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (c, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _Chip(text: task.priority, color: _priorityColor(task.priority)),
                  _Chip(text: task.status, color: AppTheme.accent),
                  _Chip(text: 'risk: ${task.risk}', color: AppTheme.textSecondary),
                ],
              ),
              if (task.description != null) ...[
                const SizedBox(height: 16),
                Text(task.description!,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),
              ],
              if (task.why != null && task.why!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Why',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(task.why!,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4)),
              ],
              const SizedBox(height: 24),
              if (task.isOpen) ...[
                const Text('Move to',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final status in ['backlog', 'in_progress', 'blocked', 'done'])
                      if (status != task.status)
                        ActionChip(
                          label: Text(status),
                          onPressed: () async {
                            final api = context.read<AppState>().api;
                            try {
                              await api.moveTask(task.id, status);
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Move failed: $e')),
                                );
                              }
                            }
                          },
                        ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return const Color(0xFFef4444);
      case 'medium':
        return const Color(0xFFf59e0b);
      default:
        return AppTheme.textSecondary;
    }
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
