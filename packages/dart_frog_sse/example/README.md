# Example

Use `sseHandler` to manage Server-Sent Events (SSE) connections in a Dart Frog route handler.

```dart
// routes/sse.dart
import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_sse/dart_frog_sse.dart';

Future<Response> onRequest(RequestContext context) async {

  final keepAlive = request.url.queryParameters['keepAlive'] ?? '30';
  final keepAliveDuration = Duration(seconds: int.parse(keepAlive));
  
  final handler = sseHandler(
    (connection) {
      // Send outgoing messages to the connected client.
      connection.sink.add('data from server...');
    },
    '/sse',
    keepAlive: keepAliveDuration,
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