import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../auth/user_model.dart';
import '../auth/profile_screen.dart';
import '../chat/chat_screen.dart';
import 'conversation_provider.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final conversations = ref.watch(conversationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZynkChat', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('No conversations yet', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                ],
              ),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Text(convo.otherUserName[0].toUpperCase()),
                  ),
                  title: Text(convo.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(convo.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    DateFormat('hh:mm a').format(convo.lastMessageTime),
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiver: UserModel(
                            id: convo.otherUserId,
                            name: convo.otherUserName,
                            email: '', // Not needed for chat screen
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
