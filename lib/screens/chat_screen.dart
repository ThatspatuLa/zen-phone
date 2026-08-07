import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';

/// Chat — thread style like ChatGPT/Claude mobile. Text + voice input.
class ChatScreen extends StatefulWidget {
  final String? initialProject;
  const ChatScreen({super.key, this.initialProject});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _isListening = false;
  bool _isSending = false;
  String _project = 'zen';
  List<ChatMessage> _messages = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    if (widget.initialProject != null) {
      state.selectProject(widget.initialProject);
      _project = widget.initialProject!;
    } else if (state.currentProject != null) {
      _project = state.currentProject!;
    }
    _loadHistory();
    _initSpeech();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onError: (e) => debugPrint('Speech error: $e'),
      onStatus: (s) => debugPrint('Speech status: $s'),
    );
  }

  Future<void> _loadHistory() async {
    final api = context.read<AppState>().api;
    try {
      final msgs = await api.chatHistory(_project);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loaded = true);
      }
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(role: 'user', text: text, timestamp: DateTime.now()));
      _input.clear();
    });
    _scrollToBottom();
    final api = context.read<AppState>().api;
    try {
      final reply = await api.sendPrompt(_project, text);
      if (mounted) {
        setState(() {
          _messages.add(reply);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
              role: 'system',
              text: 'Error: $e',
              timestamp: DateTime.now()));
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleListen() async {
    if (!_speechReady) {
      final granted = await _speech.initialize();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech permission denied')),
          );
        }
        return;
      }
      _speechReady = true;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _input.text = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
            selected: _project,
            onSelect: (p) {
              setState(() {
                _project = p;
                _messages = [];
                _loaded = false;
              });
              context.read<AppState>().selectProject(p);
              _loadHistory();
            },
          ),
          Expanded(
            child: !_loaded
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _EmptyChat(project: _project)
                    : _MessageList(messages: _messages, scroll: _scroll),
          ),
          _InputBar(
            controller: _input,
            onSend: _send,
            onMic: _toggleListen,
            isListening: _isListening,
            isSending: _isSending,
          ),
        ],
      ),
    );
  }
}

class _ProjectSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _ProjectSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final projects = ['zen', 'kiyosaki', 'minato', 'nami', 'rin', 'toji', 'kazuki'];
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
                backgroundColor: AppTheme.bgElevated,
                labelStyle: TextStyle(
                  color: selected == p ? AppTheme.accent : AppTheme.text,
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

class _EmptyChat extends StatelessWidget {
  final String project;
  const _EmptyChat({required this.project});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, color: AppTheme.textMuted, size: 56),
            const SizedBox(height: 16),
            Text(
              'Send a prompt to $project',
              style: const TextStyle(color: AppTheme.text, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type below or tap the mic to talk.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scroll;
  const _MessageList({required this.messages, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (ctx, i) => _MessageBubble(message: messages[i]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isSystem = message.role == 'system';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: isSystem
                    ? AppTheme.bgElevated
                    : (isUser ? AppTheme.accent : AppTheme.bgCard),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 14),
                ),
                border: isSystem ? Border.all(color: const Color(0xFFef4444), width: 0.5) : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isSystem ? const Color(0xFFef4444) : (isUser ? Colors.black : AppTheme.text),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final bool isListening;
  final bool isSending;
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onMic,
    required this.isListening,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? AppTheme.accent : AppTheme.textMuted,
              ),
              onPressed: onMic,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(color: AppTheme.text),
                  decoration: const InputDecoration(
                    hintText: 'Send a prompt',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: isSending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                    )
                  : const Icon(Icons.send, color: AppTheme.accent),
              onPressed: isSending ? null : onSend,
            ),
          ],
        ),
      ),
    );
  }
}
