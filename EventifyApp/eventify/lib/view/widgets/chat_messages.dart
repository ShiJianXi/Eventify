import 'package:eventify/model/message.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'message_bubble.dart';
import '../../provider/firebase_provider.dart';
import 'empty_widget.dart';
import 'message_bubble.dart';

class ChatMessages extends StatelessWidget {
  ChatMessages({super.key, required this.receiverId});
  final String receiverId;

  final messages = [
    Message(
        senderId: '2',
        receiverId: '1',
        content: 'Hello',
        sentTime: DateTime.now(),
        messageType: MessageType.text),
    Message(
        senderId: '1',
        receiverId: '2',
        content: 'How are you?',
        sentTime: DateTime.now(),
        messageType: MessageType.text),
    Message(
        senderId: '2',
        receiverId: '1',
        content: 'Fine',
        sentTime: DateTime.now(),
        messageType: MessageType.text),
    Message(
        senderId: '1',
        receiverId: '2',
        content: 'What are you doing?',
        sentTime: DateTime.now(),
        messageType: MessageType.text),
    Message(
        senderId: '2',
        receiverId: '1',
        content: 'Nothing',
        sentTime: DateTime.now(),
        messageType: MessageType.text),
    Message(
        senderId: '1',
        receiverId: '2',
        content: 'Can you help me?',
        sentTime: DateTime.now(),
        messageType: MessageType.text),
    Message(
        senderId: '2',
        receiverId: '1',
        content:
            'https://images.unsplash.com/photo-1669992755631-3c46eccbeb7d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMHx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60',
        sentTime: DateTime.now(),
        messageType: MessageType.image),
  ];

  @override
  Widget build(BuildContext context) => Consumer<FirebaseProvider>(
        builder: (context, value, child) => value.messages.isEmpty
            ? const Expanded(
                child: EmptyWidget(icon: Icons.waving_hand, text: 'Say Hello!'),
              )
            : Expanded(
                child: ListView.builder(
                  controller:
                      Provider.of<FirebaseProvider>(context, listen: false)
                          .scrollController,
                  itemCount: value.messages.length,
                  itemBuilder: (context, index) {
                    final isTextMessage =
                        value.messages[index].messageType == MessageType.text;
                    final isMe = receiverId != value.messages[index].senderId;

                    return isTextMessage
                        ? MessageBubble(
                            isMe: isMe,
                            message: value.messages[index],
                            isImage: false,
                          )
                        : MessageBubble(
                            isMe: isMe,
                            message: value.messages[index],
                            isImage: true,
                          );
                  },
                ),
              ),
      );
}
