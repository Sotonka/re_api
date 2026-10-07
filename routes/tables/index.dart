import 'package:dart_frog/dart_frog.dart';
import 'package:re_api/database.dart';
import 'package:re_api/repositories/table_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(
      statusCode: 405,
      headers: {
        'Allow': 'GET',
      },
    );
  }

  try {
    final repository = TableRepository(await connection);

    final start = context.request.uri.queryParameters['start'];
    final end = context.request.uri.queryParameters['end'];

    if (start != null || end != null) {
      if (start == null || end == null) {
        return Response.json(
          statusCode: 400,
          body: {
            'error': 'start and end are required together',
          },
        );
      }

      if (!_isValidRdate(start) || !_isValidRdate(end)) {
        return Response.json(
          statusCode: 400,
          body: {
            'error': 'Dates must be in YYYYMMDD format',
          },
        );
      }

      if (start.compareTo(end) > 0) {
        return Response.json(
          statusCode: 400,
          body: {
            'error': 'start cannot be greater than end',
          },
        );
      }

      final data = await repository.getByRange(
        start: start,
        end: end,
      );

      return Response.json(
        body: data,
      );
    }

    final data = await repository.getAll();

    return Response.json(
      body: data,
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'Internal server error',
      },
    );
  }
}

bool _isValidRdate(String value) {
  return RegExp(r'^\d{8}$').hasMatch(value);
}
