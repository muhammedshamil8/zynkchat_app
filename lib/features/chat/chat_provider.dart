import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../auth/auth_provider.dart';
import 'message_model.dart';
import '../../core/constants/api_constants.dart';



class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;

  ChatState({this.messages = const [], this.isLoading = false});

  ChatState copyWith({List<MessageModel>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Using Notifier (Riverpod 3.0 compatible)
class ChatNotifier extends Notifier<ChatState> {
  late String _receiverId;

  @override
  ChatState build() => ChatState();

  void init(String receiverId) {
    _receiverId = receiverId;
    _fetchHistory();
    _setupListeners();
  }

  void _setupListeners() {
    final socketService = ref.read(socketProvider);
    
    socketService.socket.on('newMessage', (data) {
      final message = MessageModel.fromJson(data);
      if (message.sender == _receiverId || message.receiver == _receiverId) {
        state = state.copyWith(messages: [...state.messages, message]);
      }
    });

    socketService.socket.on('messageStatusUpdate', (data) {
      final String messageId = data['messageId'];
      final String status = data['status'];
      
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == messageId) {
            return MessageModel(
              id: m.id,
              sender: m.sender,
              receiver: m.receiver,
              content: m.content,
              status: MessageModel.parseStatus(status),
              createdAt: m.createdAt,
            );
          }
          return m;
        }).toList(),
      );
    });
  }

  Future<void> _fetchHistory() async {
    final api = ref.read(apiServiceProvider);
    state = state.copyWith(isLoading: true);
    try {
      final response = await api.get('${ApiConstants.chat}/history/$_receiverId');
      if (response.data['success']) {
        final List data = response.data['data'];
        final history = data.map((m) => MessageModel.fromJson(m)).toList();
        state = state.copyWith(messages: history, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty) return;
    
    final myUser = ref.read(authProvider).user;
    if (myUser == null) return;

    // Add message optimistically to the UI
    final optimisticMessage = MessageModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      sender: myUser.id,
      receiver: _receiverId,
      content: content,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, optimisticMessage]);

    ref.read(socketProvider).emit('sendMessage', {
      'receiverId': _receiverId,
      'content': content,
    });
  }
}

// Define the provider family using the Notifier
final chatProviderFamily = NotifierProvider.family<ChatNotifier, ChatState, String>((id) {
  return ChatNotifier();
});
