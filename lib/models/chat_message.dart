/// Chat message — single turn in a chat thread.
class ChatMessage {
  final String role; // 'user' | 'assistant' | 'system'
  final String text;
  final DateTime? timestamp;

  const ChatMessage({
    required this.role,
    required this.text,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String? ?? 'user',
        text: json['text'] as String? ?? json['content'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String)
            : null,
      );

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
