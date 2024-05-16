import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart'; // Para ChangeNotifier

class SocketService extends ChangeNotifier {
  late io.Socket socket;
  final String serverUrl;

  SocketService({required this.serverUrl}) {
    _initSocket();
  }

  void _initSocket() {
    socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket']) // Usa solo WebSocket
          .setReconnectionAttempts(5) // Intentos de reconexión
          .build(),
    );

    socket.connect();

    socket.on('connect', (_) {
      print('Conectado al servidor: ${socket.id}');
    });

    socket.on('disconnect', (_) {
      print('Desconectado del servidor');
    });
  }

  // Cerrar la conexión cuando el objeto es eliminado
  @override
  void dispose() {
    if (socket != null) {
      socket
          .disconnect(); // Desconecta el socket para evitar llamadas a eventos cuando el widget ya no está
      socket.dispose();
    }
    super.dispose();
  }
}
