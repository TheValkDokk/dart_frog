# Example

Use `sseHandler` to manage Server-Sent Events (SSE) connections in a Dart Frog route handler.

```dart
// routes/sse.dart
import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_sse/dart_frog_sse.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = sseHandler(
    (connection) {
      // Subscribe to the stream of messages from the client.
      connection.stream.listen(
        (message) {
          // Handle incoming messages.
          print('received: $message');
          // Send outgoing messages to the connected client.
          connection.sink.add('data from server...');
        },
        // The connection was terminated.
        onDone: () => print('disconnected and closed'),
      );
      
      // Send periodic updates
      Timer.periodic(const Duration(seconds: 5), (timer) {
        try {
          connection.sink.add('Update: ${DateTime.now()}');
        } on Exception {
          timer.cancel(); // Connection closed
        }
      });
    },
    '/sse',
    keepAlive: const Duration(seconds: 30),
  );
  
  return handler(context);
}
```

Connect a client to the remote SSE endpoint using the Dart SSE client:

```dart
// main.dart
import 'package:sse/client/sse_client.dart';

void main() async {
  // Connect to the remote SSE endpoint.
  final client = SseClient('http://localhost:8080/sse');
  await client.onConnected;

  // Listen to incoming messages from the server.
  client.stream.listen(print);
}
```