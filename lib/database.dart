import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

final env = DotEnv()..load();

final connection = Connection.open(
  Endpoint(
    host: env['DB_HOST'] ?? '127.0.0.1',
    port: int.parse(env['DB_PORT'] ?? '5432'),
    database: env['DB_NAME'] ?? 'pipi',
    username: env['DB_USER'] ?? 'pipi',
    password: env['DB_PASSWORD'] ?? '',
  ),
  settings: const ConnectionSettings(
    sslMode: SslMode.disable,
  ),
);
