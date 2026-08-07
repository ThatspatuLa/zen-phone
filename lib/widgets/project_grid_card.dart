import 'package:flutter/material.dart';

import '../models/project.dart';
import '../theme/app_theme.dart';

class ProjectGridCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  const ProjectGridCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = project.colorInt;
    final lastActive = project.lastActive;
    final lastActiveText = lastActive == null
        ? 'no activity'
        : _formatRelative(lastActive);
    final hasOpen = project.hasOpenTasks;

    return Material(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: project.hasSession ? Color(color) : AppTheme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.label,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasOpen)
                Text(
                  project.nextAction ?? 'In progress',
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              else
                const Text(
                  'No open tasks',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat(badge: '${project.backlogCount}', label: 'back', color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  _Stat(badge: '${project.inProgressCount}', label: 'ip', color: AppTheme.accent),
                  if (project.blockedCount > 0) ...[
                    const SizedBox(width: 8),
                    _Stat(badge: '${project.blockedCount}', label: 'block', color: const Color(0xFFef4444)),
                  ],
                  const Spacer(),
                  Text(
                    lastActiveText,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}

class _Stat extends StatelessWidget {
  final String badge;
  final String label;
  final Color color;
  const _Stat({required this.badge, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$badge $label',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
