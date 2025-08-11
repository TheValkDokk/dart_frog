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
///     // Subscribe to the stream of messages from the client.
///     connection.stream.listen(
///       (message) {
///         // Send outgoing messages to the connected client.
///         connection.sink.add('Server response: $message');
///       },
///       // The connection was terminated.
///       onDone: () => print('SSE connection closed'),
///     );
///   },
///   '/sse', // SSE endpoint path
/// );
/// ```
///
/// The [onConnection] callback is invoked whenever a new SSE connection
/// is established. It receives an [SseConnection] object that provides:
/// - `stream`: A stream of incoming messages from the client
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
  // Create a unique key for this handler configuration
  final handlerKey = '$path:${keepAlive?.inMilliseconds ?? 0}';
  
  // Get or create a persistent handler instance
  final sseHandler = _handlerInstances.putIfAbsent(
    handlerKey,
    () => SseHandler(Uri.parse(path), keepAlive: keepAlive),
  );

  // Start connection handling only once per handler
  if (!(_connectionHandlingStarted[handlerKey] ?? false)) {
    _connectionHandlingStarted[handlerKey] = true;
    _handleConnections(sseHandler, onConnection);
  }

  return fromShelfHandler(sseHandler.handler);
}

/// Handles new SSE connections
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

/// Clears all SSE handler instances. Useful for testing or cleanup.
void clearSseHandlers() {
  for (final handler in _handlerInstances.values) {
    handler.shutdown();
  }
  _handlerInstances.clear();
  _connectionHandlingStarted.clear();
}
