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

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<msg>', _echoHandler)
  ..get('/time', _timeHandler);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!');
}

Response _echoHandler(Request req, String msg) {
  return Response.ok(msg);
}

Response _timeHandler(Request req) {
  var time = DateTime.now().toUtc().toIso8601String();

  String? format = req.url.queryParameters['format'];

  switch (format) {
    case null:
      return Response.ok(DateTime.now().toUtc().toIso8601String());
    case 'json':
      return Response.ok(
        JsonEncoder.withIndent(' ').convert({'time': time}),
        headers: {'content-type': 'application/json'},
      );
    default:
      return Response.notFound(
          'Error: unsupported format requested: ${format} (only supported format is "json").');
  }
}
