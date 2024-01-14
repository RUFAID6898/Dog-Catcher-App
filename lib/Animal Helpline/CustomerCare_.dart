import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({super.key});

  @override
  _CustomerCareScreenState createState() => _CustomerCareScreenState();
}

class _CustomerCareScreenState extends State<CustomerCareScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Customer Care'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs.reversed;
                List<MessageBubble> messageBubbles = [];

                for (var message in messages) {
                  var messageText = message['text'];
                  var messageSender = message['sender'];

                  var messageBubble = MessageBubble(
                    sender: messageSender,
                    text: messageText,
                    isMe: _auth.currentUser?.uid == messageSender,
                  );

                  messageBubbles.add(messageBubble);
                }

                return ListView(
                  reverse: true,
                  children: messageBubbles,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    await _sendMessage();
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    try {
      String messageText = _messageController.text;
      if (messageText.trim().isNotEmpty) {
        await _firestore.collection('messages').add({
          'text': messageText,
          'sender': _auth.currentUser?.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _messageController.clear();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String text;
  final bool isMe;

  MessageBubble({required this.sender, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender ?? 'Unknown',
            style: const TextStyle(fontSize: 12.0),
          ),
          Material(
            borderRadius: BorderRadius.circular(8.0),
            elevation: 5.0,
            color: isMe ? Colors.blue : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
