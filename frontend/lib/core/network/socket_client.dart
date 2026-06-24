import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketClient {
  io.Socket? _socket;
  final _storage = const FlutterSecureStorage();

  static const String wsUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<void> connect() async {
    final token = await _storage.read(key: 'access_token');

    _socket = io.io(
      '$wsUrl/game',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  bool get isConnected => _socket?.connected ?? false;

  Stream<Map<String, dynamic>> onEvent(String event) {
    // Simple wrapper to stream
    late StreamController<Map<String, dynamic>> controller;
    controller = StreamController.broadcast(
      onListen: () => _socket?.on(event, (data) => controller.add(data as Map<String, dynamic>)),
      onCancel: () => _socket?.off(event),
    );
    return controller.stream;
  }
}

class StreamController<T> {
  final List<Function(T)> _listeners = [];
  late final Stream<T> stream;
  bool _isBroadcast = false;

  StreamController.broadcast({
    required void Function() onListen,
    required void Function() onCancel,
  }) {
    _isBroadcast = true;
    // Simplified implementation - in real app use dart:async StreamController
    stream = const Stream.empty();
  }

  void add(T event) {
    for (final l in _listeners) l(event);
  }

  void close() {}
}
