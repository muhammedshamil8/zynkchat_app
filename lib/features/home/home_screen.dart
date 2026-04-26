import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../auth/user_model.dart';
import '../auth/profile_screen.dart';
import '../chat/chat_screen.dart';
import 'conversation_provider.dart';
import 'search_screen.dart';
import 'user_list_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final conversations = ref.watch(conversationProvider);
    final users = ref.watch(userListProvider);

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
            onPressed: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discover People Section
            if (users.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('DISCOVER PEOPLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white54)),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final otherUser = users[index];
                    if (otherUser.id == user?.id) return const SizedBox.shrink();

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(receiver: otherUser),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.indigoAccent.withOpacity(0.1),
                                  child: Text(otherUser.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                if (otherUser.isOnline)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF0F172A), width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(otherUser.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16, color: Colors.white10),
            ],

            // Conversations Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('RECENT CHATS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white54)),
            ),
            if (conversations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      const Text('No messages yet', style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final convo = conversations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(convo.otherUserName[0].toUpperCase()),
                    ),
                    title: Text(convo.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(convo.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      DateFormat('hh:mm a').format(convo.lastMessageTime),
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiver: UserModel(
                              id: convo.otherUserId,
                              name: convo.otherUserName,
                              email: '',
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
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

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
