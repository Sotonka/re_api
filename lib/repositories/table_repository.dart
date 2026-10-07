import 'package:postgres/postgres.dart';

class TableRepository {
  final Connection connection;

  TableRepository(this.connection);

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await connection.execute(
      Sql.named('''
        SELECT *
        FROM "tables"
        ORDER BY rdate ASC
      '''),
    );

    return result
        .map(
          (row) => _jsonSafeRow(row.toColumnMap()),
        )
        .toList();
  }

  Future<Map<String, dynamic>?> getByRdate(
    String rdate,
  ) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT *
        FROM "tables"
        WHERE rdate = @rdate
      '''),
      parameters: {
        'rdate': rdate,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return _jsonSafeRow(
      result.first.toColumnMap(),
    );
  }

  Future<List<Map<String, dynamic>>> getByRange({
    required String start,
    required String end,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT *
        FROM "tables"
        WHERE rdate >= @start
          AND rdate <= @end
        ORDER BY rdate ASC
      '''),
      parameters: {
        'start': start,
        'end': end,
      },
    );

    return result
        .map(
          (row) => _jsonSafeRow(row.toColumnMap()),
        )
        .toList();
  }

  Future<Map<String, dynamic>> upsert({
    required String rdate,
    required Map<String, dynamic> data,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        INSERT INTO "tables" (
          rdate,
          date,
          ald,
          alr,
          rcf,
          d1,
          d2,
          d3,
          d4,
          d5,
          d6,
          d7,
          d8,
          d9,
          d10,
          d11,
          d12,
          d13,
          d14,
          d15,
          d16,
          t2d1,
          t2d2,
          t2d3,
          t2d4,
          t2d5,
          t2d6,
          t2d7,
          t2d8,
          t2d9,
          t2d10,
          t2d11,
          t2d12,
          t2d13,
          t3,
          t4d1,
          t4d2,
          t4d3,
          t4d4,
          t4d5,
          t4d6,
          t5,
          t6d1,
          t6d2,
          t6d3,
          t6d4,
          t6d5,
          t6d6,
          t6d7,
          t7d1,
          t7d2,
          t7d3,
          t7d4,
          t7d5,
          t7d6,
          t8
        )
        VALUES (
          @rdate,
          @date,
          @ald,
          @alr,
          @rcf,
          @d1,
          @d2,
          @d3,
          @d4,
          @d5,
          @d6,
          @d7,
          @d8,
          @d9,
          @d10,
          @d11,
          @d12,
          @d13,
          @d14,
          @d15,
          @d16,
          @t2d1,
          @t2d2,
          @t2d3,
          @t2d4,
          @t2d5,
          @t2d6,
          @t2d7,
          @t2d8,
          @t2d9,
          @t2d10,
          @t2d11,
          @t2d12,
          @t2d13,
          @t3,
          @t4d1,
          @t4d2,
          @t4d3,
          @t4d4,
          @t4d5,
          @t4d6,
          @t5,
          @t6d1,
          @t6d2,
          @t6d3,
          @t6d4,
          @t6d5,
          @t6d6,
          @t6d7,
          @t7d1,
          @t7d2,
          @t7d3,
          @t7d4,
          @t7d5,
          @t7d6,
          @t8
        )
        ON CONFLICT (rdate)
        DO UPDATE SET
          date = EXCLUDED.date,
          ald = EXCLUDED.ald,
          alr = EXCLUDED.alr,
          rcf = EXCLUDED.rcf,
          d1 = EXCLUDED.d1,
          d2 = EXCLUDED.d2,
          d3 = EXCLUDED.d3,
          d4 = EXCLUDED.d4,
          d5 = EXCLUDED.d5,
          d6 = EXCLUDED.d6,
          d7 = EXCLUDED.d7,
          d8 = EXCLUDED.d8,
          d9 = EXCLUDED.d9,
          d10 = EXCLUDED.d10,
          d11 = EXCLUDED.d11,
          d12 = EXCLUDED.d12,
          d13 = EXCLUDED.d13,
          d14 = EXCLUDED.d14,
          d15 = EXCLUDED.d15,
          d16 = EXCLUDED.d16,
          t2d1 = EXCLUDED.t2d1,
          t2d2 = EXCLUDED.t2d2,
          t2d3 = EXCLUDED.t2d3,
          t2d4 = EXCLUDED.t2d4,
          t2d5 = EXCLUDED.t2d5,
          t2d6 = EXCLUDED.t2d6,
          t2d7 = EXCLUDED.t2d7,
          t2d8 = EXCLUDED.t2d8,
          t2d9 = EXCLUDED.t2d9,
          t2d10 = EXCLUDED.t2d10,
          t2d11 = EXCLUDED.t2d11,
          t2d12 = EXCLUDED.t2d12,
          t2d13 = EXCLUDED.t2d13,
          t3 = EXCLUDED.t3,
          t4d1 = EXCLUDED.t4d1,
          t4d2 = EXCLUDED.t4d2,
          t4d3 = EXCLUDED.t4d3,
          t4d4 = EXCLUDED.t4d4,
          t4d5 = EXCLUDED.t4d5,
          t4d6 = EXCLUDED.t4d6,
          t5 = EXCLUDED.t5,
          t6d1 = EXCLUDED.t6d1,
          t6d2 = EXCLUDED.t6d2,
          t6d3 = EXCLUDED.t6d3,
          t6d4 = EXCLUDED.t6d4,
          t6d5 = EXCLUDED.t6d5,
          t6d6 = EXCLUDED.t6d6,
          t6d7 = EXCLUDED.t6d7,
          t7d1 = EXCLUDED.t7d1,
          t7d2 = EXCLUDED.t7d2,
          t7d3 = EXCLUDED.t7d3,
          t7d4 = EXCLUDED.t7d4,
          t7d5 = EXCLUDED.t7d5,
          t7d6 = EXCLUDED.t7d6,
          t8 = EXCLUDED.t8,
          updated_at = NOW()
        RETURNING *
      '''),
      parameters: {
        'rdate': rdate,
        'date': data['date'],
        'ald': data['ald'],
        'alr': data['alr'],
        'rcf': data['rcf'],
        'd1': data['d1'],
        'd2': data['d2'],
        'd3': data['d3'],
        'd4': data['d4'],
        'd5': data['d5'],
        'd6': data['d6'],
        'd7': data['d7'],
        'd8': data['d8'],
        'd9': data['d9'],
        'd10': data['d10'],
        'd11': data['d11'],
        'd12': data['d12'],
        'd13': data['d13'],
        'd14': data['d14'],
        'd15': data['d15'],
        'd16': data['d16'],
        't2d1': data['t2d1'],
        't2d2': data['t2d2'],
        't2d3': data['t2d3'],
        't2d4': data['t2d4'],
        't2d5': data['t2d5'],
        't2d6': data['t2d6'],
        't2d7': data['t2d7'],
        't2d8': data['t2d8'],
        't2d9': data['t2d9'],
        't2d10': data['t2d10'],
        't2d11': data['t2d11'],
        't2d12': data['t2d12'],
        't2d13': data['t2d13'],
        't3': data['t3'],
        't4d1': data['t4d1'],
        't4d2': data['t4d2'],
        't4d3': data['t4d3'],
        't4d4': data['t4d4'],
        't4d5': data['t4d5'],
        't4d6': data['t4d6'],
        't5': data['t5'],
        't6d1': data['t6d1'],
        't6d2': data['t6d2'],
        't6d3': data['t6d3'],
        't6d4': data['t6d4'],
        't6d5': data['t6d5'],
        't6d6': data['t6d6'],
        't6d7': data['t6d7'],
        't7d1': data['t7d1'],
        't7d2': data['t7d2'],
        't7d3': data['t7d3'],
        't7d4': data['t7d4'],
        't7d5': data['t7d5'],
        't7d6': data['t7d6'],
        't8': data['t8'],
      },
    );

    return _jsonSafeRow(
      result.first.toColumnMap(),
    );
  }

  Future<bool> delete(
    String rdate,
  ) async {
    final result = await connection.execute(
      Sql.named('''
        DELETE FROM "tables"
        WHERE rdate = @rdate
      '''),
      parameters: {
        'rdate': rdate,
      },
    );

    return result.affectedRows > 0;
  }

  Map<String, dynamic> _jsonSafeRow(
    Map<String, dynamic> row,
  ) {
    return row.map(
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
}
