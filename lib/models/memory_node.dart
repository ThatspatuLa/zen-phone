/// MemoryNode — one item in the Obsidian vault tree.
class MemoryNode {
  final String name;
  final String path; // relative to vault root
  final bool isDirectory;
  final int? sizeBytes; // for files only
  final DateTime? modified;

  const MemoryNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.sizeBytes,
    this.modified,
  });

  factory MemoryNode.fromJson(Map<String, dynamic> json) => MemoryNode(
        name: json['name'] as String,
        path: json['path'] as String,
        isDirectory: json['isDirectory'] as bool? ?? false,
        sizeBytes: json['sizeBytes'] as int?,
        modified: json['modified'] != null
            ? DateTime.tryParse(json['modified'] as String)
            : null,
      );
}

/// Recent memory activity entry — used by the activity feed.
class MemoryActivity {
  final String path;
  final String kind; // 'modified' | 'created' | 'deleted'
  final DateTime when;

  const MemoryActivity({
    required this.path,
    required this.kind,
    required this.when,
  });

  factory MemoryActivity.fromJson(Map<String, dynamic> json) => MemoryActivity(
        path: json['path'] as String,
        kind: json['kind'] as String? ?? 'modified',
        when: DateTime.tryParse(json['when'] as String? ?? '') ?? DateTime.now(),
      );
}
