import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/project.dart';
import '../models/memory_node.dart';
import '../widgets/project_grid_card.dart';

/// Home — "The Pulse". One-glance status of all 7 projects + activity feed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refresh() {
    final api = context.read<AppState>().api;
    setState(() {
      _future = _loadHome(api);
    });
  }

  Future<_HomeData> _loadHome(api) async {
    final projects = await api.projectsSummary();
    final activity = await api.memoryActivity();
    return _HomeData(projects: projects, activity: activity);
  }

  Future<void> _onRefresh() async {
    _refresh();
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse'),
        leading: Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          );
        }),
      ),
      drawer: null, // provided by app shell
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorState(error: snap.error.toString(), onRetry: _refresh);
            }
            final data = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader('Projects'),
                const SizedBox(height: 12),
                _ProjectsGrid(projects: data.projects),
                const SizedBox(height: 24),
                const _SectionHeader('Activity'),
                const SizedBox(height: 8),
                if (data.activity.isEmpty)
                  const _EmptyHint(text: 'No recent memory activity.')
                else
                  ...data.activity.take(20).map((a) => _ActivityRow(item: a)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeData {
  final List<Project> projects;
  final List<MemoryActivity> activity;
  _HomeData({required this.projects, required this.activity});
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(text, style: const TextStyle(color: AppTheme.textMuted)),
      );
}

class _ProjectsGrid extends StatelessWidget {
  final List<Project> projects;
  const _ProjectsGrid({required this.projects});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: projects.length,
      itemBuilder: (ctx, i) {
        final p = projects[i];
        return ProjectGridCard(
          project: p,
          onTap: () {
            state.selectProject(p.id);
            Navigator.of(context).pushNamed('chat', arguments: p.id);
          },
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final MemoryActivity item;
  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final fmt = item.kind == 'created' ? '+' : '·';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              fmt,
              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              item.path,
              style: const TextStyle(color: AppTheme.text, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _ago(item.when),
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _ago(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: AppTheme.textMuted, size: 48),
          const SizedBox(height: 16),
          const Text('Cannot reach desktop',
              style: TextStyle(color: AppTheme.text, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
