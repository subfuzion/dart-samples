import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  // Port value of 0 will cause an available port to be chosen at random.
  const initPort = '0';
  late int assignedPort;
  late String baseUrl;
  late TestProcess proc;

  group('test server', () {
    setUp(() async {
      proc = await TestProcess.start(
        'dart',
        ['run', 'bin/server.dart'],
        environment: {'PORT': initPort},
      );

      var output = await proc.stdout.next;
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
        expect(time, predicate<DateTime>((t) => t.difference(now).inSeconds < 1,
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
