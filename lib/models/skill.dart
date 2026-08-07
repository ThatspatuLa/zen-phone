/// Skill — read-only entry from the skills list endpoint.
class Skill {
  final String id;
  final String name;
  final String? description;
  final String level; // 'core' | 'expert' | 'standard' | 'reference'
  final DateTime? lastUsed;
  final int weeklyCount;
  final int totalCount;

  const Skill({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    this.lastUsed,
    required this.weeklyCount,
    required this.totalCount,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'] as String,
        name: json['name'] as String? ?? json['id'] as String,
        description: json['description'] as String?,
        level: json['level'] as String? ?? 'standard',
        lastUsed: json['lastUsed'] != null
            ? DateTime.tryParse(json['lastUsed'] as String)
            : null,
        weeklyCount: json['weeklyCount'] as int? ?? 0,
        totalCount: json['totalCount'] as int? ?? 0,
      );
}

/// A single skill's full content (loaded on tap).
class SkillDetail {
  final String id;
  final String name;
  final String content; // full markdown body
  final List<String> triggers;

  const SkillDetail({
    required this.id,
    required this.name,
    required this.content,
    required this.triggers,
  });

  factory SkillDetail.fromJson(Map<String, dynamic> json) => SkillDetail(
        id: json['id'] as String,
        name: json['name'] as String? ?? json['id'] as String,
        content: json['content'] as String? ?? '',
        triggers: (json['triggers'] as List?)?.cast<String>() ?? const [],
      );
}
