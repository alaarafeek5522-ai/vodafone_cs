import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/vodafone_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final String phone, firstName, lastName, tariff;
  const ChatScreen({
    super.key,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.tariff,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];

  String? _chatId;
  bool _connecting = true;
  bool _agentJoined = false;
  bool _disposed = false;
  int _lastPosition = 0;

  @override
  void initState() {
    super.initState();
    _startChat();
  }

  Future<void> _startChat() async {
    try {
      _chatId = await VodafoneService.createChatSession();
      await VodafoneService.joinChat(
        chatId: _chatId!,
        firstName: widget.firstName,
        lastName: widget.lastName,
        phone: widget.phone,
        tariff: widget.tariff,
      );
      _pollLoop();
    } catch (e) {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _pollLoop() async {
    while (!_disposed) {
      try {
        final data = await VodafoneService.refreshChat(_chatId!, _lastPosition);
        if (_disposed) break;

        if (data['transcriptPosition'] != null) {
          _lastPosition = data['transcriptPosition'];
        }

        final transcript = data['transcriptToShow'];
        if (transcript != null) {
          for (final msg in transcript) {
            if (_disposed) break;
            if (msg is! List || msg.isEmpty) continue;

            if (msg[0] == 'Notice.Joined' && !_agentJoined) {
              if (mounted) setState(() { _agentJoined = true; _connecting = false; });
            }

            if (msg.length >= 5 && msg[0] == 'Message.Text' && msg[4] == 'AGENT') {
              if (mounted) setState(() {
                _messages.add(ChatMessage(text: msg[2].toString(), isUser: false));
              });
              _scrollDown();
            }
          }
        }
      } catch (_) {}

      if (!_disposed) await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _chatId == null || !_agentJoined) return;
    _msgCtrl.clear();
    setState(() => _messages.add(ChatMessage(text: text, isUser: true)));
    _scrollDown();
    try { await VodafoneService.sendMessage(_chatId!, text); } catch (_) {}
  }

  Future<void> _endChat() async {
    _disposed = true;
    try { if (_chatId != null) await VodafoneService.disconnect(_chatId!); } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF141414) : Colors.white;
    final inputBg = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : const Color(0xFF0A0A0A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0.5,
        shadowColor: Colors.grey.withOpacity(0.2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خدمة العملاء',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
                Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _agentJoined ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      _connecting ? 'جاري الاتصال...' : _agentJoined ? 'متصل' : 'في الانتظار...',
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: _agentJoined ? Colors.green : Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_agentJoined)
            TextButton(
              onPressed: _endChat,
              child: Text('إنهاء',
                  style: GoogleFonts.cairo(color: AppTheme.red, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_connecting)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF3F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(color: AppTheme.red, strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text('جاري البحث عن موظف...',
                      style: GoogleFonts.cairo(color: AppTheme.red, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: Colors.grey.withOpacity(0.3), size: 52),
                        const SizedBox(height: 12),
                        Text(
                          _agentJoined ? 'ابدأ المحادثة' : 'في الانتظار...',
                          style: GoogleFonts.cairo(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _MessageBubble(msg: _messages[i]),
                  ),
          ),

          if (_agentJoined)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              decoration: BoxDecoration(
                color: appBarBg,
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.withOpacity(0.15)),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        style: GoogleFonts.cairo(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          hintStyle: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.red,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: AppTheme.red.withOpacity(0.35), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    final bubbleColor = isUser ? const Color(0xFF1565C0) : AppTheme.red;
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? Radius.zero : const Radius.circular(16),
            bottomRight: isUser ? const Radius.circular(16) : Radius.zero,
          ),
          boxShadow: [BoxShadow(color: bubbleColor.withOpacity(0.25), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isUser ? 'أنت' : 'الموظف',
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(msg.text,
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.white, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
