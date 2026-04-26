import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import 'storage_service.dart';
import '../features/auth/auth_provider.dart';

class SocketService {
  late io.Socket _socket;
  final StorageService _storage;
  final _messageController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageController.stream;

  SocketService(this._storage);

  io.Socket get socket => _socket;

  void connect() async {
    final token = await _storage.getAccessToken();
    if (token == null) return;

    // We use 127.0.0.1 for local dev with adb reverse
    _socket = io.io('http://127.0.0.1:3000', 
      io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .enableAutoConnect()
        .build()
    );

    _socket.onConnect((_) => print('🔌 Connected to Socket Server'));
    _socket.onDisconnect((_) => print('❌ Disconnected from Socket Server'));
    _socket.onConnectError((err) => print('⚠️ Connection Error: $err'));

    _socket.on('receive_message', (data) => _messageController.add(data));
    _socket.on('message_sent', (data) => _messageController.add(data));
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void disconnect() {
    _socket.disconnect();
  }
}

final socketProvider = Provider((ref) {
  final service = SocketService(ref.read(storageProvider));
  service.connect();
  return service;
});
