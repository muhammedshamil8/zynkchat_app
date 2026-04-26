enum MessageStatus { sent, delivered, seen }

class MessageModel {
  final String id;
  final String sender;
  final String receiver;
  final String content;
  final MessageStatus status;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Backend can send populated user object OR just the ID string
    String getUserId(dynamic userData) {
      if (userData is Map) return userData['_id'] ?? '';
      return userData.toString();
    }

    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      sender: getUserId(json['sender'] ?? json['senderId']),
      receiver: getUserId(json['receiver'] ?? json['receiverId']),
      content: json['content'] ?? '',
      status: parseStatus(json['status'] ?? 'sent'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()).toLocal(),
    );
  }

  static MessageStatus parseStatus(String? status) {
    switch (status) {
      case 'delivered': return MessageStatus.delivered;
      case 'seen': return MessageStatus.seen;
      default: return MessageStatus.sent;
    }
  }

  bool isMe(String myId) => sender == myId;
}
