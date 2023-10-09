import 'package:postgres/postgres.dart';

PostgreSQLConnection createDatabaseConnection() {
  final host = '37.140.241.144';
  final port = 5432;
  final databaseName = 'postgres';
  final username = 'postgres';
  final password = '1';

  final postgresConnection = PostgreSQLConnection(
    host,
    port,
    databaseName,
    username: username,
    password: password,
  );

  return postgresConnection;
}
// не используеться 
