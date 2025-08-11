[<img src="https://raw.githubusercontent.com/dart-frog-dev/dart_frog/main/assets/dart_frog.png" align="left" height="63.5px" />](https://dart-frog.dev)

### Dart Frog SSE

<br clear="left"/>

[![discord][discord_badge]][discord_link]
[![dart][dart_badge]][dart_link]

[![ci][ci_badge]][ci_link]
[![coverage][coverage_badge]][ci_link]
[![pub package][pub_badge]][pub_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Server-Sent Events (SSE) support for [Dart Frog][dart_frog_link].

## Quick Start 🚀

Use `sseHandler` to manage Server-Sent Events (SSE) connections in a Dart Frog route handler.

```dart
// routes/sse.dart
import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_sse/dart_frog_sse.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = sseHandler(
    (connection) {
      // Send data to client
      connection.sink.add('data from server...');
    },
    '/sse',
    keepAlive: const Duration(seconds: 30),
  );
  
  return handler(context);
}
```

Connect a client to the remote SSE endpoint.

```dart
// main.dart
import 'package:sse/client/sse_client.dart';

void main() async {
  // Connect to the remote SSE endpoint.
  final client = SseClient('http://localhost:8080/sse');
  
  // Wait for connection to be established.
  await client.onConnected;

  // Listen to incoming messages from the server.
  client.stream.listen(print);

  // Send messages to the server.
  client.sink.add('ping');
}
```

[ci_badge]: https://github.com/dart-frog-dev/dart_frog/actions/workflows/dart_frog_sse.yaml/badge.svg?branch=main
[ci_link]: https://github.com/dart-frog-dev/dart_frog/actions/workflows/dart_frog_sse.yaml
[coverage_badge]: https://raw.githubusercontent.com/dart-frog-dev/dart_frog/main/packages/dart_frog_sse/coverage_badge.svg
[credits_link]: https://github.com/dart-frog-dev/dart_frog/blob/main/CREDITS.md#acknowledgments
[dart_badge]: https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=5BB4F0&color=1E2833
[dart_link]: https://dart.dev
[dart_frog_link]: https://github.com/dart-frog-dev/dart_frog
[discord_badge]: https://img.shields.io/discord/1394707782271238184?style=for-the-badge&logo=discord&color=1C2A2E&logoColor=1DF9D2
[discord_link]: https://discord.gg/dart-frog
[docs_link]: https://dart-frog.dev/advanced/server-sent-events
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/dart-frog-dev/dart_frog/main/assets/dart_frog_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/dart-frog-dev/dart_frog/main/assets/dart_frog_logo_white.png#gh-dark-mode-only
[pub_badge]: https://img.shields.io/pub/v/dart_frog_sse.svg
[pub_link]: https://pub.dartlang.org/packages/dart_frog_sse
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures