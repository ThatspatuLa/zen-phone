/// Memory — full Obsidian vault browser + activity feed.
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/memory_node.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  late Future<List<MemoryNode>> _future;
  String _path = ''; // empty = root
  late Future<List<MemoryActivity>> _activityFuture;

  @override
  void initState() {
    super.initState();
    _load();
    _loadActivity();
  }

  void _load() {
    final api = context.read<AppState>().api;
    setState(() {
      _future = api.memoryVault();
    });
  }

  void _loadActivity() {
    final api = context.read<AppState>().api;
    setState(() {
      _activityFuture = api.memoryActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        leading: Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          );
        }),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: AppTheme.bg,
              child: const TabBar(
                indicatorColor: AppTheme.accent,
                labelColor: AppTheme.text,
                unselectedLabelColor: AppTheme.textMuted,
                tabs: [
                  Tab(icon: Icon(Icons.folder), text: 'Vault'),
                  Tab(icon: Icon(Icons.timeline), text: 'Activity'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _VaultTab(
                    future: _future,
                    path: _path,
                    onRefresh: _load,
                    onNavigate: (p) => setState(() => _path = p),
                  ),
                  _ActivityTab(future: _activityFuture, onRefresh: _loadActivity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultTab extends StatelessWidget {
  final Future<List<MemoryNode>> future;
  final String path;
  final VoidCallback onRefresh;
  final ValueChanged<String> onNavigate;
  const _VaultTab({
    required this.future,
    required this.path,
    required this.onRefresh,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MemoryNode>>(
      future: future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: AppTheme.textMuted)));
        }
        var items = snap.data ?? [];
        // Filter by current path prefix
        if (path.isNotEmpty) {
          items = items.where((n) => n.path.startsWith(path) && n.path != path).toList();
        }
        // Sort: directories first, then files
        items.sort((a, b) {
          if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        if (items.isEmpty) {
          return const Center(child: Text('Empty directory', style: TextStyle(color: AppTheme.textMuted)));
        }
        return Column(
          children: [
            if (path.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: AppTheme.textMuted),
                title: const Text('..', style: TextStyle(color: AppTheme.text)),
                onTap: () {
                  final parts = path.split('/');
                  parts.removeLast();
                  onNavigate(parts.join('/'));
                },
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => onRefresh(),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final n = items[i];
                    return ListTile(
                      leading: Icon(
                        n.isDirectory ? Icons.folder : Icons.description,
                        color: n.isDirectory ? AppTheme.accent : AppTheme.textMuted,
                      ),
                      title: Text(n.name, style: const TextStyle(color: AppTheme.text)),
                      subtitle: n.modified != null
                          ? Text(_iso(n.modified!), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11))
                          : null,
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                      onTap: () {
                        if (n.isDirectory) {
                          onNavigate(n.path);
                        } else {
                          _openFile(context, n);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openFile(BuildContext context, MemoryNode node) {
    final api = context.read<AppState>().api;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgElevated,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (c, scroll) => FutureBuilder<String>(
          future: api.memoryFile(node.path),
          builder: (ctx, snap) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node.name,
                      style: const TextStyle(color: AppTheme.text, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(node.path, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: snap.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : snap.hasError
                            ? Text('Error: ${snap.error}', style: const TextStyle(color: AppTheme.textMuted))
                            : Markdown(
                                data: snap.data ?? '',
                                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                      p: const TextStyle(color: AppTheme.text, fontSize: 13, height: 1.4),
                                      h1: const TextStyle(color: AppTheme.text, fontSize: 20, fontWeight: FontWeight.w600),
                                      h2: const TextStyle(color: AppTheme.text, fontSize: 17, fontWeight: FontWeight.w600),
                                      h3: const TextStyle(color: AppTheme.text, fontSize: 15, fontWeight: FontWeight.w600),
                                      code: const TextStyle(color: AppTheme.accent, fontSize: 12),
                                      codeblockDecoration: BoxDecoration(
                                        color: AppTheme.bg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _iso(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} $h:$m';
  }
}

class _ActivityTab extends StatelessWidget {
  final Future<List<MemoryActivity>> future;
  final VoidCallback onRefresh;
  const _ActivityTab({required this.future, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: FutureBuilder<List<MemoryActivity>>(
        future: future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: AppTheme.textMuted)));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No activity', style: TextStyle(color: AppTheme.textMuted)));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
            itemBuilder: (ctx, i) {
              final a = items[i];
              return ListTile(
                leading: Icon(
                  a.kind == 'created' ? Icons.add_circle : Icons.edit,
                  color: a.kind == 'created' ? AppTheme.accent : AppTheme.textMuted,
                  size: 18,
                ),
                title: Text(a.path, style: const TextStyle(color: AppTheme.text, fontSize: 13)),
                subtitle: Text(_relative(a.when), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              );
            },
          );
        },
      ),
    );
  }

  String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}
