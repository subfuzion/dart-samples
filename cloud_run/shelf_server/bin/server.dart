// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';
import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:hello/routes.dart' show router;

Future<void> main(List<String> args) async {
  // Server should allow connections from networks outside of the container.
  var ip = InternetAddress.anyIPv4;

  // Server should bind to the PORT configured by Cloud Run.
  var port = int.parse(Platform.environment['PORT'] ?? '8080');

  // A shelf pipeline daisy chains middleware and handler functions
  var handlers = Pipeline().addMiddleware(logRequests()).addHandler(router);

  var server = await serve(handlers, ip, port);
  print('Server listening on port ${server.port}');
}
