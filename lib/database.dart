import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

final env = DotEnv()..load();

final Future<Connection> connection = Connection.open(
  Endpoint(
    host: env['DB_HOST']!,
    port: int.parse(env['DB_PORT']!),
    database: env['DB_NAME']!,
    username: env['DB_USER']!,
    password: env['DB_PASSWORD']!,
  ),
  settings: const ConnectionSettings(
    sslMode: SslMode.disable,
  ),
);
