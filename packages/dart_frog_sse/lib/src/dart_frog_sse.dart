import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:sse/server/sse_handler.dart';

// Global handler instances to maintain connection state across requests
final Map<String, SseHandler> _handlerInstances = {};
final Map<String, bool> _connectionHandlingStarted = {};

/// Creates a Dart Frog [Handler] that handles Server-Sent Events (SSE)
/// connections.
///
/// ```dart
/// import 'package:dart_frog_sse/dart_frog_sse.dart';
///
/// final onRequest = sseHandler(
///   (connection) {
///      // Send outgoing messages to the connected client.
///      connection.sink.add('Server response: $message');
///   },
///   '/sse', // SSE endpoint path
/// );
/// ```
///
/// The [onConnection] callback is invoked whenever a new SSE connection
/// is established. It receives an [SseConnection] object that provides:
/// - `sink`: A sink for sending messages to the client
///
/// The [path] parameter specifies the URI path for SSE connections.
/// This should match the path that clients connect to.
///
/// If [keepAlive] is specified, it defines the period for sending keep-alive
/// messages to maintain the connection.
///
/// This method uses [`package:sse`](https://pub.dev/packages/sse) internally
/// to provide bi-directional communication over Server-Sent Events.
Handler sseHandler(
  void Function(SseConnection connection) onConnection,
  String path, {
  Duration? keepAlive,
}) {
  final handlerKey = '$path:${keepAlive?.inMilliseconds ?? 0}';

  final sseHandler = _handlerInstances.putIfAbsent(
    handlerKey,
    () => SseHandler(Uri.parse(path), keepAlive: keepAlive),
  );

  if (!(_connectionHandlingStarted[handlerKey] ?? false)) {
    _connectionHandlingStarted[handlerKey] = true;
    _handleConnections(sseHandler, onConnection);
  }

  return fromShelfHandler(sseHandler.handler);
}

void _handleConnections(
  SseHandler sseHandler,
  void Function(SseConnection connection) onConnection,
) {
  Future<void> processConnections() async {
    final connections = sseHandler.connections;
    try {
      final connection = await connections.next;
      onConnection(connection);
    } on Exception {
      // Handle connection errors
      Timer(const Duration(milliseconds: 100), processConnections);
      return;
    }

    Timer.run(processConnections);
  }

  Timer.run(processConnections);
}
