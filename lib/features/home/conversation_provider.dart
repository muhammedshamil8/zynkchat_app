import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';
import '../../core/constants/api_constants.dart';

class ConversationModel {
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      otherUserId: json['otherUser']['_id'],
      otherUserName: json['otherUser']['name'],
      lastMessage: json['lastMessage']['content'],
      lastMessageTime: DateTime.parse(json['lastMessage']['createdAt']),
    );
  }
}

class ConversationNotifier extends Notifier<List<ConversationModel>> {
  @override
  List<ConversationModel> build() {
    Future.microtask(() => fetchConversations());
    return [];
  }

  Future<void> fetchConversations() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.get('${ApiConstants.chat}/conversations');
      if (response.data['success']) {
        final List data = response.data['data'];
        state = data.map((json) => ConversationModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error
    }
  }
}

final conversationProvider = NotifierProvider<ConversationNotifier, List<ConversationModel>>(ConversationNotifier.new);
