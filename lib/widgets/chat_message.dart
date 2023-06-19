import 'package:chat_firebase/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshotData) {
        if (snapshotData.connectionState == ConnectionState.waiting) {
          const Center(child: CircularProgressIndicator());
        }
        if (!snapshotData.hasData || snapshotData.data!.docs.isEmpty) {
          const Center(
            child: Text('No Message Found'),
          );
        }
        if (snapshotData.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }
        final loadedMessage = snapshotData.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessage.length,
            itemBuilder: (context, idx) {
              final chatMessage = loadedMessage[idx].data();
              final nextChatMessage = idx + 1 < loadedMessage.length
                  ? loadedMessage[idx + 1].data()
                  : null;

              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}
