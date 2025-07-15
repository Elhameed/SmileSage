import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isSending = false;

  // Gemini endpoint
  static const String _geminiEndpoint =
      "https://teniola04-gemini-dental-chat.hf.space/chat";

  // Context from the scan (if any)
  Map<String, dynamic>? _scanContext;

  // User profile image (base64)
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _messages.clear(); // Always start fresh

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        _messages.add(_ChatMessage(
          text: AppLocalizations.of(context)!.chatGreeting,
          isUser: false,
        ));
        if (arguments != null && arguments is Map<String, dynamic>) {
          _scanContext = arguments;
          final condition = _scanContext!['condition'] ?? 'a dental condition';
          final confidence = _scanContext!['confidence'] != null
              ? '${(_scanContext!['confidence']! * 100).toStringAsFixed(1)}% confidence'
              : '';
          _messages.add(_ChatMessage(
            text: AppLocalizations.of(context)!
                .scanContextMessage(condition, confidence),
            isUser: false,
          ));
        }
      });
    });
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    // Load the user's profile image from SharedPreferences (base64)
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageBase64 = prefs.getString('profile_image');
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Prepare the messages for Gemini
      final List<Map<String, dynamic>> geminiMessages = [
        // System prompt
        {
          "role": "user",
          "content":
              "You are a dental health assistant. Respond with clear, evidence-based short answers about oral hygiene, dental diseases, and oral care. If the question is outside this domain, politely explain that you're limited to dental topics."
        },
        // Then the entire chat history including the context message and user messages
        ..._messages
            .map((msg) => {
                  "role": msg.isUser ? "user" : "model",
                  "content": msg.text,
                })
            .toList(),
      ];

      final response = await http.post(
        Uri.parse(_geminiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "system_prompt":
              "You are a dental health assistant. Respond with clear, evidence-based short answers about oral hygiene, dental diseases, and oral care. If the question is outside this domain, politely explain that you're limited to dental topics.",
          "messages": geminiMessages,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _messages.add(_ChatMessage(
            text: jsonResponse['response'],
            isUser: false,
          ));
        });
      } else {
        _showError(AppLocalizations.of(context)!
            .chatError('API Error: ${response.statusCode}'));
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.chatError('Error: $e'));
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add(_ChatMessage(
        text: message,
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
                  final author = msg.isUser
                      ? AppLocalizations.of(context)!.you
                      : AppLocalizations.of(context)!.smileSage;
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
                              _profileImageBase64 != null &&
                                      _profileImageBase64!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 16,
                                      backgroundImage: MemoryImage(
                                          base64Decode(_profileImageBase64!)),
                                    )
                                  : CircleAvatar(
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
                  hintText: AppLocalizations.of(context)!.typeAMessage,
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
                  suffixIcon: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF7CF4A4),
                            ),
                          ),
                        )
                      : IconButton(
                          icon:
                              const Icon(Icons.send, color: Color(0xFF7CF4A4)),
                          onPressed: _sendMessage,
                        ),
                ),
                onSubmitted: (text) => _sendMessage(),
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
