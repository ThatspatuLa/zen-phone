/// Skills — read-only list with level, last used, weekly count.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/skill.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  late Future<List<Skill>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final api = context.read<AppState>().api;
    setState(() {
      _future = api.skillsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
        leading: Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          );
        }),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (s) => setState(() => _search = s),
              style: const TextStyle(color: AppTheme.text),
              decoration: const InputDecoration(
                hintText: 'Search skills',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Skill>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: AppTheme.textMuted)));
                }
                var skills = snap.data ?? [];
                if (_search.isNotEmpty) {
                  final q = _search.toLowerCase();
                  skills = skills.where((s) => s.name.toLowerCase().contains(q)).toList();
                }
                // Sort by weekly count descending
                skills.sort((a, b) => b.weeklyCount.compareTo(a.weeklyCount));
                if (skills.isEmpty) {
                  return const Center(child: Text('No skills found', style: TextStyle(color: AppTheme.textMuted)));
                }
                return RefreshIndicator(
                  onRefresh: () async => _load(),
                  child: ListView.separated(
                    itemCount: skills.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (ctx, i) => _SkillRow(skill: skills[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final Skill skill;
  const _SkillRow({required this.skill});

  Color get _levelColor {
    switch (skill.level.toLowerCase()) {
      case 'core':
        return AppTheme.accent;
      case 'expert':
        return const Color(0xFF10b981);
      case 'reference':
        return AppTheme.textMuted;
      default:
        return const Color(0xFF3b82f6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(skill.name, style: const TextStyle(color: AppTheme.text, fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _levelColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                skill.level,
                style: TextStyle(color: _levelColor, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              skill.lastUsed == null ? 'never used' : 'last: ${_ago(skill.lastUsed!)}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
            const SizedBox(width: 8),
            Text(
              '${skill.weeklyCount}/wk',
              style: const TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.bgElevated,
          isScrollControlled: true,
          builder: (ctx) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            builder: (c, scroll) => SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill.name,
                      style: const TextStyle(color: AppTheme.text, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    'level: ${skill.level} · last used: ${skill.lastUsed == null ? "never" : _ago(skill.lastUsed!)} · ${skill.weeklyCount}/wk · ${skill.totalCount} total',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (skill.description != null)
                    Text(
                      skill.description!,
                      style: const TextStyle(color: AppTheme.text, fontSize: 13, height: 1.4),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Full content available on desktop only.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _ago(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
