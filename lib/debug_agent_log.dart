import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Debug session logger — posts NDJSON to local ingest server.
void agentDebugLog({
  required String location,
  required String message,
  required String hypothesisId,
  Map<String, dynamic>? data,
  String runId = 'pre-fix',
}) {
  // #region agent log
  final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  final uri = Uri.parse(
    'http://$host:7758/ingest/f3087892-d027-469d-9f7f-e47b47f5bab8',
  );
  http
      .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Debug-Session-Id': '89e905',
        },
        body: jsonEncode({
          'sessionId': '89e905',
          'runId': runId,
          'hypothesisId': hypothesisId,
          'location': location,
          'message': message,
          'data': data ?? {},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      )
      .ignore();
  // #endregion
}
