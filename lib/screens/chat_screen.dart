import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/vodafone_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, required this.time});
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
  bool _ended = false;
  int _lastPosition = 0;
  Timer? _pollTimer;

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
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    } catch (e) {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _poll() async {
    if (_chatId == null || _ended) return;
    try {
      final data =
          await VodafoneService.refreshChat(_chatId!, _lastPosition);
      if (data['transcriptPosition'] != null) {
        _lastPosition = data['transcriptPosition'];
      }
      final transcript = data['transcriptToShow'];
      if (transcript != null) {
        for (final msg in transcript) {
          if (msg is List && msg.isNotEmpty) {
            if (msg[0] == 'Notice.Joined' && !_agentJoined) {
              setState(() {
                _agentJoined = true;
                _connecting = false;
              });
            }
            if (msg.length >= 5 && msg[0] == 'Message.Text' && msg[4] == 'AGENT') {
              setState(() {
                _messages.add(ChatMessage(
                  text: msg[2].toString(),
                  isUser: false,
                  time: DateTime.now(),
                ));
              });
              _scrollDown();
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _chatId == null || !_agentJoined) return;
    _msgCtrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
    });
    _scrollDown();
    await VodafoneService.sendMessage(_chatId!, text);
  }

  Future<void> _endChat() async {
    _pollTimer?.cancel();
    if (_chatId != null) await VodafoneService.disconnect(_chatId!);
    setState(() => _ended = true);
    if (mounted) Navigator.pop(context);
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: AppTheme.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خدمة العملاء',
                    style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(
                  _connecting
                      ? 'جاري الاتصال...'
                      : _agentJoined
                          ? 'متصل'
                          : 'في الانتظار...',
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: _agentJoined ? Colors.greenAccent : AppTheme.grey),
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
                  style: GoogleFonts.cairo(
                      color: AppTheme.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
        ],
      ),
      body: Column(
        children: [
          // loading
          if (_connecting)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: AppTheme.darkSurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: AppTheme.red, strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text('جاري البحث عن موظف...',
                      style: GoogleFonts.cairo(
                          color: AppTheme.grey, fontSize: 13)),
                ],
              ),
            ),

          // رسائل
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(msg: _messages[i]),
            ),
          ),

          // إدخال
          if (_agentJoined)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              color: AppTheme.darkCard,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        style: GoogleFonts.cairo(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          hintStyle: GoogleFonts.cairo(
                              color: AppTheme.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.red,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.red.withOpacity(0.4),
                              blurRadius: 12),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
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
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.darkSurface : AppTheme.red,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? Radius.zero : const Radius.circular(16),
            bottomRight: isUser ? const Radius.circular(16) : Radius.zero,
          ),
          boxShadow: isUser
              ? []
              : [
                  BoxShadow(
                      color: AppTheme.red.withOpacity(0.2),
                      blurRadius: 8)
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('الموظف',
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600)),
              ),
            Text(msg.text,
                style: GoogleFonts.cairo(
                    fontSize: 14, color: Colors.white, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
