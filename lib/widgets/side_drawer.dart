import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SideDrawer extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onNavigate;

  const SideDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _DrawerItem('home', Icons.home, 'Home'),
      _DrawerItem('kanban', Icons.view_kanban, 'Kanban'),
      _DrawerItem('chat', Icons.chat_bubble_outline, 'Chat'),
      _DrawerItem('skills', Icons.layers, 'Skills'),
      _DrawerItem('memory', Icons.account_tree, 'Memory'),
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Zen',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              _DrawerRow(
                item: item,
                isSelected: currentRoute == item.id,
                onTap: () {
                  Navigator.of(context).pop();
                  onNavigate(item.id);
                },
              ),
            const Divider(height: 32, color: AppTheme.border),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'PROJECTS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _ProjectRow(id: 'zen', label: 'Zen', color: const Color(0xFF6366f1)),
                  _ProjectRow(id: 'kiyosaki', label: 'Kiyosaki', color: const Color(0xFF10b981)),
                  _ProjectRow(id: 'minato', label: 'Minato', color: const Color(0xFFf59e0b)),
                  _ProjectRow(id: 'nami', label: 'Nami', color: const Color(0xFFef4444)),
                  _ProjectRow(id: 'rin', label: 'Rin', color: const Color(0xFF8b5cf6)),
                  _ProjectRow(id: 'toji', label: 'Toji', color: const Color(0xFF3b82f6)),
                  _ProjectRow(id: 'kazuki', label: 'Kazuki', color: const Color(0xFFec4899)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            ListTile(
              leading: const Icon(Icons.settings, color: AppTheme.textSecondary),
              title: const Text('Settings', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.of(context).pop();
                onNavigate('settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final String id;
  final IconData icon;
  final String label;
  const _DrawerItem(this.id, this.icon, this.label);
}

class _DrawerRow extends StatelessWidget {
  final _DrawerItem item;
  final bool isSelected;
  final VoidCallback onTap;
  const _DrawerRow({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 3,
                color: isSelected ? AppTheme.accent : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: isSelected ? AppTheme.accent : AppTheme.textSecondary),
              const SizedBox(width: 14),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final String id;
  final String label;
  final Color color;
  const _ProjectRow({required this.id, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final isActive = state.currentProject == id;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          state.selectProject(id);
          Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
