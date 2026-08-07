/// API client for the Zen backend running at agent_os_server.py.
///
/// Default base URL is the Tailscale mesh address of your desktop. Override
/// via Settings (stored in shared_preferences) when running off-network.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/project.dart';
import '../models/kanban_task.dart';
import '../models/chat_message.dart';
import '../models/skill.dart';
import '../models/memory_node.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _http;
  final Duration timeout;

  ApiClient({String? baseUrl, http.Client? httpClient, this.timeout = const Duration(seconds: 10)})
      : baseUrl = baseUrl ?? 'http://100.126.122.39:8765',
        _http = httpClient ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> _getJson(String path) async {
    final r = await _http.get(_uri(path)).timeout(timeout);
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, r.body);
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    final r = await _http
        .post(_uri(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(timeout);
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, r.body);
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  // ----- 1.1 Projects summary -----
  Future<List<Project>> projectsSummary() async {
    final j = await _getJson('/api/projects/summary');
    final list = (j['projects'] as List?) ?? const [];
    return list.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ----- 1.2 Project kanban -----
  Future<List<KanbanTask>> projectKanban(String projectId) async {
    final j = await _getJson('/api/projects/$projectId/kanban');
    final list = (j['tasks'] as List?) ?? const [];
    return list.map((e) => KanbanTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ----- 1.3 Single task detail -----
  Future<KanbanTask?> taskDetail(String taskId) async {
    try {
      final j = await _getJson('/api/kanban/task/$taskId');
      return KanbanTask.fromJson(j);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  // ----- 1.4 Move task -----
  Future<KanbanTask> moveTask(String taskId, String newStatus) async {
    final j = await _postJson('/api/kanban/task/$taskId/move', {'status': newStatus});
    return KanbanTask.fromJson(j['task'] as Map<String, dynamic>);
  }

  // ----- 1.5 Chat history -----
  Future<List<ChatMessage>> chatHistory(String project) async {
    final j = await _getJson('/api/chat/$project/history');
    final list = (j['messages'] as List?) ?? const [];
    return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ----- 1.6 Send prompt -----
  Future<ChatMessage> sendPrompt(String project, String text) async {
    final j = await _postJson('/api/chat/$project/send', {'text': text});
    return ChatMessage.fromJson(j['message'] as Map<String, dynamic>);
  }

  // ----- 1.8 Skills list -----
  Future<List<Skill>> skillsList() async {
    final j = await _getJson('/api/skills');
    final list = (j['skills'] as List?) ?? const [];
    return list.map((e) => Skill.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ----- 1.9 Memory vault tree -----
  Future<List<MemoryNode>> memoryVault() async {
    final j = await _getJson('/api/memory/vault');
    final list = (j['items'] as List?) ?? (j['children'] as List?) ?? const [];
    return list.map((e) => MemoryNode.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ----- 1.10 Memory file content -----
  Future<String> memoryFile(String path) async {
    final j = await _getJson('/api/memory/file?path=${Uri.encodeComponent(path)}');
    return j['content'] as String? ?? '';
  }

  // ----- 1.11 Memory activity -----
  Future<List<MemoryActivity>> memoryActivity() async {
    final j = await _getJson('/api/memory/activity');
    final list = (j['items'] as List?) ?? (j['activity'] as List?) ?? const [];
    return list.map((e) => MemoryActivity.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ----- 1.13 Agents status -----
  Future<List<Map<String, dynamic>>> agentsStatus() async {
    final j = await _getJson('/api/agents/status');
    final list = (j['agents'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  void close() => _http.close();
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException($statusCode): $body';
}
