import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../auth/auth_provider.dart';
import 'message_model.dart';
import '../../core/constants/api_constants.dart';

// Provider for SocketService
final socketProvider = Provider((ref) {
  final service = SocketService(ref.read(storageProvider));
  service.connect();
  return service;
});

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

// Modern Riverpod 3.0 FamilyNotifier
class ChatNotifier extends FamilyNotifier<ChatState, String> {
  @override
  ChatState build(String arg) {
    // Start initialization logic
    Future.microtask(() => _init());
    return ChatState();
  }

  String get _receiverId => arg;

  void _init() {
    final socketService = ref.read(socketProvider);
    
    fetchHistory();
    
    // Listen for incoming messages
    socketService.socket.on('newMessage', (data) {
      final message = MessageModel.fromJson(data);
      if (message.sender == _receiverId || message.receiver == _receiverId) {
        state = state.copyWith(messages: [...state.messages, message]);
      }
    });

    // Listen for status updates
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

  Future<void> fetchHistory() async {
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
    final socketService = ref.read(socketProvider);
    
    socketService.emit('sendMessage', {
      'receiverId': _receiverId,
      'content': content,
    });
  }
}

// Global Auth Provider Family
final chatProviderFamily = NotifierProvider.family<ChatNotifier, ChatState, String>(ChatNotifier.new);
