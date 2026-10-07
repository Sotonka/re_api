import 'package:dart_frog/dart_frog.dart';
import 'package:re_api/database.dart';
import 'package:re_api/repositories/table_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String rdate,
) async {
  if (!_isValidRdate(rdate)) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'rdate must be in YYYYMMDD format',
      },
    );
  }

  try {
    final repository = TableRepository(await connection);

    switch (context.request.method) {
      case HttpMethod.get:
        return _get(repository, rdate);

      case HttpMethod.put:
        return _put(context, repository, rdate);

      case HttpMethod.delete:
        return _delete(repository, rdate);

      default:
        return Response(
          statusCode: 405,
          headers: {
            'Allow': 'GET, PUT, DELETE',
          },
        );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'Internal server error',
      },
    );
  }
}

Future<Response> _get(
  TableRepository repository,
  String rdate,
) async {
  final data = await repository.getByRdate(rdate);

  if (data == null) {
    return Response.json(
      statusCode: 404,
      body: {
        'error': 'Table not found',
      },
    );
  }

  return Response.json(
    body: data,
  );
}

Future<Response> _put(
  RequestContext context,
  TableRepository repository,
  String rdate,
) async {
  final body = await context.request.json();

  if (body is! Map<String, dynamic>) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Request body must be a JSON object',
      },
    );
  }

  final error = _validateTable(body, rdate);

  if (error != null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': error,
      },
    );
  }

  final data = await repository.upsert(
    rdate: rdate,
    data: body,
  );

  return Response.json(
    body: data,
  );
}

Future<Response> _delete(
  TableRepository repository,
  String rdate,
) async {
  final deleted = await repository.delete(rdate);

  if (!deleted) {
    return Response.json(
      statusCode: 404,
      body: {
        'error': 'Table not found',
      },
    );
  }

  return Response.json(
    body: {
      'message': 'Table deleted',
      'rdate': rdate,
    },
  );
}

String? _validateTable(
  Map<String, dynamic> data,
  String rdate,
) {
  final requiredFields = <String>[
    'date',
    'ald',
    'alr',
    'rcf',
    'd1',
    'd2',
    'd3',
    'd4',
    'd5',
    'd6',
    'd7',
    'd8',
    'd9',
    'd10',
    'd11',
    'd12',
    'd13',
    'd14',
    'd15',
    'd16',
    't2d1',
    't2d2',
    't2d3',
    't2d4',
    't2d5',
    't2d6',
    't2d7',
    't2d8',
    't2d9',
    't2d10',
    't2d11',
    't2d12',
    't2d13',
    't3',
    't4d1',
    't4d2',
    't4d3',
    't4d4',
    't4d5',
    't4d6',
    't5',
    't6d1',
    't6d2',
    't6d3',
    't6d4',
    't6d5',
    't6d6',
    't6d7',
    't7d1',
    't7d2',
    't7d3',
    't7d4',
    't7d5',
    't7d6',
    't8',
  ];

  for (final field in requiredFields) {
    if (!data.containsKey(field)) {
      return 'Missing required field: $field';
    }
  }

  final date = data['date'];

  if (date is! String || !RegExp(r'^\d{8}$').hasMatch(date)) {
    return 'date must be in DDMMYYYY format';
  }

  final expectedDate = '${rdate.substring(6, 8)}'
      '${rdate.substring(4, 6)}'
      '${rdate.substring(0, 4)}';

  if (date != expectedDate) {
    return 'date does not match rdate';
  }

  return null;
}

bool _isValidRdate(String value) {
  return RegExp(r'^\d{8}$').hasMatch(value);
}
