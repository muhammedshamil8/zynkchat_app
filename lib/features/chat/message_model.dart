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
    return MessageModel(
      id: json['_id'] ?? '',
      sender: json['sender'] is Map ? json['sender']['_id'] : json['sender'],
      receiver: json['receiver'] is Map ? json['receiver']['_id'] : json['receiver'],
      content: json['content'],
      status: parseStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
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
