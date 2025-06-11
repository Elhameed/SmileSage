import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Hi there! How can I help you today?', isUser: false),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const botAvatar = 'assets/images/avatar_bot.png';
    const userAvatar = 'assets/images/avatar.png';
    const botBubbleColor = Color(0xFFF3F5F7); // very light grey
    const userBubbleColor = Color(0xFFE8F4EC); // pale mint
    const bubbleTextColor = Color(0xFF0A244E); // navy text
    const inputFill = Color(0xFFE8F4EC); // same pale mint

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final msg = _messages[i];
                  final author = msg.isUser ? 'You' : 'SmileSage';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: msg.isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // Author label
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Avatar + bubble row
                        Row(
                          mainAxisAlignment: msg.isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!msg.isUser) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage(botAvatar),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: msg.isUser
                                      ? userBubbleColor
                                      : botBubbleColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: bubbleTextColor,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                            if (msg.isUser) ...[
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage(userAvatar),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Input field
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 8,
                top: 8,
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  filled: true,
                  fillColor: inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF7CF4A4)),
                    onPressed: _sendMessage,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
