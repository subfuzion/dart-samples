import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

// Test a running instance of the server.
void main() {
  late int assignedPort;
  late String baseUrl;
  late TestProcess proc;

  group('test server', () {
    setUp(() async {
      // Start server on a random port (by using '0' for port value).
      proc = await TestProcess.start(
        'dart',
        ['run', 'bin/server.dart'],
        environment: {'PORT': '0'},
      );
      var output = await proc.stdout.next;

      // Determine URL using actual port that was assigned for subsequent tests.
      var parts = output.split('Server listening on port ');
      assignedPort = int.parse(parts[1].trim());
      baseUrl = 'http://localhost:$assignedPort';

      print('- test server started on port $assignedPort');
    });

    tearDown(() async {
      print('- test server stopped');
    });

    group('route', () {
      final defTimeout = Timeout(Duration(seconds: 5));

      test('/', () async {
        final response = await get(Uri.parse('$baseUrl/'));
        expect(response.statusCode, 200);
        expect(response.body, 'Hello, World!');
        await proc.kill();
      }, timeout: defTimeout);

      test('/echo', () async {
        final response = await get(Uri.parse('$baseUrl/echo/hello'));
        expect(response.statusCode, 200);
        expect(response.body, 'hello');
        await proc.kill();
      }, timeout: defTimeout);

      test('/time', () async {
        final response = await get(Uri.parse('$baseUrl/time'));
        expect(response.statusCode, 200);

        var time = DateTime.parse(response.body);
        var now = DateTime.now();
        expect(
            time,
            predicate<DateTime>((t) => t.difference(now).inSeconds < 1,
                'Server time ($time) should be within a second of current time ($now)'));
        await proc.kill();
      }, timeout: defTimeout);

      test('/time?format=json', () async {
        final response = await get(Uri.parse('$baseUrl/time?format=json'));
        expect(response.statusCode, 200);

        var body = JsonDecoder().convert(response.body);
        var time = DateTime.parse(body['time']);
        var now = DateTime.now();
        expect(
            time,
            predicate<DateTime>((t) => t.difference(now).inSeconds < 1,
                'Server time ($time) should be within a second of current time ($now)'));
        await proc.kill();
      }, timeout: defTimeout);

      test('404', () async {
        final response = await get(Uri.parse('$baseUrl/foo'));
        expect(response.statusCode, 404);
        await proc.kill();
      });
    });
  });
}
