// ignore_for_file: no_default_cases, avoid_catching_errors

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:re_api/database.dart';
import 'package:re_api/table_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final repository = TableRepository(await connection);

  try {
    switch (context.request.method) {
      case HttpMethod.get:
        return await _get(repository, id);

      case HttpMethod.put:
        return await _put(context, repository, id);

      case HttpMethod.delete:
        return await _delete(repository, id);

      default:
        return _jsonResponse(
          405,
          {
            'error': 'Method not allowed',
          },
        );
    }
  } catch (e, stackTrace) {
    //print(e);
    //print(stackTrace);

    return _jsonResponse(
      500,
      {
        'error': 'Internal server error',
        'message': e.toString(),
      },
    );
  }
}

Future<Response> _get(
  TableRepository repository,
  String date,
) async {
  final row = await repository.getById(date);

  if (row == null) {
    return _jsonResponse(
      404,
      {
        'error': 'Record not found',
      },
    );
  }

  return _jsonResponse(
    200,
    row,
  );
}

Future<Response> _put(
  RequestContext context,
  TableRepository repository,
  String date,
) async {
  final body = await context.request.body();

  if (body.isEmpty) {
    return _jsonResponse(
      400,
      {
        'error': 'Request body is empty',
      },
    );
  }

  dynamic decoded;

  try {
    decoded = jsonDecode(body);
  } catch (_) {
    return _jsonResponse(
      400,
      {
        'error': 'Invalid JSON',
      },
    );
  }

  if (decoded is! Map<String, dynamic>) {
    return _jsonResponse(
      400,
      {
        'error': 'JSON body must be an object',
      },
    );
  }

  try {
    final row = await repository.update(
      date,
      decoded,
    );

    if (row == null) {
      return _jsonResponse(
        404,
        {
          'error': 'Record not found',
        },
      );
    }

    return _jsonResponse(
      200,
      row,
    );
  } on ArgumentError catch (e) {
    return _jsonResponse(
      400,
      {
        'error': e.message,
      },
    );
  }
}

Future<Response> _delete(
  TableRepository repository,
  String date,
) async {
  final deleted = await repository.delete(date);

  if (!deleted) {
    return _jsonResponse(
      404,
      {
        'error': 'Record not found',
      },
    );
  }

  return _jsonResponse(
    200,
    {
      'success': true,
      'date': date,
    },
  );
}

Response _jsonResponse(
  int statusCode,
  dynamic data,
) {
  return Response(
    statusCode: statusCode,
    headers: {
      'content-type': 'application/json',
    },
    body: jsonEncode(data),
  );
}
