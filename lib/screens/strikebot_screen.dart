import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../services/strikebot_service.dart';

class StrikeBotScreen extends StatefulWidget {
  const StrikeBotScreen({super.key});

  @override
  State<StrikeBotScreen> createState() => _StrikeBotScreenState();
}

class _StrikeBotScreenState extends State<StrikeBotScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Halo Angler! 🎣 Saya StrikeBot, AI Assistant memancingmu. Tanyakan apa saja tentang teknik strike, rekomendasi umpan, waktu terbaik, atau rahasia spot!',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? quickText]) async {
    final text = quickText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (quickText == null) _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _scrollToBottom();

    final historyToSend = List<ChatMessage>.from(_messages.sublist(1, _messages.length - 1));
    final botReply = await StrikeBotService.getBotResponse(
      text,
      conversationHistory: historyToSend,
    );

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: botReply, isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    const quickPrompts = [
      'Umpan terbaik Kakap Merah?',
      'Rekomendasi umpan ikan Gabus',
      'Kapan waktu terbaik mancing?',
      'Tips memilih ukuran senar PE',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text('StrikeBot AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Quick Prompts Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final prompt = quickPrompts[index];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12, color: AppColors.primaryDark)),
                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.6),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: msg.isUser ? AppColors.primaryGradient : null,
                      color: msg.isUser ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppRadius.lg),
                        topRight: const Radius.circular(AppRadius.lg),
                        bottomLeft: Radius.circular(msg.isUser ? AppRadius.lg : 2),
                        bottomRight: Radius.circular(msg.isUser ? 2 : AppRadius.lg),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading typing indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  borderRadius: AppRadius.pill,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('StrikeBot sedang mengetik...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tanya umpan, cuaca, atau taktik...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
