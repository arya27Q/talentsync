import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  ChatMessage(this.text, this.isMe);
}

class MentorChatScreen extends StatefulWidget {
  const MentorChatScreen({super.key});

  @override
  State<MentorChatScreen> createState() => _MentorChatScreenState();
}

class _MentorChatScreenState extends State<MentorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> messages = [
    ChatMessage('Hi Arya, how can I help you today with your Flutter architecture?', false),
    ChatMessage('Hello Pak Budi! I am confused about where to put my business logic in Feature-First approach.', true),
    ChatMessage('No problem! Let\'s start a quick video call so I can share my screen.', false),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      messages.add(ChatMessage(_messageController.text, true));
    });
    _messageController.clear();
    _scrollToBottom();

    // Fake Auto-Reply for Demo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          messages.add(ChatMessage("Silakan join link video call-nya ya. Saya sudah standby di room.", false));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(color: Color(0xFF6A1B9A), shape: BoxShape.circle), // Purple color from image
              child: const Center(child: Text('BS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isMe ? const Color(0xFFB88656) : Colors.white, // primaryTan for me, white for mentor
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isMe ? 20 : 0),
                  bottomRight: Radius.circular(message.isMe ? 0 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(color: message.isMe ? Colors.white : AppColors.darkBrown, height: 1.5, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.attach_file_rounded, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primaryTan,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Floating Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warmOffWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.keyboard_arrow_left_rounded, color: AppColors.darkBrown),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Mentoring Session',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.videoCall),
                    child: const Icon(Icons.videocam_rounded, color: AppColors.darkBrown),
                  ),
                ],
              ),
            ),
            
            // Session Timer Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text('Session in Progress', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('45:00', style: TextStyle(color: AppColors.darkBrown, fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('mins remaining', style: TextStyle(color: AppColors.primaryTan, fontSize: 12)),
                ],
              ),
            ),

            // Chat bubbles
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildBubble(messages[index]);
                },
              ),
            ),
            
            // Footer Chat Input
            _buildChatInput(),
          ],
        ),
      ),
    );
  }
}
