import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  // Port value of 0 will cause an available port to be chosen at random.
  final initPort = '0';
  late int port;
  late String uri;
  late TestProcess _proc;

  group('tests', () {
    setUp(() async {
      _proc = await TestProcess.start(
        'dart',
        ['run', 'bin/server.dart'],
        environment: {'PORT': initPort},
      );

      // Matches strings that start with 'Serving' or 'Server' and ends anything
      // that crudely resembles a port number.
      final _servingPattern = RegExp(r'^Serv[^\d]+(\d{1,5})$');

      final output = await _proc.stdout.next;
      final match = _servingPattern.firstMatch(output);
      // explicit test instead of null operator for exception clarity
      if (match == null) {
        throw Exception('Unexpected server output after start: "${output}"');
      }
      port = int.parse(match[1]!);
      uri = 'http://localhost:${port}';
      print('test server started on port ${port}');
    });

    tearDown(() async {
//      await _proc.kill();
      print('test server stopped');
    });

    group('server tests', () {
      final defTimeout = Timeout(Duration(seconds: 5));

      test('url root (/)', () async {
        final response = await get(Uri.parse('${uri}/'));
        expect(response.statusCode, 200);
        expect(response.body, 'Hello, World!');
        await _proc.kill();
      }, timeout: defTimeout);

      // test('Echo', () async {
      //   final response = await get(Uri.parse('${uri}/echo/hello'));
      //   expect(response.statusCode, 200);
      //   expect(response.body, 'hello');
      // });
      test('404', () async {
        final response = await get(Uri.parse('${uri}/foobar'));
        expect(response.statusCode, 404);
        await _proc.kill();
      });
    });
  });
}
