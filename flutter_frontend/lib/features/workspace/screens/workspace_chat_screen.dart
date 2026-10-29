import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final String? attachment;
  ChatMessage(this.text, this.isMe, {this.attachment});
}

class WorkspaceChatScreen extends StatefulWidget {
  const WorkspaceChatScreen({super.key});

  @override
  State<WorkspaceChatScreen> createState() => _WorkspaceChatScreenState();
}

class _WorkspaceChatScreenState extends State<WorkspaceChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> messages = [
    ChatMessage('Hello! Are you ready to start working on the wireframes?', false),
    ChatMessage('Yes, I am! I have reviewed the requirements you sent earlier.', true),
    ChatMessage('Great. I attached the brand guidelines for your reference.', false, attachment: 'Brand_Guidelines.pdf'),
    ChatMessage('Thanks, I will take a look. I should have the first draft ready by tomorrow.', true),
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
          messages.add(ChatMessage("Siap! Ditunggu updatenya ya mas bro. Nanti kita review bareng di sesi meeting.", false));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200, // Extra padding
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
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(color: Color(0xFF8C5E3C), shape: BoxShape.circle),
              child: const Center(child: Text('BN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.primaryTan : Colors.white,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.attachment != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFFF8F00)),
                          const SizedBox(width: 8),
                          Text(message.attachment!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8F00), fontSize: 12)),
                        ],
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(color: message.isMe ? Colors.white : AppColors.darkBrown, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(color: AppColors.darkBrown, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 16)),
            ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24),
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
                            'Messages',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                          ),
                        ],
                      ),
                      Row(
                        children: [

                          
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Chat bubbles
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: messages.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Center(child: Text('Today, 10:42 AM', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                        );
                      }
                      if (index == messages.length + 1) {
                        return const SizedBox(height: 180);
                      }
                      return _buildBubble(messages[index - 1]);
                    },
                  ),
                ),
                
            // Footer Section (Stacked neatly)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Swipe to Complete
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.submission);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFB88656), Color(0xFF8C5E3C)]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8C5E3C).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_right_alt_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Swipe to Complete Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                _buildChatInput(),
                
                const SizedBox(height: 16),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}