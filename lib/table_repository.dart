import 'package:postgres/postgres.dart';

class TableRepository {
  final Connection connection;

  TableRepository(this.connection);

  /// GET /tables
  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await connection.execute(
      Sql.named('''
        SELECT *
        FROM "tables"
        ORDER BY date DESC
      '''),
    );

    return result.map(_rowToMap).toList();
  }

  /// GET /tables/:date
  Future<Map<String, dynamic>?> getById(String date) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT *
        FROM "tables"
        WHERE date = @date
      '''),
      parameters: {
        'date': date,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return _rowToMap(result.first);
  }

  /// POST /tables
  Future<Map<String, dynamic>> create(
    Map<String, dynamic> data,
  ) async {
    final columns = <String>[];
    final values = <String>[];
    final parameters = <String, dynamic>{};

    for (final column in _columns) {
      if (data.containsKey(column)) {
        columns.add('"$column"');
        values.add('@$column');
        parameters[column] = data[column];
      }
    }

    if (columns.isEmpty) {
      throw ArgumentError('No fields to insert');
    }

    final result = await connection.execute(
      Sql.named('''
        INSERT INTO "tables" (
          ${columns.join(', ')}
        )
        VALUES (
          ${values.join(', ')}
        )
        RETURNING *
      '''),
      parameters: parameters,
    );

    return _rowToMap(result.first);
  }

  /// PUT /tables/:date
  Future<Map<String, dynamic>?> update(
    String date,
    Map<String, dynamic> data,
  ) async {
    final sets = <String>[];
    final parameters = <String, dynamic>{
      'date': date,
    };

    for (final column in _columns) {
      // PRIMARY KEY нельзя менять через этот endpoint.
      if (column == 'date') {
        continue;
      }

      if (data.containsKey(column)) {
        sets.add('"$column" = @$column');
        parameters[column] = data[column];
      }
    }

    if (sets.isEmpty) {
      throw ArgumentError('No fields to update');
    }

    sets.add('updated_at = NOW()');

    final result = await connection.execute(
      Sql.named('''
        UPDATE "tables"
        SET ${sets.join(', ')}
        WHERE date = @date
        RETURNING *
      '''),
      parameters: parameters,
    );

    if (result.isEmpty) {
      return null;
    }

    return _rowToMap(result.first);
  }

  /// DELETE /tables/:date
  Future<bool> delete(String date) async {
    final result = await connection.execute(
      Sql.named('''
        DELETE FROM "tables"
        WHERE date = @date
      '''),
      parameters: {
        'date': date,
      },
    );

    return result.affectedRows > 0;
  }

  /// GET /tables/filter?start=ddmmyyyy&end=ddmmyyyy
  Future<List<Map<String, dynamic>>> filter(
    String start,
    String end,
  ) async {
    final startDate = _dateFormat(start);
    final endDate = _dateFormat(end);

    final result = await connection.execute(
      Sql.named('''
      SELECT *
      FROM "tables"
      WHERE (
        SUBSTRING(date, 5, 4) ||
        SUBSTRING(date, 3, 2) ||
        SUBSTRING(date, 1, 2)
      )::INTEGER BETWEEN @startDate AND @endDate
      ORDER BY (
        SUBSTRING(date, 5, 4) ||
        SUBSTRING(date, 3, 2) ||
        SUBSTRING(date, 1, 2)
      )::INTEGER DESC
    '''),
      parameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    return result.map(_rowToMap).toList();
  }

  /// ddmmyyyy -> yyyymmdd
  int _dateFormat(String value) {
    if (value.length != 8 || int.tryParse(value) == null) {
      throw ArgumentError(
        'Invalid date format: "$value". Expected ddmmyyyy',
      );
    }

    final day = value.substring(0, 2);
    final month = value.substring(2, 4);
    final year = value.substring(4, 8);

    return int.parse('$year$month$day');
  }

  /// PostgreSQL row -> JSON-friendly Map
  Map<String, dynamic> _rowToMap(ResultRow row) {
    final map = row.toColumnMap();

    return map.map(
      (key, value) {
        if (value is DateTime) {
          return MapEntry(
            key,
            value.toIso8601String(),
          );
        }

        return MapEntry(
          key,
          value,
        );
      },
    );
  }

  /// Разрешённые поля таблицы.
  ///
  /// id здесь НЕТ, потому что PRIMARY KEY теперь date.
  static const Set<String> _columns = {
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
    'd100',
    'd101',
    'd102',
    'd103',
    'd104',
    'd105',
    'd106',
    'd107',
    'd108',
    'd109',
    'd110',
    'td1',
    'td2',
    'td3',
    'td4',
    'td5',
    't2d6',
    't2d7',
    't2d8',
    't2d9',
    't2d10',
    't2d11',
    't2d12',
    't2d100',
    't2d101',
    't2d102',
    't2d103',
    't2d104',
    't2d105',
    't2d106',
    't2d107',
    't2cls',
    't3d1',
    't3d2',
    't3d3',
    't3d4',
    't3d5',
    't3d6',
    't3d100',
    't3d101',
    't3d102',
    't3d103',
    't4zap',
    't5d1',
    't5d2',
    't5d3',
    't5d4',
    't5d5',
    't5d6',
    't5d7',
    't5d100',
    't5d101',
    't5d102',
    't5d103',
    't5d104',
    't6d1',
    't6d2',
    't6d3',
    't6d4',
    't6d5',
    't6d6',
    't6d100',
    't6d101',
    't6d102',
    't6d103',
    't6d104',
    't7',
    't100',
    't101',
    't102',
  };
}
